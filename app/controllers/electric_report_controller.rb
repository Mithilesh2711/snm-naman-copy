## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process to view electric consumption report
### FOR REST API ######
class ElectricReportController < ApplicationController
   before_action :require_login
   before_action :allowed_security
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    def index
        @compCodes         = session[:loggedUserCompCode]
        printcontroll      = "1_prt_excel_electric_consumption_list"
        @printpath         = electric_report_path(printcontroll,:format=>"pdf")
        printpdf           = "1_prt_pdf_electric_consumption_list"
        @printpdfpath      = electric_report_path(printpdf,:format=>"pdf")
        @sewDepart     =   Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment=''",@compCodes).order("departDescription ASC")
        if params[:id] != nil && params[:id] != ''
          @compDetail  = MstCompany.where(["cmp_companycode = ?", @compCodes]).first
          ids = params[:id].to_s.split("_")
          if ids[1] == 'prt' && ids[2] == 'excel'
              $eclectdata = print_sewadar_salary()
              send_data @ExcelList.to_generate_electric, :filename=> "electric-consumption-list-#{Date.today}.csv"
              return
          elsif ids[1] == 'prt' && ids[2] == 'pdf'
                 @rootUrl  = "#{root_url}"
                  dataprint = print_sewadar_salary()
                  respond_to do |format|
                       format.html
                       format.pdf do
                          pdf = ElectricchargesPdf.new(dataprint,@compDetail,@stkHead,@rootUrl,session)
                          send_data pdf.render,:filename => "1_prt_electric-consumption_report.pdf", :type => "application/pdf", :disposition => "inline"
                       end
                   end
           else
               ########### EDIT CASES ONLY ##########
               if( params[:id].to_i >0 )
                @Allsewobj     =   MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode =?",@compCodes).order("sw_sewadar_name ASC")
             end
          end
      end
        
        
         @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
         @HrMonths          = nil
         @Hryears           = nil
         @month_numbers     = 0
         @nbegindates  =  2021
         if @HeadHrp
               month_numbers =  @HeadHrp.hph_months
               myyears       =  @HeadHrp.hph_years
               month_begins  =  Time.now
               begdates      =  Date.parse(month_begins.to_s)
              
         end
    end
    def create
    end
    def show
      @compCodes = session[:loggedUserCompCode]
      
    end
   def ajax_process
       @compcodes       = session[:loggedUserCompCode]
       if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
          get_sewadar_info();
          return       
      end
end
private
def get_sewadar_info
  session[:mys_sl_years]     = nil
  session[:mys_sl_months]    = nil
  session[:mys_sl_depart]    = nil
  session[:mys_sewacode]     = nil 
  session[:mys_sl_type]      = nil
 
  years       = params[:years]
  months      = params[:months] !=nil && params[:months] != '' ? get_month_listed_data(params[:months]) : ''
  sedep       = params[:sedep]
  sewacode     = params[:sewacode]  
  sltype      = params[:sltype]

  iswhere = "ec_compcode ='#{@compcodes}'"
  if years !=nil && years !=''
    iswhere += " AND ec_readingyear ='#{years}'"
    session[:mys_sl_years] = years
  end
  if months !=nil && months !=''
    iswhere += " AND ec_readingmonth ='#{months}'"
    session[:mys_sl_months] = months
  end
  if sedep !=nil && sedep !=''
    iswhere += " AND sw_depcode ='#{sedep}'"
     session[:mys_sl_depart] = sedep
  end
  
  if sewacode !=nil && sewacode !=''
    session[:mys_sewacode] = sewacode
    iswhere += " AND ec_sewdarcode ='#{sewacode}'"
  end
  
  
  
  isflags   = false
  message   = ""
  isselect  = " trn_electric_consumptions.id as swsid,sewa.id as sewid"
  jons      = " JOIN mst_sewadars sewa ON( sw_compcode = ec_compcode AND sw_sewcode = ec_sewdarcode)"
  pmsobj    = TrnElectricConsumption.select(isselect).joins(jons).where(iswhere).order("ec_sewdarcode ASC")
  listdats  = []
  if pmsobj.length >0
    listdats = print_sewadar_salary()
    isflags = true
  end
  respond_to do |format|
    format.json { render :json => { 'data'=>listdats, "message"=>message,:status=>isflags} }
  end
