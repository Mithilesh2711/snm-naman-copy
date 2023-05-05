## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process banking KYC,Attachment,QUALIF etc
### FOR REST API ######
class ReportsController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_sewdar_designation_detail,:get_all_department_detail
  helper_method :set_dct,:set_ent,:get_personal_information,:get_office_information,:get_roles_information,:format_oblig_date,:get_university_deegre_listed
  helper_method :get_sewa_all_department,:get_sewa_all_qualification,:get_sewa_all_rolesresp,:get_sewa_all_designation,:get_first_my_sewadar
def index
   @compCodes         = session[:loggedUserCompCode]
   @mydepartcode      = ''
   @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
  
   @ListDesignation   = Designation.where("compcode = ?",@compCodes).order("ds_description ASC")
   if session[:autherizedUserType] && session[:autherizedUserType].to_s != 'adm'      
    @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =? AND sw_depcode = ?",@compCodes,@mydepartcode)
   else
     @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =?",@compCodes)
  end
   
end
### SEWADAR REPORT ANALYSIS ###
def daily_report
    loguserids     = session[:autherizedUserId]
    @compcodes     = session[:loggedUserCompCode]
    @empDetail     = MstSewadar.select("sw_sewcode as emp_code,sw_sewadar_name as emp_name").where("sw_compcode =?",@compcodes).order("sw_sewadar_name ASC")
    @Department    = Department.select("departDescription as dp_name,departCode,id").where("compCode = ?",@compcodes).order("TRIM(departDescription) ASC") 
    @Locations     = MstHeadOffice.where("hof_compcode = ?",@compcodes).order("hof_description ASC")
    
    month_numbers =  Time.now.month
    month_begins  =  Date.new(Date.today.year, month_numbers)
    begdates      =  Date.parse(month_begins.to_s)
    @nbegindates  =  Date.today.strftime('%d-%b-%Y') #begdates.strftime('%d-%b-%Y')
    month_endings =  month_begins.end_of_month
    endingdates   =  Date.parse(month_endings.to_s)
    @enddates     =  Date.today.strftime('%d-%b-%Y') #endingdates.strftime('%d-%b-%Y')
    @attendance   =  ''
    @processdetail = nil
    
    printpath     = "1_prt_daily_attendance_report"
    @mypaths      = reports_path(printpath,:format=>"pdf")
  end
def show
   @compcodes     = session[:loggedUserCompCode]
   @compDetail    = MstCompany.where(["cmp_companycode = ?", @compcodes]).first
    rooturl       = "#{root_url}"
    if params[:id] != nil && params[:id] != ''
      docsid  = params[:id].to_s.split("_")
      if docsid[2] == 'slip'
          @voucherdata  =  print_sewadar_salary
          respond_to do |format|
              format.html
              format.pdf do
                 pdf = SalaryslipPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                 send_data pdf.render,:filename => "1_salary_slip_report.pdf", :type => "application/pdf", :disposition => "inline"
              end
           end
          elsif docsid[2] == 'daily'
            mytypes     = session[:at_reqtype]            
            printdata    = print_attendance_list           
            if mytypes  == 'PRFS'
                respond_to do |format|
                    format.html
                    format.pdf do
                      pdf = PerformancedailyPdf.new(printdata,@compDetail,rooturl,session,'')
                      send_data pdf.render,:filename => "1_performance_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                end  
              elsif mytypes  == 'ARV'
                  respond_to do |format|
                      format.html
                      format.pdf do
                        pdf = ArrivalreportPdf.new(printdata,@compDetail,'',rooturl,session)
                        send_data pdf.render,:filename => "1_arrival_report.pdf", :type => "application/pdf", :disposition => "inline"
                      end
                  end 
                elsif mytypes  == 'ARSD'
                  printdatas = departmentwise_attendance_list
                  respond_to do |format|
                      format.html
                      format.pdf do
                        pdf = ArrivalsummarydeptPdf.new(printdatas,@compDetail,'',rooturl,session)
                        send_data pdf.render,:filename => "1_arrivalsummarydpt_report.pdf", :type => "application/pdf", :disposition => "inline"
                      end
                  end    
                elsif mytypes  == 'ARS'
                  printdatas = departmentwise_attendance_list
                  respond_to do |format|
                      format.html
                      format.pdf do
                        pdf = ArrivalsummarylocPdf.new(printdatas,@compDetail,'',rooturl,session)
                        send_data pdf.render,:filename => "1_arrivalsummaryloc_report.pdf", :type => "application/pdf", :disposition => "inline"
                      end
                  end  
                elsif mytypes  == 'MSP'
                  respond_to do |format|
                      format.html
                      format.pdf do
                        pdf = MisspunchPdf.new(printdata,@compDetail,rooturl,session,'')
                        send_data pdf.render,:filename => "1_misspunch_report.pdf", :type => "application/pdf", :disposition => "inline"
                      end
                  end    
                elsif mytypes  == 'ABS'
                  respond_to do |format|
                      format.html
                      format.pdf do
                        pdf = AbsentPdf.new(printdata,@compDetail,rooturl,session,'')
                        send_data pdf.render,:filename => "1_absent_report.pdf", :type => "application/pdf", :disposition => "inline"
                      end
                  end
                elsif mytypes  == 'OVT'
                  respond_to do |format|
                      format.html
                      format.pdf do
                        pdf = OvertimedepartmentwisePdf.new(printdata,@compDetail,rooturl,session,'')
                        send_data pdf.render,:filename => "1_overtime_report.pdf", :type => "application/pdf", :disposition => "inline"
                      end
                  end
                elsif mytypes  == 'OVTS'
                  respond_to do |format|
                      format.html
                      format.pdf do
                        pdf = OvertimesummaryPdf.new(printdata,@compDetail,'',rooturl,session)
                        send_data pdf.render,:filename => "1_overtimesummary_report.pdf", :type => "application/pdf", :disposition => "inline"
                      end
                  end                          
            end
            return     
      elsif  docsid[2] == 'register'
       
          printype      = session[:print_excel_type]
          if printype == 'BK'
           # print_sewadar_salary()
            @voucherdata  = print_sewadar_salary #get_salary_slip_register(printype)
            respond_to do |format|
                format.html
                format.pdf do
                  pdf = BanktransferPdf.new(@voucherdata,@compDetail,rooturl,@username,session)
                  send_data pdf.render,:filename => "1_bankwise_summary_report.pdf", :type => "application/pdf", :disposition => "inline"
                end
            end
          
          elsif printype == 'DT'
            @voucherdata =  print_sewadar_salary()
            #@voucherdata  = get_salary_slip_register(printype)
            respond_to do |format|
                format.html
                format.pdf do
                  pdf = MaintenanceallowancereportsPdf.new(@voucherdata,@compDetail,rooturl,@username,session)
                  send_data pdf.render,:filename => "1_department_summary_report.pdf", :type => "application/pdf", :disposition => "inline"
                end
            end 
          else

                @voucherdata  =  print_sewadar_salary
                respond_to do |format|
                    format.html
                    format.pdf do
                      pdf = SalaryregisterPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                      send_data pdf.render,:filename => "1_salary_register_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                end
            end

      elsif  docsid[2] == 'excel'
       
          printype      = session[:print_excel_type]
          @ExcelList    = nil        
          $printdatatype = printype 
          $mymonths        = get_month_listed_data(session[:my_sl_months])
          $myyears         = session[:my_sl_years]
          if printype.to_s == 'BK'     
              $voucherdata  = print_sewadar_salary
              if @ExcelList !=nil              
                  send_data @ExcelList.process_excel_data, :filename=> "salary_register-#{Date.today}.csv"
              end
          else
            print_sewadar_salary()
             $voucherdata  = get_salary_slip_register(printype)
              if @ExcelList !=nil              
                  send_data @ExcelList.process_excel_data, :filename=> "salary_register-#{Date.today}.csv"
              end
          end
          
      elsif  docsid[2] == 'common'
                types         = session[:my_sl_type]
                @voucherdata  =  print_sewadar_salary
                if types == 'LIC'
                    respond_to do |format|
                        format.html
                        format.pdf do
                           pdf = MonthlylicPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                           send_data pdf.render,:filename => "1_salary_lic_report.pdf", :type => "application/pdf", :disposition => "inline"
                        end
                     end

               elsif  types == 'BUILD'
                    respond_to do |format|
                        format.html
                        format.pdf do
                           pdf = MonthlybuildingPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                           send_data pdf.render,:filename => "1_salary_accomodation_report.pdf", :type => "application/pdf", :disposition => "inline"
                          end
                        end
               elsif  types == 'ELEC'
                    respond_to do |format|
                        format.html
                        format.pdf do
                           pdf = MonthlyelectricPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                           send_data pdf.render,:filename => "1_salary_electric_report.pdf", :type => "application/pdf", :disposition => "inline"
                          end
                        end
               elsif  types == 'ADVL'
                    respond_to do |format|
                        format.html
                        format.pdf do
                           pdf = MonthlyadvancePdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                           send_data pdf.render,:filename => "1_salary_advance_loan_report.pdf", :type => "application/pdf", :disposition => "inline"
                          end
                        end
                elsif  types == 'HEAL'
                    respond_to do |format|
                        format.html
                        format.pdf do
                           pdf = MonthlyhealthPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                           send_data pdf.render,:filename => "1_salary_health_report.pdf", :type => "application/pdf", :disposition => "inline"
                          end
                        end
                end
                
                
                elsif  docsid[2] == 'personal'
                types         = session[:my_sl_type]
                @voucherdata  =  print_sewadar_salary
                if types == 'BIO'
                    
                    respond_to do |format|
                        format.html
                        format.pdf do
                           pdf = BiodataPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                           send_data pdf.render,:filename => "1_personal_details_report.pdf", :type => "application/pdf", :disposition => "inline"
                        end
                     end

               elsif  types == 'CHARACTER'
                    respond_to do |format|
                        format.html
                        format.pdf do
                           pdf = CharPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                           send_data pdf.render,:filename => "1_character_certificate_report.pdf", :type => "application/pdf", :disposition => "inline"
                          end
                        end
               elsif  types == 'HINDICHARACTER'
                    respond_to do |format|
                        format.html
                        format.pdf do
                           pdf = CharhindiPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                           send_data pdf.render,:filename => "1_hindi_character_certificate_report.pdf", :type => "application/pdf", :disposition => "inline"
                          end
                        end
                    end
      end
