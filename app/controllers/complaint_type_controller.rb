## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for designation
### FOR REST API ######
class ComplaintTypeController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
   def index
      @compCodes       = session[:loggedUserCompCode]
      @ListComplaintTypes = get_complaint_type_list
      printcontroll    = "1_prt_excel_complaint_type_list"
      @printpath       = complaint_type_path(printcontroll,:format=>"pdf")
      printpdf         = "1_prt_pdf_complaint_type_list"
      @printpdfpath    = complaint_type_path(printpdf,:format=>"pdf")
      
      if params[:id] != nil && params[:id] != ''
            ids = params[:id].to_s.split("_")
            if ids[1] == 'prt' && ids[2] == 'excel'
                @ExcelList = print_excel_listed
                send_data @ExcelList.to_generate_complaint_type, :filename=> "complaint_type_list_#{Date.today}.csv"
                return
            elsif ids[1] == 'prt' && ids[2] == 'pdf'
                @rootUrl  = "#{root_url}"
                dataprint = print_excel_listed
                respond_to do |format|
                     format.html
                     format.pdf do
                        pdf = ComplaintTypePdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                        send_data pdf.render,:filename => "1_prt_complaint_type_report.pdf", :type => "application/pdf", :disposition => "inline"
                     end
                 end
            end
      end
 
   end
 
   def add_complaint_type
     @compCodes  =  session[:loggedUserCompCode]
     @lastcodes  =  generate_complaint_type_series
     @ListComplaintType = nil
     if params[:id].to_i >0
         @ListComplaintType  = MstComplaintType.where("ct_compcode = ? AND id = ?",@compCodes,params[:id]).first
     end
 
   end
 
   def create
   @compCodes  =  session[:loggedUserCompCode]
   isFlags     = true
   begin
   if params[:ct_code] == '' || params[:ct_code] == nil
      flash[:error] =  "ComplaintType code is required."
      isFlags = false
   elsif params[:ct_name] == '' || params[:ct_name] == nil
      flash[:error] =  "ComplaintType name is required."
      isFlags = false
 
   else
     curcode = params[:curctcode].to_s.strip
     codes    = params[:ct_code].to_s.strip
     mid           = params[:mid]
     if mid.to_i >0
 
           if curcode.to_s.downcase != codes.to_s.downcase
               @chekCur   = MstComplaintType.where("ct_compcode = ? AND LOWER(ct_code) = ?",@compCodes,codes.to_s.downcase)
               if @chekCur.length >0
                     flash[:error] = "This ComplaintType code is already taken!"
                     isFlags       = false
               end
 
           end
             if isFlags
                 chkobj   = MstComplaintType.where("ct_compcode = ? AND id = ?",@compCodes,mid).first
                 if chkobj
                   chkobj.update(ct_params)
                       flash[:error] = "Data updated successfully"
                       isFlags       = true
                 end
             end
 
     else
               @chekCur   = MstComplaintType.where("ct_compcode = ? AND LOWER(ct_code) = ?",@compCodes,codes.to_s.downcase)
               if @chekCur.length >0
                     flash[:error] = "This ComplaintType code is already taken!"
                     isFlags       = false
               end
              if isFlags
                    obj = MstComplaintType.new(ct_params)
                    if obj.save
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
       redirect_to  "#{root_url}complaint_type"
     else
       redirect_to  "#{root_url}complaint_type/add_complaint_type"
     end
   
 end
 
  def destroy
     @compcodes = session[:loggedUserCompCode]
     if params[:id].to_i >0
          @Cur =  MstComplaintType.where("ct_compcode =? AND id = ?",@compcodes,params[:id]).first
          if @Cur

            @Cur.destroy
            flash[:error] =  "Data deleted successfully."
            isFlags       = true
            session[:isErrorhandled] = nil
                  
          end
     end
     redirect_to "#{root_url}complaint_type"
  end
 
 
 private
 def ct_params
     params[:ct_compcode]         = session[:loggedUserCompCode]
     params[:ct_code]         = params[:ct_code] !=nil && params[:ct_code] !='' ? params[:ct_code].to_s.delete(' ').upcase : ''
     params[:ct_name]   = params[:ct_name]!=nil && params[:ct_name] !='' ? params[:ct_name].to_s.strip : ''
     params[:ct_status]   = params[:ct_status]!=nil && params[:ct_status] !='' ? params[:ct_status].to_s.strip : ''
     params.permit(:ct_compcode,:ct_code,:ct_name,:ct_status)
 end
 
 private
   def get_complaint_type_list
        if params[:page].to_i >0
          pages = params[:page]
       else
          pages = 1
       end
      if params[:requestserver] !=nil && params[:requestserver] != ''
         session[:req_search_design] = nil
      end
       search_complaint_type = params[:search_complaint_type] !=nil && params[:search_complaint_type] != '' ? params[:search_complaint_type].to_s.strip : session[:req_search_design]
       iswhere = "ct_compcode ='#{@compCodes}'"
       if search_complaint_type !=nil && search_complaint_type !=''
         iswhere += " AND ( ct_code LIKE '%#{search_complaint_type}%' OR  ct_name LIKE '%#{search_complaint_type}%' ) "
         @search_complaint_type = search_complaint_type
         session[:req_search_design] = search_complaint_type
       end
       stsobj =  MstComplaintType.where(iswhere).paginate(:page =>pages,:per_page => 10).order("ct_name ASC")
       return stsobj
   end
 
   private
   def print_excel_listed
        search_complaint_type =  session[:req_search_design]
         iswhere = "ct_compcode ='#{@compCodes}'"
         if search_complaint_type !=nil && search_complaint_type !=''
           iswhere += " AND ( ct_code LIKE '%#{search_complaint_type}%' OR  ct_name LIKE '%#{search_complaint_type}%' ) "
           @search_complaint_type = search_complaint_type
           session[:req_search_design] = search_complaint_type
         end
         stsobj =  MstComplaintType.where(iswhere).order("ct_name ASC")
         return stsobj
   end
   
  private
 def generate_complaint_type_series
   prefixobj    = get_common_prefix('ComplaintType')
   @Startx      = prefixobj ? prefixobj.sn_length : ''
   @isCode      = 0
   @recCodes    = MstComplaintType.select("ct_code").where(["ct_compcode = ? AND ct_code<>''", @compCodes]).last
   if @recCodes
      @isCode1    = @recCodes.ct_code.to_s.gsub(/[^\d]/, '')
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
   
 end
 