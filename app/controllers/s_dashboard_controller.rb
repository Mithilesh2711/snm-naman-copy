## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: VIEW SEWADAR ALL RELATED DATA
### FOR REST API ######
class SDashboardController < ApplicationController
   before_action :require_login
   before_action :allowed_security
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
   include ErpModule::Common
   helper_method :get_sel_brand,:currency_formatted,:year_month_days_formatted,:formatted_date,:set_ent,:set_dct,:get_first_my_sewadar,:format_oblig_date
   helper_method :get_all_department_detail,:get_sewdar_designation_detail,:get_district_detail,:get_state_detail,:get_my_selected_department_code
   helper_method :get_name_global_qualification,:get_leavemaster_detail,:get_creditleave_detail,:get_leave_taken
   helper_method :get_unapproved_leave_request,:get_unapproved_advance_loan,:get_department_detail,:get_all_opening_balance
  def index
      sewadarcode      = session[:sec_sewdar_code]
      @compCodes       = session[:loggedUserCompCode]
      @SessFromDate     = "2022-01-01"
      @SessEnddate      = "2022-12-31"
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
      @leaveLedger     = nil 
      @advListobj      = nil   
      if ( sewadarcode !=nil && sewadarcode !='' || params[:id].to_i >0 )
          sewacode = sewadarcode !=nil && sewadarcode !='' ? sewadarcode : params[:id].to_i
          if params[:id].to_i >0
            @seawdarsobj     = MstSewadar.where("sw_compcode =? AND id = ?",@compCodes,params[:id].to_i).first
          else
            @seawdarsobj     = MstSewadar.where("sw_compcode =? AND sw_sewcode = ?",@compCodes,sewadarcode).first
          end
          @leaveLedger    =   print_sewdar_leave_balances()
          if session[:sec_ec_approved] && ( session[:sec_ec_approved].to_s =='ec' || session[:sec_ec_approved].to_s =='cod' )
            @ListSewBirth   =   get_birth_of_orgmember(session[:sec_ecmem_code])
          else
            @ListSewBirth   =   get_birth_of_sewadar(sewacode)
          end
          
          isselection     =   "SUM(ls_nodays) as takenleave,ls_empcode,ls_depcode,ls_leave_code"
          @leaveXListed   =   TrnLeave.select(isselection).where("ls_compcode = ? AND ls_empcode = ? AND ls_status='A'",@compCodes,sewacode).group("ls_leave_code").order("ls_leave_code")
          nselected       =   "(al_advanceamt+al_loanamount) as adamounts,al_installpermonth as totalemi,al_requesttype,al_approvestatus,al_compcode,al_installpermonth,YEAR(al_boucherdate) as mymonths,MONTH(al_boucherdate) as myyears,al_sewadarcode,'' as totalpaid"
          @advListobj     =   TrnAdvanceLoan.select(nselected).where("al_compcode =? AND al_sewadarcode = ? AND al_balances >0",@compCodes,sewacode).order("al_requesttype")
          @LeaveUnapprove =   get_unapproved_leave_request(sewacode,'P')
          @AdvUnapprove   =   get_unapproved_advance_loan(sewacode)
          @TrnRaiseTicket =   TrnRaiseTicket.where(["rt_compcode = ? AND rt_status = 'O' AND rt_sewadar = ?", @compCodes,sewacode]).order('rt_ticketno ASC')
    end

     @listAnnouncement    = TrnAnnouncement.where("ans_compcode = ? AND DATE(ans_publishdate) = DATE(NOW()) AND ans_status = 'Y'",@compCodes).order("ans_publishdate DESC")
     @ListAbsents         = get_currentmonth_absent_listed()
     @ListLeaveTakens     = get_total_taken_leavelisted()
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

  def print_sewdar_leave_balances
     compcode   =  session[:loggedUserCompCode]  
     if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
       sewcode    =  session[:sec_sewdar_code]
    else
       sewcode    =  params[:al_sewadarcode]!=nil && params[:al_sewadarcode]!=nil ? params[:al_sewadarcode].to_s.strip : '' 
    end
          
     itemsarra  =  []
    
      crediobj   = get_credited_leave_listed(compcode,sewcode,'','','')
      if crediobj.length >0
          crediobj.each do |newbls|
              itemsarra.push newbls
         end
   
      end
     availobj   =  get_user_availed_listings(compcode,sewcode,'','','')
     if availobj.length >0
         availobj.each do |newobx|
             itemsarra.push newobx
         end
     end
     newarrays = []
     if itemsarra.length >0
       TrnTempLeaveSummary.all.destroy_all
         itemsarra.each do |newbts|
             merge_leave_types(compcode,newbts.leavecode,newbts.tleave,newbts.mytpe)
         end
         isselect  = "tls_leavetype as leavecode,SUM(tls_credit) as credits,SUM(tls_debit) as debits"
         newarrays = TrnTempLeaveSummary.select(isselect).all.group("tls_leavetype")
     end
   
     return newarrays
   
   end
   
   
   private
   def merge_leave_types(compcode,leavetype,tkens,type)
     credit = 0
     debits = 0
     if type == 'dbt'
       debits = tkens
     else
       credit = tkens
     end
       tlsobj = TrnTempLeaveSummary.new(:tls_compcode=>compcode,:tls_leavetype=>leavetype,:tls_credit=>credit,:tls_debit=>debits)
       if tlsobj.save
   ###
       end
   end
   
   
   private
   def get_user_availed_listings(compcode,sewacode,fromdated,uptodated,leavecode)
      
        iswherex   = "ls_compcode ='#{compcode}' AND ls_status ='A'"
        
        iswherex  += " AND ls_fromdate >='#{@SessFromDate}' "
        iswherex  += " AND ls_todate <='#{@SessEnddate}'"
          
        iswherex  += " AND ls_empcode = '#{sewacode}'"
           
        isselect  = "ls_nodays as tleave,ls_fromdate,ls_todate,ls_leave_code as leavecode,ls_empcode  as sewacode,'dbt' as mytpe"
        leaveobj = TrnLeave.select(isselect).where(iswherex) #.group("ls_leave_code")
        return leaveobj
        
      end
   
   
   def get_credited_leave_listed(compcode,sewacode,fromdated,uptodated,leavecode)
    
         iswhere = "cl_compcode ='#{compcode}'"
         if leavecode !=nil && leavecode !='' && leavecode !='All'
             iswhere  += " AND cl_leavecode ='#{leavecode}'"
         end
         if fromdated !=nil && fromdated !='' 
             iswhere  += " AND cl_creditdate >='#{fromdated}'"
         end 
         if uptodated !=nil && uptodated !='' 
             iswhere  += " AND cl_creditdate <='#{uptodated}'"
         end 
         iswhere  += " AND cl_sewacode ='#{sewacode}'"
         arritems = []
         isselect  = "cl_creditdays as tleave,cl_leavecode as leavecode,cl_sewacode  as sewacode,'cdt' as mytpe"
         lvsobj  = TrnCreditLeave.select(isselect).where(iswhere).order("cl_leavecode ASC")#.group("cl_leavecode")
         if lvsobj.length >0
             lvsobj.each do |newd|
                 arritems.push newd 
   
             end
         end
         return arritems
   end
   
   private
   def get_all_opening_balance(leavecode="")
     compcode   =  session[:loggedUserCompCode] 
     if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
        sewcode    =  session[:sec_sewdar_code]
     else
        sewcode    =  params[:al_sewadarcode]!=nil && params[:al_sewadarcode]!=nil ? params[:al_sewadarcode].to_s.strip : '' 
     end
     
     # availleave =  get_avail_leave_ob(compcode,sewcode,'','','')
     # creditedlv =  get_credited_leave_ob(compcode,sewcode,'','','')
     
     mywhere    =  " lb_compcode ='#{compcode}' AND lb_empcode ='#{sewcode}'"  
     if leavecode != nil && leavecode != ''
         mywhere  += " AND lb_leavecode ='#{leavecode}'"
     end 
     newobs     = 0       
      oblsobj   = TrnLeaveBalance.select("SUM(lb_openbal) as tleavs").where(mywhere).first
      if oblsobj
          newobs = oblsobj.tleavs
      end
      fobalance  = newobs #(newobs.to_f+creditedlv.to_f).to_f-availleave.to_f
      return fobalance
   
   end
   
   def get_avail_leave_ob(compcode,sewacode,fromdated,uptodated,leavecode)
     tcounts = 0
     iswhere   = "ls_compcode ='#{compcode}' AND ls_status ='A'"
     if leavecode !=nil && leavecode !='' && leavecode !='All'
         iswhere  += " AND ls_leave_code ='#{leavecode}'"
     end
     if fromdated !=nil && fromdated !='' 
         iswhere  += " AND ls_fromdate <'#{fromdated}'"
     else
       iswhere  += " AND ls_fromdate >='#{@SessFromDate}' AND ls_fromdate <='#{@SessEnddate}'"
           
     end 
     
     iswhere  += " AND ls_empcode = '#{sewacode}'"       
     isselect  = "SUM(ls_nodays) as tleaves"
     leaveobj  = TrnLeave.select(isselect).where(iswhere).first
     if leaveobj
         tcounts = leaveobj.tleaves
     end
     return tcounts
   end
   def get_credited_leave_ob(compcode,sewacode,fromdated,uptodated,leavecode)
     
     tcounts = 0
         iswhere = "cl_compcode ='#{compcode}'"
         if leavecode !=nil && leavecode !='' && leavecode !='All'
             iswhere  += " AND cl_leavecode ='#{leavecode}'"
         end
         if fromdated !=nil && fromdated !='' 
             iswhere  += " AND cl_creditdate <'#{fromdated}'"
          else
           iswhere  += " AND cl_creditdate <'#{@SessFromDate}'" 
         end 
         iswhere  += " AND cl_sewacode ='#{sewacode}'"
         isselect  = "SUM(cl_creditdays) as tleave"
         lvsobj  = TrnCreditLeave.select(isselect).where(iswhere).first
         if lvsobj
             tcounts = lvsobj.tleave
         end
         return tcounts
   end

  private
 def get_currentmonth_absent_listed
  compcodes  = session[:loggedUserCompCode]
  sewacode   = session[:sec_sewdar_code]  
  tcounts    = 0
  iswhere    = "al_compcode = '#{compcodes}' AND al_empcode='#{sewacode}' AND MONTH(al_trandate)=MONTH(NOW()) AND al_absent>0 "
  isselect   = "COUNT(*) as totalabsent"
  chekattd = TrnAttendanceList.select(isselect).where(iswhere).first
  if chekattd
    tcounts = chekattd.totalabsent
    if tcounts.to_i >31
      tcounts = 31
    end
  end
  return tcounts

 end

 def get_total_taken_leavelisted
  compcodes  = session[:loggedUserCompCode]
  sewacode   = session[:sec_sewdar_code]  
  tcounts    = 0
  iswhere   = "ls_compcode ='#{compcodes}' AND ls_status ='A' AND UPPER(ls_leave_code) NOT IN('LWM','CO','OD') AND lower(`ls_leavereson`)<>'forfeit' "
  iswhere   += " AND ls_empcode = '#{sewacode}' AND ( MONTH(ls_fromdate) = MONTH(NOW()) OR MONTH(ls_todate)= MONTH(NOW()) )"
  isselect  = "COUNT(*) as tleaves"
  leaveobj  = TrnLeave.select(isselect).where(iswhere).first
  if leaveobj
      tcounts = leaveobj.tleaves
  end
  return tcounts

end


end