end

end


def salary_register
  @compCodes         = session[:loggedUserCompCode]
  @nbegindate        = 2021
  @mydepartcode      = ''
  @HeadHrp           =  MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
  @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
  @familylisted      = total_sewadar_kyc_family(@compCodes)
  @printPath         = "reports/1_salary_register_report.pdf"
  @printExcelPath    = "reports/1_salary_excel_register.pdf"
  @ListDesignation   = Designation.where("compcode = ?",@compCodes).order("ds_description ASC")
  @BankList          = MstSewadarKycBank.where("skb_compcode =? AND skb_bank<>''", @compCodes).group("skb_bank").order("skb_bank ASC")
  if session[:autherizedUserType] && session[:autherizedUserType].to_s != 'adm'
   @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =? AND sw_depcode = ?",@compCodes,@mydepartcode)
  else
    @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =?",@compCodes)
 end
  
              
  
end



def salary_slip
  @compCodes         = session[:loggedUserCompCode]
  @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
  @nbegindate        = 2021
  @mydepartcode      = ''
  @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
  @familylisted      = total_sewadar_kyc_family(@compCodes)
  @printPath         =  "reports/1_salary_slip_report.pdf"
  @ListDesignation   = Designation.where("compcode = ?",@compCodes).order("ds_description ASC")
  
  if session[:autherizedUserType] && session[:autherizedUserType].to_s != 'adm'      
   @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =? AND sw_depcode = ?",@compCodes,@mydepartcode)
  else
    @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =?",@compCodes)
 end
  
end

def monthly_deduction
  @compCodes         = session[:loggedUserCompCode]
  @nbegindate        = 2021
  @mydepartcode      = ''
  @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
  @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
  @familylisted      = total_sewadar_kyc_family(@compCodes)
  @printPath         =  "reports/1_deduction_common_report.pdf"
  @ListDesignation   = Designation.where("compcode = ?",@compCodes).order("ds_description ASC")

  if session[:autherizedUserType] && session[:autherizedUserType].to_s != 'adm'
   @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =? AND sw_depcode = ?",@compCodes,@mydepartcode)
  else
    @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =?",@compCodes)
 end

end

def personal_details
  @compCodes         = session[:loggedUserCompCode]
  @nbegindate        = 2021
  @mydepartcode      = ''
  @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
  @familylisted      = total_sewadar_kyc_family(@compCodes)
  @printPath         =  "reports/1_list_personal_report.pdf"
  @ListDesignation   = Designation.where("compcode = ?",@compCodes).order("ds_description ASC")

  if session[:autherizedUserType] && session[:autherizedUserType].to_s != 'adm'
   @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =? AND sw_depcode = ?",@compCodes,@mydepartcode)
  else
    @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =?",@compCodes)
 end

end


def new_sewadar_user
  session[:request_processlogid] = nil
  redirect_to "#{root_url}sewadar_information/add_sewadar"
end
def create
  
end

def sewadar_info_grid
  
end

def ajax_process
  @compcodes  = session[:loggedUserCompCode]
  if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
    get_sewadar_info();
    return
  elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'DAILYRPT'
    get_attendance_performance();
    return
  end






end

