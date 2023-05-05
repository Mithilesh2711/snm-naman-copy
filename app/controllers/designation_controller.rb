## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for designation
### FOR REST API ######
class DesignationController < ApplicationController
   before_action :require_login
   before_action :allowed_security
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  def index
     @compCodes       = session[:loggedUserCompCode]
     @ListDesignation = get_designation_list
     printcontroll    = "1_prt_excel_designation_list"
     @printpath       = designation_path(printcontroll,:format=>"pdf")
     printpdf         = "1_prt_pdf_designation_list"
     @printpdfpath    = designation_path(printpdf,:format=>"pdf")
     
     if params[:id] != nil && params[:id] != ''
           ids = params[:id].to_s.split("_")
           if ids[1] == 'prt' && ids[2] == 'excel'
               @ExcelList = print_excel_listed
               send_data @ExcelList.to_generate_designation, :filename=> "designation_list_#{Date.today}.csv"
               return
           elsif ids[1] == 'prt' && ids[2] == 'pdf'
               @rootUrl  = "#{root_url}"
               dataprint = print_excel_listed
               respond_to do |format|
                    format.html
                    format.pdf do
                       pdf = DesignationPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                       send_data pdf.render,:filename => "1_prt_designation_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                end
           end
     end

  end

  def add_designation
    @compCodes  =  session[:loggedUserCompCode]
    @lastcodes  =  generate_designation_series
    @ListDepart = nil
    if params[:id].to_i >0
        @ListDepart  = Designation.where("compcode = ? AND id = ?",@compCodes,params[:id]).first
    end

  end

  def create
  @compCodes  =  session[:loggedUserCompCode]
  isFlags     = true
  begin
  if params[:desicode] == '' || params[:desicode] == nil
     flash[:error] =  "Designation code is required."
     isFlags = false
  elsif params[:ds_description] == '' || params[:ds_description] == nil
     flash[:error] =  "Designation name is required."
     isFlags = false

  else

    curdcode = params[:curdesicode].to_s.strip
    codes    = params[:desicode].to_s.strip
    mid           = params[:mid]
    if mid.to_i >0

          if curdcode.to_s.downcase != codes.to_s.downcase
              @chekDepart   = Designation.where("compcode = ? AND LOWER(desicode) = ?",@compCodes,codes.to_s.downcase)
              if @chekDepart.length >0
                    flash[:error] = "This designation code is already taken!"
                    isFlags       = false
              end

          end
            if isFlags
                chkdeprtobj   = Designation.where("compcode = ? AND id = ?",@compCodes,mid).first
                if chkdeprtobj
                  chkdeprtobj.update(desis_params)
                      flash[:error] = "Data updated successfully"
                      isFlags       = true
                end
            end

    else
              @chekDepart   = Designation.where("compcode = ? AND LOWER(desicode) = ?",@compCodes,codes.to_s.downcase)
              if @chekDepart.length >0
                    flash[:error] = "This designation code is already taken!"
                    isFlags       = false
              end
             if isFlags
                   deprtsvobj = Designation.new(desis_params)
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
      redirect_to  "#{root_url}designation"
    else
      redirect_to  "#{root_url}designation/add_designation"
    end
  
end

 def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         @ListSate =  Designation.where("compcode =? AND id = ?",@compcodes,params[:id]).first
         if @ListSate

               chekobj =  check_existing_designation(@compcodes,@ListSate.desicode)
               if chekobj
                   
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
    redirect_to "#{root_url}designation"
 end


private
def desis_params
    params[:compcode]         = session[:loggedUserCompCode]
    params[:desicode]         = params[:desicode] !=nil && params[:desicode] !='' ? params[:desicode].to_s.delete(' ').upcase : ''
    params[:ds_description]   = params[:ds_description]!=nil && params[:ds_description] !='' ? params[:ds_description].to_s.strip : ''
    params[:ds_type]          = params[:ds_type] !=nil && params[:ds_type] !='' ? params[:ds_type] : ''
    params.permit(:compcode,:desicode,:ds_description,:ds_type)
end

private
  def get_designation_list
       if params[:page].to_i >0
         pages = params[:page]
      else
         pages = 1
      end
     if params[:requestserver] !=nil && params[:requestserver] != ''
        session[:req_search_design] = nil
     end
      search_departcode = params[:search_departcode] !=nil && params[:search_departcode] != '' ? params[:search_departcode].to_s.strip : session[:req_search_design]
      iswhere = "compcode ='#{@compCodes}'"
      if search_departcode !=nil && search_departcode !=''
        iswhere += " AND ( desicode LIKE '%#{search_departcode}%' OR  ds_description LIKE '%#{search_departcode}%' ) "
        @search_departcode = search_departcode
        session[:req_search_design] = search_departcode
      end
      stsobj =  Designation.where(iswhere).paginate(:page =>pages,:per_page => 10).order("ds_description ASC")
      return stsobj
  end

  private
  def print_excel_listed
        search_departcode =  session[:req_search_design]
        iswhere = "compcode ='#{@compCodes}'"
        if search_departcode !=nil && search_departcode !=''
          iswhere += " AND ( desicode LIKE '%#{search_departcode}%' OR  ds_description LIKE '%#{search_departcode}%' ) "
          @search_departcode = search_departcode
          session[:req_search_design] = search_departcode
        end
        stsobj =  Designation.where(iswhere).order("ds_description ASC")
        return stsobj
  end
  
 private
def generate_designation_series
  prefixobj    = get_common_prefix('Designation')
  @Startx      = prefixobj ? prefixobj.sn_length : ''
  @isCode      = 0
  @recCodes    = Designation.select("desicode").where(["compcode = ? AND desicode<>''", @compCodes]).last
  if @recCodes
     @isCode1    = @recCodes.desicode.to_s.gsub(/[^\d]/, '')
     @isCode     = @isCode1.to_i

  end
  @sumXOfCode    = @isCode.to_i + 1
  newlength      = @sumXOfCode.to_s.length
  genleth        = @Startx.to_i-newlength.to_i
  zeroseires     = serial_global_number(genleth)
  @sumXOfCode    = zeroseires.to_s+@sumXOfCode.to_s
  myprefix        = ""
  if prefixobj
      myprefix = prefixobj.sn_prefix
  end
  if myprefix !=nil && myprefix !=''
    myprefix = myprefix.to_s+@sumXOfCode.to_s
  else
    myprefix = @sumXOfCode
  end
  return myprefix

end

 private
  def check_existing_designation(compcodes,dptcodes)
     istruefalse = false
      sewobj     = MstSewadarOfficeInfo.select("so_compcode").where("so_compcode = ? AND so_desigcode =?",compcodes,dptcodes)
       if sewobj.length >0
         istruefalse = true
       end
       return istruefalse
  end
  
end
