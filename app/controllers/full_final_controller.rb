class FullFinalController < ApplicationController
     before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_sewdar_designation_detail,:get_all_department_detail
    helper_method :get_mysewdar_list_details,:get_monthyeardays_diffdate
   def index

    @compCodes         = session[:loggedUserCompCode]
    month_number       = Time.now
    begdate            = Date.parse(month_number.to_s)
    @nbegindate        = 2021
    nedatas            = []
    @CurrentYear       = Time.now.strftime("%Y")
    @CurrentMonth      = Time.now.strftime("%m")
    @mydepartcode      = ''
    @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")   
    mydeprtcode        = ""
    @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
    if session[:sec_sewdar_code] != nil
          sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
          if sewobjs  
              @mydepartcode = sewobjs.sw_depcode
              mydeprtcode   = sewobjs.sw_depcode
          end
    end
    @monthsx = ""
    @yearsx  = ""
    if  @HeadHrp
      @monthsx = @HeadHrp.hph_months
      @yearsx  = @HeadHrp.hph_years
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
     
    @fullfinallisted = get_full_final_list
      

   end
   def show
    @compCodes       = session[:loggedUserCompCode]
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
    @PaymonthList    = nil
    @LastMonths      = nil
    rooturl       = "#{root_url}"
    preparedby    = ""
    @compDetail      = MstCompany.where(["cmp_companycode = ?", @compCodes]).first
    if params[:id] !=nil && params[:id] !=''
        docs  = params[:id].to_s.split("_")
        if docs[1] == 'prt'
              @listFullFinal  = TrnFullFinal.where("ff_compcode =? AND id = ?",@compCodes,docs[2].to_i).first
              if @listFullFinal
                get_all_formats_data(@listFullFinal.ff_sewacode,@listFullFinal.ff_leavingdate)
                  userobj = user_detail(@listFullFinal.ff_preparedby)
                  if userobj
                        preparedbyid = userobj.sewadarcode
                        sobjsx       = get_mysewdar_list_details(preparedbyid)
                        if sobjsx
                            preparedby = sobjsx.sw_sewadar_name
                        end
                  end
              end          

                respond_to do |format|
                  format.html
                  format.pdf do
                  pdf = ExgratiaPdf.new(@seawdarsobj,@compDetail,rooturl,@sewadarpersonal,@empChecked,@EmpKyc,@EmpKycBank,@EmpKycQulifc,@EmpKycFamily,@EmpWorkExp,@EmpStatelist,@EmpDistrict,@Hodlisted,@EmpDepartment,@listFullFinal,@PaymonthList,@LastMonths,preparedby)
                  send_data pdf.render,:filename => "1_prt_full_and_final_report.pdf", :type => "application/pdf", :disposition => "inline"
                  end
                end	
        end
      end
   end

    def create
        @compCodes = session[:loggedUserCompCode]
   isFlags    = true
    ApplicationRecord.transaction do
    #begin
        if params[:ff_departcode] == nil || params[:ff_departcode] == ''
           flash[:error] =  "Department is required."
           isFlags = false
        elsif params[:ff_sewacode] == nil || params[:ff_sewacode] == ''
           flash[:error] =  "Sewdar code is required."
           isFlags = false      
        elsif   params[:ff_leavingdate] == nil || params[:ff_leavingdate] == ''
           flash[:error] =  "Leaving date is required."
           isFlags = false
         elsif   params[:ff_fullandfinaldate] == nil || params[:ff_fullandfinaldate] == ''
           flash[:error] =  "Full and final date is required."
           isFlags = false
        elsif   params[:ff_datejoing] == nil || params[:ff_datejoing] == ''
            flash[:error] =  "Date of joining is required."
            isFlags = false   
        else
            mid          = params[:mid]  
            empcode      = params[:ff_sewacode]         
            if mid.to_i >0
                 
                  if isFlags
                     stateupobj  = TrnFullFinal.where("ff_compcode = ? AND id = ?",@compCodes,mid).first
                      if stateupobj
                            stateupobj.update(ff_params) 
                            update_leavingdate_details(params[:ff_sewacode],params[:ff_leavingdate],params[:ff_fullandfinaldate],params[:ff_leavingreason]) 
                            update_elenchash(@compCodes,params[:ff_sewacode],params[:ff_leavingdate],params[:ff_totalel],params[:ff_encashel])                         
                            flash[:error] =  "Data updated successfully."
                            isFlags      =  true
                      end
                  end
            else
                    if isFlags
                          stateupobj  = TrnFullFinal.where("ff_compcode = ? AND ff_sewacode = ?",@compCodes,empcode)  
                          if stateupobj.length >0
                                flash[:error] =  "Full and final is already applied as selected sewadar (#{empcode})."
                                isFlags       =  false
                          end
                      end

                       if isFlags
                            stsobj = TrnFullFinal.new(ff_params)
                            if stsobj.save 
                               update_leavingdate_details(params[:ff_sewacode],params[:ff_leavingdate],params[:ff_fullandfinaldate],params[:ff_leavingreason])                              
                               update_elenchash(@compCodes,params[:ff_sewacode],params[:ff_leavingdate],params[:ff_totalel],params[:ff_encashel])
                               flash[:error] =  "Data saved successfully."
                               isFlags = true
                            end

                       end
            end
        end
      #     rescue Exception => exc
      #     flash[:error] =   "#{exc.message}"
      #     session[:isErrorhandled] = 1
      #     raise ActiveRecord::Rollback
      #     isFlags = false
      # end
    end
     if !isFlags
       #  session[:request_params] = params
         session[:isErrorhandled] = 1
         isFlags = false
     else
         session[:request_params] = nil
         session[:isErrorhandled] = nil
         session.delete(:request_params)
     end
     if isFlags
       redirect_to "#{root_url}"+"full_final"
     else
       redirect_to "#{root_url}"+"full_final/add_fullfinal"
     end


    end


   def add_fullfinal
            @compCodes         = session[:loggedUserCompCode]
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
    @compCodes       = session[:loggedUserCompCode]
    if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
		get_sewdar_listing_by_department();
		return
    elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'SWCD'
		get_sewdarselected();
		return    
   elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'GRAT'
	   	process_gratia_detail();
	  	return    
    elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'PMDATA'
        get_paymonth_data_listed();
        return    
   elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'TOTSERVICE'
        get_total_sewa_of_sewadar();
        return    
    end

    

 end
   private
 def get_sewdar_listing_by_department
    isflags   = false
    sedarname = []
    depcode = params[:depcode]
    iswhere = "sw_compcode ='#{@compCodes}' AND sw_depcode ='#{depcode}'"
    sewobj  =  MstSewadar.select("sw_sewcode,sw_sewadar_name,sw_catgeory,sw_catcode").where(iswhere).order("sw_sewcode ASC")
    if sewobj.length >0
      isflags = true
      sedarname = get_newsewdar_list(depcode)
    end
     respond_to do |format|
        format.json { render :json => { 'data'=>sewobj,'sedarname'=>sedarname,"message"=>'',:status=>isflags} }
      end
 end


 private
 def get_paymonth_data_listed
    isflags       =  false  
    empcode       =  params[:empcode]
    leavingdate   =  params[:leavingdate]
     pmsobj       =  get_paymonthly_list_data(@compCodes,empcode,leavingdate,'clt')
     if pmsobj
         isflags = true
     end
      respond_to do |format|
        format.json { render :json => { 'data'=>pmsobj,"message"=>'',:status=>isflags} }
      end
 end

 private
 def get_total_sewa_of_sewadar
      isflags     =  false  
      totalsewa   =  0
      totals      = 0
      beforelwmdt = ""
      sewcode     =  params[:sewcode]   
      leavingdate =  params[:leavingdate]
      if leavingdate != nil && leavingdate != ''
            isselect    = "sw_joiningdate,sw_prevlwm"
            iswhere     =  "sw_compcode ='#{@compCodes}' AND sw_sewcode ='#{sewcode}'"
            sewobj      =  MstSewadar.select(isselect).where(iswhere).first
            if sewobj
                lwms        = sewobj.sw_prevlwm
                totals      = get_lwm_count(sewcode)
                totals      = totals.to_i+lwms.to_i
                totalsewa   = get_monthyeardays_diffdate(year_month_days_formatted(sewobj.sw_joiningdate),leavingdate,totals)
                beforelwmdt = get_monthyeardays_diffdate(year_month_days_formatted(sewobj.sw_joiningdate),leavingdate,'')
                isflags    = true
            end
      end    
      respond_to do |format|
         format.json { render :json => { 'data'=>totalsewa,"lwm"=>totals,"beforelwmdate"=>beforelwmdt,"message"=>'',:status=>isflags} }
      end

 end

 private
 def get_lwm_count(empcode)
  compcodes = session[:loggedUserCompCode]
  lwmcounts = 0
  mylswhere = "ls_compcode ='#{compcodes}' AND ls_empcode ='#{empcode}'  AND ls_status ='A' AND ls_leave_code ='LWM'"
  leavaobj  = TrnLeave.select("SUM(ls_nodays) as totalwm").where(mylswhere).first 
  if leavaobj
     lwmcounts = leavaobj.totalwm
  end
  return lwmcounts

