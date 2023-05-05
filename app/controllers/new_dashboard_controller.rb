## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0 || 05-Mar-2023
## DESCRIPTION :: This module control all common process display transaction DT
### FOR REST API ######
class NewDashboardController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  include ErpModule::Common
  helper_method :get_sel_brand,:currency_formatted,:year_month_days_formatted,:formatted_date,:set_ent,:set_dct,:get_first_my_sewadar,:format_oblig_date
  helper_method :get_all_department_detail,:get_sewdar_designation_detail,:get_district_detail,:get_state_detail,:get_my_selected_department_code
  helper_method :get_name_global_qualification,:get_leavemaster_detail,:get_creditleave_detail,:get_leave_taken,:get_leave_detail_by_code,:get_today_absent_listed
  helper_method :get_dashboard_list_view_detail,:get_ma_listing_views,:get_advance_request_list,:get_leave_count_listed,:get_total_absent_listed
  helper_method :get_mysewdar_list_details,:get_month_listed_data
 def index
  @compCodes        =  session[:loggedUserCompCode]
  @sewadarCategory  =  MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
  @ListMembname     = nil
  if session[:sec_ecmem_code].to_i >0
      membojs = get_member_listed(session[:sec_ecmem_code])
      if membojs
        @ListMembname  = membojs.lds_name
      end
  end
  @sewcoded         =  nil
  @newsewdarList    =  nil
  @ListDist         =  nil
  @LeavePermit      =  nil
  @lockEdited       =  true
  mydeprtcode       =  ""
  category          =  ""
  @LeaveCategory    =  ""
  @nbegindate       = 2021  
  @Years           =  "";
  @Months          =  "";
  @Monthsx         =  nil
  @Yearx           =  nil
  @deprtcode       =  nil
  @empcode         =  nil
  @ListMonths      =  nil
  @ListYears       =  nil
  @HeadHrp         =  MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
  if @HeadHrp
      @Monthsx = @ListMonths = @HeadHrp.hph_months
      @Yearx   = @ListYears = @HeadHrp.hph_years
  end
    if params[:server_request]!=nil && params[:server_request]!= ''
          if params[:empcode] !=nil && params[:empcode] !=''
            @empcode = params[:empcode]
          end
          if params[:ls_depcode] !=nil && params[:ls_depcode]!=''
            @deprtcode  = params[:ls_depcode]
          end
          if params[:hph_months]!=nil && params[:hph_months]!=''
             @Monthsx = params[:hph_months]
          end
          if params[:hph_years]!=nil && params[:hph_years]!=''
             @Yearx = params[:hph_years]
          end
        
    end
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
  #### PROCESS CHART DATA LISTED ############
     @tchartsList    = get_yearly_monthwise_summary('',@Yearx)
     @ListHighestVal = get_highest_payable_monthly('',@Yearx)
  ######### END CHART PROCESS DATA ############
 end

 def ajax_process
  @compcodes  = session[:loggedUserCompCode]
  if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
     get_load_more_data()  ;
     return;
  elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'SWDABS'
    restore_session_data()  ;
    return;
 end
   
