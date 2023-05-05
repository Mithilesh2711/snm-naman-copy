## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for designation
### FOR REST API ######
class SubscriptionController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    helper_method :formatted_date, :format_oblig_date, :get_dispatchto_by_type, :handle_subscription_amount
   def index
      @compCodes       = session[:loggedUserCompCode]
      @ListSubscriptions = get_subscription_list
      printcontroll    = "1_prt_excel_subscription_list"
      @printpath       = subscription_path(printcontroll,:format=>"pdf")
      printpdf         = "1_prt_pdf_subscription_list"
      @printpdfpath    = subscription_path(printpdf,:format=>"pdf")
      
      if params[:id] != nil && params[:id] != ''
            ids = params[:id].to_s.split("_")
            if ids[1] == 'prt' && ids[2] == 'excel'
                @ExcelList = print_excel_listed
                send_data @ExcelList.to_generate_subscription, :filename=> "subscription_list_#{Date.today}.csv"
                return
            elsif ids[1] == 'prt' && ids[2] == 'pdf'
                @rootUrl  = "#{root_url}"
                dataprint = print_excel_listed
                respond_to do |format|
                     format.html
                     format.pdf do
                        pdf = SubscriptionPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                        send_data pdf.render,:filename => "1_prt_subscription_report.pdf", :type => "application/pdf", :disposition => "inline"
                     end
                 end
            end
      end
 
   end
 
   def add_subscription
     @compCodes  =  session[:loggedUserCompCode]
     @cdate = Date.today
     @lastcodes  =  generate_subscription_series
     @ListMember = Member.where("mbr_compcode =?",@compCodes).order("mbr_name ASC")
     @ListSubTyp = MstSubscriptionType.where("subtyp_compcode =?",@compCodes).order("subtyp_name ASC")
     @ListMagazine = MstMagazine.where("mag_compcode =?",@compCodes).order("mag_name ASC")
     @ListCur = MstCurrency.where("cur_compcode =?",@compCodes).order("cur_name ASC")
     @ListDM = MstDispatchMode.where("dm_compcode =?",@compCodes).order("dm_name ASC")
     @ListDT = MstDispatchType.where("dt_compcode =?",@compCodes).order("dt_name ASC")
     @ListBranch = MstBranch.where("bch_compcode =?",@compCodes).order("bch_branchname ASC")
     @ListSubscription = nil
     if params[:id].to_i >0
         @ListSubscription  = Subscription.where("sub_compcode = ? AND id = ?",@compCodes,params[:id]).first
     end
 
   end

   def ajax_process
    @compcodes = session[:loggedUserCompCode]
   if params[:identity] !=nil && params[:identity] !='' && params[:identity] == 'AMOUNT'
        get_subscription_amount
        return false
    elsif params[:identity] !=nil && params[:identity] !='' && params[:identity] == 'DISPATCHTO'
        get_dispatch_to
        return false
   end
   
