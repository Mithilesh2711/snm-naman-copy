class SubLocationController < ApplicationController
  before_action :require_login
   before_action :allowed_security
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
   helper_method :get_ho_location
  def index
     @compCodes       = session[:loggedUserCompCode]
     @ListHeadOffice  = get_hof_list
     printcontroll    = "1_prt_excel_sublocation_list"
     @printpath       = sub_location_path(printcontroll,:format=>"pdf")
     printpdf         = "1_prt_pdf_sublocation_list"
     @printpdfpath    = sub_location_path(printpdf,:format=>"pdf")

     if params[:id] != nil && params[:id] != ''
           ids = params[:id].to_s.split("_")
           if ids[1] == 'prt' && ids[2] == 'excel'
               @ExcelList = print_excel_listed
               send_data @ExcelList.to_generate_sublocation, :filename=> "sublocation_list_#{Date.today}.csv"
               return
           elsif ids[1] == 'prt' && ids[2] == 'pdf'
               @rootUrl  = "#{root_url}"
               dataprint = print_excel_listed
               respond_to do |format|
                    format.html
                    format.pdf do
                       pdf = SublocationPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                       send_data pdf.render,:filename => "1_prt_sublocation_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                end
           end
     end

  end

  def add_sub_location
    @compCodes     =  session[:loggedUserCompCode]
    @myheadoffice  = MstHeadOffice.where("hof_compcode =?",@compCodes).order("hof_description ASC")
    @ListDepart = nil
    if params[:id].to_i >0
        @ListDepart  = MstSubLocation.where("sl_compcode = ? AND id = ?",@compCodes,params[:id]).first
    end

  end

  def create
  @compCodes  =  session[:loggedUserCompCode]
  isFlags     = true
  begin
  if params[:sl_locid] == '' || params[:sl_locid] == nil
     flash[:error] =  "Location is required."
     isFlags = false
  elsif params[:sl_description] == '' || params[:sl_description] == nil
     flash[:error] =  "Description is required."
     isFlags = false
  else

    curdcode          = params[:cur_description].to_s.strip
    hof_description   = params[:sl_description].to_s.strip
    locid             = params[:sl_locid]
    mid               = params[:mid]
    if mid.to_i >0

          if curdcode.to_s.downcase != hof_description.to_s.downcase
              chkunb   = MstSubLocation.where("sl_compcode = ? AND LOWER(sl_description) = ? AND sl_locid =?",@compCodes,hof_description.to_s.downcase,locid)
              if chkunb.length >0
                    flash[:error] = "This description is already taken!"
                    isFlags       = false
              end

          end
            if isFlags
                chkdeprtobj   = MstSubLocation.where("sl_compcode = ? AND id = ?",@compCodes,mid).first
                if chkdeprtobj
                  chkdeprtobj.update(sub_params)
                      flash[:error] = "Data updated successfully"
                      isFlags       = true
                end
            end

    else
              chkunb   = MstSubLocation.where("sl_compcode = ? AND LOWER(sl_description) = ? AND sl_locid =?",@compCodes,hof_description.to_s.downcase,locid)
              if chkunb.length >0
                    flash[:error] = "This description is already taken!"
                    isFlags       = false
              end
             if isFlags
                   deprtsvobj = MstSubLocation.new(sub_params)
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
      redirect_to  "#{root_url}head_office"
    else
      redirect_to  "#{root_url}sub_location/add_sub_location"
    end

end

 def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         @ListSate =  MstSubLocation.where("sl_compcode =? AND id = ?",@compcodes,params[:id]).first
         if @ListSate
               chkobjs = check_existing_subloc(@compcodes,params[:id])
               if chkobjs
                 flash[:error] =  "Sorry !! Data could not be deleted due to somewhere used."
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
    redirect_to "#{root_url}head_office"
 end


private
def sub_params
    params[:sl_compcode]      = session[:loggedUserCompCode]
    params[:sl_locid]         = params[:sl_locid]!=nil && params[:sl_locid] !='' ? params[:sl_locid].to_s.strip : 0
    params.permit(:sl_compcode,:sl_locid,:sl_description)
end

private
  def get_hof_list
       if params[:page].to_i >0
         pages = params[:page]
      else
         pages = 1
      end
     if params[:requestserver] !=nil && params[:requestserver] != ''
        session[:req_sl_description] = nil
     end
      search_departcode = params[:search_departcode] !=nil && params[:search_departcode] != '' ? params[:search_departcode].to_s.strip : session[:req_sl_description]
      iswhere = "sl_compcode ='#{@compCodes}'"
      if search_departcode !=nil && search_departcode !=''
        iswhere += " AND (  sl_description LIKE '%#{search_departcode}%' ) "
        @search_departcode = search_departcode
        session[:req_sl_description] = search_departcode
      end
      stsobj =  MstSubLocation.where(iswhere).paginate(:page =>pages,:per_page => 10).order("sl_description ASC")
      return stsobj
  end

  private
  def print_excel_listed
        search_departcode =  session[:req_search_sub_departcode] ? session[:req_search_sub_departcode] : session[:req_sl_description]
        iswhere = "sl_compcode ='#{@compCodes}'"
        if search_departcode !=nil && search_departcode !=''
          iswhere += " AND (  sl_description LIKE '%#{search_departcode}%' ) "
        end
        stsobj =  MstSubLocation.select("'' as locations,mst_sub_locations.*").where(iswhere).order("sl_description ASC")
        return stsobj
  end
  private
  def check_existing_subloc(compcodes,dptcodes)
      istruefalse = false
       sewobj = MstSewadarOfficeInfo.select("so_compcode").where("so_compcode = ? AND so_sublocation =?",compcodes,dptcodes)
       if sewobj.length >0
         istruefalse = true
       end
       return istruefalse
  end
  
end
