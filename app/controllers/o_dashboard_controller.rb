class ODashboardController < ApplicationController

    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :get_sel_brand,:currency_formatted,:year_month_days_formatted,:formatted_date,:set_ent,:set_dct,:get_first_my_sewadar,:format_oblig_date
    helper_method :get_all_department_detail,:get_sewdar_designation_detail,:get_district_detail,:get_state_detail,:get_my_selected_department_code
    helper_method :get_name_global_qualification,:get_leavemaster_detail,:get_creditleave_detail,:get_leave_taken
    helper_method :get_unapproved_leave_request,:get_unapproved_advance_loan,:get_department_detail
   def index
       sewadarcode      = session[:sec_ecmem_code]
       @compCodes       = session[:loggedUserCompCode]
       
       @seawdarsobj     = nil
       @sewadarpersonal = nil
       @empChecked      = nil
       @EmpKyc          = nil
       @EmpKycBank      = nil
       @EmpKycQulifc    = nil
       @EmpKycFamily    = nil
       @EmpWorkExp      = nil
       @leaveXListed    = nil
       @BirthdayList    = MstBirthdayWish.where("bw_compcode = ?",@compCodes).first
       iswheres         = "compCode ='#{@compCodes}' AND DATE(dateYear)>=DATE(NOW())"
       @Holidaylisted   = Holiday.where(iswheres).order("dateYear ASC").first
       
       if ( sewadarcode !=nil && sewadarcode !='' || params[:id].to_i >0 )
         sewacode = sewadarcode !=nil && sewadarcode !='' ? sewadarcode : params[:id].to_i
         ismyselect = "lds_profile as sw_image,lds_name as sw_sewadar_name"
         if params[:id].to_i >0
             @seawdarsobj     =  MstLedger.select(ismyselect).where("lds_compcode = ? AND id = ?",@compCodes,params[:id].to_i).first
         else
             @seawdarsobj     =  MstLedger.select(ismyselect).where("lds_compcode = ? AND id = ?",@compCodes,sewadarcode.to_i).first
         end
      
           @ListSewBirth   =   get_birth_of_sewadar(sewacode)
          # isselection     =   "SUM(ls_nodays) as takenleave,ls_empcode,ls_depcode,ls_leave_code"
           @leaveXListed   =   [] #TrnLeave.select(isselection).where("ls_compcode = ? AND ls_empcode = ? AND ls_status='A'",@compCodes,sewacode).group("ls_leave_code").order("ls_leave_code")
          # nselected       =   "(SUM(al_advanceamt)+SUM(al_loanamount)) as adamounts,SUM(al_installpermonth) as totalemi,al_requesttype,al_compcode,al_installpermonth,YEAR(al_boucherdate) as mymonths,MONTH(al_boucherdate) as myyears,al_sewadarcode,'' as totalpaid"
           @advListobj     =   # [] TrnAdvanceLoan.select(nselected).where("al_compcode =? AND al_balances >0",@compCodes).group("MONTH(al_boucherdate),al_requesttype").order("al_requesttype")
           @LeaveUnapprove =  [] #get_unapproved_leave_request(sewacode,'P')
           @AdvUnapprove   =  [] # get_unapproved_advance_loan(sewacode)
           @TrnRaiseTicket =   []
     end
 
      @listAnnouncement    =  TrnAnnouncement.where("ans_compcode = ? AND DATE(ans_publishdate) = DATE(NOW()) AND ans_status = 'Y'",@compCodes).order("ans_publishdate DESC")
      
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
        sewdarobj =  MstSewadarKycQualification.where("skq_compcode =? AND skq_sewcode = ?",compcode,sewcode).order("skq_passingyear ASC")
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
