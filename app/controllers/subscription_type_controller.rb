## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for designation
### FOR REST API ######
class SubscriptionTypeController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
   def index
      @compCodes       = session[:loggedUserCompCode]
      @ListSubtyp = get_subtyp_list
      printcontroll    = "1_prt_excel_subtyp_list"
      @printpath       = subscription_type_path(printcontroll,:format=>"pdf")
      printpdf         = "1_prt_pdf_subtyp_list"
      @printpdfpath    = subscription_type_path(printpdf,:format=>"pdf")
      
      if params[:id] != nil && params[:id] != ''
            ids = params[:id].to_s.split("_")
            if ids[1] == 'prt' && ids[2] == 'excel'
                @ExcelList = print_excel_listed
                send_data @ExcelList.to_generate_subtyp, :filename=> "subtyp_list_#{Date.today}.csv"
                return
            elsif ids[1] == 'prt' && ids[2] == 'pdf'
                @rootUrl  = "#{root_url}"
                dataprint = print_excel_listed
                respond_to do |format|
                     format.html
                     format.pdf do
                        pdf = SubscriptionTypePdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                        send_data pdf.render,:filename => "1_prt_subtyp_report.pdf", :type => "application/pdf", :disposition => "inline"
                     end
                 end
            end
      end
 
   end
 
   def add_subscription_type
     @compCodes  =  session[:loggedUserCompCode]
     @lastcodes  =  generate_subtyp_series
     @ListSub = nil
     if params[:id].to_i >0
         @ListSub  = MstSubscriptionType.where("subtyp_compcode = ? AND id = ?",@compCodes,params[:id]).first
     end
 
   end
 
   def create
   @compCodes  =  session[:loggedUserCompCode]
   isFlags     = true
   begin
   if params[:subtyp_code] == '' || params[:subtyp_code] == nil
      flash[:error] =  "Subscription type code is required."
      isFlags = false
   elsif params[:subtyp_name] == '' || params[:subtyp_name] == nil
      flash[:error] =  "Subscription type name is required."
      isFlags = false
 
   else
 
     curscode = params[:cursubtypcode].to_s.strip
     codes    = params[:subtyp_code].to_s.strip
     mid           = params[:mid]
     if mid.to_i >0
           if curscode.to_s.downcase != codes.to_s.downcase
               @cheksubtyp   = MstSubscriptionType.where("subtyp_compcode = ? AND LOWER(subtyp_code) = ?",@compCodes,codes.to_s.downcase)
               if @cheksubtyp.length >0
                     flash[:error] = "This Subscription type code is already taken!"
                     isFlags       = false
               end
 
           end
             if isFlags
                 chksubtypobj   = MstSubscriptionType.where("subtyp_compcode = ? AND id = ?",@compCodes,mid).first
                 if chksubtypobj
                   chksubtypobj.update(subtyp_params)
                       flash[:error] = "Data updated successfully"
                       isFlags       = true
                 end
             end
 
     else
                @cheksubtyp   = MstSubscriptionType.where("subtyp_compcode = ? AND LOWER(subtyp_code) = ?",@compCodes,codes.to_s.downcase)
                if @cheksubtyp.length >0
                    flash[:error] = "This Subscription type code is already taken!"
                    isFlags       = false
                end
              if isFlags
                    subtypvobj = MstSubscriptionType.new(subtyp_params)
                    if subtypvobj.save
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
       redirect_to  "#{root_url}subscription_type"
     else
       redirect_to  "#{root_url}subscription_type/add_subscription_type"
     end
   
 end
 
  def destroy
     @compcodes = session[:loggedUserCompCode]
     if params[:id].to_i >0
          @Subtyp =  MstSubscriptionType.where("subtyp_compcode =? AND id = ?",@compcodes,params[:id]).first
          if @Subtyp
 
            obj     = MstRateChart.where("rc_compcode = ? AND rc_subtyp = ?",@compcodes,@Subtyp.subtyp_code)
             if obj.length >0
                 flash[:error] =  "Sorry!! unable do delete this due to used in Rate chart"
                 isFlags       = true
                 session[:isErrorhandled] = 1
             else
                 @Subtyp.destroy
                 flash[:error] =  "Data deleted successfully."
                 isFlags       = true
                 session[:isErrorhandled] = nil
             end
                  
          end
     end
     redirect_to "#{root_url}subscription_type"
  end
 
 
 private
 def subtyp_params
     params[:subtyp_compcode]         = session[:loggedUserCompCode]
     params[:subtyp_code]         = params[:subtyp_code] !=nil && params[:subtyp_code] !='' ? params[:subtyp_code].to_s.delete(' ').upcase : ''
     params[:subtyp_name]   = params[:subtyp_name]!=nil && params[:subtyp_name] !='' ? params[:subtyp_name].to_s.strip : ''
     params[:status]   = params[:status]!=nil && params[:status] !='' ? params[:status].to_s.strip : ''
     params.permit(:subtyp_compcode,:subtyp_code,:subtyp_name, :status)
 end
 
 private
   def get_subtyp_list
        if params[:page].to_i >0
          pages = params[:page]
       else
          pages = 1
       end
      if params[:requestserver] !=nil && params[:requestserver] != ''
         session[:req_search_design] = nil
      end
       search_subtyp = params[:search_subtyp] !=nil && params[:search_subtyp] != '' ? params[:search_subtyp].to_s.strip : session[:req_search_design]
       iswhere = "subtyp_compcode ='#{@compCodes}'"
       if search_subtyp !=nil && search_subtyp !=''
         iswhere += " AND ( subtyp_code LIKE '%#{search_subtyp}%' OR  subtyp_name LIKE '%#{search_subtyp}%' ) "
         @search_subtyp = search_subtyp
         session[:req_search_design] = search_subtyp
       end
       stsobj =  MstSubscriptionType.where(iswhere).paginate(:page =>pages,:per_page => 10).order("subtyp_name ASC")
       return stsobj
   end
 
   private
   def print_excel_listed
         search_subtyp =  session[:req_search_design]
         iswhere = "subtyp_compcode ='#{@compCodes}'"
         if search_subtyp !=nil && search_subtyp !=''
           iswhere += " AND ( subtyp_code LIKE '%#{search_subtyp}%' OR  subtyp_name LIKE '%#{search_subtyp}%' ) "
           @search_subtyp = search_subtyp
           session[:req_search_design] = search_subtyp
         end
         stsobj =  MstSubscriptionType.where(iswhere).order("subtyp_name ASC")
         return stsobj
   end
   
  private
 def generate_subtyp_series
   prefixobj    = get_common_prefix('SubscriptionType')
   @Startx      = prefixobj ? prefixobj.sn_length : ''
   @isCode      = 0
   @recCodes    = MstSubscriptionType.select("subtyp_code").where(["subtyp_compcode = ? AND subtyp_code<>''", @compCodes]).last
   if @recCodes
      @isCode1    = @recCodes.subtyp_code.to_s.gsub(/[^\d]/, '')
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
 