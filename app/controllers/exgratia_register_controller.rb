class ExgratiaRegisterController < ApplicationController

    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_sewdar_designation_detail,:get_all_department_detail,:get_ho_location,:get_global_office_detail
    helper_method :set_dct,:set_ent,:get_personal_information,:get_office_information,:get_roles_information,:format_oblig_date,:get_university_deegre_listed,:get_my_selected_department_code
    helper_method :get_sewa_all_department,:get_sewa_all_qualification,:get_sewa_all_rolesresp,:get_sewa_all_designation,:get_first_my_sewadar,:get_subs_location
  def index
   @compCodes         = session[:loggedUserCompCode]
   @compDetail        = MstCompany.where(["cmp_companycode = ?", @compcodes]).first
   @printPath         = "exgratia_register/1_exgratia_register_report.pdf"
  
  end
  ### SEWADAR REPORT ANALYSIS ###
  def show
     @compcodes       = session[:loggedUserCompCode]
     @compDetail      = MstCompany.where(["cmp_companycode = ?", @compcodes]).first
    
     rooturl       = "#{root_url}"
      if params[:id] != nil && params[:id] != ''
      
       exgratiadata  =  print_exgratia_register
       respond_to do |format|
           format.html
           format.pdf do
              pdf = GratuityreportPdf.new(exgratiadata,@compDetail,rooturl)
              send_data pdf.render,:filename => "1_exgratia_register_report.pdf", :type => "application/pdf", :disposition => "inline"
           end
        end 
   
end
    end
 
  
  def ajax_process
         @compcodes       = session[:loggedUserCompCode]
         if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
            check_data_isexist()
            return
         end

  end

  private
  def get_all_formats_data
   @compCodes       = session[:loggedUserCompCode]
   if session[:reqs_sewdarcode] !=nil && session[:reqs_sewdarcode] !=''       
         @seawdarsobj     = MstSewadar.where("sw_compcode =? AND sw_sewcode = ?",@compCodes,session[:reqs_sewdarcode]).first  
         
         if @seawdarsobj
               @sewadarpersonal = get_personal_information(@compCodes,@seawdarsobj.sw_sewcode)
               @empChecked      = get_office_information(@compCodes,@seawdarsobj.sw_sewcode)
               @EmpKyc          = get_sewadar_kyc_information(@compCodes,@seawdarsobj.sw_sewcode)
               @EmpKycBank      = get_sewadar_kyc_bankdetail(@compCodes,@seawdarsobj.sw_sewcode)
               @EmpKycQulifc    = get_sewadar_kyc_qualification(@compCodes,@seawdarsobj.sw_sewcode)
               @EmpKycFamily    = get_sewadar_kyc_family(@compCodes,@seawdarsobj.sw_sewcode)
               @EmpWorkExp      = get_sewadar_work_experience(@compCodes,@seawdarsobj.sw_sewcode)
               @EmpDepartment   = get_all_department_detail('DPT0011')
               if @sewadarpersonal
                  @EmpStatelist    = get_state_detail(@sewadarpersonal.sp_pres_state)
                  @EmpDistrict     = get_district_detail(@sewadarpersonal.sp_pres_distcity)
               end
               if @EmpDepartment
                  @Hodlisted      = get_first_my_sewadar(@EmpDepartment.departHod)   
               end
               
         end
         

    end

  end



  private
  def print_exgratia_register
    @compCodes  = session[:loggedUserCompCode]
    iswhere   = "pm_compcode ='#{@compcodes}'" 

    arrpms    = []
    jons      = " JOIN mst_sewadars sewa ON( pm_compcode = sw_compcode AND pm_sewacode = sw_sewcode)"
    isselect  = "trn_pay_monthlies.*,sewa.id as sewid,sw_sewadar_name,sw_father_name,sw_joiningdate,sw_date_of_birth,sw_oldsewdarcode"
    isselect  += ",'' as deprtment,'' as designation,'' as bankaccount,'' as bankname,'' as ifscode,'' as statename,sw_depcode,sw_desigcode"
    isselect  += ", '' as pmactbasic,'' as pmarear,'' as pmbasic,'' as pmdedlicemployee,'' as pmdedaccomodatamount ,'' as pmdedelectricamount,'' as pmdedrepaidadvance,'' as pmdedrepaidloan "
    isselect  += ", '' as pmdedhealthsewdarpay,'' as pmincometaxamount,'' as pmtotaldeduction,'' as pmnetpay"
    isselect  += ", '' as uptosixty,'' as abovesixty,'' as exgratia,'' as maadvance,'' as wheatadvance,'' as specialadvance"
    isselect  += ", sw_catgeory as categoryname,sw_catcode,'' as monthname "
    pmsobj = TrnPayMonthly.select(isselect).joins(jons).where(iswhere)
    
    if pmsobj.length >0
        
          pmsobj.each do |newsalry|            
                      bankaccount  = ""
                      deprtment    = ""
                      bksobj       = get_sewadar_kyc_bankdetail(@compcodes,newsalry.pm_sewacode)
                      if bksobj
                          newsalry.bankaccount  = bankaccount = bksobj.skb_accountno
                          newsalry.bankname     = bksobj.skb_bank
                          newsalry.ifscode      = bksobj.skb_ifccocde                  
                      end
                      sdpobj = get_all_department_detail(newsalry.sw_depcode)
                      if sdpobj
                         newsalry.deprtment = deprtment = sdpobj.departDescription
                      end
                      desobj = get_sewdar_designation_detail(newsalry.sw_desigcode)
                      if desobj
                          newsalry.designation = desobj.ds_description
                      end
                      sewinfobj = get_personal_information(@compcodes,newsalry.pm_sewacode)
                      newsalry.monthname = get_month_listed_data(newsalry.pm_paymonth)
                      if sewinfobj
                          statecpde   = sewinfobj.sp_pres_state
                          if statecpde !=nil && statecpde !=''
                              stsnonj = get_state_detail(statecpde)
                              if stsnonj
                                newsalry.statename = stsnonj.sts_description
                              end
                          end
                      end
                      arrpms.push  newsalry 
                      
             end
    end
    return arrpms
    
  end



  private
  def check_data_isexist
    @compCodes  = session[:loggedUserCompCode]
    session[:reqs_sewdarcode]   = nil 
    session[:reqs_sedep]        = nil  
  
    
    iswhere   = "pm_compcode ='#{@compcodes}' " 

   
    arrpms    = []
    jons      = " JOIN mst_sewadars sewa ON( pm_compcode = sw_compcode AND pm_sewacode = sw_sewcode)"
    isselect  = "trn_pay_monthlies.*,sewa.id as sewid,sw_sewadar_name,sw_father_name,sw_joiningdate,sw_date_of_birth,sw_oldsewdarcode"
    isselect  += ",'' as deprtment,'' as designation,'' as bankaccount,'' as bankname,'' as ifscode,'' as statename,sw_depcode,sw_desigcode"
    isselect  += ", '' as pmactbasic,'' as pmarear,'' as pmbasic,'' as pmdedlicemployee,'' as pmdedaccomodatamount ,'' as pmdedelectricamount,'' as pmdedrepaidadvance,'' as pmdedrepaidloan "
    isselect  += ", '' as pmdedhealthsewdarpay,'' as pmincometaxamount,'' as pmtotaldeduction,'' as pmnetpay"
    isselect  += ", '' as uptosixty,'' as abovesixty,'' as exgratia,'' as maadvance,'' as wheatadvance,'' as specialadvance"
    isselect  += ", sw_catgeory as categoryname,sw_catcode,'' as monthname "
    pmsobj = TrnPayMonthly.select(isselect).joins(jons).where(iswhere)
    
      if pmsobj.length >0
         isflags = true          
      end
     respond_to do |format|
      format.json { render :json => { 'data'=>arrpms, "message"=>'',:status=>isflags} }
      end
   
    
  end
