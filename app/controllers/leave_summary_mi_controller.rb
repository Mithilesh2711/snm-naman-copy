class LeaveSummaryMiController < ApplicationController

    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_emp_attached_file,:get_employee_types,:get_leavemaster_detail
    helper_method :get_all_department_detail,:get_link_image,:format_oblig_date,:get_mysewdar_list_details,:get_first_my_sewadar,:get_global_office_detail
    helper_method :get_sewa_all_department,:get_sewa_all_rolesresp,:user_detail,:get_all_opening_balance,:get_department_detail,:get_first_my_sewadar
    helper_method :get_opening_balance,:get_credited_leave_listed,:get_user_availed_listings
    def index
      @compCodes        =  session[:loggedUserCompCode]
      @sewadarCategory  =  MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
      @sewcoded         =  nil
      @newsewdarList    =  nil
      @ListDist         =  nil
      @LeavePermit      =  nil
      @lockEdited       =  true
      mydeprtcode       =  ""
      category          =  ""
      @LeaveCategory    =  ""
      neywsr            = Date.today.strftime("%Y")
      @SessFromDate     = "2022-01-01"
      @SessEnddate      = neywsr.to_s+"-12-31"
  
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
      search_sewadar     =   params[:al_sewadarcode]!=nil && params[:al_sewadarcode]!=nil ? params[:al_sewadarcode].to_s.strip : session[:alrequest_sewadar_name]
      voucher_department =   params[:ls_depcode]!=nil && params[:ls_depcode]!=nil ? params[:ls_depcode] : session[:alvoucher_department]
   
    if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
        @markedXAllowed  =   false
        @newsewdarList   =   MstSewadar.where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")
    elsif session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'stf'
        @markedXAllowed  =   false
        @newsewdarList   =   MstSewadar.where("sw_compcode = ? AND sw_depcode = ?",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")
    else
        if voucher_department !=nil && voucher_department !=''
           @newsewdarList   =   MstSewadar.where("sw_compcode = ? AND sw_depcode = ?",@compCodes,voucher_department).order("sw_sewadar_name ASC")
        end
      end    
   
      @ListLeaveSummary = search_taken_leave_list()
     
    end
  
    def search_taken_leave_list
        if params[:requestserver]!=nil && params[:requestserver]!=''
            session[:reqst_departments]  = nil
            session[:reqst_sewadar_code] = nil
            session[:reqst_from_date]    = nil
            session[:reqst_upto_date]    = nil
            session[:reqst_leave_type]   = nil
        else
          return 
        end

       departments   = params[:ls_depcode]!=nil && params[:ls_depcode]!='' ? params[:ls_depcode] : ''
       from_date     = params[:from_date]!=nil && params[:from_date]!='' ? params[:from_date] : ''
       upto_date     = params[:upto_date]!=nil && params[:upto_date]!='' ? params[:upto_date] : ''
       leave_type    = params[:leave_type]!=nil && params[:leave_type]!='' ? params[:leave_type] : ''
       sewadar_code  = params[:ls_empcode]!=nil && params[:ls_empcode]!='' ? params[:ls_empcode] : ''

      iswhere = "sw_compcode ='#{@compCodes}'"
      if departments !=nil && departments !=''
          iswhere += " AND UPPER(sw_depcode)=UPPER('#{departments}')"
          session[:reqst_departments] = departments
          @departments   = departments
      end
      if sewadar_code !=nil && sewadar_code !=''      
          iswhere += " AND UPPER(sw_sewcode) = UPPER('#{sewadar_code}')"
          session[:reqst_sewadar_code] = sewadar_code
          @sewadar_code                = sewadar_code
      end
      if from_date !=nil && from_date!=''        
          session[:reqst_from_date] = from_date
          @from_date                = from_date
      end
      if upto_date !=nil && upto_date!=''        
          session[:reqst_upto_date] = upto_date
          @upto_date               = upto_date
      end
      if leave_type !=nil && leave_type !=''
          session[:reqst_leave_type] = leave_type
          @leave_type              = leave_type
      end
      isselect = "sw_sewcode,sw_sewadar_name,sw_gender,sw_catgeory,sw_catcode,sw_desigcode,sw_depcode,sw_joiningdate,sw_leavingdate,sw_oldsewdarcode"
      listobj =  MstSewadar.select(isselect).where(iswhere).order("sw_catgeory ASC,sw_sewadar_name")
      return listobj
    end
    
  
  def get_sewadar_leave_detail()
    compcode   =  session[:loggedUserCompCode]  
    # itemsarra  =  []   
    #  crediobj   = get_credited_leave_listed(compcode,sewcode,fromdate,uptodate,leavecode)
    #  if crediobj.length >0
    #      crediobj.each do |newbls|
    #          itemsarra.push newbls
    #     end
  
    #  end
    # availobj   =  get_user_availed_listings(compcode,sewcode,fromdate,uptodate,leavecode)
    # if availobj.length >0
    #     availobj.each do |newobx|
    #         itemsarra.push newobx
    #     end
    # end
    # codobj = get_co_od_request(compcode,sewcode,fromdate,uptodate,leavecode)
    # if codobj.length >0
    #    codobj.each do |newobx|
    #     itemsarra.push newobx
    #    end
    # end
      
    # return itemsarra
  
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
       leavtk    = 0
       iswhere   = "ls_compcode ='#{compcode}' AND ls_status ='A' AND ls_empcode = '#{sewacode}' AND ls_leave_code ='#{leavecode}'"       
       iswhere   += " AND ( ls_fromdate BETWEEN '#{year_month_days_formatted(fromdated)}' AND '#{year_month_days_formatted(uptodated)}' ) "
       isselect  =  "SUM(ls_nodays) as tleave"
       leaveobj = TrnLeave.select(isselect).where(iswhere).first 
       if leaveobj
            leavtk = leaveobj.tleave
       end
       return leavtk
       
     end
  
  
  def get_credited_leave_listed(compcode,sewacode,fromdated,uptodated,leavecode)
        leavtk    = 0
        iswhere = "cl_compcode ='#{compcode}' AND cl_sewacode ='#{sewacode}' AND cl_leavecode='#{leavecode}'"       
        if fromdated !=nil && fromdated !='' 
            iswhere  += " AND cl_creditdate >='#{year_month_days_formatted(fromdated)}'"
        end 
        if uptodated !=nil && uptodated !='' 
            iswhere  += " AND cl_creditdate <='#{year_month_days_formatted(uptodated)}'"
        end        
        isselect  = "SUM(cl_creditdays) as tleave"
        lvsobj  = TrnCreditLeave.select(isselect).where(iswhere).first
        if lvsobj
          leavtk = lvsobj.tleave
        end
        return leavtk
  end
  
 
  
  
  
  private
  def get_co_od_request(compcode,sewacode,fromdated,uptodated,leavecode)
       ltaken     = 0
       iswherex   = "ls_compcode ='#{compcode}' AND ls_status ='A' AND ls_leave_code ='#{leavecode}'"   
       iswherex   += " AND ( ls_fromdate BETWEEN '#{year_month_days_formatted(fromdated)}' AND ls_fromdate '#{year_month_days_formatted(uptodated)}' ) "            
       isselect    = "SUM(ls_nodays) as tleave"  
       odrqobj = TrnRequestCoOd.select(isselect).where(iswherex).first
       if odrqobj
          ltaken = odrqobj.tleave
       end
       return ltaken
  end
  
 
  private
  def get_opening_balance(sewcode,leavecode,fromdated,uptodated)
      compcode   =  session[:loggedUserCompCode] 
      availleave =  get_avail_leave_ob(compcode,sewcode,fromdated,leavecode)
      creditedlv =  get_credited_leave_ob(compcode,sewcode,fromdated,leavecode)
      reqcod     =  get_cood_leave_ob(compcode,sewcode,fromdated,leavecode)
      if leavecode.to_s == 'EL' || leavecode.to_s == 'CL' || leavecode.to_s == 'CO'
        obs        =  get_all_opening_balance(sewcode,leavecode)
      else
        obs        =  0
      end
      
      totals     =  (obs.to_f+creditedlv.to_f+reqcod.to_f).to_f-availleave.to_f
      return totals
  end
  def get_avail_leave_ob(compcode,sewacode,fromdated,leavecode)
    tcounts   = 0
    iswhere   =  "ls_compcode ='#{compcode}' AND ls_status ='A'"
    iswhere   += " AND ls_empcode = '#{sewacode}'  AND ls_fromdate <'#{year_month_days_formatted(fromdated)}'"
    iswhere   += " AND ls_leave_code ='#{leavecode}'"    
    isselect  =  " SUM(ls_nodays) as tleaves"
    leaveobj  = TrnLeave.select(isselect).where(iswhere).first
    if leaveobj
        tcounts = leaveobj.tleaves
    end
    return tcounts
  end
  def get_credited_leave_ob(compcode,sewacode,fromdated,leavecode)
        tcounts  =  0
        iswhere  =  " cl_compcode ='#{compcode}' AND cl_creditdate <'#{year_month_days_formatted(fromdated)}'"
        iswhere  += " AND cl_leavecode ='#{leavecode}' AND cl_sewacode ='#{sewacode}'"      
        isselect  = "SUM(cl_creditdays) as tleave"
        lvsobj  = TrnCreditLeave.select(isselect).where(iswhere).first
        if lvsobj
            tcounts = lvsobj.tleave
        end
        return tcounts
  end
  def get_cood_leave_ob(compcode,sewacode,fromdated,leavecode)
    tcounts   = 0
    iswhere   = "ls_compcode ='#{compcode}' AND ls_status='A' AND ls_fromdate <'#{year_month_days_formatted(fromdated)}'" 
    iswhere   += " AND ls_leave_code ='#{leavecode}' AND ls_empcode = '#{sewacode}'"
    isselect  = "SUM(ls_nodays) as tleaves"
    leaveobj  = TrnRequestCoOd.select(isselect).where(iswhere).first
    if leaveobj
        tcounts = leaveobj.tleaves
    end
    return tcounts
  end

  private
def get_all_opening_balance(sewcode,leavecode)
  compcode   =  session[:loggedUserCompCode] 
  newobs     = 0 
  mywhere    = " lb_compcode ='#{compcode}' AND lb_empcode ='#{sewcode}' AND lb_leavecode ='#{leavecode}'"  
  oblsobj    = TrnLeaveBalance.select("SUM(lb_openbal) as tleavs").where(mywhere).first
   if oblsobj
       newobs = oblsobj.tleavs
   end
   return newobs

end

end
