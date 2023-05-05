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

        if params[:from_month] !=nil && params[:from_month] !=''
          xnewdates  = params[:from_month].to_s.split("-")
          xmonths    = xnewdates[0]
          xyears     = xnewdates[1]
            fromdateds  = get_total_days_of_month(xmonths,xyears).to_s+"-"+params[:from_month].to_s.to_s
            fromdated   = year_month_days_formatted(fromdateds)
            @from_month = params[:from_month]
        end
        if params[:from_uptomonth] !=nil && params[:from_uptomonth]  !=''
            newdates  = params[:from_uptomonth].to_s.split("-")
            months    = newdates[0]
            years     = newdates[1]
            uptodateds = get_total_days_of_month(months,years).to_s++"-"+params[:from_uptomonth].to_s.to_s
            uptodated  = year_month_days_formatted(uptodateds)
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
    if itemsarra.length >0
        TrnTempAdvanceLedger.all.destroy_all ##3 check empty rules
        itemsarra.each do |newadv|
          process_advance_data(newadv.adamounts,newadv.types,newadv.reqdated,newadv.requestyear)
        end
        set_order_ledger_advance()
        newarrrs = TrnTempAdvanceLedger.all.order("reqdated DESC,requestyear DESC,types DESC")
    end
    return newarrrs
  
  end

  
  private
  def set_order_ledger_advance
        newarrrs = TrnTempAdvanceLedger.all.order("reqdated ASC,requestyear ASC,types ASC")
        if newarrrs.length >0
            balance = 0
            newarrrs.each do |neworder|
                            
                if neworder.types.to_s=='Debit'
                    balance = balance.to_f-neworder.adamounts.to_f
                    update_process_advance_data(balance,neworder.id)
                end
                if neworder.types.to_s=='Credit'                   
                    if balance.to_f >0
                        balance = balance.to_f+neworder.adamounts.to_f
                    else
                        balance = neworder.adamounts
                    end
                    
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
  def process_advance_data(adamounts,types,reqdated,requestyear)
    adamounts = adamounts !=nil && adamounts !='' ? adamounts : 0
    types     = types !=nil && types !='' ? types : ''
    reqdated  = reqdated !=nil && reqdated !='' ? reqdated : ''
    requestyear = requestyear !=nil && requestyear !='' ? requestyear : ''
     saveobj = TrnTempAdvanceLedger.new(:adamounts=>adamounts,:types=>types,:reqdated=>reqdated,:requestyear=>requestyear)
     if saveobj.save
        ## execute other method if required
     end
  end
  
  private
  def get_user_debited_listings(compcode,sewacode,fromdated,uptodated)
       iswhere  = "pm_compcode = '#{compcode}' AND pm_sewacode = '#{sewacode}' AND (pm_ded_repaidloan >0  OR pm_ded_repaidadvance>0 )"       
        if fromdated != nil && fromdated != '' 
            iswhere  += " AND DATE(CONCAT_WS('-', pm_payyear, LPAD(pm_paymonth,2,0), '01'))  >= '#{fromdated}'"
        end
        if uptodated != nil && uptodated !=''
           iswhere  += " AND DATE(CONCAT_WS('-', pm_payyear, LPAD(pm_paymonth,2,0), '30'))   <= '#{uptodated}'"
        end
        isselect    = "(pm_ded_repaidloan+pm_ded_repaidadvance) as adamounts,'Debit' as types,pm_paymonth as reqdated,pm_payyear as requestyear,'Deduct' as requesttype"
        advanobj    = TrnPayMonthly.select(isselect).where(iswhere).order("pm_paymonth DESC,pm_payyear DESC")
       return advanobj
     end
  
  
  def get_credited_advance_listed(compcode,sewacode,fromdated,uptodated)
        arritems  = []   
        iswhere   = "al_compcode ='#{compcode}' AND ( al_openingdata ='Y' OR al_broucherno<>'') AND al_sewadarcode ='#{sewacode}'"        
        if fromdated !=nil && fromdated !='' 
            iswhere  += " AND al_requestdate >='#{fromdated}'"
        end 
        if uptodated !=nil && uptodated !='' 
            iswhere  += " AND al_requestdate <='#{uptodated}'"
        end       
    
        nselected       =   "(al_loanamount+al_advanceamt ) as adamounts,al_installpermonth as totalemi,al_compcode,al_sewadarcode"
        nselected       +=  ",MONTH(al_requestdate) as reqdated,YEAR(al_requestdate) as requestyear ,'Credit' as types,al_requesttype as requesttype"
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
      fromdated  =  params[:fromdated] !=nil && params[:fromdated]  !='' ? params[:fromdated]  : '' 
      uptodated  =  params[:uptodated] !=nil && params[:uptodated]  !='' ? params[:uptodated]  : ''      
     advanceamt   =  get_credited_advance_opening(compcode,sewcode,fromdated)
     debistamt    =  get_debited_obalnce(compcode,sewcode,fromdated)
    
     newobs     = 0    
     fobalance  = (newobs.to_f+advanceamt.to_f).to_f-debistamt.to_f
     return fobalance
  
  end
  
  def get_credited_advance_opening(compcode,sewacode,fromdated)
    total      =   0
    iswhere    =   "al_compcode ='#{compcode}' AND ( al_openingdata ='Y' OR al_broucherno<>'')  AND al_sewadarcode ='#{sewacode}'"        
    iswhere    +=  " AND al_requestdate <'#{fromdated}'"     
    nselected  =   "(SUM(al_loanamount)+SUM(al_advanceamt)) as adamounts"   
    advanceobj =   TrnAdvanceLoan.select(nselected).where(iswhere).first
    if advanceobj
        total  = advanceobj.adamounts
    end
    return total
end

  def get_debited_obalnce(compcode,sewacode,fromdated)
        totamts  = 0
        iswhere  = "pm_compcode = '#{compcode}' AND pm_sewacode = '#{sewacode}' AND (pm_ded_repaidloan >0  OR pm_ded_repaidadvance>0 )"       
        iswhere  += " AND DATE(CONCAT_WS('-', pm_payyear, LPAD(pm_paymonth,2,0), '01'))  <'#{fromdated}'"    
        isselect  = "( SUM(pm_ded_repaidloan)+SUM(pm_ded_repaidadvance)) as total"
        advanobj    = TrnPayMonthly.select(isselect).where(iswhere).first
        if advanobj
            totamts = advanobj.total
        end
        return totamts
  end
  
  
  
end