##### ITR COLLECTION LIST
  

  private
  def get_sewdara_inofrmation_first(sewcode)
         compcode  = session[:loggedUserCompCode]
         sewdarobj =  MstSewadar.where("sw_compcode =? AND sw_sewcode =?",compcode,sewcode).first
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
  def get_common_information(compcode,empcode)
         isselect  = "mst_sewadar_office_infos.*,'' as sewadarname,so_sewcode as sw_sewcode,so_sewcode,'' as accomodation"
         isselect  +=",'' as sw_father_name,'' as sw_gender,'' as sw_maritalstatus,'' as sw_husbprefix,'' as sw_father_prefix,'' as sw_joiningdate,'' as sw_sewadar_prefix,'' as sw_sewadar_name,'' as sw_husbandname"
         sewdarobj =  MstSewadarOfficeInfo.select(isselect).where("so_compcode =? AND so_sewcode =?",compcode,empcode)
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
       sewdarobj =  MstSewadarKycQualification.where("skq_compcode =? AND skq_sewcode = ?",compcode,sewcode).order("skq_passingyear DESC")
       return sewdarobj
  end

  private
  def get_sewadar_kyc_family(compcode,sewcode)
       sewdarobj =  MstSewdarKycFamilyDetail.where("skf_compcode =? AND skf_sewcode =?",compcode,sewcode).order("skf_dependent ASC")
       return sewdarobj
  end

  private
  def get_sewadar_work_experience(compcode,sewcode)
       sewdarobj =  MstSewadarWorkExperience.where("swe_compcode =? AND swe_sewcode =?",compcode,sewcode).order("swe_employer ASC")
       return sewdarobj
  end

end
