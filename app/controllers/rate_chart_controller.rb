## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for designation
### FOR REST API ######
class RateChartController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    helper_method :get_currency_detail, :get_subscription_type_detail, :get_magazine_detail
   def index
      @compCodes       = session[:loggedUserCompCode]
      @ListRateCharts = get_rate_chart_list
      printcontroll    = "1_prt_excel_rate_chart_list"
      @printpath       = rate_chart_path(printcontroll,:format=>"pdf")
      printpdf         = "1_prt_pdf_rate_chart_list"
      @printpdfpath    = rate_chart_path(printpdf,:format=>"pdf")
      
      if params[:id] != nil && params[:id] != ''
            ids = params[:id].to_s.split("_")
            if ids[1] == 'prt' && ids[2] == 'excel'
                @ExcelList = print_excel_listed
                send_data @ExcelList.to_generate_rate_chart, :filename=> "rate_chart_list_#{Date.today}.csv"
                return
            elsif ids[1] == 'prt' && ids[2] == 'pdf'
                @rootUrl  = "#{root_url}"
                dataprint = print_excel_listed
                respond_to do |format|
                     format.html
                     format.pdf do
                        pdf = RateChartPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                        send_data pdf.render,:filename => "1_prt_rate_chart_report.pdf", :type => "application/pdf", :disposition => "inline"
                     end
                 end
            end
      end
 
   end
 
   def add_rate_chart
     @compCodes  =  session[:loggedUserCompCode]
     @lastcodes  =  generate_rate_chart_series
     @ListCurrency = MstCurrency.where("cur_compcode =?",@compCodes).order("cur_name ASC")
     @ListSubTyp = MstSubscriptionType.where("subtyp_compcode =?",@compCodes).order("subtyp_name ASC")
     @ListMag = MstMagazine.where("mag_compcode =?",@compCodes).order("mag_name ASC")
     @ListRateChart = nil
     if params[:id].to_i >0
         @ListRateChart  = MstRateChart.where("rc_compcode = ? AND id = ?",@compCodes,params[:id]).first
     end
 
   end
 
   def create
   @compCodes  =  session[:loggedUserCompCode]
   isFlags     = true
   begin
   if params[:rc_code] == '' || params[:rc_code] == nil
      flash[:error] =  "RateChart code is required."
      isFlags = false
   elsif params[:rc_name] == '' || params[:rc_name] == nil
      flash[:error] =  "RateChart name is required."
      isFlags = false
   elsif params[:rc_currency] == nil || params[:rc_currency] == ''
        flash[:error] =  "RateChart currency is required."
        isFlags = false
    elsif params[:rc_subtyp] == nil || params[:rc_subtyp] == ''
        flash[:error] =  "RateChart subscription type is required."
        isFlags = false
 
   else
 
     curcode = params[:currccode].to_s.strip
     codes    = params[:rc_code].to_s.strip
     currency = params[:rc_currency].to_s.strip
     subtyp = params[:rc_subtyp].to_s.strip
     mid           = params[:mid]
     
     if mid.to_i >0
 
           if curcode.to_s.downcase != codes.to_s.downcase
               @chekCur   = MstRateChart.where("rc_compcode = ? AND LOWER(rc_currency) = ? AND LOWER(rc_subtyp) = ?",@compCodes,currency.to_s.downcase,subtyp.to_s.downcase)
               if @chekCur.length >0
                     flash[:error] = "This RateChart is already taken!"
                     isFlags       = false
               end
 
           end
             if isFlags
                 chkobj   = MstRateChart.where("rc_compcode = ? AND id = ?",@compCodes,mid).first
                 if chkobj
                   chkobj.update(rc_params)
                       flash[:error] = "Data updated successfully"
                       isFlags       = true
                 end
             end
 
     else
                @chekCur   = MstRateChart.where("rc_compcode = ? AND LOWER(rc_currency) = ? AND LOWER(rc_subtyp) = ?",@compCodes,currency.to_s.downcase,subtyp.to_s.downcase)
                if @chekCur.length >0
                    flash[:error] = "This RateChart is already taken!"
                    isFlags       = false
                end
              if isFlags
                    obj = MstRateChart.new(rc_params)
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
       redirect_to  "#{root_url}rate_chart"
     else
       redirect_to  "#{root_url}rate_chart/add_rate_chart"
     end
   
 end
 
  def destroy
     @compcodes = session[:loggedUserCompCode]
     if params[:id].to_i >0
          @Cur =  MstRateChart.where("rc_compcode =? AND id = ?",@compcodes,params[:id]).first
          if @Cur
 
            @Cur.destroy
            flash[:error] =  "Data deleted successfully."
            isFlags       =  true
            session[:isErrorhandled] = nil
                  
          end
     end
     redirect_to "#{root_url}rate_chart"
  end
 
 
 private
 def rc_params
     params[:rc_compcode]         = session[:loggedUserCompCode]
     params[:rc_code]         = params[:rc_code] !=nil && params[:rc_code] !='' ? params[:rc_code].to_s.delete(' ').upcase : ''
     params[:rc_name]   = params[:rc_name]!=nil && params[:rc_name] !='' ? params[:rc_name].to_s.strip : ''
     params[:rc_status]   = params[:rc_status]!=nil && params[:rc_status] !='' ? params[:rc_status].to_s.strip : ''
     params[:rc_currency] = params[:rc_currency]!=nil && params[:rc_currency] !='' ? params[:rc_currency].to_s.strip : ''
     params[:rc_subtyp] = params[:rc_subtyp]!=nil && params[:rc_subtyp] !='' ? params[:rc_subtyp].to_s.strip : ''
     params[:rc_amount] = params[:rc_amount]!=nil && params[:rc_amount] !='' ? params[:rc_amount].to_i : ''
     params[:rc_magazine] = params[:rc_magazine]!=nil && params[:rc_magazine] !='' ? params[:rc_magazine].to_s.strip : ''
     params.permit(:rc_compcode,:rc_code,:rc_name,:rc_status,:rc_subtyp,:rc_currency,:rc_amount,:rc_magazine)
 end
 
 private
   def get_rate_chart_list
        if params[:page].to_i >0
          pages = params[:page]
       else
          pages = 1
       end
      if params[:requestserver] !=nil && params[:requestserver] != ''
         session[:req_search_design] = nil
      end
       search_rate_chart = params[:search_rate_chart] !=nil && params[:search_rate_chart] != '' ? params[:search_rate_chart].to_s.strip : session[:req_search_design]
       iswhere = "rc_compcode ='#{@compCodes}'"
       if search_rate_chart !=nil && search_rate_chart !=''
         iswhere += " AND ( rc_code LIKE '%#{search_rate_chart}%' OR  rc_name LIKE '%#{search_rate_chart}%' ) "
         @search_rate_chart = search_rate_chart
         session[:req_search_design] = search_rate_chart
       end
       stsobj =  MstRateChart.where(iswhere).paginate(:page =>pages,:per_page => 10).order("rc_name ASC")
       return stsobj
   end
 
   private
   def print_excel_listed
        search_rate_chart =  session[:req_search_design]
         iswhere = "rc_compcode ='#{@compCodes}'"
         if search_rate_chart !=nil && search_rate_chart !=''
           iswhere += " AND ( rc_code LIKE '%#{search_rate_chart}%' OR  rc_name LIKE '%#{search_rate_chart}%' ) "
           @search_rate_chart = search_rate_chart
           session[:req_search_design] = search_rate_chart
         end
         stsobj =  MstRateChart.where(iswhere).order("rc_name ASC")
         return stsobj
   end
   
  private
 def generate_rate_chart_series
   prefixobj    = get_common_prefix('RateChart')
   @Startx      = prefixobj ? prefixobj.sn_length : ''
   @isCode      = 0
   @recCodes    = MstRateChart.select("rc_code").where(["rc_compcode = ? AND rc_code<>''", @compCodes]).last
   if @recCodes
      @isCode1    = @recCodes.rc_code.to_s.gsub(/[^\d]/, '')
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
 