end
#####GET SEWDAR DETAIL LIST ##########
 private
 def get_dashboard_list_view_detail(type,years="",months="")
  compcodes  = session[:loggedUserCompCode] ###sw_sewcode
  empcode    = params[:empcode]
  deprtcode  = params[:ls_depcode]
  months     = params[:hph_months]!=nil && params[:hph_months]!='' ? params[:hph_months] : months
  years      = params[:hph_years]!=nil && params[:hph_years]!='' ? params[:hph_years] : years
  mycounts   = 0
  iswhere    = nil
  if type.to_s == 'TOT'
  iswhere     = "sw_compcode ='#{compcodes}' AND sw_leavingdate='0000-00-00'"
  elsif type.to_s == 'REG'
    iswhere    = "sw_compcode ='#{compcodes}' AND sw_leavingdate='0000-00-00' AND sw_catcode='SDP'"    
  elsif type.to_s == 'TEP'
    iswhere    = "sw_compcode ='#{compcodes}' AND sw_leavingdate='0000-00-00' AND sw_catcode='VIT'"    
  elsif type.to_s == 'OTH'
    iswhere    = "sw_compcode ='#{compcodes}' AND sw_leavingdate='0000-00-00' AND sw_catcode NOT IN('VIT','SDP')"    
  end
  if empcode !=nil && empcode!=''
      iswhere += " AND sw_sewcode='#{empcode}'"
      @empcode = empcode
  end
  if deprtcode !=nil && deprtcode!=''
      iswhere  += " AND sw_depcode='#{deprtcode}'"
      @deprtcode = deprtcode
  end
  if iswhere !=nil && iswhere !=''
      sewdobj    = MstSewadar.select("COUNT(*) as total").where(iswhere).first
      if sewdobj
        mycounts = sewdobj.total
      end
  end
  
  return mycounts

 end
 private
 def get_ma_listing_views(type="",years="",months="")
  compcodes  = session[:loggedUserCompCode] ###sw_sewcode
  mycounts   = 0
  empcode    = params[:empcode]
  deprtcode  = params[:ls_depcode]
  months     = params[:hph_months]!=nil && params[:hph_months]!='' ? params[:hph_months] : months
  years      = params[:hph_years]!=nil && params[:hph_years]!='' ? params[:hph_years] : years
  
  if type.to_s == 'PRV'
      if months.to_i == 1
          years = years.to_i-1
          months     =12-1
      else
        months     = months.to_i-1   
      end
     
     iswhere    = "pm_compcode='#{compcodes}' AND pm_paymonth='#{months}' AND pm_payyear='#{years}'"
  else
    
     iswhere    = "pm_compcode='#{compcodes}' AND pm_paymonth='#{months}' AND pm_payyear='#{years}'"  
  end
 if empcode !=nil && empcode!=''
    iswhere += " AND pm_sewacode='#{empcode}'"
    @empcode = empcode