end
 

 private
 def get_sewdarselected
    isflags    = false
    sewcode    = params[:sewcode]
    monthlydav = params[:monthly_advance]
    leavingdate = params[:leavingdate]
	  sewdarpan  = "";
    arritem    = []
    iswhere    = "sw_compcode ='#{@compCodes}' AND sw_sewcode ='#{sewcode}'"
    isselect   = "sw_sewcode,sw_oldsewdarcode,sw_status,sw_catcode,sw_catgeory,sw_outstandingamt,sw_depcode,'' as department,sw_sewadar_name,DATE_FORMAT(sw_joiningdate,'%d-%b-%Y') as joiningdate,'' as sewduration,'' as outstatnding"
    isselect   += ",sw_isaccommodation as accomodation, '' as superannualdate,DATE_FORMAT(sw_date_of_birth,'%d-%b-%Y') as dobs,'' as advanced,'' as totalma,'' as leavebalances"
    isselect   += ",'' as elenashment,'' as dateofreguliazation,sw_leavingdate,'' as exgamount,sw_leavingdate as leavingdate"
    sewobj     =  MstSewadar.select(isselect).where(iswhere).first
    if sewobj
       isflags = true
       if sewobj
        maamount = 0
        elbal    = 0
                newsea =   sewobj
                 newsea.sewduration =   get_total_sewa_calculation(newsea.joiningdate)
                 if newsea.sw_status == 'Y'
                      newsea.outstatnding =  newsea.sw_outstandingamt
                 end
               deptobj = get_all_department_detail( newsea.sw_depcode)
                if deptobj
                  newsea.department  = deptobj.departDescription
                end
                officeobj  = get_office_information(@compCodes,sewcode)
                if officeobj
                    newsea.superannualdate      = formatted_date(officeobj.so_superannuationdate)
                    newsea.totalma              = currency_formatted(officeobj.so_basic)
                    maamount                    = currency_formatted(officeobj.so_basic)
                    dateofreguliazation         = formatted_date(officeobj.so_regularizationdate)
                    newsea.dateofreguliazation  = dateofreguliazation
                    
                end
                advntotal = 0
                exgamount = 0
                advanobj = TrnAdvanceLoan.select("(SUM(al_advanceamt)+SUM(al_loanamount)) as advanced").where("al_compcode =? AND al_sewadarcode = ? AND al_approvestatus='A' AND al_requesttype<>'Ex-gratia' ",@compCodes,sewcode).first
                if advanobj
                    advntotal = advanobj.advanced
                end
                deducttotal     = get_totaladvance_listings(@compCodes,sewcode)
                gtotals         = advntotal.to_f-deducttotal.to_f
                newsea.advanced = currency_formatted(gtotals)
                exobjsx         = TrnAdvanceLoan.select("(SUM(al_advanceamt)+SUM(al_loanamount)) as advanced").where("al_compcode =? AND al_sewadarcode = ? AND al_approvestatus='A' AND al_requesttype='Ex-gratia' ",@compCodes,sewcode).first
                if exobjsx
                  exgamount = exobjsx.advanced
                end
                newsea.exgamount = currency_formatted(exgamount)
                leaveobj = TrnLeaveBalance.select("SUM(lb_closingbal) as totals,SUM(lb_openbal) as opbalances").where("lb_compcode = ? AND lb_empcode = ? AND lb_leavecode = ?",@compCodes,sewcode,'EL').first
                if leaveobj                    
                      newsea.leavebalances = leaveobj.totals
                      elbal                = leaveobj.totals
                end
                if maamount.to_f >0
                  newamts  = maamount.to_f/30
                  finamts  = newamts.to_f*elbal.to_f
                  elenashment = currency_formatted(finamts);
                  newsea.elenashment = elenashment
               end
               
                arritem.push newsea
       end
	     panobj =  get_sewadar_kyc_information(@compCodes,sewcode)
		 if panobj
			sewdarpan = panobj.sk_panno
		 end

          
    end
   
    monthslay     = ''
    # if monthlydav == 'advance'
    #     monthslay  =  get_monthly_processed_salary_detail(sewcode)
    #     if monthslay != nil && monthslay.length  >0          
    #          ### execute parameters 
    #     else         
    #          monthslay = get_singled_monthly_advance_detail(sewcode)
    #     end
    #  end
        @HeadHrp     = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
        @HrMonths    = nil
        @Hryears     = nil
        if @HeadHrp
          @HrMonths  = @HeadHrp.hph_months
          @Hryears   = @HeadHrp.hph_years
        end
          advamounts   = 0
          adinstallamt = 0
        #   advamtsobj   = get_advance_listed_data(@compCodes,sewcode,@HrMonths)
        #   if advamtsobj
        #     advamounts    = advamtsobj.al_loanamount
        #     adinstallamt = advamtsobj.al_installpermonth
        #   end

     respond_to do |format|
        format.json { render :json => { 'data'=>arritem,'sewdarpin':sewdarpan,'monthslay'=>monthslay,'adinstallamt'=>adinstallamt,'advamounts'=>advamounts,"message"=>'',:status=>isflags} }
      end
 end

 private
 def get_totaladvance_listings(compcode,sewacode)
    totals = 0
    iswhere     = "pm_compcode = '#{compcode}' AND pm_sewacode = '#{sewacode}' AND (pm_ded_repaidloan >0  OR pm_ded_repaidadvance>0 )"       
    isselect    = "(SUM(pm_ded_repaidloan)+SUM(pm_ded_repaidadvance)) as adamounts"
    advanobj    = TrnPayMonthly.select(isselect).where(iswhere).first
    if advanobj
      totals = advanobj.adamounts
    end
  return totals