private
def get_sewadar_info
  session[:my_sl_years]      = nil
  session[:my_sl_months]     = nil
  session[:my_sl_depart]     = nil
  session[:my_sl_category]   = nil
  session[:my_sl_refrence]   = nil
  session[:my_sl_searchstr]  = nil
  session[:my_sl_type]       = nil
  session[:print_excel_type] = nil
  session[:my_bankname]      = nil
  session[:my_bankname]      = nil
  years       = params[:years]
  months      = params[:months] !=nil && params[:months] != '' ? params[:months] : ''
  if months.to_s.length <2
    #months = "0"+months.to_s
  end

  sedep       = params[:sedep]
  sewcatg     = params[:sewcatg]
  refecoename = params[:refecoename]
  sewsearches = params[:sewsearches]
  sltype      = params[:sltype]
  bankname    = params[:bankname]
  mybanks     = false
  if params[:printtype] !=''  && params[:printtype] != nil
    session[:print_excel_type] = params[:printtype]
  end

  if months.to_i >=4 
     genfinalyear = years.to_s+"-"+(years.to_i+1).to_s
  else
     genfinalyear = (years.to_i-1).to_s+"-"+years.to_s
  end 
  iswhere = "pm_compcode ='#{@compcodes}' AND pm_financialyear='#{genfinalyear}'"
  if years !=nil && years !=''
    iswhere += " AND pm_payyear ='#{years}'"
    session[:my_sl_years] = years
  end
  if months !=nil && months !=''
    iswhere += " AND pm_paymonth ='#{months}'"
    session[:my_sl_months] = months
  end
  if sedep !=nil && sedep !=''
    iswhere += " AND sw_depcode ='#{sedep}'"
     session[:my_sl_depart] = sedep
  end
  if sewcatg !=nil && sewcatg !=''
    iswhere += " AND sw_catgeory ='#{sewcatg}'"
    session[:my_sl_category] = sewcatg
  end
  if bankname !=nil && bankname !=''
    if bankname.to_s == 'oth'
      iswhere += " AND REPLACE(LOWER(skb_bank),' ','') !='bankofindia' AND REPLACE(LOWER(skb_bank),' ','') !='punjabnationalbank'"   
    else
      iswhere += " AND REPLACE(LOWER(skb_bank),' ','') =REPLACE(LOWER('#{bankname}'),' ','')"  
    end    
    session[:my_bankname] = bankname
    mybanks = true
  end
  if refecoename !=nil && refecoename !=''
      session[:my_sl_refrence] = refecoename
      if sewsearches !=nil && sewsearches !=''
        session[:my_sl_searchstr] = sewsearches

            if refecoename == 'mycode'
             iswhere += " AND pm_sewacode ='#{sewsearches}'"
           elsif refecoename == 'myrefcode'
             iswhere += " AND sw_oldsewdarcode ='#{sewsearches}'"
           elsif refecoename == 'myname'
             iswhere += " AND sw_sewadar_name LIKE '%#{sewsearches}%'"
           elsif refecoename == 'mymobile'
             iswhere += " AND sw_mobile ='#{sewsearches}'"
           elsif refecoename == 'myemail'
             iswhere += " AND sw_email ='#{sewsearches}'"
           end
      end
  end
  
  if sltype !=nil && sltype !='' && sltype =='LIC'
       session[:my_sl_type]  = sltype
       iswhere += " AND ( pm_ded_licemployee > 0 OR  pm_licemployer >0 )"
  elsif sltype !=nil && sltype !='' && sltype =='BUILD'
       session[:my_sl_type]  = sltype
       iswhere += " AND ( pm_dedaccomodatamount >0 )"
  elsif sltype !=nil && sltype !='' && sltype =='ELEC'
       session[:my_sl_type]  = sltype
       iswhere += " AND ( pm_ded_electricamount >0 )"
  elsif sltype !=nil && sltype !='' && sltype =='ADVL'
       session[:my_sl_type]  = sltype
       iswhere += " AND ( pm_ded_repaidadvance > 0 OR  pm_ded_repaidloan >0 )"
  elsif sltype !=nil && sltype !='' && sltype =='HEAL'
       session[:my_sl_type]  = sltype
       iswhere += " AND ( pm_ded_healthmandalpay > 0 OR  pm_ded_healthsewdarpay >0 )"
  
  elsif sltype !=nil && sltype !='' && sltype =='BIO'
       session[:my_sl_type]  = sltype       
        elsif sltype !=nil && sltype !='' && sltype =='CHARACTER'
        session[:my_sl_type]  = sltype
       
       elsif sltype !=nil && sltype !='' && sltype =='HINDICHARACTER'
       session[:my_sl_type]  = sltype
       
  end
  
  isflags   = false
  message   = ""
  isselect  = "trn_pay_monthlies.*,sewa.id as sewid,sw_sewadar_name,sw_father_name"
  jons      = " LEFT JOIN mst_sewadars sewa ON( sw_compcode = pm_compcode AND sw_sewcode = pm_sewacode)"
  if mybanks
    isselect += ",bnk.id as banks"
    jons     += " LEFT JOIN mst_sewadar_kyc_banks bnk ON( skb_compcode = pm_compcode AND sbk_sewcode = pm_sewacode)"    
  end
  pmsobj    = TrnPayMonthly.select(isselect).joins(jons).where(iswhere).order("pm_sewacode ASC")
  if pmsobj.length >0
    isflags = true
    message ="Success"
  end
  respond_to do |format|
    format.json { render :json => { 'data'=>'', "message"=>message,:status=>isflags} }
  end
end


