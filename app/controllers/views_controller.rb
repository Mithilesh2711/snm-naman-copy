## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process banking KYC,Attachment,QUALIF etc
### FOR REST API ######
class ViewsController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search,:birthday_list,:sewadar_cards,:deductions_list]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_sewdar_designation_detail,:get_all_department_detail,:get_ho_location,:get_global_office_detail
  helper_method :set_dct,:set_ent,:get_personal_information,:get_office_information,:get_roles_information,:format_oblig_date,:get_university_deegre_listed,:get_my_selected_department_code
  helper_method :get_sewa_all_department,:get_sewa_all_qualification,:get_sewa_all_rolesresp,:get_sewa_all_designation,:get_first_my_sewadar,:get_subs_location
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
      elsif  docsid[2] == 'register'
          @voucherdata  =  print_sewadar_salary
          respond_to do |format|
              format.html
              format.pdf do
                 pdf = SalaryregisterPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                 send_data pdf.render,:filename => "1_salary_register_report.pdf", :type => "application/pdf", :disposition => "inline"
              end
           end
      elsif  docsid[2] == 'bdexcel'
           @ExcelList    = nil
           $voucherdata  =  excel_birth_of_sewadar
          if @ExcelList !=nil              
              send_data @ExcelList.to_get_birthday_listed, :filename=> "birthday_sewadar_listed-#{Date.today}.csv"
          end
     elsif  docsid[2] == 'excel'
          @ExcelList = nil
         $voucherdata  =  print_sewadar_salary
         if @ExcelList !=nil              
             send_data @ExcelList.process_excel_data, :filename=> "salary_register-#{Date.today}.csv"
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
              elsif  docsid[2] == 'pdfcard'
                    mycattype = session[:req_sewp_cat] 
                    if mycattype == 'SW'                      
                      @voucherdata = print_card_of_sewadar()
                    else
                      @voucherdata = print_card_of_members()
                    end                  

                    respond_to do |format|
                        format.html
                        format.pdf do
                           pdf = CardlistPdf.new(@voucherdata,@compDetail,mycattype,rooturl,session)
                           send_data pdf.render,:filename => "1_sewadar_card_report.pdf", :type => "application/pdf", :disposition => "inline"
                          end
                        end                          
                    
                  elsif  docsid[2] == 'excelcard'
                        @ExcelList    = nil
                        mycattype = session[:req_sewp_cat] 
                        if mycattype == 'SW' 
                           listeddata    = print_card_of_sewadar()
                          $categiry_name = listeddata[0].sw_catgeory                    
                          $voucherdata   = listeddata
                          
                        else
                          $categiry_name = session[:swp_sewa_member]
                          $voucherdata = print_card_of_members()
                        end                
    
                        
                        
                        if @ExcelList !=nil              
                            send_data @ExcelList.to_get_sewacard_listed, :filename=> "sewadar_card_listed-#{Date.today}.csv"
                        end                         
                        
                  end
end

end
def birthday_list
    @compCodes         = session[:loggedUserCompCode]
    @printPath         = "views/1_prt_bdexcel_birth_report.pdf"
    mymonths           = params[:mymonths] !=nil && params[:mymonths] !='' ? params[:mymonths] : Date.today.strftime('%m')   
    @listedBirthday    = searches_birth_of_sewadar(mymonths)
    if mymonths !=nil && mymonths !=''
       @mymonths = mymonths
    else
      @mymonths = Date.today.strftime('%m') 
    end
end

def sewadar_cards
    @compCodes         = session[:loggedUserCompCode]
    @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
    @printPath         = "views/1_prt_excelcard_download_report.pdf" 
    @printPdfPath      = "views/1_prt_pdfcard_report.pdf" 
    cattype            = params[:cattype] != nil && params[:cattype] !='' ? params[:cattype] : session[:req_sewp_cat] 
    if cattype == 'MB'
      @listedBirthday    = searches_card_of_members()
      @cattype  = cattype
      session[:req_sewp_cat] = cattype
    else    

      @listedBirthday    = searches_card_of_sewadar()
      @cattype           = 'SW'
      session[:req_sewp_cat] = 'SW'

    end
    
    
end

def salary_register
  @compCodes         = session[:loggedUserCompCode]
  @nbegindate        = 2021
  @mydepartcode      = ''
  @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
  @familylisted      = total_sewadar_kyc_family(@compCodes)
  @printPath         = "reports/1_salary_register_report.pdf"
  @printExcelPath    = "reports/1_salary_excel_register.pdf"
  @ListDesignation   = Designation.where("compcode = ?",@compCodes).order("ds_description ASC")

  if session[:autherizedUserType] && session[:autherizedUserType].to_s != 'adm'
   @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =? AND sw_depcode = ?",@compCodes,@mydepartcode)
  else
    @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =?",@compCodes)
 end
  
              
  