end


 private
 def get_newsewdar_list(depcode)
    iswhere = "sw_compcode ='#{@compCodes}' AND sw_depcode ='#{depcode}'"
    sewobj  =  MstSewadar.select("sw_sewcode,sw_sewadar_name").where(iswhere).order("sw_sewadar_name ASC")
    return sewobj
 end

 private
   def get_total_sewa_calculation(joiningdated)
       newdate = ''
       if joiningdated != nil && joiningdated != ''
              newdate = get_dob_calculate(year_month_days_formatted(joiningdated))
       end
       return newdate
   end
   private
   def get_sewadar_kyc_information(compcode,sewcode)
        sewdarobj =  MstSewadarKyc.where("sk_compcode =? AND sk_sewcode =?",compcode,sewcode).first
        return sewdarobj
   end
   private
   def get_advance_listed_data(compcode,sewacode,months)
    isselect  = "al_advanceamt,al_loanamount,al_installpermonth"
    iswhere   = "al_compcode='#{compcode}' AND al_sewadarcode ='#{sewacode}' AND MONTH(al_requestdate)='#{months}'"
    loansobj  = TrnAdvanceLoan.select(isselect).where(iswhere).first
   end

   private
  def get_office_information(compcode,empcode)
         sewdarobj =  MstSewadarOfficeInfo.where("so_compcode =? AND so_sewcode =?",compcode,empcode).first
         return sewdarobj
  end

  private
 def ff_params
    
    joindate    = 0
    leavingdate = 0
    supanndate  = 0
    dobs        = 0
    dtregulized = 0

    if params[:ff_datejoing] !=nil && params[:ff_datejoing] !=''
    joindate = year_month_days_formatted(params[:ff_datejoing])
    end
    if params[:ff_leavingdate] !=nil && params[:ff_leavingdate] !=''
    leavingdate = year_month_days_formatted(params[:ff_leavingdate])
    end

    if params[:ff_datesupan] !=nil && params[:ff_datesupan] !=''
    supanndate = year_month_days_formatted(params[:ff_datesupan])
    end
    if params[:ff_dob] !=nil && params[:ff_dob] !=''
    dobs = year_month_days_formatted(params[:ff_dob])
    end
    if params[:ff_datereguliazation] !=nil && params[:ff_datereguliazation] !=''
      dtregulized = year_month_days_formatted(params[:ff_datereguliazation])
    end
    params[:ff_datejoing]   = joindate
    params[:ff_leavingdate] = leavingdate
    params[:ff_datesupan]   = supanndate
    params[:ff_dob]         = dobs
    params[:ff_datereguliazation] = dtregulized
    
    params[:ff_compcode]          = session[:loggedUserCompCode]
    params[:ff_maintenancealw]    = ff_maintenancealw  = params[:ff_maintenancealw] !=nil && params[:ff_maintenancealw] !='' ? params[:ff_maintenancealw] : 0
    params[:ff_goldenhandshake]   = ff_goldenhandshake  = params[:ff_goldenhandshake] !=nil && params[:ff_goldenhandshake] !='' ? params[:ff_goldenhandshake] : 0
    params[:ff_totaladvance]      = params[:ff_totaladvance] !=nil && params[:ff_totaladvance] !='' ? params[:ff_totaladvance] : 0
    params[:ff_totalel]           = params[:ff_totalel]  !=nil && params[:ff_totalel]  !='' ? params[:ff_totalel]  : 0
    params[:ff_encashel]          = params[:ff_encashel] !=nil && params[:ff_encashel] !='' ? params[:ff_encashel] : 0
    params[:ff_exgratiatued]      = params[:ff_exgratiatued] !=nil && params[:ff_exgratiatued] !='' ? params[:ff_exgratiatued] : 0
    params[:ff_gratiaamount]      = params[:ff_gratiaamount] !=nil && params[:ff_gratiaamount] !='' ? params[:ff_gratiaamount] : 0
    params[:ff_prevsalary]        = params[:ff_prevsalary] !=nil && params[:ff_prevsalary] !='' ? params[:ff_prevsalary] : 0

    params[:ff_deductfirst]       = params[:ff_deductfirst] !=nil && params[:ff_deductfirst] !='' ? params[:ff_deductfirst] : 0
    params[:ff_deductsecond]      = params[:ff_deductsecond] !=nil && params[:ff_deductsecond] !='' ? params[:ff_deductsecond] : 0

    params[:ff_deductfirstrmk]    = params[:ff_deductfirstrmk] !=nil && params[:ff_deductfirstrmk] !='' ? params[:ff_deductfirstrmk] : ''
    params[:ff_deductsecrmk]      = params[:ff_deductsecrmk] !=nil && params[:ff_deductsecrmk] !='' ? params[:ff_deductsecrmk] : ''
    params[:ff_totallwm]          = params[:ff_totallwm] !=nil && params[:ff_totallwm] !='' ? params[:ff_totallwm] : ''
    params[:ff_beforelwmtotalsewa]= params[:ff_beforelwmtotalsewa] !=nil && params[:ff_beforelwmtotalsewa] !='' ? params[:ff_beforelwmtotalsewa] : ''
    
    ffhandshake                   = ff_maintenancealw.to_f*ff_goldenhandshake.to_f
    params[:ff_goldenhandshkamt]  = ffhandshake
    params[:ff_preparedby]        = session[:logedUserId]
    params.permit(:ff_compcode,:ff_totallwm,:ff_beforelwmtotalsewa,:ff_deductfirst,:ff_deductsecond,:ff_deductfirstrmk,:ff_deductsecrmk,:ff_preparedby,:ff_datereguliazation,:ff_departcode,:ff_sewacode,:ff_leavingdate,:ff_leavingreason,:ff_fullandfinaldate,:ff_datejoing,:ff_dob,:ff_datesupan,:ff_totalsewa,:ff_maintenancealw,:ff_totaladvance,:ff_totalel,:ff_encashel,:ff_exgratiatued,:ff_vaccant,:ff_gratiaamount,:ff_goldenhandshake,:ff_goldenhandshkamt,:ff_prevsalary)
 end

 private
 def process_gratia_detail
  dtofjoining      = params[:dtofjoining] !=nil && params[:dtofjoining] !='' ? params[:dtofjoining] : ''
  dateleaving      = params[:dateleaving] !=nil && params[:dateleaving] !='' ? params[:dateleaving] : ''
  dtereguliza      = params[:dtereguliza] !=nil && params[:dtereguliza] !='' ? params[:dtereguliza] : ''
  maamount         = params[:maamount] !=nil && params[:maamount] !='' ? params[:maamount] : 0
  elbal            = params[:elbal] !=nil && params[:elbal] !='' ? params[:elbal] : 0
  sewcode          = params[:sewcode] !=nil && params[:sewcode] !='' ? params[:sewcode] : ''
  commndated       = ""
  graiatiaz        = ""
  gratiaamont      = 0
  totals           = ""
  isflags          = false
    if dtereguliza !=nil && dtereguliza !=''
      commndated = dtereguliza
    elsif dtofjoining !=nil && dtofjoining !=''
      commndated = dtofjoining 
    end

    if dateleaving != nil && dateleaving != ''
          isselect    = "sw_joiningdate,sw_prevlwm"
          iswhere     = "sw_compcode ='#{@compCodes}' AND sw_sewcode ='#{sewcode}'"
          sewobj      =  MstSewadar.select(isselect).where(iswhere).first
          if sewobj
              lwms       = sewobj.sw_prevlwm
              totals     = get_lwm_count(sewcode)
              totals     = totals.to_i+lwms.to_i              
          end
    end 

    newcreategratia = ""    
     if commndated != nil && commndated !='' && dateleaving !=nil && dateleaving !=''
          graiatiaz  =  get_graita_calculate(dtofjoining,dateleaving,totals)
          newzartias =  graiatiaz.to_s.split(".")
          ### ALLOW EX-GRTIA YEARS
          if newzartias && newzartias[0].to_i >=5
                if newzartias && newzartias[1].to_f >=6
                  newcreategratia = newzartias[0].to_i+1
                  gratiaamont     = newcreategratia.to_f*maamount.to_f
                  gratiaamont     = currency_formatted(gratiaamont)
                else
                  newcreategratia = newzartias[0].to_i
                  gratiaamont     = newcreategratia.to_f*maamount.to_f
                  gratiaamont     = currency_formatted(gratiaamont)
                end
          end  ## end if
          if gratiaamont.to_f >1500000
             gratiaamont = 1500000          
          end
          isflags = true
     end
     
     respond_to do |format|
      format.json { render :json => { 'data'=>'','gratiaamont'=>gratiaamont,'graiatiaz':newcreategratia,'stringgrat'=>graiatiaz,:status=>isflags} }
    end
 end

 def get_full_final_list

  if params[:page].to_i >0
    pages = params[:page]
    else
    pages = 1
    end
    jons = ""
    if params[:requestserver] !=nil && params[:requestserver] != ''     
      session[:ffreq_sewadar_string]      = nil      
      session[:ffreq_sewadar_departments] = nil
      session[:ffreqsewadar_codetype]      = nil
      session[:req_hph_months] = nil
      session[:req_hph_years] = nil
    end
    sewadar_string       = params[:sewadar_string].to_s.strip !=nil && params[:sewadar_string].to_s.strip != '' ? params[:sewadar_string].to_s.strip : session[:ffreq_sewadar_string].to_s.strip
    sewadar_departments  = params[:sewadar_departments].to_s.strip !=nil && params[:sewadar_departments].to_s.strip != ''  ? params[:sewadar_departments].to_s.strip : session[:ffreq_sewadar_departments]
    sewadar_codetype     = params[:sewadar_codetype] !=nil && params[:sewadar_codetype] != ''  ? params[:sewadar_codetype] : session[:ffreq_sewadar_codetype]

    hph_months           = params[:hph_months] !=nil && params[:hph_months] != ''  ? params[:hph_months] : session[:req_hph_months]
    hph_years            = params[:hph_years] !=nil && params[:hph_years] != ''  ? params[:hph_years] : session[:req_hph_years]

   
  myflagsjs = false
  mytflags   = false
  iswhere    = "ff_compcode ='#{@compCodes}'"
  if hph_months != nil && hph_months != ''
    iswhere  += " AND MONTH(ff_leavingdate) ='#{hph_months}'"
    @hph_months = hph_months
    session[:req_hph_months] = hph_months
  else
    iswhere  += " AND MONTH(ff_leavingdate) ='#{@monthsx}'"   
    @hph_months =  @monthsx
  end
  if hph_years != nil && hph_years != ''
    iswhere  += " AND YEAR(ff_leavingdate) ='#{hph_years}'"
    session[:req_hph_years] = hph_years
    @hph_years = hph_years
  else
    iswhere  += " AND YEAR(ff_leavingdate) ='#{@yearsx}'"  
    @hph_years = @yearsx  
  end
  if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'stf' || session[:requestuser_loggedintp].to_s == 'swd'
        iswhere += " AND ff_departcode LIKE '%#{@mydepartcode}%'"
        session[:ffreq_sewadar_departments] = @mydepartcode
        @sewadar_departments                = @mydepartcode
     
  else
        if sewadar_departments !=nil && sewadar_departments !=''
          iswhere += " AND ff_departcode LIKE '%#{sewadar_departments}%'"
          session[:ffreq_sewadar_departments] = sewadar_departments
          @sewadar_departments              = sewadar_departments
        end
  end
  

  

   if sewadar_codetype !=nil && sewadar_codetype !=''
      @sewadar_codetype                  =  sewadar_codetype
      session[:ffreqsewadar_codetype]      =  sewadar_codetype
  end
  if sewadar_string !=nil && sewadar_string != ''
      session[:ffreqs_sewadar_string]      = sewadar_string
      @sewadar_string                    = sewadar_string
      myflagsjs = true

    if sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='mycode'
       iswhere += " AND ff_sewacode LIKE '%#{sewadar_string.to_s.strip}%' "
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


   jons       =  " LEFT JOIN mst_sewadar_personal_infos spi on(sp_compcode = ff_compcode AND ff_sewacode = sp_sewcode)"
   isselects  =  "trn_full_finals.*,spi.id as SpId"
    listobj   =  TrnFullFinal.select(isselects).joins(jons).where(iswhere).paginate(:page =>pages,:per_page => 20).order("ff_leavingdate DESC")
 
  
  return listobj

 end

 private
  def update_leavingdate_details(sewcode,leavingdate,fullfinaldate,reason)
         compcode       = session[:loggedUserCompCode]         
         leavingdate    = leavingdate != nil && leavingdate != '' ? year_month_days_formatted(leavingdate) : ''
         fullfinaldates = fullfinaldate !=nil && fullfinaldate!='' ? year_month_days_formatted(fullfinaldate) : 0
         if leavingdate !=nil && leavingdate !=''
            svuobj       = MstSewadarOfficeInfo.where("so_compcode = ? AND so_sewcode = ?",compcode,sewcode).first
            sewobj       = MstSewadar.where("sw_compcode = ? AND sw_sewcode =?",compcode,sewcode).first
              if svuobj          
                  svuobj.update(:so_leavingdate=>leavingdate,:so_fullfinaldate=>fullfinaldates,:so_leavingreason=>reason)
              end
              if sewobj
                sewobj.update(:sw_leavingdate=>leavingdate)
              end
          end
  end