private
def print_sewadar_salary
  years       = session[:my_sl_years]
  months      = session[:my_sl_months]
  sedep       = session[:my_sl_depart]
  sewcatg     = session[:my_sl_category]
  refecoename = session[:my_sl_refrence]
  sewsearches = session[:my_sl_searchstr]
  sltype      = session[:my_sl_type]
  bankname   =  session[:my_bankname]
  
  if session[:print_excel_type] == 'DT'
    iswhere = "pm_compcode ='#{@compcodes}' AND pm_netpay >0 AND pm_hold<>'Y'"
  else
    iswhere = "pm_compcode ='#{@compcodes}' AND pm_hold<>'Y'"
  end
  if years !=nil && years !=''
    iswhere += " AND pm_payyear ='#{years}'"
  end
 
  if months !=nil && months !=''
    iswhere += " AND pm_paymonth ='#{months}'"
  end
 # sedep= "DPT0008"
  if sedep !=nil && sedep !=''
    iswhere += " AND sw_depcode ='#{sedep}'"
  end
  if sewcatg !=nil && sewcatg !=''
    iswhere += " AND sw_catgeory ='#{sewcatg}'"
  end
  if bankname !=nil && bankname !=''
    
    if bankname.to_s == 'oth'
      iswhere += " AND pm_netpay >0 AND REPLACE(LOWER(skb_bank),' ','') !='bankofindia' AND REPLACE(LOWER(skb_bank),' ','') !='punjabnationalbank'"   
    else
      iswhere += " AND pm_netpay >0 AND REPLACE(LOWER(skb_bank),' ','') =REPLACE(LOWER('#{bankname}'),' ','')"   
    end
     
   
  end

 

  if refecoename !=nil && refecoename !=''
    if sewsearches !=nil && sewsearches !=''
        if refecoename == 'mycode'
         iswhere += " AND pm_sewacode ='#{sewsearches}'"
       elsif refecoename == 'myrefcode'
         iswhere += " AND sw_oldsewdarcode ='#{sewsearches}'"
       elsif refecoename == 'myname'
         iswhere += " AND sw_sewadar_name LIKE '%#{sewsearches}%'"
       elsif refecoename == 'mymobile'
         iswhere += " AND sw_mobile ='#{sewsearches}'"
       elsif refecoename == 'myemail'
         iswhere += " AND sw_email ='#{sewsearches}'"
       end
    end
  end
  if sltype !='' && sltype !=nil && sltype == 'LIC'
       iswhere += " AND ( pm_ded_licemployee > 0 OR  pm_licemployer >0 )"
  elsif sltype !=nil && sltype !='' && sltype =='BUILD'
       iswhere += " AND ( pm_dedaccomodatamount >0 )"
  elsif sltype !=nil && sltype !='' && sltype =='ELEC'
       iswhere += " AND ( pm_ded_electricamount >0 )"
  elsif sltype !=nil && sltype !='' && sltype =='ADVL'
       iswhere += " AND ( pm_ded_repaidadvance > 0 OR  pm_ded_repaidloan >0 )"
  elsif sltype !=nil && sltype !='' && sltype =='HEAL'
       iswhere += " AND ( pm_ded_healthmandalpay > 0 OR  pm_ded_healthsewdarpay >0 )"
  end
  arrpms    = []
  
  


  # if session[:print_excel_type] == 'BK' || session[:print_excel_type] == 'CT' || session[:print_excel_type] == 'DT'
  #   jons      += " LEFT JOIN trn_process_monthly_advances avs ON( pma_compcode = pm_compcode AND pma_sewacode = pm_sewacode AND pma_month='#{months}' AND pma_year='#{years}' )"
  #   isselect  =  "pm_sewacode,sw_depcode,sw_desigcode,pm_payyear,pm_paymonth,SUM(pm_workingday) as pm_workingday,SUM(pm_paidleave) as pm_paidleave,SUM(pm_hl) as pm_hl,SUM(pm_wo) as pm_wo,SUM(pm_absent) as pm_absent"
  #   isselect  += ",SUM(pm_actbasic) as pmactbasic,SUM(pm_arear) as pmarear,SUM(pm_basic) as pmbasic,SUM(pm_ded_licemployee) as pmdedlicemployee,SUM(pm_dedaccomodatamount) as pmdedaccomodatamount"
  #   isselect  += ",SUM(pm_ded_electricamount) as pmdedelectricamount,SUM(pm_ded_healthsewdarpay) as pmdedhealthsewdarpay,SUM(pm_totaltds) as pmincometaxamount,SUM(pm_totaldeduction) as pmtotaldeduction,SUM(pm_netpay) as pmnetpay"
  #   isselect  += ",'' as deprtment,'' as designation,'' as bankname,'' as ifscode,'' as statename,sw_depcode,sw_desigcode"
  #   #isselect  += ", '' as uptosixty,'' as abovesixty,'' as exgratia,'' as maadvance,'' as wheatadvance,'' as specialadvance"

  #   isselect  += ",(CASE WHEN UPPER(pma_type) =UPPER('Loan') THEN SUM(pma_installment) ELSE 0 END) as uptosixty"
  #   isselect  += ",(CASE WHEN UPPER(pma_type) =UPPER('Advance Above 60k') THEN SUM(pma_installment) ELSE 0 END) as abovesixty"
  #   isselect  += ",(CASE WHEN UPPER(pma_type) =UPPER('Advance') THEN SUM(pma_installment) ELSE 0 END) as maadvance"
  #   isselect  += ",(CASE WHEN UPPER(pma_type) =UPPER('Special Advance') THEN SUM(pma_installment) ELSE 0 END) as specialadvance"
  #   isselect  += ",(CASE WHEN UPPER(pma_type) =UPPER('Wheat Advance') THEN SUM(pma_installment) ELSE 0 END) as wheatadvance"
  # else
  #   isselect  = "trn_pay_monthlies.*,sewa.id as sewid,sw_sewadar_name,sw_father_name,sw_joiningdate,sw_oldsewdarcode"
  #   isselect  += ",'' as deprtment,'' as designation,'' as bankaccount,'' as bankname,'' as ifscode,'' as statename,sw_depcode,sw_desigcode"
  #   isselect  += ", '' as pmactbasic,'' as pmarear,'' as pmbasic,'' as pmdedlicemployee,'' as pmdedaccomodatamount ,'' as pmdedelectricamount,'' as pmdedrepaidadvance,'' as pmdedrepaidloan "
  #   isselect  += ", '' as pmdedhealthsewdarpay,'' as pmincometaxamount,'' as pmtotaldeduction,'' as pmnetpay"
  #   isselect  += ", '' as uptosixty,'' as abovesixty,'' as exgratia,'' as maadvance,'' as wheatadvance,'' as specialadvance"
  #   isselect  += ", sw_catgeory as categoryname,sw_catcode "
  # end

  # if session[:print_excel_type] == 'BK'
  #   isselect  += ",skb_accountno as bankaccount ,bk.id as catId"
  #   jons      += "JOIN mst_sewadar_kyc_banks bk ON( skb_compcode = pm_compcode AND sbk_sewcode = pm_sewacode)"
  #   pmsobj    = TrnPayMonthly.select(isselect).joins(jons).where(iswhere).group("skb_accountno").order("skb_accountno ASC")
  # elsif session[:print_excel_type] == 'CT'
  #   isselect  += ", sc_name as categoryname,cat.id as catId,'' as bankaccount,'' as department"
  #   jons      += " LEFT JOIN mst_sewadar_categories cat ON( sc_compcode = pm_compcode AND sc_catcode = sw_catcode)"
  #   pmsobj    = TrnPayMonthly.select(isselect).joins(jons).where(iswhere).group("sc_catcode").order("sc_name ASC") 
  # elsif session[:print_excel_type] == 'DT'
  #   isselect  += ", departDescription as department,dpt.id as catId,'' as bankaccount,'' as categoryname"
  #   jons      += " LEFT JOIN departments dpt ON( compCode = pm_compcode AND departCode = sw_depcode)"
  #   pmsobj    = TrnPayMonthly.select(isselect).joins(jons).where(iswhere).group("sw_depcode").order("departDescription ASC")    
  # else
  #   pmsobj    = TrnPayMonthly.select(isselect).joins(jons).where(iswhere).order("pm_sewacode ASC")
  # end

  if session[:print_excel_type] == 'DT'
   #jons      += " LEFT JOIN trn_process_monthly_advances avs ON( pma_compcode = pm_compcode AND pma_sewacode = pm_sewacode AND pma_month='#{months}' AND pma_year='#{years}' )"
      jons      = " JOIN mst_sewadars sewa ON( sw_compcode = pm_compcode AND sw_sewcode = pm_sewacode)"   
      isselect  =  "sw_depcode,SUM(pm_workingday) as pm_workingday,SUM(pm_paidleave) as pm_paidleave,SUM(pm_hl) as pm_hl,SUM(pm_wo) as pm_wo,SUM(pm_absent) as pm_absent"
      isselect  += ",SUM(pm_actbasic) as pmactbasic,SUM(pm_arear) as pmarear,SUM(pm_basic) as pmbasic,SUM(pm_ded_licemployee) as pmdedlicemployee,SUM(pm_dedaccomodatamount) as pmdedaccomodatamount"
      isselect  += ",SUM(pm_ded_electricamount) as pmdedelectricamount,SUM(pm_ded_healthsewdarpay) as pmdedhealthsewdarpay,SUM(pm_totaltds) as pmincometaxamount,SUM(pm_totaldeduction) as pmtotaldeduction,SUM(pm_netpay) as pmnetpay,'' as totaldepart"
      isselect  += ",(SUM(pm_ded_repaidadvance)+SUM(pm_ded_repaidloan)) as refundamt,'' as deprtment,'' as designation,'' as bankname,'' as ifscode,'' as statename,sw_depcode,sw_desigcode,'' as totalboibank,'' as totalpnbbank,'' as totalpothersbank"
      isselect  += ",SUM(pm_allowancefirst) as allowance1,SUM(pm_allowancesecond) as allowance2,SUM(pm_dedfirst) as deduction1,SUM(pm_dedsecond) as deduction2"
      # isselect  += ",( CASE WHEN REPLACE(LOWER(skb_bank),' ','')='bankofindia' THEN SUM(pm_netpay) else 0 END ) as totalboibank  " 
      # isselect  += ",( CASE WHEN REPLACE(LOWER(skb_bank),' ','')='punjabnationalbank' THEN SUM(pm_netpay) else 0 END ) as totalpnbbank  " 
    
      #isselect  +=",(SELECT SUM(pm_netpay)  FROM trn_pay_monthlies LEFT JOIN mst_sewadar_kyc_banks bnks ON( skb_compcode = pm_compcode AND sbk_sewcode = pm_sewacode) where #{iswhere} AND REPLACE(LOWER(skb_bank),' ','') !='punjabnationalbank' AND REPLACE(LOWER(skb_bank),' ','') !='bankofindia' ) as totalpothersbank"
      #isselect  +=",(SELECT SUM(pm_netpay)  FROM trn_pay_monthlies LEFT JOIN mst_sewadar_kyc_banks bnks ON( skb_compcode = pm_compcode AND sbk_sewcode = pm_sewacode) where #{iswhere} AND REPLACE(LOWER(skb_bank),' ','') ='bankofindia' ) as totalboibank"
      # isselect  += ",( CASE WHEN REPLACE(LOWER(skb_bank),' ','') !='punjabnationalbank' THEN SUM(pm_netpay)
      #                  WHEN REPLACE(LOWER(skb_bank),' ','') !='bankofindia' THEN SUM(pm_netpay) 
      #                 ELSE
      #                     0
      #                  END 
      #                  ) as totalpothersbank  " 
    isselect  += ",'' as deprtment,'' as designation,'' as bankaccount,'' as bankname,'' as ifscode,'' as statename"
      #isselect  += ", '' as uptosixty,'' as abovesixty,'' as exgratia,'' as maadvance,'' as wheatadvance,'' as specialadvance"
  
   else
      jons      = " JOIN mst_sewadars sewa ON( sw_compcode = pm_compcode AND sw_sewcode = pm_sewacode)"
      isselect  = "trn_pay_monthlies.*,sewa.id as sewid,sw_sewadar_name,sw_father_name,sw_joiningdate,sw_oldsewdarcode"
      isselect  += ",'' as deprtment,'' as designation,'' as bankaccount,'' as bankname,'' as ifscode,'' as statename,sw_depcode,sw_desigcode"
      isselect  += ", '' as pmactbasic,pm_fixarear as pmarear,'' as pmbasic,'' as pmdedlicemployee,'' as pmdedaccomodatamount ,'' as pmdedelectricamount,'' as pmdedrepaidadvance,'' as pmdedrepaidloan "
      isselect  += ", '' as pmdedhealthsewdarpay,'' as pmincometaxamount,'' as pmtotaldeduction,'' as pmnetpay"
      isselect  += ", '' as uptosixty,'' as abovesixty,'' as exgratia,'' as maadvance,'' as wheatadvance,'' as specialadvance"
      isselect  += ", sw_catgeory as categoryname,sw_catcode,'' as totaldepart,pm_ded_electricamount as pmdedelectricamount "
      isselect  += ",pm_allowancefirst as allowance1,pm_allowancesecond as allowance2,pm_dedfirst as deduction1,pm_dedsecond as deduction2"
  end

  if bankname !=nil && bankname != '' || session[:print_excel_type] == 'DT'   
     
      jons   += " LEFT JOIN mst_sewadar_kyc_banks bnk ON( skb_compcode = pm_compcode AND sbk_sewcode = pm_sewacode)"
  end


  if bankname !=nil && bankname !='' || sltype.to_s == 'DT' 
     isselect  += ", skb_bank,skb_branch,skb_address,skb_accountno,skb_ifccocde "
  end
  if session[:print_excel_type] == 'DT'
   
      pmsobj = TrnPayMonthly.select(isselect).joins(jons).where(iswhere).group("sw_depcode").order("pm_sewacode ASC")
  else
      pmsobj = TrnPayMonthly.select(isselect).joins(jons).where(iswhere).order("pm_sewacode ASC")
  end
  
  
  if pmsobj.length >0
      TrnTempSalaryRegister.all.destroy_all
        @ExcelList = pmsobj
        pmsobj.each do |newsalry|    

                    bankaccount  = ""
                    deprtment    = ""
                    bankname     = ""
                    sdpobj = get_all_department_detail(newsalry.sw_depcode)
                    if sdpobj
                       newsalry.deprtment = deprtment = sdpobj.departDescription
                    end
                    
                    newsalry.totaldepart     = get_department_counts(newsalry.sw_depcode)
                    if session[:print_excel_type] == 'DT'
                      newsalry.totalboibank      =  process_department_banks(@compcodes,newsalry.sw_depcode,'boi', months,years)
                      newsalry.totalpnbbank      =  process_department_banks(@compcodes,newsalry.sw_depcode,'pnb', months,years)
                      newsalry.totalpothersbank  =  process_department_banks(@compcodes,newsalry.sw_depcode,'oth', months,years)
                    else
                    bksobj       = get_sewadar_kyc_bankdetail(@compcodes,newsalry.pm_sewacode)
                    if bksobj
                        newsalry.bankaccount  = bankaccount = bksobj.skb_accountno
                        newsalry.bankname     = bankname = bksobj.skb_bank
                        newsalry.ifscode      = bksobj.skb_ifccocde                  
                    end
                   
                    #,'' as totalboibank,'' as totalpnbbank,'' as totalpothersbank
                   

                    
                    desobj = get_sewdar_designation_detail(newsalry.sw_desigcode)
                    if desobj
                        newsalry.designation = desobj.ds_description
                    end
                    sewinfobj = get_personal_information(@compcodes,newsalry.pm_sewacode)

                    if sewinfobj
                        statecpde   = sewinfobj.sp_pres_state
                        if statecpde !=nil && statecpde !=''
                            stsnonj = get_state_detail(statecpde)
                            if stsnonj
                              newsalry.statename = stsnonj.sts_description
                            end
                        end
                    end

                  end
                    if session[:print_excel_type] == 'SR' #|| session[:print_excel_type] == 'DT' #|| session[:print_excel_type] == 'BK'  
                        uptosixty      = advance_transaction_list(newsalry.pm_sewacode,'Loan',newsalry.pm_paymonth,newsalry.pm_payyear)
                        abovesixty     = advance_transaction_list(newsalry.pm_sewacode,'Advance Above 60k',newsalry.pm_paymonth,newsalry.pm_payyear)
                        exgratia       = advance_transaction_list(newsalry.pm_sewacode,'Ex-gratia',newsalry.pm_paymonth,newsalry.pm_payyear)
                        maadvance      = advance_transaction_list(newsalry.pm_sewacode,'Advance',newsalry.pm_paymonth,newsalry.pm_payyear)
                        wheatadvance   = advance_transaction_list(newsalry.pm_sewacode,'Wheat Advance',newsalry.pm_paymonth,newsalry.pm_payyear)
                        specialadvance = advance_transaction_list(newsalry.pm_sewacode,'Special Advance',newsalry.pm_paymonth,newsalry.pm_payyear)
                          
                          process_to_insert_data(newsalry.pm_sewacode,newsalry.sw_sewadar_name,newsalry.categoryname,deprtment,bankaccount,newsalry.pm_workingday,newsalry.pm_paidleave,newsalry.pm_hl,newsalry.pm_wo,newsalry.pm_absent,newsalry.pm_actbasic,newsalry.pmarear,newsalry.pm_basic,newsalry.pm_ded_licemployee,newsalry.pm_dedaccomodatamount,newsalry.pm_ded_electricamount,uptosixty,abovesixty,maadvance,specialadvance,wheatadvance,newsalry.pm_ded_healthsewdarpay,newsalry.pm_totaltds,newsalry.pm_totaldeduction,newsalry.pm_netpay,newsalry.sw_catcode,newsalry.sw_depcode, newsalry.allowance1,newsalry.allowance2,newsalry.deduction1,newsalry.deduction2) 
                    end
                  arrpms.push newsalry
                       
                    
           end
  end
  return arrpms
  
