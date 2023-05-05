## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for designation
### FOR REST API ######
class CurrencyController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
   def index
      @compCodes       = session[:loggedUserCompCode]
      @ListCurrencies = get_currency_list
      printcontroll    = "1_prt_excel_currency_list"
      @printpath       = currency_path(printcontroll,:format=>"pdf")
      printpdf         = "1_prt_pdf_currency_list"
      @printpdfpath    = currency_path(printpdf,:format=>"pdf")
      
      if params[:id] != nil && params[:id] != ''
            ids = params[:id].to_s.split("_")
            if ids[1] == 'prt' && ids[2] == 'excel'
                @ExcelList = print_excel_listed
                send_data @ExcelList.to_generate_currency, :filename=> "currency_list_#{Date.today}.csv"
                return
            elsif ids[1] == 'prt' && ids[2] == 'pdf'
                @rootUrl  = "#{root_url}"
                dataprint = print_excel_listed
                respond_to do |format|
                     format.html
                     format.pdf do
                        pdf = CurrencyPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                        send_data pdf.render,:filename => "1_prt_currency_report.pdf", :type => "application/pdf", :disposition => "inline"
                     end
                 end
            end
      end
 
   end
 
   def add_currency
     @compCodes  =  session[:loggedUserCompCode]
     @lastcodes  =  generate_currency_series
     @ListCur = nil
     if params[:id].to_i >0
         @ListCur  = MstCurrency.where("cur_compcode = ? AND id = ?",@compCodes,params[:id]).first
     end
 
   end
 
   def create
   @compCodes  =  session[:loggedUserCompCode]
   isFlags     = true
   begin
   if params[:cur_code] == '' || params[:cur_code] == nil
      flash[:error] =  "Currency code is required."
      isFlags = false
   elsif params[:cur_name] == '' || params[:cur_name] == nil
      flash[:error] =  "Currency name is required."
      isFlags = false
 
   else
     curcode = params[:curcode].to_s.strip
     codes    = params[:cur_code].to_s.strip
     mid           = params[:mid]
     if mid.to_i >0
 
           if curcode.to_s.downcase != codes.to_s.downcase
               @chekCur   = MstCurrency.where("cur_compcode = ? AND LOWER(cur_code) = ?",@compCodes,codes.to_s.downcase)
               if @chekCur.length >0
                     flash[:error] = "This currency code is already taken!"
                     isFlags       = false
               end
 
           end
             if isFlags
                 chkobj   = MstCurrency.where("cur_compcode = ? AND id = ?",@compCodes,mid).first
                 if chkobj
                   chkobj.update(cur_params)
                       flash[:error] = "Data updated successfully"
                       isFlags       = true
                 end
             end
 
     else
               @chekCur   = MstCurrency.where("cur_compcode = ? AND LOWER(cur_code) = ?",@compCodes,codes.to_s.downcase)
               if @chekCur.length >0
                     flash[:error] = "This currency code is already taken!"
                     isFlags       = false
               end
              if isFlags
                    obj = MstCurrency.new(cur_params)
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
       redirect_to  "#{root_url}currency"
     else
       redirect_to  "#{root_url}currency/add_currency"
     end
   
 end
 
  def destroy
     @compcodes = session[:loggedUserCompCode]
     if params[:id].to_i >0
          @Cur =  MstCurrency.where("cur_compcode =? AND id = ?",@compcodes,params[:id]).first
          if @Cur
 
            obj     = MstRateChart.where("rc_compcode = ? AND rc_currency = ?",@compcodes,@Cur.cur_code)
             if obj.length >0
                 flash[:error] =  "Sorry!! unable do delete this due to used in Rate chart"
                 isFlags       = true
                 session[:isErrorhandled] = 1
             else
                 @Cur.destroy
                 flash[:error] =  "Data deleted successfully."
                 isFlags       = true
                 session[:isErrorhandled] = nil
             end
                  
          end
     end
     redirect_to "#{root_url}currency"
  end
 
 
 private
 def cur_params
     params[:cur_compcode]         = session[:loggedUserCompCode]
     params[:cur_code]         = params[:cur_code] !=nil && params[:cur_code] !='' ? params[:cur_code].to_s.delete(' ').upcase : ''
     params[:cur_name]   = params[:cur_name]!=nil && params[:cur_name] !='' ? params[:cur_name].to_s.strip : ''
     params[:cur_status]   = params[:cur_status]!=nil && params[:cur_status] !='' ? params[:cur_status].to_s.strip : ''
     params.permit(:cur_compcode,:cur_code,:cur_name,:cur_status)
 end
 
 private
   def get_currency_list
        if params[:page].to_i >0
          pages = params[:page]
       else
          pages = 1
       end
      if params[:requestserver] !=nil && params[:requestserver] != ''
         session[:req_search_design] = nil
      end
       search_currency = params[:search_currency] !=nil && params[:search_currency] != '' ? params[:search_currency].to_s.strip : session[:req_search_design]
       iswhere = "cur_compcode ='#{@compCodes}'"
       if search_currency !=nil && search_currency !=''
         iswhere += " AND ( cur_code LIKE '%#{search_currency}%' OR  cur_name LIKE '%#{search_currency}%' ) "
         @search_currency = search_currency
         session[:req_search_design] = search_currency
       end
       stsobj =  MstCurrency.where(iswhere).paginate(:page =>pages,:per_page => 10).order("cur_name ASC")
       return stsobj
   end
 
   private
   def print_excel_listed
        search_currency =  session[:req_search_design]
         iswhere = "cur_compcode ='#{@compCodes}'"
         if search_currency !=nil && search_currency !=''
           iswhere += " AND ( cur_code LIKE '%#{search_currency}%' OR  cur_name LIKE '%#{search_currency}%' ) "
           @search_currency = search_currency
           session[:req_search_design] = search_currency
         end
         stsobj =  MstCurrency.where(iswhere).order("cur_name ASC")
         return stsobj
   end
   
  private
 def generate_currency_series
   prefixobj    = get_common_prefix('Currency')
   @Startx      = prefixobj ? prefixobj.sn_length : ''
   @isCode      = 0
   @recCodes    = MstCurrency.select("cur_code").where(["cur_compcode = ? AND cur_code<>''", @compCodes]).last
   if @recCodes
      @isCode1    = @recCodes.cur_code.to_s.gsub(/[^\d]/, '')
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
 