######## COLLECT DATA OF FULL AND FINALS ############
private
def get_all_formats_data(sewdarcode,leavingdate)
 @compCodes       = session[:loggedUserCompCode]
 
 if sewdarcode !=nil && sewdarcode !=''       
       @seawdarsobj     = MstSewadar.where("sw_compcode =? AND sw_sewcode = ?",@compCodes,sewdarcode).first  
       if @seawdarsobj
             @sewadarpersonal = get_personal_information(@compCodes,@seawdarsobj.sw_sewcode)
             @empChecked      = get_office_information(@compCodes,@seawdarsobj.sw_sewcode)
             @EmpKyc          = get_sewadar_kyc_information(@compCodes,@seawdarsobj.sw_sewcode)
             @EmpKycBank      = get_sewadar_kyc_bankdetail(@compCodes,@seawdarsobj.sw_sewcode)
             @EmpKycQulifc    = get_sewadar_kyc_qualification(@compCodes,@seawdarsobj.sw_sewcode)
             @EmpKycFamily    = get_sewadar_kyc_family(@compCodes,@seawdarsobj.sw_sewcode)
             @EmpWorkExp      = get_sewadar_work_experience(@compCodes,@seawdarsobj.sw_sewcode)
             @EmpDepartment   = get_all_department_detail(@seawdarsobj.sw_depcode) #DPT0011
             @PaymonthList    = get_paymonthly_list_data(@compCodes,@seawdarsobj.sw_sewcode,leavingdate)
             @LastMonths      = get_lastallownace_paymonthly_list_data(@compCodes,@seawdarsobj.sw_sewcode,leavingdate)
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