end

private
def process_to_insert_data(pm_sewacode,sw_sewadar_name,categoryname,deprtment,bankaccount,pm_workingday,pm_paidleave,pm_hl,pm_wo,pm_absent,pmactbasic,pmarear,pmbasic,pmdedlicemployee,pmdedaccomodatamount,pmdedelectricamount,uptosixty,abovesixty,maadvance,specialadvance,wheatadvance,pmdedhealthsewdarpay,pmincometaxamount,pmtotaldeduction,pmnetpay,catcode,departcode,allowance1,allowance2,deduction1,deduction2)
  uptosixty       = uptosixty !=nil && uptosixty !='' ? uptosixty : 0
  abovesixty      = abovesixty !=nil && abovesixty !='' ? abovesixty : 0
  maadvance       = maadvance !=nil && maadvance !='' ? maadvance : 0
  specialadvance  = specialadvance !=nil && specialadvance !='' ? specialadvance : 0
  wheatadvance    = wheatadvance !=nil && wheatadvance !='' ? wheatadvance : 0 
  allowance1      = allowance1 !=nil && allowance1 !='' ? allowance1 : 0
  allowance2      = allowance2 !=nil && allowance2!='' ? allowance2 : 0
  deduction1      = deduction1 !=nil && deduction1 !='' ? deduction1 : 0
  deduction2      = deduction2 !=nil && deduction2 !='' ? deduction2 : 0
  #,:allowance1=>allowance1,:allowance2=>allowance2,:deduction1=>deduction1,:deduction2=>deduction2
  chekinstobj = TrnTempSalaryRegister.new(:pm_sewacode=>pm_sewacode,:sw_sewadar_name=>sw_sewadar_name,:categoryname=>categoryname,:deprtment=>deprtment,:bankaccount=>bankaccount,:pm_workingday=>pm_workingday,:pm_paidleave=>pm_paidleave,:pm_hl=>pm_hl,:pm_wo=>pm_wo,:pm_absent=>pm_absent,:pmactbasic=>pmactbasic,:pmarear=>pmarear,:pmbasic=>pmbasic,:pmdedlicemployee=>pmdedlicemployee,:pmdedaccomodatamount=>pmdedaccomodatamount,:pmdedelectricamount=>pmdedelectricamount,:uptosixty=>uptosixty,:abovesixty=>abovesixty,:maadvance=>maadvance,:specialadvance=>specialadvance,:wheatadvance=>wheatadvance,:pmdedhealthsewdarpay=>pmdedhealthsewdarpay,:pmincometaxamount=>pmincometaxamount,:pmtotaldeduction=>pmtotaldeduction,:pmnetpay=>pmnetpay,:catcode=>catcode,:departcode=>departcode,:allowance1=>allowance1,:allowance2=>allowance2,:deduction1=>deduction1,:deduction2=>deduction2)
    if chekinstobj.save
        ### execute message
    end
