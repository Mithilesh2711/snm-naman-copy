## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for designation
### FOR REST API ######
class MagazineReceiptController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    helper_method :formatted_date, :format_oblig_date
   def index
      @compCodes       = session[:loggedUserCompCode]
      @ListMagazineReceipts = get_magazine_receipt_list
      printcontroll    = "1_prt_excel_magazine_receipt_list"
      @printpath       = magazine_receipt_path(printcontroll,:format=>"pdf")
      printpdf         = "1_prt_pdf_magazine_receipt_list"
      @printpdfpath    = magazine_receipt_path(printpdf,:format=>"pdf")
      
      if params[:id] != nil && params[:id] != ''
            ids = params[:id].to_s.split("_")
            if ids[1] == 'prt' && ids[2] == 'excel'
                @ExcelList = print_excel_listed
                send_data @ExcelList.to_generate_magazine_receipt, :filename=> "magazine_receipt_list_#{Date.today}.csv"
                return
            elsif ids[1] == 'prt' && ids[2] == 'pdf'
                @rootUrl  = "#{root_url}"
                dataprint = print_excel_listed
                respond_to do |format|
                     format.html
                     format.pdf do
                        pdf = MagazineReceiptPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                        send_data pdf.render,:filename => "1_prt_magazine_receipt_report.pdf", :type => "application/pdf", :disposition => "inline"
                     end
                 end
            end
      end
 
   end
 
   def add_magazine_receipt
     @compCodes  =  session[:loggedUserCompCode]
     @cdate = Date.today
     @lastcodes  =  generate_magazine_receipt_series
     @ListSubscription = Subscription.where("sub_compcode =? AND sub_code =?",@compCodes,params[:subid]).first
     @ListMagazine = nil
     @ListMember = nil
     if @ListSubscription
        @ListMagazine = MstMagazine.where("mag_compcode =? AND mag_code=?",@compCodes,@ListSubscription.sub_magazine).first
        @ListMember = Member.where("mbr_compcode =? AND mbr_code=?",@compCodes,@ListSubscription.sub_member).first
     end
     @ListMagazineReceipt = nil
     if params[:id].to_i >0
         @ListMagazineReceipt  = MagazineReceipt.where("mr_compcode = ? AND id = ?",@compCodes,params[:id]).first
     end
 
   end
 
   def create
   @compCodes  =  session[:loggedUserCompCode]
   isFlags     = true
   begin
   if params[:mr_code] == '' || params[:mr_code] == nil
      flash[:error] =  "MagazineReceipt code is required."
      isFlags = false
   elsif params[:mr_member] == '' || params[:mr_member] == nil
      flash[:error] =  "MagazineReceipt member is required."
      isFlags = false
    elsif params[:mr_subscription] == nil || params[:mr_subscription] == ''
        flash[:error] =  "MagazineReceipt subscription is required."
        isFlags = false
    elsif params[:mr_magazine] == nil || params[:mr_magazine] == ''
        flash[:error] =  "MagazineReceipt magazine is required."
        isFlags = false
    elsif params[:mr_amount] == nil || params[:mr_amount] == ''
        flash[:error] =  "MagazineReceipt amount is required."
        isFlags = false
 
   else
 
     curcode = params[:curmrcode].to_s.strip
     codes    = params[:mr_code].to_s.strip
     mid           = params[:mid]
     
     if mid.to_i >0
 
           if curcode.to_s.downcase != codes.to_s.downcase
               @checkmr   = MagazineReceipt.where("mr_compcode = ? AND mr_code = ?",@compCodes,codes)
               if @checkmr.length >0
                     flash[:error] = "This MagazineReceipt is already taken!"
                     isFlags       = false
               end
 
           end
             if isFlags
                 chkobj   = MagazineReceipt.where("mr_compcode = ? AND id = ?",@compCodes,mid).first
                 if chkobj
                   chkobj.update(mr_params)
                       flash[:error] = "Data updated successfully"
                       isFlags       = true
                 end
             end
 
     else
            @checkmr   = MagazineReceipt.where("mr_compcode = ? AND mr_code = ?",@compCodes,codes)
            if @checkmr.length >0
                flash[:error] = "This MagazineReceipt is already taken!"
                isFlags       = false
            end
              if isFlags
                    obj = MagazineReceipt.new(mr_params)
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
       redirect_to  "#{root_url}magazine_receipt"
     else
       redirect_to  "#{root_url}magazine_receipt/add_magazine_receipt"
     end
   
 end
 
  def destroy
     @compcodes = session[:loggedUserCompCode]
     if params[:id].to_i >0
          @Obj =  MagazineReceipt.where("mr_compcode =? AND id = ?",@compcodes,params[:id]).first
          if @Obj
 
            @Obj.destroy
            flash[:error] =  "Data deleted successfully."
            isFlags       =  true
            session[:isErrorhandled] = nil
                  
          end
     end
     redirect_to "#{root_url}magazine_receipt"
  end
 
 
 private
 def mr_params
     params[:mr_compcode]         = session[:loggedUserCompCode]
     params[:mr_code]         = params[:mr_code] !=nil && params[:mr_code] !='' ? params[:mr_code].to_s.delete(' ').upcase : ''
     params[:mr_status]   = params[:mr_status]!=nil && params[:mr_status] !='' ? params[:mr_status].to_s.strip : ''
     params[:mr_magazine]   = params[:mr_magazine]!=nil && params[:mr_magazine] !='' ? params[:mr_magazine].to_s.strip : ''
     params[:mr_subscription]   = params[:mr_subscription]!=nil && params[:mr_subscription] !='' ? params[:mr_subscription].to_s.strip : ''
     params[:mr_amount]   = params[:mr_amount]!=nil && params[:mr_amount] !='' ? params[:mr_amount].to_s.strip : ''
     params[:mr_member]   = params[:mr_member]!=nil && params[:mr_member] !='' ? params[:mr_member].to_s.strip : ''
     params[:mr_paymentmode]   = params[:mr_paymentmode]!=nil && params[:mr_paymentmode] !='' ? params[:mr_paymentmode].to_s.strip : ''
     params[:mr_bankname]   = params[:mr_bankname]!=nil && params[:mr_bankname] !='' ? params[:mr_bankname].to_s.strip : ''
     params[:mr_accountrectdate]   = params[:mr_accountrectdate]!=nil && params[:mr_accountrectdate] !='' ? params[:mr_accountrectdate].to_s.strip : ''
     params[:mr_accountrectnum]   = params[:mr_accountrectnum]!=nil && params[:mr_accountrectnum] !='' ? params[:mr_accountrectnum].to_s.strip : ''
     params[:mr_createdby]   = params[:mr_createdby]!=nil && params[:mr_createdby] !='' ? params[:mr_createdby].to_s.strip : ''
     params[:mr_modifiedby]   = params[:mr_modifiedby]!=nil && params[:mr_modifiedby] !='' ? params[:mr_modifiedby].to_s.strip : ''
     params[:mr_currencyamount]   = params[:mr_currencyamount]!=nil && params[:mr_currencyamount] !='' ? params[:mr_currencyamount].to_s.strip : ''
     params[:mr_documentnum]   = params[:mr_documentnum]!=nil && params[:mr_documentnum] !='' ? params[:mr_documentnum].to_s.strip : ''
     params[:mr_manualrectdate]   = params[:mr_manualrectdate]!=nil && params[:mr_manualrectdate] !='' ? params[:mr_manualrectdate].to_s.strip : ''
     params[:mr_manualrectnum]   = params[:mr_manualrectnum]!=nil && params[:mr_manualrectnum] !='' ? params[:mr_manualrectnum].to_s.strip : ''
     params.permit(:mr_compcode,:mr_code,:mr_accountrectdate,:mr_accountrectnum,:mr_amount,:mr_bankname,:mr_createdby,:mr_currencyamount,:mr_documentnum,:mr_magazine,:mr_manualrectdate,:mr_manualrectnum,:mr_member,:mr_modifiedby,:mr_paymentmode,:mr_status,:mr_subscription)
 end
 
 private
   def get_magazine_receipt_list
        if params[:page].to_i >0
          pages = params[:page]
       else
          pages = 1
       end
      if params[:requestserver] !=nil && params[:requestserver] != ''
         session[:req_search_design] = nil
      end
       search_magazine_receipt = params[:search_magazine_receipt] !=nil && params[:search_magazine_receipt] != '' ? params[:search_magazine_receipt].to_s.strip : session[:req_search_design]
       iswhere = "mr_compcode ='#{@compCodes}'"
       if search_magazine_receipt !=nil && search_magazine_receipt !=''
         iswhere += " AND ( mr_code LIKE '%#{search_magazine_receipt}%' OR  mr_member LIKE '%#{search_magazine_receipt}%') "
         @search_magazine_receipt = search_magazine_receipt
         session[:req_search_design] = search_magazine_receipt
       end
       stsobj =  MagazineReceipt.where(iswhere).paginate(:page =>pages,:per_page => 10)
       return stsobj
   end
 
   private
   def print_excel_listed
        search_magazine_receipt =  session[:req_search_design]
         iswhere = "mr_compcode ='#{@compCodes}'"
         if search_magazine_receipt !=nil && search_magazine_receipt !=''
           iswhere += " AND ( mr_code LIKE '%#{search_magazine_receipt}%' OR  mr_member LIKE '%#{search_magazine_receipt}%' ) "
           @search_magazine_receipt = search_magazine_receipt
           session[:req_search_design] = search_magazine_receipt
         end
         pdobj =  MagazineReceipt.where(iswhere)
         return pdobj
   end
   
  private
 def generate_magazine_receipt_series
   prefixobj    = get_common_prefix('MagazineReceipt')
   @Startx      = prefixobj ? prefixobj.sn_length : ''
   @isCode      = 0
   @recCodes    = MagazineReceipt.select("mr_code").where(["mr_compcode = ? AND mr_code<>''", @compCodes]).last
   if @recCodes
      @isCode1    = @recCodes.mr_code.to_s.gsub(/[^\d]/, '')
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
 