end
 
   def create
   @compCodes  =  session[:loggedUserCompCode]
   isFlags     = true
   begin
   if params[:sub_code] == '' || params[:sub_code] == nil
      flash[:error] =  "Subscription code is required."
      isFlags = false
   elsif params[:sub_name] == '' || params[:sub_name] == nil
      flash[:error] =  "Subscription name is required."
      isFlags = false
 
   else
 
     curcode = params[:cursubcode].to_s.strip
     codes    = params[:sub_code].to_s.strip
     mid           = params[:mid]
     @gobj = nil
     
     if mid.to_i >0
 
           if curcode.to_s.downcase != codes.to_s.downcase
               @checksub   = Subscription.where("sub_compcode = ? AND LOWER(sub_name) = ?",@compCodes,params[:sub_name].to_s.downcase)
               if @checksub.length >0
                     flash[:error] = "This Subscription is already taken!"
                     isFlags       = false
               end
 
           end
             if isFlags
                 chkobj   = Subscription.where("sub_compcode = ? AND id = ?",@compCodes,mid).first
                 if chkobj
                   chkobj.update(sub_params)
                       flash[:error] = "Data updated successfully"
                       isFlags       = true
                       add_logs?(chkobj)
                       gobj = chkobj
                 end
             end
 
     else
            @checksub   = Subscription.where("sub_compcode = ? AND LOWER(sub_name) = ?",@compCodes,params[:sub_name].to_s.downcase)
            if @checksub.length >0
                flash[:error] = "This Subscription is already taken!"
                isFlags       = false
            end
              if isFlags
                    obj = Subscription.new(sub_params)
                    if obj.save
                       flash[:error] = "Data saved successfully"
                       isFlags       = true
                       add_logs?(obj)
                       gobj = obj
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
       redirect_to  "#{root_url}magazine_receipt/add_magazine_receipt_by_subscription/#{gobj.sub_code}"
     else
       redirect_to  "#{root_url}subscription/add_subscription"
     end
   
 end
 
  def destroy
     @compcodes = session[:loggedUserCompCode]
     if params[:id].to_i >0
          @Obj =  Subscription.where("sub_compcode =? AND id = ?",@compcodes,params[:id]).first
          if @Obj
 
            @Obj.destroy
            flash[:error] =  "Data deleted successfully."
            isFlags       =  true
            session[:isErrorhandled] = nil
                  
          end
     end
     redirect_to "#{root_url}subscription"
  end

  def view_logs
    @compcodes = session[:loggedUserCompCode]
    @Member = Member.where("mbr_compcode =? AND mbr_code=?",@compcodes,params[:memid]).first
    @ListSubscriptionLogs = get_subscription_logs_list
    
  end
 
 
 private
 def sub_params
     params[:sub_compcode]         = session[:loggedUserCompCode]
     params[:sub_code]         = params[:sub_code] !=nil && params[:sub_code] !='' ? params[:sub_code].to_s.delete(' ').upcase : ''
     params[:sub_name]   = params[:sub_name]!=nil && params[:sub_name] !='' ? params[:sub_name].to_s.strip : ''
     params[:sub_amount]   = params[:sub_amount]!=nil && params[:sub_amount] !='' ? params[:sub_amount].to_s.strip : ''
     params[:sub_amountrcv]   = params[:sub_amountrcv]!=nil && params[:sub_amountrcv] !='' ? params[:sub_amountrcv].to_s.strip : ''
     params[:sub_bankname]   = params[:sub_bankname]!=nil && params[:sub_bankname] !='' ? params[:sub_bankname].to_s.strip : ''
     params[:sub_branch]   = params[:sub_branch]!=nil && params[:sub_branch] !='' ? params[:sub_branch].to_s.strip : ''
     params[:sub_currency]   = params[:sub_currency]!=nil && params[:sub_currency] !='' ? params[:sub_currency].to_s.strip : ''
     params[:sub_dispatchmode]   = params[:sub_dispatchmode]!=nil && params[:sub_dispatchmode] !='' ? params[:sub_dispatchmode].to_s.strip : ''
     params[:sub_dispatchtype]   = params[:sub_dispatchtype]!=nil && params[:sub_dispatchtype] !='' ? params[:sub_dispatchtype].to_s.strip : ''
     params[:sub_dispatchto]   = params[:sub_dispatchto]!=nil && params[:sub_dispatchto] !='' ? params[:sub_dispatchto].to_s.strip : ''
     params[:sub_docdate]   = params[:sub_docdate]!=nil && params[:sub_docdate] !='' ? params[:sub_docdate].to_s.strip : ''
     params[:sub_docnum]   = params[:sub_docnum]!=nil && params[:sub_docnum] !='' ? params[:sub_docnum].to_s.strip : ''
     params[:sub_enddate]   = params[:sub_enddate]!=nil && params[:sub_enddate] !='' ? params[:sub_enddate].to_s.strip : ''
     params[:sub_inramount]   = params[:sub_inramount]!=nil && params[:sub_inramount] !='' ? params[:sub_inramount].to_s.strip : ''
     params[:sub_status]   = params[:sub_status]!=nil && params[:sub_status] !='' ? params[:sub_status].to_s.strip : ''
     params[:sub_magazine]   = params[:sub_magazine]!=nil && params[:sub_magazine] !='' ? params[:sub_magazine].to_s.strip : ''
     params[:sub_member]   = params[:sub_member]!=nil && params[:sub_member] !='' ? params[:sub_member].to_s.strip : ''
     params[:sub_paymentmode]   = params[:sub_paymentmode]!=nil && params[:sub_paymentmode] !='' ? params[:sub_paymentmode].to_s.strip : ''
     params[:sub_quantity]   = params[:sub_quantity]!=nil && params[:sub_quantity] !='' ? params[:sub_quantity].to_s.strip : ''
     params[:sub_reason_change]   = params[:sub_reason_change]!=nil && params[:sub_reason_change] !='' ? params[:sub_reason_change].to_s.strip : ''
     params[:sub_receiptdate]   = params[:sub_receiptdate]!=nil && params[:sub_receiptdate] !='' ? params[:sub_receiptdate].to_s.strip : ''
     params[:sub_receiptno]   = params[:sub_receiptno]!=nil && params[:sub_receiptno] !='' ? params[:sub_receiptno].to_s.strip : ''
     params[:sub_remarks]   = params[:sub_remarks]!=nil && params[:sub_remarks] !='' ? params[:sub_remarks].to_s.strip : ''
     params[:sub_roe]   = params[:sub_roe]!=nil && params[:sub_roe] !='' ? params[:sub_roe].to_s.strip : ''
     params[:sub_startdate]   = params[:sub_startdate]!=nil && params[:sub_startdate] !='' ? params[:sub_startdate].to_s.strip : ''
     params[:sub_subtyp]   = params[:sub_subtyp]!=nil && params[:sub_subtyp] !='' ? params[:sub_subtyp].to_s.strip : ''


     params.permit(:sub_compcode,:sub_code,:sub_name,:sub_amount,:sub_amountrcv,:sub_bankname,:sub_branch,:sub_currency,:sub_dispatchmode,:sub_dispatchto,:sub_dispatchtype,:sub_docdate,:sub_docnum,:sub_enddate,:sub_inramount,:sub_magazine,:sub_member,:sub_paymentmode,:sub_quantity,:sub_reason_change,:sub_receiptdate,:sub_receiptno,:sub_remarks,:sub_roe,:sub_startdate,:sub_status,:sub_subtyp)
 end
 
 private
   def get_subscription_list
        if params[:page].to_i >0
          pages = params[:page]
       else
          pages = 1
       end
      if params[:requestserver] !=nil && params[:requestserver] != ''
         session[:req_search_design] = nil
      end
       search_subscription = params[:search_subscription] !=nil && params[:search_subscription] != '' ? params[:search_subscription].to_s.strip : session[:req_search_design]
       iswhere = "sub_compcode ='#{@compCodes}'"
       if search_subscription !=nil && search_subscription !=''
         iswhere += " AND ( sub_code LIKE '%#{search_subscription}%' OR  sub_name LIKE '%#{search_subscription}%' ) "
         @search_subscription = search_subscription
         session[:req_search_design] = search_subscription
       end
       stsobj =  Subscription.where(iswhere).paginate(:page =>pages,:per_page => 10).order("sub_name ASC")
       return stsobj
   end

   private
   def get_subscription_logs_list
        
        if params[:page].to_i >0
          pages = params[:page]
       else
          pages = 1
       end
      if params[:requestserver] !=nil && params[:requestserver] != ''
         session[:req_search_design] = nil
      end
       stsobj =  SubscriptionLogs.where("sl_compcode =? AND sl_membercode =?",@compcodes,@Member.mbr_code).paginate(:page =>pages,:per_page => 10).order("created_at DESC")
       return stsobj 
   end
 
   private
   def print_excel_listed
        search_subscription =  session[:req_search_design]
         iswhere = "sub_compcode ='#{@compCodes}'"
         if search_subscription !=nil && search_subscription !=''
           iswhere += " AND ( sub_code LIKE '%#{search_subscription}%' OR  sub_name LIKE '%#{search_subscription}%' ) "
           @search_subscription = search_subscription
           session[:req_search_design] = search_subscription
         end
         pdobj =  Subscription.where(iswhere).order("sub_name ASC")
         return pdobj
   end
   
  private
 def generate_subscription_series
   prefixobj    = get_common_prefix('Subscription')
   @Startx      = prefixobj ? prefixobj.sn_length : ''
   @isCode      = 0
   @recCodes    = Subscription.select("sub_code").where(["sub_compcode = ? AND sub_code<>''", @compCodes]).last
   if @recCodes
      @isCode1    = @recCodes.sub_code.to_s.gsub(/[^\d]/, '')
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
 def get_subscription_amount
    compcode = session[:loggedUserCompCode]
     mag = params[:mag]
     subtyp = params[:subtyp]
     cur = params[:cur]
     isfalgs  = false
    rcobj       = MstRateChart.where("rc_compcode = ? AND rc_magazine = ? AND rc_subtyp = ? AND rc_currency = ?",compcode,mag,subtyp,cur).first
    if rcobj
    isfalgs = true
    end
     respond_to do |format|
       format.json { render :json => { 'data'=>rcobj.rc_amount, "message"=>'',:status=>isfalgs} }
    end
    
 end

 private
 def get_dispatch_to
    compcode = session[:loggedUserCompCode]
     dispatchType = params[:dispatchType]
     member = params[:member]
     isfalgs  = false
     
     dispatch_type       = MstDispatchType.where("dt_compcode = ? AND dt_code = ?",compcode,dispatchType).first
     
     arrttem   = []
     dtvalue = ""
     if dispatch_type.dt_name.to_s == 'Personal'
        isfalgs  = false
        disobj     = MstAddress.where("adr_compcode = ? AND adr_membercode = ?",@compcodes,member).order("adr_name ASC")
        if disobj
          arrttem = disobj
          dtvalue = "Personal"
          isfalgs = true
          puts disobj
        end
     

     elsif dispatch_type.dt_name == 'Individual Bundle'
        isfalgs  = false
        disobj     = MstIndividualHead.where("ih_compcode = ?",@compcodes)
        if disobj
          arrttem = disobj
          dtvalue = "Individual"
          isfalgs = true
        end
     

     elsif dispatch_type.dt_name == 'Branch Bundle'
        isfalgs  = false
        disobj     = MstBranch.where("bch_compcode = ?",@compcodes)
        if disobj
          arrttem = disobj
          dtvalue = "Branch"
          isfalgs = true
        end
     end

      respond_to do |format|
        format.json { render :json => { 'data'=>arrttem,'dtval'=>dtvalue, "message"=>'',:status=>isfalgs} }
     end
    
 end

  private
  def add_logs?(old)
    compcode = session[:loggedUserCompCode]
    title = old.sub_reason_change
    description = ""
    type = ""
    if old.persisted?
        description = "New Record"
        type = "Activate"
    else
        old.previous_changes.each do |k,v|
            if k.to_s != "updated_at" && k.to_s != "sub_reason_change"  
                description += k.to_s+" => "+v[0].to_s+" TO "+v[1].to_s + " "
            end
        end

        if old.previous_changes.key?("sub_magazine")
            type = "Convert"
        
        elsif old.previous_changes.key?("sub_enddate")
            type = "Renew"
        
        elsif old.previous_changes.key?("sub_status") && old.previous_changes[:sub_status][1] == "N"
            type = "Deactivate"
        
        elsif old.previous_changes.key?("sub_status") && old.previous_changes[:sub_status][1] == "Y"
            type = "Activate"

        else 
            type = "Edit"
        end
    end


    subobj = SubscriptionLogs.new(sl_type:type,sl_compcode:compcode,sl_title:title,sl_description:description,sl_subcode:old.sub_code,sl_membercode:params[:sub_member])
    memobj = MemberLogs.new(ml_compcode:compcode,ml_title:title,ml_description:description,ml_member_code:params[:sub_member])
    subobj.save
    memobj.save
  end
   
 
end
 