end
  if deprtcode !=nil && deprtcode!=''
      iswhere  += " AND sw_depcode='#{deprtcode}'"
      @deprtcode = deprtcode
  end
    jons      = " JOIN mst_sewadars sewa ON( sw_compcode = pm_compcode AND sw_sewcode = pm_sewacode)"    
    isselect  =  "sewa.id as sewid,sw_depcode,SUM(pm_workingday) as pm_workingday,SUM(pm_paidleave) as pm_paidleave,SUM(pm_hl) as pm_hl,SUM(pm_wo) as pm_wo,SUM(pm_absent) as pm_absent"
    isselect  += ",SUM(ROUND(pm_actbasic,0)) as pmactbasic,SUM(ROUND(pm_fixarear,0)) as pmarear,SUM(ROUND(pm_basic,0)) as pmbasic,SUM(ROUND(pm_ded_licemployee,0)) as pmdedlicemployee,SUM(ROUND(pm_dedaccomodatamount,0)) as pmdedaccomodatamount"
    isselect  += ",SUM(ROUND(pm_ded_electricamount,0)) as pmdedelectricamount,SUM(ROUND(pm_ded_healthsewdarpay,0)) as pmdedhealthsewdarpay,SUM(ROUND(pm_totaltds,0)) as pmincometaxamount,SUM(ROUND(pm_totaldeduction,0)) as pmtotaldeduction,SUM(ROUND(pm_netpay,0)) as pmnetpay,'' as totaldepart"
    isselect  += ",(SUM(ROUND(pm_ded_repaidadvance,0))+SUM(ROUND(pm_ded_repaidloan,0))) as refundamt,SUM(ROUND(pm_totaldeduction,0)) as totaldeductions"
    isselect  += ",SUM(ROUND(pm_allowancefirst,0)) as allowance1,SUM(ROUND(pm_allowancesecond,0)) as allowance2,SUM(ROUND(pm_dedfirst,0)) as deduction1,SUM(ROUND(pm_dedsecond,0)) as deduction2"
     pmsobj   = TrnPayMonthly.select(isselect).joins(jons).where(iswhere).first
    return   pmsobj
 end

 private
 def get_advance_request_list(type="",retype="",monthx="",years="")
  compcodes  = session[:loggedUserCompCode] ###sw_sewcode
  totals = 0
  empcode    = params[:empcode]
  deprtcode  = params[:ls_depcode]
  months     = params[:hph_months]!=nil && params[:hph_months]!='' ? params[:hph_months] : monthx
  years      = params[:hph_years]!=nil && params[:hph_years]!='' ? params[:hph_years] : years
  
  if( type == 'PRV')
    if months.to_i == 1
        years = years.to_i-1
     end
     iswhere    = "al_compcode='#{compcodes}' AND al_requesttype<>'Ex-gratia' AND MONTH(al_requestdate)='#{months}' AND YEAR(al_requestdate)='#{years}'"
  else
    iswhere    = "al_compcode='#{compcodes}' AND al_requesttype<>'Ex-gratia' AND MONTH(al_requestdate)='#{months}' AND YEAR(al_requestdate)='#{years}'"
  end
  if retype =='AD'
    iswhere   += " AND (al_approvestatus='A' OR al_openingdata='Y')"
  elsif retype =='PD'
     iswhere   += " AND (al_approvestatus IN('N',''))"
  end 
  if empcode !=nil && empcode!=''
    iswhere += " AND al_sewadarcode='#{empcode}'"
    @empcode = empcode
  end
  if deprtcode !=nil && deprtcode!=''
      iswhere  += " AND al_depcode='#{deprtcode}'"
      @deprtcode = deprtcode
  end
   issleect="(SUM(al_advanceamt)+SUM(al_loanamount)) as totals "
   listloans = TrnAdvanceLoan.select(issleect).where(iswhere).first
   if listloans
    totals = listloans.totals
   end
    return totals
 end

 private
 def get_leave_count_listed(type="",months,years)
  compcodes  = session[:loggedUserCompCode] ###sw_sewcode
  totals     = 0
  empcode    = params[:empcode] !=nil && params[:empcode]!='' ? params[:empcode] : ''
  deprtcode  = params[:ls_depcode]!=nil && params[:ls_depcode]!='' ? params[:ls_depcode] : ''
  months     = params[:hph_months]!=nil && params[:hph_months]!='' ? params[:hph_months] : months
  years      = params[:hph_years]!=nil && params[:hph_years]!='' ? params[:hph_years] : years
  iswhere   = "ls_compcode='#{compcodes}' AND ls_leave_code<>'OD' AND MONTH(ls_fromdate) ='#{months}' AND YEAR(ls_fromdate)='#{years}' AND lower(`ls_leavereson`)<>'forfeit'"
  if type == 'PD'
    iswhere   += " AND ls_status IN('','N') "
  elsif type == 'UNP'
    iswhere   += " AND ls_status ='A' AND ls_leave_code='LWM'"  
  else
    iswhere   += " AND ls_status='A' AND ls_leave_code<>'LWM'"
  end
  if empcode !=nil && empcode!=''
    iswhere += " AND ls_empcode='#{empcode}'"
    @empcode = empcode
  end
  if deprtcode !=nil && deprtcode!=''
      iswhere  += " AND ls_depcode='#{deprtcode}'"
      @deprtcode = deprtcode
  end
  isselect  = "SUM(ls_nodays) as totalnumber"
  leaveobj  =   TrnLeave.select(isselect).where(iswhere).first
  if leaveobj
    totals = leaveobj.totalnumber
  end
  return totals

 end

 private
 def get_leave_detail_by_code(type="",months,years)
  compcodes  = session[:loggedUserCompCode] ###sw_sewcode
 
  empcode    = params[:empcode] !=nil && params[:empcode]!='' ? params[:empcode] : ''
  deprtcode  = params[:ls_depcode]!=nil && params[:ls_depcode]!='' ? params[:ls_depcode] : ''
  months     = params[:hph_months]!=nil && params[:hph_months]!='' ? params[:hph_months] : months
  years      = params[:hph_years]!=nil && params[:hph_years]!='' ? params[:hph_years] : years
  
  iswhere    = "ls_compcode='#{compcodes}' AND MONTH(ls_fromdate) ='#{months}' AND YEAR(ls_fromdate)='#{years}' AND ls_status='A' AND lower(`ls_leavereson`)<>'forfeit' AND ls_leave_code<>'OD'"
  if empcode !=nil && empcode!=''
    iswhere += " AND ls_empcode='#{empcode}'"
    @empcode = empcode
  end
  if deprtcode !=nil && deprtcode!=''
      iswhere  += " AND ls_depcode='#{deprtcode}'"
      @deprtcode = deprtcode
  end
  
  isselect   = "SUM(ls_nodays) as totalnumber,ls_leave_code"
  leaveobj   = TrnLeave.select(isselect).where(iswhere).group("ls_leave_code").order("ls_leave_code ASC")  
  return leaveobj

 end

 def get_total_absent_listed(months,years)
  compcodes  = session[:loggedUserCompCode] ###sw_sewcode
  empcode    = params[:empcode] !=nil && params[:empcode]!='' ? params[:empcode] : ''
  deprtcode  = params[:ls_depcode]!=nil && params[:ls_depcode]!='' ? params[:ls_depcode] : ''
  months     = params[:hph_months]!=nil && params[:hph_months]!='' ? params[:hph_months] : months
  years      = params[:hph_years]!=nil && params[:hph_years]!='' ? params[:hph_years] : years
  mycounts   = 0
  iswhere    = "pm_compcode='#{compcodes}' AND pm_paymonth='#{months}' AND pm_payyear='#{years}'" 
  if empcode !=nil && empcode!=''
    iswhere += " AND pm_sewacode='#{empcode}'"
    @empcode = empcode
  end
  if deprtcode !=nil && deprtcode!=''
      iswhere  += " AND sw_depcode='#{deprtcode}'"
      @deprtcode = deprtcode
  end 
  isselect = "SUM(pm_absent) as tabsent"
  jons      = " JOIN mst_sewadars sewa ON( sw_compcode = pm_compcode AND sw_sewcode = pm_sewacode)"   
  pmsobj   = TrnPayMonthly.select(isselect).joins(jons).where(iswhere).first
  if pmsobj
      mycounts = pmsobj.tabsent
  end
  return mycounts
 end

 private
 def get_today_absent_listed
  compcodes  = session[:loggedUserCompCode]
  empcode    = params[:empcode] !=nil && params[:empcode]!='' ? params[:empcode] : ''
  deprtcode  = params[:ls_depcode]!=nil && params[:ls_depcode]!='' ? params[:ls_depcode] : ''  
  iswhere    = "al_compcode = '#{compcodes}' AND DATE(al_trandate)=DATE(NOW()) AND al_absent>0 "
  if empcode !=nil && empcode!=''
        iswhere += " AND al_empcode='#{empcode}'"
        @empcode = empcode
  end
  if deprtcode !=nil && deprtcode!=''
        iswhere    += " AND al_department='#{deprtcode}'"
        @deprtcode = deprtcode
  end 
  isselect = "al_empcode,id"
  chekattd = TrnAttendanceList.select(isselect).where(iswhere).group("al_empcode").order("al_empcode ASC")
  return chekattd

 end

 private
 def get_load_more_data
  compcodes  = session[:loggedUserCompCode]
  empcode    = params[:empcode] !=nil && params[:empcode]!='' ? params[:empcode] : ''
  deprtcode  = params[:ls_depcode]!=nil && params[:ls_depcode]!='' ? params[:ls_depcode] : '' 
  isflags    = false 
  arritem    = []
  iswhere    = "al_compcode = '#{compcodes}' AND DATE(al_trandate)=DATE(NOW()) AND al_absent>0"
  if empcode !=nil && empcode!=''
        iswhere += " AND al_empcode='#{empcode}'"
        @empcode = empcode
  end
  if deprtcode !=nil && deprtcode!=''
        iswhere    += " AND al_department='#{deprtcode}'"
        @deprtcode = deprtcode
  end 
  isselect = "al_empcode,id,'' as sewadarname,'' as sewadarimage"
  chekattd = TrnAttendanceList.select(isselect).where(iswhere).group("al_empcode").order("al_empcode ASC")
  if chekattd.length >0
      isflags = true
      chekattd.each do |newitem|
          sewobjs = get_mysewdar_list_details(newitem.al_empcode)
          if sewobjs
                myimages  = "#{root_url}assets/img/profiles/avatar-02.jpg"
                newitem.sewadarname  = sewobjs.sw_sewadar_name
                if sewobjs.sw_image !=nil && sewobjs.sw_image !=''
                  chekpath = "#{Rails.root}/public/images/sewadar/"+sewobjs.sw_image.to_s
                  if File.file?(chekpath)
                    myimages = "#{root_url}images/sewadar/"+sewobjs.sw_image.to_s
                  end
                end
                newitem.sewadarimage = myimages
          end
          arritem.push newitem
      end
  end
   respond_to do |format|
     format.json { render :json => { 'data'=>arritem, "message"=>'',:status=>isflags } }
   end
   return 

 end


 private
 def get_yearly_monthwise_summary(type="",years="")
  compcodes  = session[:loggedUserCompCode] ###sw_sewcode
  empcode    = params[:empcode]
  deprtcode  = params[:ls_depcode]
  months     = params[:hph_months]!=nil && params[:hph_months]!='' ? params[:hph_months] : months
  years      = params[:hph_years]!=nil && params[:hph_years]!='' ? params[:hph_years] : years  

  iswhere    = "pm_compcode='#{compcodes}' AND pm_payyear='#{years}'"  
