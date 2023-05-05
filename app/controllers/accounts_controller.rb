class AccountsController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_emp_attached_file,:get_employee_types,:get_leavemaster_detail
  helper_method :get_all_department_detail,:get_link_image,:format_oblig_date,:get_mysewdar_list_details,:get_first_my_sewadar
  helper_method :get_sewa_all_department,:get_sewa_all_rolesresp,:user_detail
  def index
    @authorizedId  =   session[:autherizedUserId] 
    @compCodes     =   session[:loggedUserCompCode]
    tdslimits      =   0
    @HeadHrp       =   MstHrParameterHead.where("hph_compcode = ?",@compCodes).first 
    ### PRINT TDS REPORT ################
    
    if params[:id].to_s.strip != '' && params[:id].to_s.strip !=nil
         rooturl      = "#{root_url}"
          docs = params[:id].to_s.split("_")
          @compDetail  = MstCompany.where(["cmp_companycode = ?", @compCodes]).first
          if docs[2].to_s == 'yearly'
              listobj = print_tds_report()
              respond_to do |format|
                format.html
                format.pdf do
                pdf = SewadartdsyearlyPdf.new(listobj,@compDetail,rooturl,@username,session)
                send_data pdf.render,:filename => "1_tds_yearly_report.pdf", :type => "application/pdf", :disposition => "inline"
                end
              end
            elsif docs[2].to_s == 'monthly'
              listobj = print_tds_report()
              respond_to do |format|
                format.html
                format.pdf do
                pdf = SewadartdsmonthlyPdf.new(listobj,@compDetail,rooturl,@username,session)
                send_data pdf.render,:filename => "1_tds_monthly_report.pdf", :type => "application/pdf", :disposition => "inline"
          end
        end
         else docs[2].to_s == 'sewadar'
             listobj = print_tds_report()
             respond_to do |format|
             format.html
             format.pdf do
             pdf = SewadartdsreportPdf.new(listobj,@compDetail,rooturl,@username,session)
             send_data pdf.render,:filename => "1_tds_swd_report.pdf", :type => "application/pdf", :disposition => "inline"
         end
       end
 
      end
    end
     #### END PRINT TDS REPORT ###############
  end
  def tds_entry
    @authorizedId   =   session[:autherizedUserId]
    @compCodes      =   session[:loggedUserCompCode]
    tdslimits       =   0
    @HrMonths       =   nil
    @Hryears        =   nil 
    @HeadHrp        =   MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
    @FincialListed  =   TrnPayMonthly.select("pm_financialyear").where("pm_compcode = ? AND pm_financialyear<>''",@compCodes).group("pm_financialyear").order("pm_financialyear ASC")

    if @HeadHrp
      tdslimits    = @HeadHrp.hph_deductedlimited
      @HrMonths    = get_month_listed_data(@HeadHrp.hph_months)
      @Hryears     = @HeadHrp.hph_years
    end
    myjons           =  " LEFT JOIN mst_sewadar_office_infos ofc ON(so_compcode = sw_compcode AND so_sewcode = sw_sewcode)"
    @newsewdarList   =   MstSewadar.select("sw_sewcode,sw_sewadar_name,ofc.id as ofcId").joins(myjons).where("sw_compcode =? AND so_basic >='#{tdslimits}' && so_basic >0 AND sw_leavingdate='0000-00-00'",@compCodes).order("sw_sewadar_name ASC")
    #@myfinacilayers =   financial_session_years.to_s+"-"+last_financial_session_years.to_s
    

  end
  
  def tds_reports
    @authorizedId  =   session[:autherizedUserId]
    @compCodes     =   session[:loggedUserCompCode]
    printcontroll  =  "1_prt_tds_report_monthly"
    @printpath     =   accounts_path(printcontroll,:format=>"pdf")
    @HeadHrp       =   MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
    @FincialListed =   TrnPayMonthly.select("pm_financialyear").where("pm_compcode = ? AND pm_financialyear<>''",@compCodes).group("pm_financialyear").order("pm_financialyear ASC")


    tdslimits      = 0
    if @HeadHrp
      tdslimits    = @HeadHrp.hph_deductedlimited
      @HrMonths    = get_month_listed_data(@HeadHrp.hph_months)
      @Hryears     = @HeadHrp.hph_years
    end
    myjons          =  " LEFT JOIN mst_sewadar_office_infos ofc ON(so_compcode = sw_compcode AND so_sewcode = sw_sewcode)"
    @newsewdarList =  MstSewadar.select("sw_sewcode,sw_sewadar_name,ofc.id as ofcId").joins(myjons).where("sw_compcode = ? AND so_basic >='#{tdslimits}' && so_basic >0 AND sw_leavingdate='0000-00-00'",@compCodes).order("sw_sewadar_name ASC")
    @HrMonths      =   nil
    @Hryears       =   nil
    @nbegindates   =  2021
    if @HeadHrp
      @HrMonths   = get_month_listed_data(@HeadHrp.hph_months)
      @Hryears     = @HeadHrp.hph_years
    end
    @myfinacilayers = financial_session_years.to_s+"-"+last_financial_session_years.to_s  
    
  end
  def ajax_process
      @compCodes       = session[:loggedUserCompCode]
      if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
          process_tds();
          return
      elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'TDS'
          process_tds_listing();
          return
      elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'TDRPT'
          process_tds_report();
          return
      end

    
  end

  