end


private
def print_sewadar_salary
  years       = session[:mys_sl_years]
  months      = session[:mys_sl_months]
  sedep       = session[:mys_sl_depart]
  sewacode    = session[:mys_sewacode]  
  sltype      = session[:mys_sl_type]
  
  if @compcodes == nil
    @compcodes   = @compCodes
  end

  iswhere = "ec_compcode ='#{@compcodes}'"
  if years !=nil && years !=''
    iswhere += " AND ec_readingyear ='#{years}'"
    session[:mys_sl_years] = years
  end
  if months !=nil && months !=''
    iswhere += " AND ec_readingmonth ='#{months}'"
    session[:mys_sl_months] = months
  end
  if sedep !=nil && sedep !=''
    iswhere += " AND sw_depcode ='#{sedep}'"
     session[:mys_sl_depart] = sedep
  end
  
  if sewacode !=nil && sewacode !=''
    session[:mys_sewacode] = sewacode
    iswhere += " AND ec_sewdarcode ='#{sewacode}'"
  end
  
  
  arrpms   = []
  isselect = "trn_electric_consumptions.*,sewa.id as sewid,sw_sewadar_name,sw_father_name,sw_joiningdate,sw_oldsewdarcode,sw_meterno,sw_sewcode"
  isselect += ",'' as deprtment,'' as designation,'' as bankaccount,'' as bankname,'' as ifscode,'' as statename,sw_depcode,sw_desigcode"
  isselect += ", '' as pmactbasic,'' as pmarear,'' as pmbasic,'' as pmdedlicemployee,'' as pmdedaccomodatamount ,'' as pmdedelectricamount,'' as pmdedrepaidadvance,'' as pmdedrepaidloan "
  isselect += ", '' as pmdedhealthsewdarpay,'' as pmincometaxamount,'' as pmtotaldeduction,'' as pmnetpay"
  isselect += ",'' as curreading,'' as lastreading,'' as consumption,'' as tamounts,'' as remarks"

  jons      = " JOIN mst_sewadars sewa ON( sw_compcode = ec_compcode AND sw_sewcode = ec_sewdarcode)"
  pmsobj    = TrnElectricConsumption.select(isselect).joins(jons).where(iswhere).order("ec_sewdarcode ASC")
  if pmsobj.length >0
      @ExcelList = pmsobj
      pmsobj.each do |newsalry|
          
          sdpobj = get_all_department_detail(newsalry.sw_depcode)
          if sdpobj
             newsalry.deprtment = sdpobj.departDescription
          end
          desobj = get_sewdar_designation_detail(newsalry.sw_desigcode)
          if desobj
            newsalry.designation = desobj.ds_description
          end
          newsalry.curreading   = newsalry.ec_currentreading
          newsalry.lastreading  = newsalry.ec_lastreading
          newsalry.tamounts     = newsalry.ec_totalamount
          newsalry.remarks      = newsalry.ec_reamrk
          diffs                 = newsalry.ec_currentreading.to_f-newsalry.ec_lastreading.to_f
          newsalry.consumption = diffs
          arrpms.push newsalry
      end
  end
  return arrpms
  
end

private
def get_current_last_reading(sewcode,month)
  compcode  = session[:loggedUserCompCode]
  iswhere   =  "ec_compcode ='#{@compcodes}' AND ec_sewdarcode ='#{sewcode}' AND ec_readingmonth='#{month}'"
  elecobjs  = TrnElectricConsumption.where(iswhere).first
  return elecobjs
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



end
