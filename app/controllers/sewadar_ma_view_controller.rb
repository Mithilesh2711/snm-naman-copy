class SewadarMaViewController < ApplicationController

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
     @ListSearch =   print_sewadar_paid_balances()
       
    end
  
    
  
  def print_sewadar_paid_balances    
        compcode   =  session[:loggedUserCompCode]         
        fromdated  =  params[:from_month] 
        uptodated  =  params[:from_uptomonth]
        empcode    =  params[:ls_empcode]
        deprtcode  =  params[:ls_depcode]
        pmsobj      = []
        if empcode == nil || empcode == ''
            return pmsobj
        end
        iswhere = " pm_compcode='#{compcode}'"
        if empcode !=nil && empcode!=''
            iswhere += " AND pm_sewacode='#{empcode}'"
            @empcode = empcode
        end
        if deprtcode !=nil && deprtcode!=''
            iswhere += " AND sw_depcode='#{deprtcode}'"
            @deprtcode = deprtcode
        end
        if fromdated !=nil && fromdated !=''
            fromdateds = fromdated.to_s.split("-") 
            fromdateds = fromdateds[1].to_s+"-"+fromdateds[0].to_s+"-01"      
            iswhere += " AND DATE(CONCAT(pm_payyear,'-',pm_paymonth,'-','01')) >='#{year_month_days_formatted(fromdateds)}' "
            @fromdated = fromdated
        end
        if uptodated !=nil && uptodated !=''
            uptodateds = uptodated.to_s.split("-")
            uptodateds = uptodateds[1].to_s+"-"+uptodateds[0].to_s+"-01"  
            iswhere += " AND DATE(CONCAT(pm_payyear,'-',pm_paymonth,'-','01'))<='#{year_month_days_formatted(uptodateds)}'"
            @uptodated = uptodated
        end
        jons      = " JOIN mst_sewadars sewa ON( sw_compcode = pm_compcode AND sw_sewcode = pm_sewacode)"
        isselect  = "trn_pay_monthlies.*,'' as licno,sewa.id as sewid"
        pmsobj    = TrnPayMonthly.select(isselect).joins(jons).where(iswhere).order("pm_payyear DESC,pm_paymonth DESC")
        return pmsobj
  
  end

  
  
  

end