end

def process_department_banks(compcode,dpcode,type,months,years)
  totals  = 0
  if type == 'boi'
     iswhere = "pm_compcode ='#{compcode}'  AND pm_netpay >0 AND pm_payyear ='#{years}' AND pm_paymonth ='#{months}' AND REPLACE(LOWER(skb_bank),' ','')='bankofindia' AND sw_depcode='#{dpcode}'"
  elsif type == 'pnb'
    iswhere = "pm_compcode ='#{compcode}' AND pm_netpay >0  AND pm_payyear ='#{years}' AND pm_paymonth ='#{months}'AND REPLACE(LOWER(skb_bank),' ','')='punjabnationalbank' AND sw_depcode='#{dpcode}'"
  else
    iswhere = "pm_compcode ='#{compcode}' AND pm_netpay >0  AND pm_payyear ='#{years}' AND pm_paymonth ='#{months}' AND REPLACE(LOWER(skb_bank),' ','') NOT IN('bankofindia','punjabnationalbank') AND sw_depcode='#{dpcode}'"
  end
  jons    = " LEFT JOIN mst_sewadars sewa ON( sw_compcode = pm_compcode AND sw_sewcode = pm_sewacode)"  
  jons   += " LEFT JOIN mst_sewadar_kyc_banks bnk ON( skb_compcode = pm_compcode AND sbk_sewcode = pm_sewacode)"
  isselect = "SUM(pm_netpay) as total"
  pmsobj   = TrnPayMonthly.select(isselect).joins(jons).where(iswhere).first
  if pmsobj
    totals = pmsobj.total
  end
  return totals
end

private
def get_salary_slip_register(type)
    isselect  =  "pm_sewacode,departcode as sw_depcode,'' as sw_desigcode,'' as pm_payyear,'' as pm_paymonth,SUM(pm_workingday) as pm_workingday,SUM(pm_paidleave) as pm_paidleave,SUM(pm_hl) as pm_hl,SUM(pm_wo) as pm_wo,SUM(pm_absent) as pm_absent"
    isselect  += ",SUM(pmactbasic) as pmactbasic,SUM(pmarear) as pmarear,SUM(pmbasic) as pmbasic,SUM(pmdedlicemployee) as pmdedlicemployee,SUM(pmdedaccomodatamount) as pmdedaccomodatamount,bankaccount"
    isselect  += ",SUM(pmdedelectricamount) as pmdedelectricamount,SUM(pmdedhealthsewdarpay) as pmdedhealthsewdarpay,SUM(pmincometaxamount) as pmincometaxamount,SUM(pmtotaldeduction) as pmtotaldeduction,SUM(pmnetpay) as pmnetpay"
    isselect  += ", SUM(uptosixty) as uptosixty,SUM(abovesixty)  as abovesixty,SUM(maadvance) as maadvance,SUM(wheatadvance) as wheatadvance,SUM(specialadvance) as specialadvance"
    isselect  += ",categoryname,deprtment as department"
    if type == 'BK'
      chekinstobj = TrnTempSalaryRegister.select(isselect).all.group("bankaccount").order("bankaccount")
    elsif type == 'DT'
      chekinstobj = TrnTempSalaryRegister.select(isselect).all.group("sw_depcode").order("deprtment")   
    elsif type == 'CT'
      chekinstobj = TrnTempSalaryRegister.select(isselect).all.group("catcode").order("categoryname")   
    else
      chekinstobj = TrnTempSalaryRegister.all.order("sw_sewadar_name ASC")
    end
    return chekinstobj

end

private
def get_department_counts(departcode)
  
       compcode  =  session[:loggedUserCompCode]
       mycounts  = 0
       sewdarobj =  MstSewadar.select("COUNT(sw_depcode) as totaldepartment").where("sw_compcode =? AND sw_depcode =?",compcode,departcode).first
       if sewdarobj
          mycounts = sewdarobj.totaldepartment
       end
       return mycounts
end

private
def get_sewdara_inofrmation_first(sewcode)
       compcode  = session[:loggedUserCompCode]
       sewdarobj =  MstSewadar.select("sw_depcode").where("sw_compcode =? AND sw_sewcode =?",compcode,sewcode).first
       return sewdarobj
end

private
def get_personal_information(compcode,empcode)
       sewdarobj =  MstSewadarPersonalInfo.where("sp_compcode =? AND sp_sewcode =?",compcode,empcode).first
       return sewdarobj
end

private
def get_office_information(compcode,empcode)
       sewdarobj =  MstSewadarOfficeInfo.where("so_compcode =? AND so_sewcode =?",compcode,empcode).first
       return sewdarobj
end

 private
def get_roles_information(compcode,rspcode)
       sewdarobj =  MstResponsibility.where("rsp_compcode =? AND rsp_rspcode =?",compcode,rspcode).first
       return sewdarobj
end

private
def get_sewadar_kyc_information(compcode,sewcode)
     sewdarobj =  MstSewadarKyc.where("sk_compcode =? AND sk_sewcode =?",compcode,sewcode).first
     return sewdarobj
end
private
def get_sewadar_kyc_bankdetail(compcode,sewcode)
     sewdarobj =  MstSewadarKycBank.where("skb_compcode =? AND sbk_sewcode =?",compcode,sewcode).first
     return sewdarobj
end

private
def get_sewadar_kyc_qualification(compcode,sewcode)
     arritem   = []
     isselct   = "mst_sewadar_kyc_qualifications.*,'' as universityboard,'' as  degreedip"
     sewdarobj = MstSewadarKycQualification.select(isselct).where("skq_compcode =? AND skq_sewcode = ?",compcode,sewcode).order("skq_passingyear ASC")
     if sewdarobj.length >0
       sewdarobj.each do |qualif|
           unobj =   get_name_global_university(qualif.skq_universityboard)
           if unobj
             qualif.universityboard = unobj.un_description
           end
           qlfobj = get_name_global_qualification(qualif.skq_degreedip)
           if qlfobj
             qualif.degreedip  = qlfobj.ql_qualdescription
           end
           arritem.push qualif
       end
        
     end
     return arritem