end



def salary_slip
  @compCodes         = session[:loggedUserCompCode]
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
def deductions_list
  @compCodes         = session[:loggedUserCompCode]
  @nbegindate        = 2021
  @mydepartcode      = ''
  
  @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
  @familylisted      = total_sewadar_kyc_family(@compCodes)
  @printPath         =  "reports/1_deduction_common_report.pdf"
  @ListDesignation   = Designation.where("compcode = ?",@compCodes).order("ds_description ASC")

  if session[:autherizedUserType] && session[:autherizedUserType].to_s != 'adm'
   @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =? AND sw_depcode = ?",@compCodes,@mydepartcode)
  else
    @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =?",@compCodes)
 end

 @sewdarList        = get_deduction_listing()

end

 def get_deduction_listing
  if params[:page].to_i >0
  pages = params[:page]
  else
  pages = 1
  end
  jons = ""
  if params[:requestserver] !=nil && params[:requestserver] != ''
    
    session[:req_sewadar_string]      = nil
    session[:req_sewadar_categories]  = nil
    session[:req_sewadar_department]  = nil
    session[:req_sewadar_codetype]    = nil
  end

sewadar_string       = params[:sewadar_string].to_s.strip !=nil && params[:sewadar_string].to_s.strip != '' ? params[:sewadar_string].to_s.strip : session[:req_sewadar_string].to_s.strip
sewadar_categories   = params[:sewadar_categories].to_s.strip !=nil && params[:sewadar_categories].to_s.strip != ''  ? params[:sewadar_categories].to_s.strip : session[:req_sewadar_categories]
sewadar_codetype     = params[:sewadar_codetype] !=nil && params[:sewadar_codetype] != ''  ? params[:sewadar_codetype] : session[:req_sewadar_codetype]
request_type         = params[:requesttype] !=nil && params[:requesttype] != ''  ? params[:requesttype] : session[:req_request_type]
sewadar_departments  = params[:sewadar_departments] !=nil && params[:sewadar_departments] != ''  ? params[:sewadar_departments] : session[:req_sewadar_department]

myflagsjs  = false
mytflags   = false
if sewadar_codetype !=nil && sewadar_codetype !='' 
   session[:req_sewadar_codetype] = sewadar_codetype
  @sewadar_codetype               = sewadar_codetype
end
iswhere = "sw_compcode ='#{@compCodes}' "
if request_type !=nil && request_type !='' && request_type =='LIC'
  iswhere += " AND so_licgroup = 'Y' "
  session[:req_request_type] = request_type
  @request_type              = request_type
elsif request_type !=nil && request_type !='' && request_type.to_s =='BUILD'
 
  iswhere += " AND sw_isaccommodation = 'Y' AND sw_accomodexemption<>'N'"
  session[:req_request_type] = request_type
  @request_type              = request_type  
elsif request_type !=nil && request_type !='' && request_type =='ELEC'
    iswhere += " AND sw_iselectricconsump = 'Y' AND sw_electricexemption<>'N'"
    session[:req_request_type] = request_type
    @request_type              = request_type   
  elsif request_type !=nil && request_type !='' && request_type =='HEAL'
    iswhere += " AND so_healthinsurance = 'Y' "
    session[:req_request_type] = request_type
    @request_type              = request_type     
else
  iswhere += " AND so_licgroup = 'Y'"
end


if sewadar_categories !=nil && sewadar_categories !=''
    iswhere += " AND sw_catgeory LIKE '%#{sewadar_categories}%'"
    session[:req_sewadar_categories] = sewadar_categories
    @sewadar_categories             = sewadar_categories
end
if sewadar_departments !=nil && sewadar_departments !=''
    iswhere += " AND sw_depcode LIKE '%#{sewadar_departments}%'"
    session[:req_sewadar_department] = sewadar_departments
    @sewadar_departments              = sewadar_departments
end



if sewadar_string !=nil && sewadar_string != ''
    session[:reqs_sewadar_string]      = sewadar_string
    @sewadar_string                    = sewadar_string   
    if sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='mycode'
      iswhere += " AND sw_sewcode LIKE '%#{sewadar_string.to_s.strip}%' "
    elsif sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='myemail'
      iswhere += " AND sp_personal_email LIKE '%#{sewadar_string.to_s.strip}%' "
    elsif sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='mymobile'
      iswhere += " AND sp_mobileno LIKE '%#{sewadar_string.to_s.strip}%'  "
    elsif sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='myname'
      iswhere += " AND sw_sewadar_name LIKE '%#{sewadar_string.to_s.strip}%'  "
    elsif sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='myrefcode'
      iswhere += " AND sw_oldsewdarcode LIKE '%#{sewadar_string.to_s.strip}%' "
    end

