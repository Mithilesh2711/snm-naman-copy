class ReportFullAndFinalController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_sewdar_designation_detail,:get_all_department_detail
    helper_method :get_mysewdar_list_details
    def index
        @compCodes         = session[:loggedUserCompCode]
        @printPath          = "report_full_and_final/1_full_final_report.pdf"
        @mydepartcode      = ''
        @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")   
        mydeprtcode        = ""
        if session[:sec_sewdar_code] != nil
                sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
                if sewobjs
                    @mydepartcode = sewobjs.sw_depcode
                    mydeprtcode   = sewobjs.sw_depcode
                end
        end
        @empDetail = nil
        if params[:id].to_i >0
            @listFullFinal  = TrnFullFinal.where("ff_compcode =? AND id = ?",@compCodes,params[:id].to_i).first
            if @listFullFinal
              @empDetail     = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_depcode = ?",@compCodes,@listFullFinal.ff_departcode).order("sw_sewadar_name ASC")

            end
            
        end
        if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
            @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment ='' AND departCode = ? ",@compCodes,mydeprtcode).order("departDescription ASC")
            if session[:requestuser_loggedintp].to_s == 'swd'
                @Allsewobj         = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")
            else
                @Allsewobj         = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_depcode = ?",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")
            end

        else
            @markedAllowed    = true
            @markedFieldAlw   = true
            @sewDepart        = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compCodes).order("departDescription ASC")
            @Allsewobj        = [] #MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode =?",@compCodes).order("sw_sewadar_name ASC")
        end
    end
    def ajax_process
        @compcodes       = session[:loggedUserCompCode]
        if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
           session[:reqtypes] = params[:types]
           session[:req_sewdarcode] = params[:sewacode]
           respond_to do |format|
             format.json { render :json => { 'data'=>'', "message"=>'',:status=>true} }
           end
          return
       end
    
    end

   def show
    @compcodes       = session[:loggedUserCompCode]   
    @seawdarsobj     = nil
    @sewadarpersonal = nil
    @empChecked      = nil
    @EmpKyc          = nil
    @EmpKycBank      = nil
    @EmpKycQulifc    = nil
    @EmpKycFamily    = nil
    @EmpWorkExp      = nil
    @EmpStatelist    = nil
    @EmpDistrict     = nil
    @Hodlisted       = nil
    @EmpDepartment   = nil
    @compDetail      = MstCompany.where(["cmp_companycode = ?", @compcodes]).first
    if session[:req_sewdarcode] !=nil && session[:req_sewdarcode] !='' 
       get_all_formats_data();
    end
     rooturl       = "#{root_url}"
     if params[:id] != nil && params[:id] != ''
       docsid  = session[:reqtypes]
       if docsid == 'EXG'
           @voucherdata  =  [] #print_sewadar_salary
           respond_to do |format|
               format.html
               format.pdf do
                  pdf = ExgratiaPdf.new(@seawdarsobj,@compDetail,rooturl,@sewadarpersonal,@empChecked,@EmpKyc,@EmpKycBank,@EmpKycQulifc,@EmpKycFamily,@EmpWorkExp,@EmpStatelist,@EmpDistrict,@Hodlisted,@EmpDepartment)
                  send_data pdf.render,:filename => "1_full_final_report.pdf", :type => "application/pdf", :disposition => "inline"
               end
            end
        end   
   end

end
   

private
def get_all_formats_data
@compCodes       = session[:loggedUserCompCode]
if session[:req_sewdarcode] != nil && session[:req_sewdarcode] != ''       
    @seawdarsobj     = MstSewadar.where("sw_compcode =? AND sw_sewcode = ?",@compCodes,session[:req_sewdarcode]).first  
    
    if @seawdarsobj
            @sewadarpersonal = get_personal_information(@compCodes,@seawdarsobj.sw_sewcode)
            @empChecked      = get_office_information(@compCodes,@seawdarsobj.sw_sewcode)
            @EmpKyc          = get_sewadar_kyc_information(@compCodes,@seawdarsobj.sw_sewcode)
            @EmpKycBank      = get_sewadar_kyc_bankdetail(@compCodes,@seawdarsobj.sw_sewcode)
            @EmpKycQulifc    = get_sewadar_kyc_qualification(@compCodes,@seawdarsobj.sw_sewcode)
            @EmpKycFamily    = get_sewadar_kyc_family(@compCodes,@seawdarsobj.sw_sewcode)
            @EmpWorkExp      = get_sewadar_work_experience(@compCodes,@seawdarsobj.sw_sewcode)
            @EmpDepartment   = get_all_department_detail( @seawdarsobj.sw_depcode)

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