end

private
def get_sewadar_kyc_family(compcode,sewcode)      
     isselect  = "mst_sewdar_kyc_family_details.*,DATE_FORMAT(skf_datebirth,'%d/%m/%Y') as bdate1"
     sewdarobj =  MstSewdarKycFamilyDetail.select(isselect).where("skf_compcode =? AND skf_sewcode =?",compcode,sewcode).order("skf_dependent ASC")
     return sewdarobj
end

private
def total_sewadar_kyc_family(compcode)
     isselect  = "mst_sewdar_kyc_family_details.*,DATE_FORMAT(skf_datebirth,'%d/%m/%Y') as bdate1"
     sewdarobj =  MstSewdarKycFamilyDetail.select(isselect).where("skf_compcode =?",compcode).group("skf_dependent").order("skf_dependent ASC")
     return sewdarobj
end

private
def get_sewadar_work_experience(compcode,sewcode)
     sewdarobj =  MstSewadarWorkExperience.where("swe_compcode =? AND swe_sewcode =?",compcode,sewcode).order("swe_employer ASC")
     return sewdarobj
end

###########ATTENDANCE REPORTS #################

###############ATTENDANCE REPORT #################################
private
  def get_attendance_performance

    session[:at_reqtype]       = nil 
    session[:atreq_fromattend] = nil
    session[:atreq_uptoattend] = nil
    session[:atreq_empattend]  = nil
    session[:atreq_empdept]    = nil
    session[:atreq_location]   = nil
    frmbegindated  = params[:from_date] !=nil  && params[:from_date] != '' ? year_month_days_formatted(params[:from_date]) : ''
    enddated       = params[:upto_date] !=nil  && params[:upto_date] != '' ? year_month_days_formatted(params[:upto_date]) : ''
    emplid         = params[:empcodes] !=nil && params[:empcodes] != ''  ? params[:empcodes] : ''
    empdpt         = params[:department] !=nil && params[:department] !='' ? params[:department] : ''
    loc            = params[:location] !=nil && params[:location] !='' ? params[:location] : ''
    type           = params[:types] !=nil && params[:types] !='' ? params[:types] : ''


    iswhere        = "al_compcode='#{@compcodes}'"
      if type !=nil && type !=''
        session[:at_reqtype] = type
      end
      if frmbegindated !=nil && frmbegindated !=''
        iswhere  += " AND al_trandate ='#{frmbegindated}'"

        session[:atreq_fromattend] = frmbegindated
        
      end
      # if enddated !=nil && enddated !=''
      #   iswhere  += " AND al_trandate <='#{enddated}'"
      #   session[:atreq_uptoattend] = enddated
       
      # end
      isflags = false
      istatus = false
      if emplid !=nil && emplid !=''
          iswhere  += " AND al_empcode ='#{emplid}'"
          session[:atreq_empattend]  = emplid
          isflags = true
      end
      if empdpt !=nil && empdpt !=''
          iswhere  += " AND sw_depcode ='#{empdpt}'"
          session[:atreq_empdept] = empdpt
          isflags = true        
      end
      if loc !=nil && loc !=''
          iswhere  += " AND sw_location ='#{loc}'"
          session[:atreq_location] = loc
          isflags = true        
      end
      if type == 'ARV'
        iswhere += " AND al_arrtime != 0 AND al_arrtime != '' "
        isflags = true
      end

      message = ""
        jons     = " LEFT JOIN mst_sewadars emp ON(sw_compcode = al_compcode AND sw_sewcode = al_empcode)"
        attndobj = TrnAttendanceList.joins(jons).where(iswhere).order("al_trandate ASC,al_empcode ASC")
        if attndobj.length >0
          istatus = true
          message ="success"
        end 
        
        respond_to do |format|
          format.json { render :json => { 'data'=>'', "message"=>message,:status=>istatus} }
        end

       
  end


  private
  def get_arrival_detail

    session[:at_reqtype]       = nil 
    session[:atreq_fromattend] = nil
    session[:atreq_uptoattend] = nil
    session[:atreq_empattend]  = nil
    session[:atreq_empdept]    = nil
    session[:atreq_location]   = nil

    frmbegindated  = params[:from_date] !=nil  && params[:from_date] != '' ? year_month_days_formatted(params[:from_date]) : ''
    enddated       = params[:upto_date] !=nil  && params[:upto_date] != '' ? year_month_days_formatted(params[:upto_date]) : ''
    emplid         = params[:empcodes] !=nil && params[:empcodes] != ''  ? params[:empcodes] : ''
    empdpt         = params[:department] !=nil && params[:department] !='' ? params[:department] : ''
    loc            = params[:location] !=nil && params[:location] !='' ? params[:location] : ''
    type           = params[:types] !=nil && params[:types] !='' ? params[:types] : ''
   



    iswhere        = "al_compcode='#{@compcodes}'"
      if type !=nil && type !=''
        session[:at_reqtype] = type
      end
      if frmbegindated !=nil && frmbegindated !=''
        iswhere  += " AND al_trandate ='#{frmbegindated}'"

        session[:atreq_fromattend] = frmbegindated
        
      end
      # if enddated !=nil && enddated !=''
      #   iswhere  += " AND al_trandate <='#{enddated}'"
      #   session[:atreq_uptoattend] = enddated
       
      # end
      isflags = false
      istatus = false
      if emplid !=nil && emplid !=''
          iswhere  += " AND al_empcode ='#{emplid}'"
          session[:atreq_empattend]  = emplid
          isflags = true
      end
      if empdpt !=nil && empdpt !=''
          iswhere  += " AND sw_depcode ='#{empdpt}'"
          session[:atreq_empdept] = empdpt
          isflags = true        
      end
      if loc !=nil && loc !=''
          iswhere  += " AND sw_location ='#{loc}'"
          session[:atreq_location] = loc
          isflags = true        
      end
   

      message = ""
        jons     = " LEFT JOIN mst_sewadars emp ON(sw_compcode = al_compcode AND sw_sewcode = al_empcode)"
        attndobj = TrnAttendanceList.joins(jons).where(iswhere).order("al_trandate ASC,al_empcode ASC")
        if attndobj.length >0
          istatus = true
          message ="success"
        end 
        
        respond_to do |format|
          format.json { render :json => { 'data'=>'', "message"=>message,:status=>istatus} }
        end

       
  end

  private
  def print_attendance_list
    frmbegindated  = year_month_days_formatted(session[:atreq_fromattend])
    enddated       = ''
    emplid         = session[:atreq_empattend]
    empdpt         = session[:atreq_empdept]
    loc            = session[:atreq_location]
    type           = session[:at_reqtype]

    iswhere        = "al_compcode ='#{@compcodes}'"
      if frmbegindated !=nil && frmbegindated !=''
        iswhere  += " AND al_trandate ='#{frmbegindated}'"       
      end
      # if enddated !=nil && enddated !=''
      #   iswhere  += " AND al_trandate <='#{enddated}'"
      #   session[:atreq_uptoattend] = enddated       
      # end
      isflags = false
      if emplid !=nil && emplid !=''
        iswhere  += " AND al_empcode ='#{emplid}'"        
        isflags = true
      end
      if empdpt !=nil && empdpt !=''
        iswhere  += " AND sw_depcode ='#{empdpt}'"       
        isflags = true        
      end
      if type == 'ARV'
        iswhere += "AND al_arrtime != 0 AND al_arrtime != '' "
        isflags = true
      elsif type == 'OVT'
          iswhere += "AND al_overtime >0 "
          isflags = true
      end
      if loc !=nil && loc !=''
        iswhere  += " AND sw_location ='#{loc}'"        
        isflags = true        
    end
     arritem = []
        iselect  = "trn_attendance_lists.*,sw_sewadar_name,sw_depcode,sw_location,sw_joiningdate,emp.id as empsId,'' as mydepartment,'' as location"
        jons     = " LEFT JOIN mst_sewadars emp ON(sw_compcode = al_compcode AND sw_sewcode = al_empcode)"
        attndobj = TrnAttendanceList.select(iselect).joins(jons).where(iswhere).order("al_trandate ASC,al_empcode ASC")  
        if attndobj.length >0
            attndobj.each do |newdpt|
               dptobj =   get_department_detail(newdpt.sw_depcode)
                if dptobj
                  newdpt.mydepartment = dptobj.departDescription
                end
                locobj = get_ho_location(newdpt.sw_location)
                if locobj
                  newdpt.location = locobj.hof_description
                end
                arritem.push newdpt
            end          
        end
      return arritem
  end