#  if empcode !=nil && empcode!=''
#     iswhere += " AND pm_sewacode='#{empcode}'"  
#  end
  if deprtcode !=nil && deprtcode!=''
      iswhere  += " AND pm_department='#{deprtcode}'"     
  end
    jons      = " JOIN mst_sewadars sewa ON( sw_compcode = pm_compcode AND sw_sewcode = pm_sewacode)"    
    isselect  =  "sewa.id as sewid,sw_depcode,SUM(ROUND(pm_totaldeduction,0)) as totaldeductions, pm_paymonth as months,pm_payyear as years,SUM(ROUND(pm_actbasic,0)) as pmactbasic,SUM(ROUND(pm_basic,0)) as pmbasic,SUM(ROUND(pm_netpay,0)) as pmnetpay"
    #isselect  += ",SUM(ROUND(pm_actbasic,0)) as pmactbasic,SUM(ROUND(pm_basic,0)) as pmbasic,SUM(ROUND(pm_ded_licemployee,0)) as pmdedlicemployee,SUM(ROUND(pm_dedaccomodatamount,0)) as pmdedaccomodatamount"
    #isselect  += ",SUM(ROUND(pm_ded_electricamount,0)) as pmdedelectricamount,SUM(ROUND(pm_ded_healthsewdarpay,0)) as pmdedhealthsewdarpay,SUM(ROUND(pm_totaltds,0)) as pmincometaxamount,SUM(ROUND(pm_totaldeduction,0)) as pmtotaldeduction,SUM(ROUND(pm_netpay,0)) as pmnetpay,'' as totaldepart"
    #isselect  += ",(SUM(ROUND(pm_ded_repaidadvance,0))+SUM(ROUND(pm_ded_repaidloan,0))) as refundamt,SUM(ROUND(pm_totaldeduction,0)) as totaldeductions, pm_paymonth as months,pm_payyear as years"
    #isselect  += ",SUM(ROUND(pm_allowancefirst,0)) as allowance1,SUM(ROUND(pm_allowancesecond,0)) as allowance2,SUM(ROUND(pm_dedfirst,0)) as deduction1,SUM(ROUND(pm_dedsecond,0)) as deduction2"
     pmsobj   = TrnPayMonthly.select(isselect).joins(jons).where(iswhere).group("pm_paymonth").order("pm_payyear ASC,pm_paymonth ASC")
     return   pmsobj
 end
 private
 def get_highest_payable_monthly(type="",years="")
    compcodes  = session[:loggedUserCompCode] ###sw_sewcode
    empcode    = params[:empcode]
    deprtcode  = params[:ls_depcode]
    months     = params[:hph_months]!=nil && params[:hph_months]!='' ? params[:hph_months] : months
    years      = params[:hph_years]!=nil && params[:hph_years]!='' ? params[:hph_years] : years  
    highestvalue = 0
    iswhere    = "pm_compcode='#{compcodes}' AND pm_payyear='#{years}'"  
    
    if deprtcode !=nil && deprtcode!=''
        iswhere  += " AND pm_department='#{deprtcode}'"     
    end       
    isselect  =  "SUM(ROUND(pm_basic,0)) as pmhighestval"
    pmsobj    =  TrnPayMonthly.select(isselect).where(iswhere).group("pm_paymonth").order("SUM(ROUND(pm_basic,0)) DESC").first
    if pmsobj
      highestvalue = pmsobj.pmhighestval
    end
    return  highestvalue

 end
 private
 def restore_session_data
  session[:request_absent_logged] = nil
  isflags = true
  respond_to do |format|
    format.json { render :json => { 'data'=>'', "message"=>'',:status=>isflags } }
  end
  return 
 end

end