end


  jons      = " LEFT JOIN mst_sewadar_office_infos offc on(so_compcode = sw_compcode AND sw_sewcode = so_sewcode)"
  isselects = "mst_sewadars.*,offc.id as offsId,so_healthinsurance"
  listobj   =  MstSewadar.select(isselects).joins(jons).where(iswhere).order("sw_sewcode ASC,sw_sewadar_name ASC")
  return listobj

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
       @compcodes       = session[:loggedUserCompCode]
       if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
          get_sewadar_info();
          return
        elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'datalist'
          get_data_list()
          return

       
      end
end
def get_data_list
	@compcodes = session[:loggedUserCompCode]	
	datavalue = params[:dataval]
	iswhere = "so_compcode ='#{@compcodes}' AND so_licgroup ='#{datavalue}' AND so_healthinsurance = '#{datavalue}' "
	stsobj =  MstSewadarOfficeInfo.select("so_compcode,so_licgroup,so_healthinsurance").where(iswhere).first
	isflags = false
     if stsobj
		isflags = true
	 end
	respond_to do |format|
		format.json { render :json => { 'data'=>stsobj, "message"=> '',:status=>isflags} }
	  end
		
end

private
def get_sewadar_info
  session[:my_sl_years]     = nil
  session[:my_sl_months]    = nil
  session[:my_sl_depart]    = nil
  session[:my_sl_category]  = nil
  session[:my_sl_refrence]  = nil
  session[:my_sl_searchstr] = nil
  session[:my_sl_type]      = nil
  
  years       = params[:years]
  months      = params[:months] !=nil && params[:months] != '' ? get_month_listed_data(params[:months]) : ''
  sedep       = params[:sedep]
  sewcatg     = params[:sewcatg]
  refecoename = params[:refecoename]
  sewsearches = params[:sewsearches]
  sltype      = params[:sltype]

  iswhere = "pm_compcode ='#{@compcodes}'"
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
  
  isflags = false
  message = ""
  isselect  = "trn_pay_monthlies.*,sewa.id as sewid,sw_sewadar_name,sw_father_name"
  jons      = " JOIN mst_sewadars sewa ON( sw_compcode = pm_compcode AND sw_sewcode = pm_sewacode)"
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
  
  iswhere = "pm_compcode ='#{@compcodes}'"
  if years !=nil && years !=''
    iswhere += " AND pm_payyear ='#{years}'"
  end
  if months !=nil && months !=''
    iswhere += " AND pm_paymonth ='#{months}'"
  end
  if sedep !=nil && sedep !=''
    iswhere += " AND sw_depcode ='#{sedep}'"
  end
  if sewcatg !=nil && sewcatg !=''
    iswhere += " AND sw_catgeory ='#{sewcatg}'"
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
  isselect  = "trn_pay_monthlies.*,sewa.id as sewid,sw_sewadar_name,sw_father_name,sw_joiningdate,sw_oldsewdarcode"
  isselect  += ",'' as deprtment,'' as designation,'' as bankaccount,'' as bankname,'' as ifscode,'' as statename,sw_depcode,sw_desigcode"
  isselect += ", '' as pmactbasic,'' as pmarear,'' as pmbasic,'' as pmdedlicemployee,'' as pmdedaccomodatamount ,'' as pmdedelectricamount,'' as pmdedrepaidadvance,'' as pmdedrepaidloan "
  isselect += ", '' as pmdedhealthsewdarpay,'' as pmincometaxamount,'' as pmtotaldeduction,'' as pmnetpay"

  jons      = " JOIN mst_sewadars sewa ON( sw_compcode = pm_compcode AND sw_sewcode = pm_sewacode)"
  pmsobj    = TrnPayMonthly.select(isselect).joins(jons).where(iswhere).order("pm_sewacode ASC")
  if pmsobj.length >0
      @ExcelList = pmsobj
      pmsobj.each do |newsalry|
          bksobj = get_sewadar_kyc_bankdetail(@compcodes,newsalry.pm_sewacode)
          if bksobj
            newsalry.bankaccount  = bksobj.skb_ifccocde
            newsalry.bankname     = bksobj.skb_bank
            newsalry.ifscode      = bksobj.skb_accountno
           
          end
          sdpobj = get_all_department_detail(newsalry.sw_depcode)
          if sdpobj
             newsalry.deprtment = sdpobj.departDescription
          end
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
          arrpms.push newsalry
      end
  end
  return arrpms
  
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