### ATTENDANCE SUMMARY DEPARTMENTWISE
private
  def departmentwise_attendance_list
    frmbegindated  = year_month_days_formatted(session[:atreq_fromattend])
    enddated       = ''
    emplid         = session[:atreq_empattend]
    empdpt         = session[:atreq_empdept]
    loc            = session[:atreq_location]
    type           = session[:at_reqtype]

    iswhere        = "al_compcode ='#{@compcodes}'"
      if frmbegindated !=nil && frmbegindated !=''
        iswhere  += " AND al_trandate ='#{frmbegindated}'"       
      end
      # if enddated !=nil && enddated !=''
      #   iswhere  += " AND al_trandate <='#{enddated}'"
      #   session[:atreq_uptoattend] = enddated       
      # end
      isflags = false
      if emplid !=nil && emplid !=''
        iswhere  += " AND al_empcode ='#{emplid}'"        
        isflags = true
      end
      if empdpt !=nil && empdpt !=''
        iswhere  += " AND sw_depcode ='#{empdpt}'"       
        isflags = true        
      end
      if type == 'ARV'
        iswhere += "AND al_arrtime != 0 AND al_arrtime != '' "
        isflags = true
      elsif type == 'OVT'
          iswhere += "AND al_overtime >0 "
          isflags = true
      end
      if loc !=nil && loc !=''
        iswhere  += " AND sw_location ='#{loc}'"        
        isflags = true        
    end
     arritem = []
        iselect  = "trn_attendance_lists.*,sw_depcode,sw_location,sw_joiningdate,emp.id as empsId,'' as mydepartment,'' as location"
        iselect  += ",'' as totalstrengthm, SUM(al_present) as presents,SUM(al_absent) as absents,( SUM(al_paidleave)+SUM(al_unpaidleave) ) as onleave"
        jons     = " LEFT JOIN mst_sewadars emp ON(sw_compcode = al_compcode AND sw_sewcode = al_empcode)"
        if type == 'ARS'
           jons     += " LEFT JOIN mst_head_offices loc ON(hof_compcode = sw_compcode AND sw_location = loc.id)"
        end
       
        if type == 'ARSD'
          attndobj = TrnAttendanceList.select(iselect).joins(jons).where(iswhere).group("sw_depcode").order("sw_depcode ASC") 
        else
          attndobj = TrnAttendanceList.select(iselect).joins(jons).where(iswhere).group("sw_location").order("hof_description ASC")
        end 
        if attndobj.length >0
            attndobj.each do |newdpt|
               dptobj =   get_department_detail(newdpt.sw_depcode)
                if dptobj
                  newdpt.mydepartment = dptobj.departDescription
                end
                locobj = get_ho_location(newdpt.sw_location)
                if locobj
                  newdpt.location = locobj.hof_description
                end
                newdpt.totalstrengthm = get_total_strength(newdpt.sw_depcode,newdpt.sw_location,type)
                arritem.push newdpt
            end          
        end
      return arritem
  end

### END ATTENDANCE SUMMARY DEPARTMENTWISE
private
def get_total_strength(deprtment,loc,types)
    counts     = 0
    compcodes  =  session[:loggedUserCompCode]
    if types.to_s == 'ARS'
      sewdobj    =  MstSewadar.where("sw_compcode = ? AND sw_location = ? AND sw_leavingdate='0000-00-00'",compcodes,loc)
    else
      sewdobj    =  MstSewadar.where("sw_compcode = ? AND sw_depcode = ? AND sw_leavingdate='0000-00-00'",compcodes,deprtment)
    end
    
    if sewdobj.length >0
       counts = sewdobj.length
    end
    return counts
end
private
 def print_report_listed()
  dataitem = ''
    lettobj = MstAppointmentLetter.where("apl_compcode = ? AND lower(apl_type)='appointment letter'",@compcodes).first
    if lettobj
      fromdate    = session[:my_sl_fromdate]
      uptodate    = session[:my_sl_uptodate]
      sedep       = session[:my_sl_depart]
      sewcatg     = session[:my_sl_category]
      refecoename = session[:my_sl_refrence]
      sewsearches = session[:my_sl_searchstr]
      sltype      = session[:my_sl_type]      
       iswhere       =  "sw_compcode ='#{@compcodes}'"
       iswhere       += " AND sw_sewcode ='#{sewsearches}'"     
       @seawdarsobj  = MstSewadar.where(iswhere).first
       if @seawdarsobj
        dataitem = process_merge_with_data(lettobj,@seawdarsobj)
       end
       
    end
    return dataitem
 end

 private
 def process_merge_with_data(datas,swbs)
  strpls = ""
      if datas  
           desroption =  datas.apl_description     
            if swbs
              emp_code       = swbs.sw_sewcode
              employee_name  = swbs.sw_sewadar_name
              refere_code    = swbs.sw_oldsewdarcode
              father_name    = swbs.sw_father_name
              mother_name    = swbs.sw_mothername
              dob            = formatted_date(swbs.sw_date_of_birth)
              gender         = swbs.sw_gender
              doj            = swbs.sw_joiningdate
              marital_status = swbs.sw_maritalstatus              
              department     =  swbs.sw_depcode
              designation    = swbs.sw_desigcode
              state          = ""
              location       = swbs.sw_location
              cur_date       = Date.today
              cur_time       = Time.now.strftime("%I:%H")
                strpls = desroption.to_s.gsub("[emp_code]",emp_code)
                strpls = strpls.to_s.gsub("[emp_code]",emp_code)
                strpls = strpls.to_s.gsub("[employee_name]",employee_name)
                strpls = strpls.to_s.gsub("[refere_code]",refere_code)
                strpls = strpls.to_s.gsub("[father_name]",father_name)
                strpls = strpls.to_s.gsub("[mother_name]",mother_name)

                strpls = strpls.to_s.gsub("[dob]",dob)
                strpls = strpls.to_s.gsub("[doj]",formatted_date(doj))
                strpls = strpls.to_s.gsub("[marital_status]",marital_status)
                strpls = strpls.to_s.gsub("[gender]",gender)
                strpls = strpls.to_s.gsub("[department]",department)
                strpls = strpls.to_s.gsub("[designation]",designation)
                strpls = strpls.to_s.gsub("[state]",state)
                strpls = strpls.to_s.gsub("[location]",location)
                strpls = strpls.to_s.gsub("[cur_date]",formatted_date(cur_date))
            end

      end
      return strpls
 end


end

