class AdvanceDetailController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_emp_attached_file,:get_employee_types,:get_leavemaster_detail
    helper_method :get_all_department_detail,:get_link_image,:format_oblig_date,:get_mysewdar_list_details,:get_first_my_sewadar,:get_oustanding_balance
    helper_method :get_sewa_all_department,:get_sewa_all_rolesresp,:user_detail,:get_all_opening_balance,:get_month_listed_data
    
    def index
      @compCodes        =  session[:loggedUserCompCode]
      @sewadarCategory  =  MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
      @sewcoded         =  nil
      @newsewdarList    =  nil
      @ListDist         =  nil
      @LeavePermit      =  nil
      @lockEdited       =  true
      mydeprtcode       =  ""
      category          =  ""
      @LeaveCategory    =  ""
     
  
      if session[:sec_sewdar_code]
            sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
            if sewobjs          
                mydeprtcode   = sewobjs.sw_depcode
                category      = sewobjs.sw_catcode
                @mydepartcode = mydeprtcode
            end
       end
       if session[:sec_x_dashboard] && session[:sec_x_dashboard].to_s == 'swd'
           @sewcoded      =   session[:sec_sewdar_code]
       end   
      if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf' 
          @sewDepart      = Department.where("compCode = ? AND subdepartment = '' AND departCode = ? ",@compCodes,mydeprtcode).order("departDescription ASC")
          @markedXAllowed = false
      else		  
          @sewDepart     = Department.where("compCode = ? AND subdepartment ='' ",@compCodes).order("departDescription ASC")		   		  
      end
  
    if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
        @markedXAllowed  =   false
        @newsewdarList   =   MstSewadar.where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")
    elsif session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'stf'
        @markedXAllowed  =   false
        @newsewdarList   =   MstSewadar.where("sw_compcode = ? AND sw_depcode = ?",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")
    end    
    voucher_department =   params[:ls_depcode]!=nil && params[:ls_depcode]!=nil ? params[:ls_depcode] : session[:alvoucher_department]
    if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s != 'swd' && session[:requestuser_loggedintp].to_s != 'stf'
      if voucher_department !=nil && voucher_department !=''      
          @newsewdarList   =   MstSewadar.where("sw_compcode = ? AND sw_depcode = ?",@compCodes,voucher_department).order("sw_sewadar_name ASC")
      end
    end  
     @obalances   = 0
      @leaveLedger = nil
      @OrderBanking = nil
       if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'                       
              @leaveLedger = print_sewdar_leave_balances()
              
              @obalances   = get_all_opening_balance()
        else
  
          if params[:requestserver] !=nil && params[:requestserver] != ''                   
              @leaveLedger = print_sewdar_leave_balances()
              @obalances   = get_all_opening_balance()
          end
        end
    end
  
    
  
  def print_sewdar_leave_balances
    
        compcode   =  session[:loggedUserCompCode]  
        if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
        sewcode    =  session[:sec_sewdar_code]
        else
        sewcode    =  params[:al_sewadarcode]!=nil && params[:al_sewadarcode]!=nil ? params[:al_sewadarcode].to_s.strip : '' 
        end
        if params[:server_request] !=nil && params[:server_request] != ''
        session[:dlrequest_sewadar_name]     = nil    
        session[:dlvoucher_department]       = nil
        end
        params[:fromdated]  = params[:from_month] 
        params[:uptodated]  =  params[:from_uptomonth]
        if params[:from_month] !=nil && params[:from_month] !=''
          xnewdates  = params[:from_month].to_s.split("-")
          xmonths    = xnewdates[0]
          xyears     = xnewdates[1]
            fromdateds  = get_total_days_of_month(xmonths,xyears).to_s+"-"+params[:from_month].to_s.to_s
            fromdated   = params[:from_month]  #year_month_days_formatted(fromdateds)
            @from_month = params[:from_month]
        end
        if params[:from_uptomonth] !=nil && params[:from_uptomonth]  !=''
            newdates  = params[:from_uptomonth].to_s.split("-")
            months    = newdates[0]
            years     = newdates[1]
            uptodateds = get_total_days_of_month(months,years).to_s+"-"+params[:from_uptomonth].to_s.to_s
            uptodated  = params[:from_uptomonth] #year_month_days_formatted(uptodateds)
            @from_uptomonth = params[:from_uptomonth]
        end
     
      search_sewadar     =   params[:al_sewadarcode]!=nil && params[:al_sewadarcode]!=nil ? params[:al_sewadarcode].to_s.strip : session[:alrequest_sewadar_name]
      voucher_department =   params[:ls_depcode]!=nil && params[:ls_depcode]!=nil ? params[:ls_depcode] : session[:alvoucher_department]
        
        if voucher_department !=nil && voucher_department !=''
            session[:alvoucher_department] = voucher_department
            @voucher_department = voucher_department
        end
        if search_sewadar !=nil && search_sewadar !=''
            session[:alrequest_sewadar_name] = search_sewadar
            @search_sewadar = search_sewadar
        end
      itemsarra  =  []
     newarrrs     = []
     crediobj   = get_credited_advance_listed(compcode,sewcode,fromdated,uptodated)
     if crediobj.length >0
         crediobj.each do |newbls|
             itemsarra.push newbls
        end
  
     end
    availobj   =  get_user_debited_listings(compcode,sewcode,fromdated,uptodated)
    if availobj.length >0
        availobj.each do |newobx|
            itemsarra.push newobx
        end
    end
    adjobj = get_adjustment_debited_listings(compcode,sewcode,fromdated,uptodated)
    if adjobj.length >0
        adjobj.each do |adjstmst|
            itemsarra.push adjstmst
        end
    end

    if itemsarra.length >0
        TrnTempAdvanceLedger.all.destroy_all ##3 check empty rules
        itemsarra.each do |newadv|
          process_advance_data(newadv.adamounts,newadv.types,newadv.reqdated,newadv.requestyear,newadv.lonrequesttype,newadv.sewacode,newadv.reqnumber)
        end
        set_order_ledger_advance()
        newarrrs = TrnTempAdvanceLedger.all.order("requestyear DESC,reqdated DESC,types DESC")
    end
    return newarrrs
  
  end

  
  private
  def set_order_ledger_advance
        newarrrs = TrnTempAdvanceLedger.all.order("requestyear ASC,reqdated ASC,types ASC,created_at DESC")
        @obalances   = get_all_opening_balance()
        if newarrrs.length >0
            balance = @obalances
            newarrrs.each do |neworder|
                            
                if neworder.types.to_s=='Debit'
                    balance = balance.to_f-neworder.adamounts.to_f
                    update_process_advance_data(balance,neworder.id)
                end
                if neworder.types.to_s=='Credit'  
                    balance = balance.to_f+neworder.adamounts   
                    update_process_advance_data(balance,neworder.id)              
                   
                    
                end   
            end
        end
  end

  private
  def update_process_advance_data(adamounts,pid)
    adamounts  = adamounts !=nil && adamounts !='' ? adamounts : 0 
    chekupdate = TrnTempAdvanceLedger.where("id =?",pid).first  
     if chekupdate
        chekupdate.update(:balanceamount=>adamounts)
     end
  end

  
  private
  def process_advance_data(adamounts,types,reqdated,requestyear,requesttype,sewacode,requestno)
    adamounts = adamounts !=nil && adamounts !='' ? adamounts : 0
    types     = types !=nil && types !='' ? types : ''
    reqdated  = reqdated !=nil && reqdated !='' ? reqdated : ''
    requestyear = requestyear !=nil && requestyear !='' ? requestyear : ''
    requestno   = requestno !=nil && requestno !='' ? requestno : ''
     saveobj = TrnTempAdvanceLedger.new(:adamounts=>adamounts,:types=>types,:requestno=>requestno,:reqdated=>reqdated,:requestyear=>requestyear,:requesttype=>requesttype,:sewacode=>sewacode)
     if saveobj.save
        ## execute other method if required
     end
  end
  
  private
  def get_user_debited_listings(compcode,sewacode,fromdated,uptodated)
       iswhere  = "pm_compcode = '#{compcode}' AND pm_sewacode = '#{sewacode}' AND (pm_ded_repaidloan >0  OR pm_ded_repaidadvance>0 )"       
        if fromdated != nil && fromdated != '' 
            iswhere  += " AND CONCAT_WS('-',  LPAD(pm_paymonth,2,0),pm_payyear)  >= '#{fromdated}'"
        end
        if uptodated != nil && uptodated !=''
           iswhere  += " AND CONCAT_WS('-',  LPAD(pm_paymonth,2,0),pm_payyear) <= '#{uptodated}'"
        end
        isselect    = "'' as reqnumber,(pm_ded_repaidloan+pm_ded_repaidadvance) as adamounts,'Debit' as types,pm_paymonth as reqdated,pm_payyear as requestyear,'Deduct' as requesttype,'Debit' as lonrequesttype,pm_sewacode as sewacode"
        advanobj    = TrnPayMonthly.select(isselect).where(iswhere).order("pm_paymonth DESC,pm_payyear DESC")
       return advanobj
     end
  
     private
     def get_adjustment_debited_listings(compcode,sewacode,fromdated,uptodated)
          iswhere  = "aa_compcode = '#{compcode}' AND aa_swadarcode = '#{sewacode}' "       
           if fromdated != nil && fromdated != '' 
               iswhere  += " AND DATE_FORMAT(aa_adjustmentdate,'%m-%Y')   >= '#{fromdated}'"
           end
           if uptodated != nil && uptodated !=''
              iswhere  += " AND DATE_FORMAT(aa_adjustmentdate,'%m-%Y') <= '#{uptodated}'"
           end
           isselect    = "aa_requestno as reqnumber,(aa_adjustmentamt) as adamounts,'Debit' as types,MONTH(aa_adjustmentdate) as reqdated,YEAR(aa_adjustmentdate) as requestyear,'Deduct' as requesttype,'Adjustment' as lonrequesttype,aa_swadarcode as sewacode"
           advanobj    = TrnAdvanceAdjustment.select(isselect).where(iswhere).order("aa_adjustmentdate DESC")
          return advanobj
    end 
  
  def get_credited_advance_listed(compcode,sewacode,fromdated,uptodated)
        arritems  = []   
        iswhere   = "al_compcode ='#{compcode}' AND al_requesttype<>'Ex-gratia' AND ( al_openingdata ='Y' OR al_broucherno<>'') AND al_sewadarcode ='#{sewacode}'"        
        if fromdated !=nil && fromdated !='' 
            iswhere  += " AND DATE_FORMAT(al_requestdate,'%m-%Y') >='#{fromdated}'"
        end 
        if uptodated !=nil && uptodated !='' 
            iswhere  += " AND DATE_FORMAT(al_requestdate,'%m-%Y') <='#{uptodated}'"
        end       
    
        nselected       =   "(al_loanamount+al_advanceamt ) as adamounts,al_installpermonth as totalemi,al_compcode,al_sewadarcode,al_sewadarcode as sewacode,'Credit' as lonrequesttype"
        nselected       +=  ",al_requestno as reqnumber,MONTH(al_requestdate) as reqdated,YEAR(al_requestdate) as requestyear ,'Credit' as types,al_requesttype as requesttype"
        advanceobj      =   TrnAdvanceLoan.select(nselected).where(iswhere).order("MONTH(al_requestdate) DESC,YEAR(al_requestdate) DESC")
       if advanceobj.length >0
            advanceobj.each do |newd|
                arritems.push newd 
  
            end
        end
        return arritems
  end
  
  private
  def get_all_opening_balance
    compcode   =  session[:loggedUserCompCode] 
    if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
       sewcode    =  session[:sec_sewdar_code]
    else
       sewcode    =  params[:al_sewadarcode]!=nil && params[:al_sewadarcode]!=nil ? params[:al_sewadarcode].to_s.strip : '' 
    end
     fromdated     =  params[:fromdated] !=nil && params[:fromdated]  !='' ? params[:fromdated]  : '' 
     uptodated     =  params[:uptodated] !=nil && params[:uptodated]  !='' ? params[:uptodated]  : ''      
     advanceamt    =  get_credited_advance_opening(compcode,sewcode,fromdated)
     debistamt     =  get_debited_obalnce(compcode,sewcode,fromdated)
     adjustment    =  get_adjustment_opening_listings(compcode,sewcode,fromdated,uptodated)
     newobs        =  0    
     fobalance     =  (newobs.to_f+advanceamt.to_f).to_f-(debistamt.to_f+adjustment.to_f).to_f
     return fobalance
  
  end
  
  def get_credited_advance_opening(compcode,sewacode,fromdated)
    total      =   0
    if fromdated !=nil && fromdated !=''
        iswhere    =   "al_compcode ='#{compcode}' AND ( al_openingdata ='Y' OR al_broucherno<>'')  AND al_sewadarcode ='#{sewacode}'"        
        iswhere    +=  " AND DATE_FORMAT(al_requestdate,'%m-%Y') <'#{fromdated}' AND al_requesttype<>'Ex-gratia'"     
        nselected  =   "(SUM(al_loanamount)+SUM(al_advanceamt)) as adamounts"   
        advanceobj =   TrnAdvanceLoan.select(nselected).where(iswhere).first
        if advanceobj
            total  = advanceobj.adamounts
        end
    end
    return total
end

  def get_debited_obalnce(compcode,sewacode,fromdated)
        totamts  = 0
        if fromdated !=nil && fromdated !=''
        iswhere  = "pm_compcode = '#{compcode}' AND pm_sewacode = '#{sewacode}' AND (pm_ded_repaidloan >0  OR pm_ded_repaidadvance>0 )"       
        iswhere  += " AND CONCAT_WS('-',  LPAD(pm_paymonth,2,0),pm_payyear)  <'#{fromdated}'"    
        isselect  = "( SUM(pm_ded_repaidloan)+SUM(pm_ded_repaidadvance)) as total"
        advanobj    = TrnPayMonthly.select(isselect).where(iswhere).first
        if advanobj
            totamts = advanobj.total
        end
    end
        return totamts
  end
  private
     def get_adjustment_opening_listings(compcode,sewacode,fromdated,uptodated)
        if fromdated !=nil && fromdated !=''
          iswhere  = "aa_compcode = '#{compcode}' AND aa_swadarcode = '#{sewacode}' "       
           if fromdated != nil && fromdated != '' 
               iswhere  += " AND DATE_FORMAT(aa_adjustmentdate,'%m-%Y')  < '#{fromdated}'"
           end
            isselect    = " SUM(aa_adjustmentamt) as total"            
            advanobj    = TrnAdvanceAdjustment.select(isselect).where(iswhere).first
         if advanobj
            totamts = advanobj.total
         end
        end
         return totamts
    end 
  
  
end
