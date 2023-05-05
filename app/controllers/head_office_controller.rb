class HeadOfficeController < ApplicationController
  before_action :require_login
   before_action :allowed_security
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
   helper_method :get_ho_location
  def index
     @compCodes       = session[:loggedUserCompCode]
     @search_sub_departcode = nil
     @search_departcode     = nil
     @ListHeadOffice   = get_hof_list
     @subloction       = ge_sublocation_list
     printcontroll    = "1_prt_excel_headoffice_list"
     @printpath       = head_office_path(printcontroll,:format=>"pdf")
     printpdf         = "1_prt_pdf_headoffice_list"
     @printpdfpath    = head_office_path(printpdf,:format=>"pdf")
     
       ########## SUB LOCATION VALUES ###
         
         printconsub        = "1_prt_excel_sublocation_list"
         @printpathsub      = sub_location_path(printconsub,:format=>"pdf")
         printpdfsub        = "1_prt_pdf_sublocation_list"
         @printpdfpathsub   = sub_location_path(printpdfsub,:format=>"pdf")
    ### END SUB LOCATION  ####
     if params[:id] != nil && params[:id] != ''
           ids = params[:id].to_s.split("_")
           if ids[1] == 'prt' && ids[2] == 'excel'
               @ExcelList = print_excel_listed
               send_data @ExcelList.to_generate_headoffice, :filename=> "headoffice_list_#{Date.today}.csv"
               return
           elsif ids[1] == 'prt' && ids[2] == 'pdf'
               @rootUrl  = "#{root_url}"
               dataprint = print_excel_listed
               respond_to do |format|
                    format.html
                    format.pdf do
                       pdf = HeadofficePdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                       send_data pdf.render,:filename => "1_prt_headoffice_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                end
           end
     end

  end

  def add_head_office
    @compCodes  =  session[:loggedUserCompCode]
    @ListDepart = nil
    if params[:id].to_i >0
        @ListDepart  = MstHeadOffice.where("hof_compcode = ? AND id = ?",@compCodes,params[:id]).first
    end

  end

  def create
  @compCodes  =  session[:loggedUserCompCode]
  isFlags     = true
  begin
  if params[:hof_description] == '' || params[:hof_description] == nil
     flash[:error] =  "Description is required."
     isFlags = false

  else

    curdcode          = params[:curdescript].to_s.strip
    hof_description   = params[:hof_description].to_s.strip
    mid               = params[:mid]
    if mid.to_i >0

          if curdcode.to_s.downcase != hof_description.to_s.downcase
              chkunb   = MstHeadOffice.where("hof_compcode = ? AND LOWER(hof_description) = ?",@compCodes,hof_description.to_s.downcase)
              if chkunb.length >0
                    flash[:error] = "This description is already taken!"
                    isFlags       = false
              end

          end
            if isFlags
                chkdeprtobj   = MstHeadOffice.where("hof_compcode = ? AND id = ?",@compCodes,mid).first
                if chkdeprtobj
                  chkdeprtobj.update(headoffice_params)
                      flash[:error] = "Data updated successfully"
                      isFlags       = true
                end
            end

    else
              chkunb   = MstHeadOffice.where("hof_compcode = ? AND LOWER(hof_description) = ?",@compCodes,hof_description.to_s.downcase)
              if chkunb.length >0
                    flash[:error] = "This description is already taken!"
                    isFlags       = false
              end
             if isFlags
                   deprtsvobj = MstHeadOffice.new(headoffice_params)
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
      redirect_to  "#{root_url}head_office/add_head_office"
    end

end

 def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         @ListSate =  MstHeadOffice.where("hof_compcode =? AND id = ?",@compcodes,params[:id]).first
         if @ListSate
             subobj =  check_existing_loc(@compcodes,params[:id])
             if subobj
                 flash[:error]  =  "Data could not be deleted due to used in sub location."
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
def ge_sublocation_list
   if params[:page].to_i >0
         pages = params[:page]
      else
         pages = 1
      end
     if params[:requestserver] !=nil && params[:requestserver] != ''
        session[:req_search_sub_departcode] = nil
     end
      search_departcode = params[:search_sub_departcode] !=nil && params[:search_sub_departcode] != '' ? params[:search_sub_departcode].to_s.strip : session[:req_search_sub_departcode]
      iswhere = "sl_compcode ='#{@compCodes}'"
      if search_departcode !=nil && search_departcode !=''
        iswhere += " AND (  sl_description LIKE '%#{search_departcode}%' ) "
        @search_sub_departcode = search_departcode
        session[:req_search_sub_departcode] = search_departcode
      end
      stsobj =  MstSubLocation.where(iswhere).order("sl_description ASC")
      return stsobj
end

private
def headoffice_params
    params[:hof_compcode]      = session[:loggedUserCompCode]
    params[:hof_description]   = params[:hof_description]!=nil && params[:hof_description] !='' ? params[:hof_description].to_s.strip : ''
    params.permit(:hof_compcode,:hof_description)
end

private
  def get_hof_list
       if params[:page].to_i >0
         pages = params[:page]
      else
         pages = 1
      end
     if params[:requestserver] !=nil && params[:requestserver] != ''
        session[:req_hof_description] = nil
     end
      search_departcode = params[:search_departcode] !=nil && params[:search_departcode] != '' ? params[:search_departcode].to_s.strip : session[:req_hof_description]
      iswhere = "hof_compcode ='#{@compCodes}'"
      if search_departcode !=nil && search_departcode !=''
        iswhere += " AND (  hof_description LIKE '%#{search_departcode}%' ) "
        @search_departcode = search_departcode
        session[:req_hof_description] = search_departcode
      end
      stsobj =  MstHeadOffice.where(iswhere).order("hof_description ASC")
      return stsobj
  end

  private
  def print_excel_listed
        search_departcode =  session[:req_search_design]
        iswhere = "hof_compcode ='#{@compCodes}'"
        if search_departcode !=nil && search_departcode !=''
          iswhere += " AND (  hof_description LIKE '%#{search_departcode}%' ) "
        end
        stsobj =  MstHeadOffice.where(iswhere).order("hof_description ASC")
        return stsobj
  end

  private
  def check_existing_loc(compcodes,dptcodes)
     istruefalse = false
     mstobj = MstSubLocation.where("sl_compcode =? AND sl_locid = ?",compcodes,dptcodes)
     if mstobj.length >0
         istruefalse = true
     end
       sewobj = MstSewadarOfficeInfo.select("so_compcode").where("so_compcode = ? AND so_location =?",compcodes,dptcodes)
       if sewobj.length >0
         istruefalse = true
       end
       return istruefalse
  end
  
end