private
def get_paymonthly_list_data(compcode,sewacode,dated,types="")
     mobjs = nil
     if dated !=nil && dated !=''
     
     if types.to_s == 'clt'
      ffyears    = get_finacial_years(Date.parse(dated))
     else
      ffyears    = get_finacial_years(dated)
     end
     mobjs      = TrnPayMonthly.where("pm_compcode = ? AND pm_sewacode = ? AND pm_paymonth =MONTH('#{dated}') AND pm_payyear =YEAR('#{dated}') AND pm_financialyear =?",compcode,sewacode,ffyears).first
     end
     return mobjs
end
private
def get_lastallownace_paymonthly_list_data(compcode,sewacode,dated)
      mobjs = nil
     if dated !=nil && dated !=''
        ndates = dated.to_s.split("-")
        xdated = Date.parse( dated.to_s).prev_month(1)      
      ffyears    = get_finacial_years(xdated)
       mobjs      = TrnPayMonthly.where("pm_compcode = ? AND pm_sewacode = ? AND pm_paymonth =MONTH('#{xdated}') AND pm_payyear =YEAR('#{xdated}') AND pm_financialyear =?",compcode,sewacode,ffyears).first
      return mobjs
     end
end
private
def update_elenchash(compcode,sewacode,dateds,el,elencash)
  if dateds !=nil && dateds !=''
      dated        = dateds
      ffyears      = get_finacial_years(Date.parse(dateds))
      mobjs       = TrnPayMonthly.where("pm_compcode = ? AND pm_sewacode = ? AND pm_paymonth =MONTH('#{dated}') AND pm_payyear =YEAR('#{dated}') AND pm_financialyear =?",compcode,sewacode,ffyears).first
      if mobjs
        mobjs.update(:pm_totalel=>el,:pm_elencash=>elencash)
      end
   end   
end
#### END COLLECTING DATA OF FULL AND FINAL ############


end
