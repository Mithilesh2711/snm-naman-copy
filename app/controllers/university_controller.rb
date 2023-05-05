class UniversityController < ApplicationController
  before_action :require_login
   before_action :allowed_security
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  def index
     @compCodes       = session[:loggedUserCompCode]
     @ListUnversity   = get_unversity_list
     printcontroll    = "1_prt_excel_university_list"
     @printpath       = university_path(printcontroll,:format=>"pdf")
     printpdf         = "1_prt_pdf_university_list"
     @printpdfpath    = university_path(printpdf,:format=>"pdf")

     if params[:id] != nil && params[:id] != ''
           ids = params[:id].to_s.split("_")
           if ids[1] == 'prt' && ids[2] == 'excel'
               @ExcelList = print_excel_listed
               send_data @ExcelList.to_generate_unversity, :filename=> "university_list_#{Date.today}.csv"
               return
           elsif ids[1] == 'prt' && ids[2] == 'pdf'
               @rootUrl  = "#{root_url}"
               dataprint = print_excel_listed
               respond_to do |format|
                    format.html
                    format.pdf do
                       pdf = UniversityPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                       send_data pdf.render,:filename => "1_prt_university_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                end
           end
     end

  end

  def add_university
    @compCodes  =  session[:loggedUserCompCode]    
    @ListDepart = nil
    if params[:id].to_i >0
        @ListDepart  = MstUniversity.where("un_compcode = ? AND id = ?",@compCodes,params[:id]).first
    end

  end

  def create
  @compCodes  =  session[:loggedUserCompCode]
  isFlags     = true
  begin
  if params[:un_description] == '' || params[:un_description] == nil
     flash[:error] =  "Description is required."
     isFlags = false

  else

    curdcode          = params[:cur_description].to_s.strip
    un_description    = params[:un_description].to_s.strip
    mid               = params[:mid]
    if mid.to_i >0

          if curdcode.to_s.downcase != un_description.to_s.downcase
              chkunb   = MstUniversity.where("un_compcode = ? AND LOWER(un_description) = ?",@compCodes,un_description.to_s.downcase)
              if chkunb.length >0
                    flash[:error] = "This description is already taken!"
                    isFlags       = false
              end

          end
            if isFlags
                chkdeprtobj   = MstUniversity.where("un_compcode = ? AND id = ?",@compCodes,mid).first
                if chkdeprtobj
                  chkdeprtobj.update(university_params)
                      flash[:error] = "Data updated successfully"
                      isFlags       = true
                end
            end

    else
              chkunb   = MstUniversity.where("un_compcode = ? AND LOWER(un_description) = ?",@compCodes,un_description.to_s.downcase)
              if chkunb.length >0
                    flash[:error] = "This description is already taken!"
                    isFlags       = false
              end
             if isFlags
                   deprtsvobj = MstUniversity.new(university_params)
                   if deprtsvobj.save
                      flash[:error] = "Data saved successfully"
                      isFlags       = true
                   end
             end
    end

  end

  if !isFlags
    session[:isErrorhandled] = 1

  else
    session[:isErrorhandled] = nil
    session[:postedpamams]   = nil
    isFlags = true
  end
   rescue Exception => exc
       flash[:error] =  "ERROR: #{exc.message}"
       session[:isErrorhandled] = 1

       isFlags = false
   end
    if isFlags
      redirect_to  "#{root_url}university"
    else
      redirect_to  "#{root_url}university/add_university"
    end

end

 def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         @ListSate =  MstUniversity.where("un_compcode =? AND id = ?",@compcodes,params[:id]).first
         if @ListSate
               chekunobj = check_existing_unversity(@compcodes,params[:id])
               if chekunobj
                     flash[:error] =  "Sorry!! Data could not be deleted due to somewhere used."
                     isFlags       =  true
                     session[:isErrorhandled] = 1
               else
                     @ListSate.destroy
                     flash[:error] =  "Data deleted successfully."
                     isFlags       =  true
                     session[:isErrorhandled] = nil

               end
                 
         end
    end
    redirect_to "#{root_url}university"
 end


private
def university_params
    params[:un_compcode]      = session[:loggedUserCompCode]
    params[:un_description]   = params[:un_description]!=nil && params[:un_description] !='' ? params[:un_description].to_s.strip : ''    
    qltype = ""
    if params[:un_qltype] !=nil && params[:un_qltype] !=''
        params[:un_qltype].each do |newqtype|
            qltype += newqtype.to_s+","
        end
        if qltype !=nil && qltype !=''
            qltype = qltype.to_s.chop
        end
    end
    params[:un_qltype] = qltype
    params.permit(:un_compcode,:un_description,:un_qltype)
end

private
  def get_unversity_list
       if params[:page].to_i >0
         pages = params[:page]
      else
         pages = 1
      end
     if params[:requestserver] !=nil && params[:requestserver] != ''
        session[:req_un_description] = nil
     end
      search_departcode = params[:search_departcode] !=nil && params[:search_departcode] != '' ? params[:search_departcode].to_s.strip : session[:req_un_description]
      iswhere = "un_compcode ='#{@compCodes}'"
      if search_departcode !=nil && search_departcode !=''
        iswhere += " AND (  un_description LIKE '%#{search_departcode}%' OR un_qltype LIKE '%#{search_departcode}%' ) "
        @search_departcode = search_departcode
        session[:req_un_description] = search_departcode
      end
      stsobj =  MstUniversity.where(iswhere).paginate(:page =>pages,:per_page => 10).order("un_description ASC")
      return stsobj
  end

  private
  def print_excel_listed
        search_departcode =  session[:req_search_design]
        iswhere = "un_compcode ='#{@compCodes}'"
        if search_departcode !=nil && search_departcode !=''
          iswhere += " AND (  un_description LIKE '%#{search_departcode}%' OR un_qltype LIKE '%#{search_departcode}%' ) "
        end
        stsobj =  MstUniversity.where(iswhere).order("un_description ASC")
        return stsobj
  end

   private
  def check_existing_unversity(compcodes,dptcodes)
     istruefalse = false
      sewobj     = MstSewadarKycQualification.select("skq_compcode").where("skq_compcode = ? AND skq_universityboard =?",compcodes,dptcodes)
       if sewobj.length >0
         istruefalse = true
       end
       return istruefalse
  end

end