private
def searches_birth_of_sewadar(months)
  compcode         = session[:loggedUserCompCode]
  arrbirthlist     = []
  if months && months.to_s.length <2
     months = '0'+months.to_s

  end
   session[:reqs_monthed] = months
   iswhere          = "sw_compcode ='#{compcode}' AND DATE_FORMAT(sw_date_of_birth,'%m') = '#{months}' AND sw_leavingdate='0000-00-00'"
   birthsobj        = MstSewadar.select("sw_sewcode,sw_sewadar_name,sw_gender,sw_image,sw_depcode,sw_date_of_birth,sw_location,sw_catgeory,'sw' as mytype ").where(iswhere).order("DAY(sw_date_of_birth) ASC")
    if birthsobj.length >0
          birthsobj.each do |newbth|
              arrbirthlist.push newbth
          end
    end
    orgnizobj  = get_birth_of_organization(months)
    if orgnizobj.length >0
        orgnizobj.each do |neworg|
            arrbirthlist.push neworg
        end 
    end
    listbirthdaydat = []
    if arrbirthlist.length >0
      TrnTempSewdarBirthList.destroy_all
      arrbirthlist.each do |newdbs|
        process_temp_birthadys(newdbs.sw_sewcode,newdbs.sw_sewadar_name,newdbs.sw_gender,newdbs.sw_image,newdbs.sw_depcode,newdbs.sw_date_of_birth,newdbs.sw_location,newdbs.mytype)
      end
      listbirthdaydat  = TrnTempSewdarBirthList.all.order("DAY(sw_date_of_birth) ASC")
    end
    return listbirthdaydat
end

def process_temp_birthadys(sw_sewcode,sw_sewadar_name,sw_gender,sw_image,sw_depcode,sw_date_of_birth,sw_location,mytype)
  sw_location = sw_location.to_i >0 ? sw_location : 0
  prsobj  = TrnTempSewdarBirthList.new(:sw_sewcode=>sw_sewcode,:sw_sewadar_name=>sw_sewadar_name,:sw_gender=>sw_gender,:sw_image=>sw_image,:sw_depcode=>sw_depcode,:sw_date_of_birth=>sw_date_of_birth,:sw_location=>sw_location,:sw_membtype=>mytype)
  prsobj.save
end

def get_birth_of_organization(months)
  compcode   = session[:loggedUserCompCode]
  iswhere    = "lds_compcode ='#{compcode}' AND DATE_FORMAT(lds_dob,'%m')='#{months}'"
  isselect   = "lds_membno as sw_sewcode,lds_name as sw_sewadar_name,'' as sw_gender,lds_profile as sw_image,'' as sw_depcode,lds_dob as sw_date_of_birth,'' as sw_location,lds_type as sw_catgeory,lds_designcode as designcode,'mb' as mytype "
  birthsobj  = MstLedger.select(isselect).where(iswhere).order("DAY(lds_dob) ASC")
  return birthsobj

end

private
def searches_card_of_sewadar()
  compcode   = session[:loggedUserCompCode] 
  if params[:page].to_i >0
    pages = params[:page]
  else
     pages = 1
  end
  if params[:requestserver] != nil && params[:requestserver] != ''
    session[:req_sewp_cat]          = nil
    session[:swp_sewadar_category] = nil
    session[:swp_sewa_member]      = nil
end
  
  sewadar_category = params[:sewadar_category] != nil && params[:sewadar_category] !='' ? params[:sewadar_category] : session[:swp_sewadar_category]
   if sewadar_category == nil || sewadar_category == ''
     sewadar_category = "SDP"
   end  
  iswhere    = "sw_compcode ='#{compcode}'"
  if sewadar_category != nil && sewadar_category !='' 
      iswhere  += " AND sw_catcode ='#{sewadar_category}'"
      session[:swp_sewadar_category] = sewadar_category
      @sewadar_category              = sewadar_category
  end  
  isselect   = "sw_sewcode,sw_sewadar_name,sw_gender,sw_image,sw_depcode,sw_date_of_birth,sw_location,sw_catgeory,'' as designcode"
  birthsobj  = MstSewadar.select(isselect).where(iswhere).paginate(:page =>pages,:per_page => 30).order("sw_depcode ASC")
  return birthsobj
end

