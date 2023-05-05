## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: VIEW SEWADAR ALL RELATED DATA
### FOR REST API ######
class SewadarDashboardController < ApplicationController
   before_action :require_login
   before_action :allowed_security
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
   include ErpModule::Common
   helper_method :get_sel_brand,:currency_formatted,:year_month_days_formatted,:formatted_date,:set_ent,:set_dct,:get_first_my_sewadar,:format_oblig_date
   helper_method :get_all_department_detail,:get_sewdar_designation_detail,:get_district_detail,:get_state_detail,:get_my_selected_department_code
   helper_method :get_name_global_qualification
  def index
      sewadarcode      = session[:sec_sewdar_code]
      @compCodes       = session[:loggedUserCompCode]
      @seawdarsobj     = nil
      @sewadarpersonal = nil
      @empChecked      = nil
      @EmpKyc          = nil
      @EmpKycBank      = nil
      @EmpKycQulifc    = nil
      @EmpKycFamily    = nil
      @EmpWorkExp      = nil
      if ( sewadarcode !=nil && sewadarcode !='' || params[:id].to_i >0 )
       
        if params[:id].to_i >0
          @seawdarsobj     = MstSewadar.where("sw_compcode =? AND id = ?",@compCodes,params[:id].to_i).first
        else
          @seawdarsobj     = MstSewadar.where("sw_compcode =? AND sw_sewcode = ?",@compCodes,sewadarcode).first
        end
        
        
        if @seawdarsobj
              @sewadarpersonal = get_personal_information(@compCodes,@seawdarsobj.sw_sewcode)
              @empChecked      = get_office_information(@compCodes,@seawdarsobj.sw_sewcode)
              @EmpKyc          = get_sewadar_kyc_information(@compCodes,@seawdarsobj.sw_sewcode)
              @EmpKycBank      = get_sewadar_kyc_bankdetail(@compCodes,@seawdarsobj.sw_sewcode)
              @EmpKycQulifc    = get_sewadar_kyc_qualification(@compCodes,@seawdarsobj.sw_sewcode)
              @EmpKycFamily    = get_sewadar_kyc_family(@compCodes,@seawdarsobj.sw_sewcode)
              @EmpWorkExp      = get_sewadar_work_experience(@compCodes,@seawdarsobj.sw_sewcode)
        end

      end
  end

  def create
    
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
