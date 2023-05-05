## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for designation
### FOR REST API ######
class DispatchModeController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
   def index
      @compCodes       = session[:loggedUserCompCode]
      @ListDispatchModes = get_dispatch_mode_list
      printcontroll    = "1_prt_excel_dispatch_mode_list"
      @printpath       = dispatch_mode_path(printcontroll,:format=>"pdf")
      printpdf         = "1_prt_pdf_dispatch_mode_list"
      @printpdfpath    = dispatch_mode_path(printpdf,:format=>"pdf")
      
      if params[:id] != nil && params[:id] != ''
            ids = params[:id].to_s.split("_")
            if ids[1] == 'prt' && ids[2] == 'excel'
                @ExcelList = print_excel_listed
                send_data @ExcelList.to_generate_dispatch_mode, :filename=> "dispatch_mode_list_#{Date.today}.csv"
                return
            elsif ids[1] == 'prt' && ids[2] == 'pdf'
                @rootUrl  = "#{root_url}"
                dataprint = print_excel_listed
                respond_to do |format|
                     format.html
                     format.pdf do
                        pdf = DispatchModePdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                        send_data pdf.render,:filename => "1_prt_dispatch_mode_report.pdf", :type => "application/pdf", :disposition => "inline"
                     end
                 end
            end
      end
 
   end
 
   def add_dispatch_mode
     @compCodes  =  session[:loggedUserCompCode]
     @lastcodes  =  generate_dispatch_mode_series
     @ListDispatchMode = nil
     if params[:id].to_i >0
         @ListDispatchMode  = MstDispatchMode.where("dm_compcode = ? AND id = ?",@compCodes,params[:id]).first
     end
 
   end
 
   def create
   @compCodes  =  session[:loggedUserCompCode]
   isFlags     = true
   begin
   if params[:dm_code] == '' || params[:dm_code] == nil
      flash[:error] =  "DispatchMode code is required."
      isFlags = false
   elsif params[:dm_name] == '' || params[:dm_name] == nil
      flash[:error] =  "DispatchMode name is required."
      isFlags = false
 
   else
     curcode = params[:curdmcode].to_s.strip
     codes    = params[:dm_code].to_s.strip
     mid           = params[:mid]
     if mid.to_i >0
 
           if curcode.to_s.downcase != codes.to_s.downcase
               @chekCur   = MstDispatchMode.where("dm_compcode = ? AND LOWER(dm_code) = ?",@compCodes,codes.to_s.downcase)
               if @chekCur.length >0
                     flash[:error] = "This DispatchMode code is already taken!"
                     isFlags       = false
               end
 
           end
             if isFlags
                 chkobj   = MstDispatchMode.where("dm_compcode = ? AND id = ?",@compCodes,mid).first
                 if chkobj
                   chkobj.update(dm_params)
                       flash[:error] = "Data updated successfully"
                       isFlags       = true
                 end
             end
 
     else
               @chekCur   = MstDispatchMode.where("dm_compcode = ? AND LOWER(dm_code) = ?",@compCodes,codes.to_s.downcase)
               if @chekCur.length >0
                     flash[:error] = "This DispatchMode code is already taken!"
                     isFlags       = false
               end
              if isFlags
                    obj = MstDispatchMode.new(dm_params)
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
       redirect_to  "#{root_url}dispatch_mode"
     else
       redirect_to  "#{root_url}dispatch_mode/add_dispatch_mode"
     end
   
 end
 
  def destroy
     @compcodes = session[:loggedUserCompCode]
     if params[:id].to_i >0
          @Obj =  MstDispatchMode.where("dm_compcode =? AND id = ?",@compcodes,params[:id]).first
          if @Obj
 
            @Obj.destroy
            flash[:error] =  "Data deleted successfully."
            isFlags       = true
            session[:isErrorhandled] = nil
                  
          end
     end
     redirect_to "#{root_url}dispatch_mode"
  end
 
 
 private
 def dm_params
     params[:dm_compcode]         = session[:loggedUserCompCode]
     params[:dm_code]         = params[:dm_code] !=nil && params[:dm_code] !='' ? params[:dm_code].to_s.delete(' ').upcase : ''
     params[:dm_name]   = params[:dm_name]!=nil && params[:dm_name] !='' ? params[:dm_name].to_s.strip : ''
     params[:dm_status]   = params[:dm_status]!=nil && params[:dm_status] !='' ? params[:dm_status].to_s.strip : ''
     params.permit(:dm_compcode,:dm_code,:dm_name,:dm_status)
 end
 
 private
   def get_dispatch_mode_list
        if params[:page].to_i >0
          pages = params[:page]
       else
          pages = 1
       end
      if params[:requestserver] !=nil && params[:requestserver] != ''
         session[:req_search_design] = nil
      end
       search_dispatch_mode = params[:search_dispatch_mode] !=nil && params[:search_dispatch_mode] != '' ? params[:search_dispatch_mode].to_s.strip : session[:req_search_design]
       iswhere = "dm_compcode ='#{@compCodes}'"
       if search_dispatch_mode !=nil && search_dispatch_mode !=''
         iswhere += " AND ( dm_code LIKE '%#{search_dispatch_mode}%' OR  dm_name LIKE '%#{search_dispatch_mode}%' ) "
         @search_dispatch_mode = search_dispatch_mode
         session[:req_search_design] = search_dispatch_mode
       end
       stsobj =  MstDispatchMode.where(iswhere).paginate(:page =>pages,:per_page => 10).order("dm_name ASC")
       return stsobj
   end
 
   private
   def print_excel_listed
        search_dispatch_mode =  session[:req_search_design]
         iswhere = "dm_compcode ='#{@compCodes}'"
         if search_dispatch_mode !=nil && search_dispatch_mode !=''
           iswhere += " AND ( dm_code LIKE '%#{search_dispatch_mode}%' OR  dm_name LIKE '%#{search_dispatch_mode}%' ) "
           @search_dispatch_mode = search_dispatch_mode
           session[:req_search_design] = search_dispatch_mode
         end
         stsobj =  MstDispatchMode.where(iswhere).order("dm_name ASC")
         return stsobj
   end
   
  private
 def generate_dispatch_mode_series
   prefixobj    = get_common_prefix('DispatchMode')
   @Startx      = prefixobj ? prefixobj.sn_length : ''
   @isCode      = 0
   @recCodes    = MstDispatchMode.select("dm_code").where(["dm_compcode = ? AND dm_code<>''", @compCodes]).last
   if @recCodes
      @isCode1    = @recCodes.dm_code.to_s.gsub(/[^\d]/, '')
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
 