def cancel
  @compCodes     =   session[:loggedUserCompCode]
  if params[:id].to_i >0
      leaveobj  =   TrnLeave.where("ls_compcode = ? AND id = ?",@compCodes,params[:id]).first
      if leaveobj
          if leaveobj.ls_status == 'P'
            leaveobj.update(:ls_status=>'C')
            flash[:error] =  "Data has been cancelled successfully."
          elsif leaveobj.ls_status == 'A'
            leaveobj.update(:ls_status=>'R')
            flash[:error] =  "Datta has been sent for cancellation."
          elsif leaveobj.ls_status == 'R'
            leaveobj.update(:ls_status=>'C')
            flash[:error] =  "Data has been cancelled successfully."
          end
          session[:isErrorhandled]  = nil
      end
  end
   redirect_to "#{root_url}"+"leave"
end

private
def process_tds
  sewacode = params[:sewcode]
  finayear = params[:finayear] !=nil && params[:finayear] !='' ? params[:finayear] : ''
  months   = params[:months] !=nil && params[:months] !='' ? get_number_month_data(params[:months]) : ''
  proyears = params[:proyears] !=nil && params[:proyears] !='' ? params[:proyears] : 0
  deduct   = params[:deduct] !=nil && params[:deduct] !='' ? params[:deduct] : 0
  if months.to_i >=4 
    genfinalyear = proyears.to_s+"-"+(proyears.to_i+1).to_s
  else
    genfinalyear = (proyears.to_i-1).to_s+"-"+proyears.to_s
  end


 
  isflag   = 0
  message  = ""
   mobjs   = TrnPayMonthly.where("pm_compcode = ? AND pm_sewacode = ? AND pm_financialyear = ? AND pm_paymonth = ? AND pm_payyear = ? ",@compCodes,sewacode,genfinalyear,months,proyears).first
   if mobjs
       mobjs.update(:pm_totaltds=>deduct)
       isflag = true
       message = "Data updated successfully."
   else
       mobjsv = TrnPayMonthly.new(:pm_compcode=>@compCodes,:pm_sewacode=>sewacode,:pm_paymonth=>months,:pm_payyear=>proyears,:pm_totaltds=>deduct,:pm_financialyear=>genfinalyear,:pm_paydays=>0,:pm_basic=>0,:pm_actbasic=>0,:pm_ded_repaidadvance=>0,:pm_ded_repaidloan=>0,:pm_ded_electricunit=>0,:pm_ded_electricamount=>0 ,:pm_dedaccomodatype=>0,:pm_dedaccomodationno=>0,:pm_dedaccomodatamount=>0,:pm_licemployer=>0,:pm_ded_licemployee=>0,:pm_ded_healthslab=>0,:pm_ded_healthmandalpay=>0,:pm_ded_healthsewdarpay=>0,:pm_ded_incometaxpercent=>0,:pm_incometaxamount=>0,:pm_totalallowance=>0,:pm_totaldeduction=>0,:pm_netpay=>0,:pm_absent=>0,:pm_monthday=>0,:pm_arear=>0)
       if mobjsv.save
          isflag = true
          message = "Data saved successfully."
       end
  end
    isselect  = "SUM(pm_actbasic) as myma,SUM(pm_totaltds) as totaltdsdeduct,SUM(pm_totaldeduction) as otherdeduction,SUM(pm_netpay) as netpay,pm_payyear,pm_paymonth,monthname(str_to_date(pm_paymonth,'%m')) as MonthName"
    mobjsx    = TrnPayMonthly.select(isselect).where("pm_compcode = ? AND pm_financialyear = ? AND pm_sewacode = ? ",@compCodes,genfinalyear,sewacode).group("pm_paymonth").order("pm_paymonth ASC,pm_payyear ASC") #AND pm_paymonth = ? AND pm_payyear = ? 
    respond_to do |format|
      format.json { render :json => { 'data'=>mobjsx,"message"=>message,:status=>isflag} }
    end