private
def searches_card_of_members()
  compcode   = session[:loggedUserCompCode] 
  if params[:page].to_i >0
    pages = params[:page]
  else
     pages = 1
  end
  if params[:requestserver] != nil && params[:requestserver] != ''
    session[:req_sewp_cat]          = nil
    session[:swp_sewadar_category] = nil
    session[:swp_sewa_member] = nil
 end  
  sewadar_category = params[:sewa_member] != nil && params[:sewa_member] !='' ? params[:sewa_member] : session[:swp_sewa_member]
  iswhere    = "lds_compcode ='#{compcode}'"
  if sewadar_category != nil && sewadar_category !='' 
      iswhere  += " AND lds_type ='#{sewadar_category}'"
      session[:swp_sewa_member] = sewadar_category
      @sewa_member           = sewadar_category
  end  
  isselect   = "lds_membno as sw_sewcode,lds_name as sw_sewadar_name,'' as sw_gender,lds_profile as sw_image,'' as sw_depcode,lds_dob as sw_date_of_birth,'' as sw_location,lds_type as sw_catgeory,lds_designcode as designcode"
  birthsobj  = MstLedger.select(isselect).where(iswhere).paginate(:page =>pages,:per_page => 30).order("lds_name ASC")
  return birthsobj
end

private
def excel_birth_of_sewadar
  compcode    = session[:loggedUserCompCode]
  months      = session[:reqs_monthed]
  arrsitem    = []
  iswhere     = "sw_compcode ='#{compcode}' AND DATE_FORMAT(sw_date_of_birth,'%m') = '#{months}'"
  brithobjs   = MstSewadar.select("sw_sewcode").where(iswhere).order("DAY(sw_date_of_birth) ASC")
 isselect = "sw_sewcode,sw_sewadar_name,sw_gender,sw_image,sw_depcode,sw_date_of_birth,DATE_FORMAT(sw_date_of_birth,'`%d-%b-%Y') as birthdays,sw_location,'' as department,'' as location,'' as sublocation,DATE_FORMAT(sw_date_of_birth,'%d-%m-%Y') as sw_date_of_births"
  birthsobj  = TrnTempSewdarBirthList.select(isselect).all.order("DAY(sw_date_of_birth) ASC")
  if birthsobj.length >0
  @ExcelList = brithobjs
  birthsobj.each do |newbds|
  deprtobj = get_all_department_detail(newbds.sw_depcode)
  if deprtobj
    newbds.department = deprtobj.departDescription
  end
  locobjs = get_ho_location(newbds.sw_location)
  if locobjs
     newbds.location = locobjs.hof_description
  end
    sublocobj = get_global_office_detail(newbds.sw_sewcode)
    if sublocobj
        slid = sublocobj.so_sublocation
        if slid.to_i >0
              sblocobj = get_subs_location(slid)
              if sblocobj
                newbds.sublocation = sblocobj.sl_description
              end
        end
  end  
  arrsitem.push newbds
  end
end
  return arrsitem
end


private
def print_card_of_sewadar()
  compcode         = session[:loggedUserCompCode]   
  sewadar_category = session[:swp_sewadar_category]
  iswhere          = "sw_compcode ='#{compcode}'"

  if sewadar_category != nil && sewadar_category !='' 
      iswhere  += " AND sw_catcode ='#{sewadar_category}'"
      
  end 
  arritem  = [] 
  isselect   = "sw_sewcode,sw_sewadar_name,sw_gender,sw_image,sw_depcode,sw_date_of_birth,sw_location,sw_catgeory,'' as department"
  birthsobj  = MstSewadar.select(isselect).where(iswhere).order("sw_sewcode ASC")
  if birthsobj.length >0
     @ExcelList = birthsobj
      birthsobj.each do |newswd|
        department =''
        deprtobj = get_all_department_detail(newswd.sw_depcode)
        if deprtobj
          newswd.department = deprtobj.departDescription
        end
        arritem.push newswd
      end
  end
  return arritem
end

private
def print_card_of_members()
  compcode         = session[:loggedUserCompCode]  
  sewadar_category = session[:swp_sewa_member]
  iswhere    = "lds_compcode ='#{compcode}'"
  if sewadar_category != nil && sewadar_category !=''  
      iswhere  += " AND lds_type ='#{sewadar_category}'"      
  end  
  arritem  = [] 
  isselect   = "lds_membno as sw_sewcode,lds_name as sw_sewadar_name,'' as sw_gender,lds_profile as sw_image,'' as sw_depcode,lds_dob as sw_date_of_birth,'' as sw_location,lds_type as sw_catgeory,'' as department"
  birthsobj  = MstLedger.select(isselect).where(iswhere).order("lds_name ASC")
  if birthsobj.length >0
      @ExcelList = birthsobj
      birthsobj.each do |newswd|
        arritem.push newswd
      end
  end
  return arritem
end




end

