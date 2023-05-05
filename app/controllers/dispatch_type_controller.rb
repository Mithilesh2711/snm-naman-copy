## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for designation
### FOR REST API ######
class DispatchTypeController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
   def index
      @compCodes       = session[:loggedUserCompCode]
      @ListDispatchTypes = get_dispatch_type_list
      printcontroll    = "1_prt_excel_dispatch_type_list"
      @printpath       = dispatch_type_path(printcontroll,:format=>"pdf")
      printpdf         = "1_prt_pdf_dispatch_type_list"
      @printpdfpath    = dispatch_type_path(printpdf,:format=>"pdf")
      
      if params[:id] != nil && params[:id] != ''
            ids = params[:id].to_s.split("_")
            if ids[1] == 'prt' && ids[2] == 'excel'
                @ExcelList = print_excel_listed
                send_data @ExcelList.to_generate_dispatch_type, :filename=> "dispatch_type_list_#{Date.today}.csv"
                return
            elsif ids[1] == 'prt' && ids[2] == 'pdf'
                @rootUrl  = "#{root_url}"
                dataprint = print_excel_listed
                respond_to do |format|
                     format.html
                     format.pdf do
                        pdf = DispatchTypePdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                        send_data pdf.render,:filename => "1_prt_dispatch_type_report.pdf", :type => "application/pdf", :disposition => "inline"
                     end
                 end
            end
      end
 
   end
 
   def add_dispatch_type
     @compCodes  =  session[:loggedUserCompCode]
     @lastcodes  =  generate_dispatch_type_series
     @ListDispatchType = nil
     if params[:id].to_i >0
         @ListDispatchType  = MstDispatchType.where("dt_compcode = ? AND id = ?",@compCodes,params[:id]).first
     end
 
   end
 
   def create
   @compCodes  =  session[:loggedUserCompCode]
   isFlags     = true
   begin
   if params[:dt_code] == '' || params[:dt_code] == nil
      flash[:error] =  "DispatchType code is required."
      isFlags = false
   elsif params[:dt_name] == '' || params[:dt_name] == nil
      flash[:error] =  "DispatchType name is required."
      isFlags = false
 
   else
     curcode = params[:curdtcode].to_s.strip
     codes    = params[:dt_code].to_s.strip
     mid           = params[:mid]
     if mid.to_i >0
 
           if curcode.to_s.downcase != codes.to_s.downcase
               @chekCur   = MstDispatchType.where("dt_compcode = ? AND LOWER(dt_code) = ?",@compCodes,codes.to_s.downcase)
               if @chekCur.length >0
                     flash[:error] = "This DispatchType code is already taken!"
                     isFlags       = false
               end
 
           end
             if isFlags
                 chkobj   = MstDispatchType.where("dt_compcode = ? AND id = ?",@compCodes,mid).first
                 if chkobj
                   chkobj.update(dt_params)
                       flash[:error] = "Data updated successfully"
                       isFlags       = true
                 end
             end
 
     else
               @chekCur   = MstDispatchType.where("dt_compcode = ? AND LOWER(dt_code) = ?",@compCodes,codes.to_s.downcase)
               if @chekCur.length >0
                     flash[:error] = "This DispatchType code is already taken!"
                     isFlags       = false
               end
              if isFlags
                    obj = MstDispatchType.new(dt_params)
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
       redirect_to  "#{root_url}dispatch_type"
     else
       redirect_to  "#{root_url}dispatch_type/add_dispatch_type"
     end
   
 end
 
  def destroy
     @compcodes = session[:loggedUserCompCode]
     if params[:id].to_i >0
          @Obj =  MstDispatchType.where("dt_compcode =? AND id = ?",@compcodes,params[:id]).first
          if @Obj
 
            @Obj.destroy
            flash[:error] =  "Data deleted successfully."
            isFlags       = true
            session[:isErrorhandled] = nil
                  
          end
     end
     redirect_to "#{root_url}dispatch_type"
  end
 
 
 private
 def dt_params
     params[:dt_compcode]         = session[:loggedUserCompCode]
     params[:dt_code]         = params[:dt_code] !=nil && params[:dt_code] !='' ? params[:dt_code].to_s.delete(' ').upcase : ''
     params[:dt_name]   = params[:dt_name]!=nil && params[:dt_name] !='' ? params[:dt_name].to_s.strip : ''
     params[:dt_status]   = params[:dt_status]!=nil && params[:dt_status] !='' ? params[:dt_status].to_s.strip : ''
     params.permit(:dt_compcode,:dt_code,:dt_name,:dt_status)
 end
 
 private
   def get_dispatch_type_list
        if params[:page].to_i >0
          pages = params[:page]
       else
          pages = 1
       end
      if params[:requestserver] !=nil && params[:requestserver] != ''
         session[:req_search_design] = nil
      end
       search_dispatch_type = params[:search_dispatch_type] !=nil && params[:search_dispatch_type] != '' ? params[:search_dispatch_type].to_s.strip : session[:req_search_design]
       iswhere = "dt_compcode ='#{@compCodes}'"
       if search_dispatch_type !=nil && search_dispatch_type !=''
         iswhere += " AND ( dt_code LIKE '%#{search_dispatch_type}%' OR  dt_name LIKE '%#{search_dispatch_type}%' ) "
         @search_dispatch_type = search_dispatch_type
         session[:req_search_design] = search_dispatch_type
       end
       stsobj =  MstDispatchType.where(iswhere).paginate(:page =>pages,:per_page => 10).order("dt_name ASC")
       return stsobj
   end
 
   private
   def print_excel_listed
        search_dispatch_type =  session[:req_search_design]
         iswhere = "dt_compcode ='#{@compCodes}'"
         if search_dispatch_type !=nil && search_dispatch_type !=''
           iswhere += " AND ( dt_code LIKE '%#{search_dispatch_type}%' OR  dt_name LIKE '%#{search_dispatch_type}%' ) "
           @search_dispatch_type = search_dispatch_type
           session[:req_search_design] = search_dispatch_type
         end
         stsobj =  MstDispatchType.where(iswhere).order("dt_name ASC")
         return stsobj
   end
   
  private
 def generate_dispatch_type_series
   prefixobj    = get_common_prefix('DispatchType')
   @Startx      = prefixobj ? prefixobj.sn_length : ''
   @isCode      = 0
   @recCodes    = MstDispatchType.select("dt_code").where(["dt_compcode = ? AND dt_code<>''", @compCodes]).last
   if @recCodes
      @isCode1    = @recCodes.dt_code.to_s.gsub(/[^\d]/, '')
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
 