end


private
def process_tds_listing
  sewacode = params[:sewcode]
  finayear = params[:finayear] !=nil && params[:finayear] !='' ? params[:finayear] : ''
  months   = params[:months] !=nil && params[:months] !='' ? get_number_month_data(params[:months]) : ''
  proyears = params[:proyears] !=nil && params[:proyears] !='' ? params[:proyears] : 0
  isflag   = true
  message  = ""
  
    isselect  = "SUM(pm_actbasic) as myma,SUM(pm_totaltds) as totaltdsdeduct,SUM(pm_totaldeduction) as otherdeduction,SUM(pm_netpay) as netpay,pm_payyear,pm_paymonth,monthname(str_to_date(pm_paymonth,'%m')) as MonthName"
    mobjsx    = TrnPayMonthly.select(isselect).where("pm_compcode = ? AND pm_financialyear = ? AND pm_sewacode = ? ",@compCodes,finayear,sewacode).group("pm_paymonth").order("pm_paymonth ASC,pm_payyear ASC")
    newdata   = get_monthly_tds_data_list()

    respond_to do |format|
      format.json { render :json => { 'data'=>mobjsx,'newdata'=>newdata,"message"=>message,:status=>isflag} }
    end

end

private
def get_monthly_tds_data_list()
  sewacode = params[:sewcode]
  finayear = params[:finayear] !=nil && params[:finayear] !='' ? params[:finayear] : ''
  months   = params[:months] !=nil && params[:months] !='' ? get_number_month_data(params[:months]) : ''
  proyears = params[:proyears] !=nil && params[:proyears] !='' ? params[:proyears] : 0
  isflag   = true
  message  = ""
  
    isselect  = "SUM(pm_actbasic) as myma,SUM(pm_totaltds) as totaltdsdeduct,SUM(pm_totaldeduction) as otherdeduction,SUM(pm_netpay) as netpay,pm_payyear,pm_paymonth,monthname(str_to_date(pm_paymonth,'%m')) as MonthName"
    mobjsx    = TrnPayMonthly.select(isselect).where("pm_compcode = ? AND pm_financialyear = ? AND pm_sewacode = ? AND pm_paymonth = ? AND pm_payyear = ?",@compCodes,finayear,sewacode,months,proyears).first
    return mobjsx

end


private
def process_tds_report

   session[:requestsewacode] = nil
   session[:requestyear]     = nil
   session[:requestmonth]    = nil
  sewacode  = params[:sewacode]
  finayear  = params[:finayear] !=nil && params[:finayear] !='' ? params[:finayear] : ''
  months    = params[:months] !=nil && params[:months] !='' ? params[:months] : ''
  types     = params[:tds_type] !=nil && params[:tds_type] !='' ? params[:tds_type] : ''
  finacialyear = ""
  if finayear !=nil && finayear !=''
    finacialyear = finayear.to_s#+"-"+(finayear.to_i+1).to_s 
    session[:requestyear] = finacialyear
  end
  
  if types.to_s == 'YEAR'
    session[:requestmonth]   = nil
    session[:requestsewacode] = nil
   
     printurl  = "accounts/1_tds_yearly_report.pdf"
  elsif types.to_s == 'MONTH'
     session[:requestmonth]    = months
     session[:requestsewacode] = nil
     session[:requestyear] = nil
    finacialyear = ""
     printurl  = "accounts/1_tds_monthly_report.pdf"
  elsif types.to_s == 'SEWADAR'
      session[:requestsewacode] = sewacode
      session[:requestmonth]   = nil
     printurl  = "accounts/1_tds_swd_report.pdf"
  end
    isflag     = false
    message    = ""
    iswhere    = "pm_compcode ='#{@compCodes}' AND pm_totaltds >0"
    if finacialyear !=nil && finacialyear !=''
      iswhere    += " AND pm_financialyear ='#{finacialyear}'"
    end   
    if months !=nil && months !=''       
        iswhere   += " AND pm_paymonth ='#{months}'"
    end
    if sewacode !=nil && sewacode !=''      
      iswhere   += " AND pm_sewacode ='#{sewacode}'"
  end
    isselect  = "pm_compcode"
    mobjsx    = TrnPayMonthly.select(isselect).where(iswhere)
    if mobjsx.length >0
      isflag =true
    end
    respond_to do |format|
      format.json { render :json => { 'data'=>mobjsx,"message"=>message,:status=>isflag,'printurl'=>printurl} }
    end

end


private
def print_tds_report
  sewacode = session[:requestsewacode]
  finayear = session[:requestyear]
  months   = session[:requestmonth]
  arrtds   = []

  #AND MONTH(pm_paymonth)>='#{months}' 
    isflag    = true
    message   = ""
    iswhere   = "pm_compcode = '#{@compCodes}' AND pm_totaltds >0 "
    if finayear !=nil && finayear !=''
      iswhere   += " AND pm_financialyear = '#{finayear}'"
      
    end
    if months !=nil && months !='' 
      iswhere   += " AND pm_paymonth = '#{months}'"
    end
    if sewacode !=nil && sewacode !=''      
      iswhere   += " AND pm_sewacode ='#{sewacode}'"
  end
    
    if months !=nil && months !=''
        isselect  = "'' as myma,pm_sewacode,'' as department,'' as sewdarname,'' as selfadhar,'' as panno,'' as category,'' as oldcode,SUM(pm_actbasic) as myma1,SUM(pm_totaltds) as totaltdsdeduct,SUM(pm_totaldeduction) as otherdeduction,SUM(pm_netpay) as netpay,pm_payyear,pm_paymonth"
        mobjsx    = TrnPayMonthly.select(isselect).where(iswhere).group("pm_sewacode").order("pm_sewacode ASC")
     elsif sewacode !=nil && sewacode !=''
      isselect  = "'' as myma,pm_sewacode,'' as department,'' as sewdarname,'' as selfadhar,'' as panno,'' as category,'' as oldcode,SUM(pm_actbasic) as myma1,SUM(pm_totaltds) as totaltdsdeduct,SUM(pm_totaldeduction) as otherdeduction,SUM(pm_netpay) as netpay,pm_payyear,pm_paymonth"
      mobjsx    = TrnPayMonthly.select(isselect).where(iswhere).group("pm_paymonth").order("pm_sewacode ASC")   
    else
        ## FOR YEARS
          isselect  = "'' as myma,pm_sewacode,'' as department,'' as sewdarname,'' as selfadhar,'' as panno,'' as category,'' as oldcode,pm_actbasic as myma1,pm_totaltds as totaltdsdeduct,pm_totaldeduction as otherdeduction,pm_netpay as netpay,pm_payyear,pm_paymonth" 
          mobjsx    = TrnPayMonthly.select(isselect).where(iswhere).group("pm_sewacode").order("pm_sewacode ASC")
    end
    

    if mobjsx.length >0
      mobjsx.each do |newtds|
        sewobjs = get_mysewdar_list_details(newtds.pm_sewacode)
        if sewobjs
                newtds.category   = sewobjs.sw_catgeory
                newtds.oldcode    = sewobjs.sw_oldsewdarcode
                newtds.sewdarname = sewobjs.sw_sewadar_name
                deprtobj = get_all_department_detail(sewobjs.sw_depcode)
                if deprtobj
                     newtds.department = deprtobj.departDescription
                end
                kycobj  =  global_sewadar_kyc_information(newtds.pm_sewacode)  
                if kycobj
                      newtds.selfadhar  = kycobj.sk_adharno
                      newtds.panno      = kycobj.sk_panno
                      
                end
        end
        officeobj     = get_office_information(@compCodes,newtds.pm_sewacode)
        if officeobj
            newtds.myma = officeobj.so_basic
        end

         arrtds.push newtds
      end

    end
    return arrtds

end
private
  def get_office_information(compcode,empcode)
         sewdarobj =  MstSewadarOfficeInfo.where("so_compcode =? AND so_sewcode =?",compcode,empcode).first
         return sewdarobj
  end



end
