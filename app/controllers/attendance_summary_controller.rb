class AttendanceSummaryController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_mysewdar_list_details,:get_month_listed_data,:find_actual_hours_minuts
    helper_method :get_perday_attendance,:process_perday_list,:get_all_department_detail,:get_sewdar_designation_detail
    helper_method :employee_attendance_counts,:employee_leave_total,:get_calculate_hours,:get_perday_attendance,:get_calculated_hours_minute
    helper_method :get_week_days,:get_total_days_of_month,:get_location_detail
    def index
        @compcodes     = session[:loggedUserCompCode]
        @Allsewobj     = nil
       
        #@weeks        = week_of_month(31,2021,12)
        #  @nbegindate   = 2021
        #  @currentYear  = Date.today.year
        #   ######### GET INITIAL DUTY ##########
        #   month_number    =  Time.now.month
        #   @myCurrentMonth = month_number
        #   month_begin     =  Date.new(Date.today.year, month_number)
        #   begdate         =  Date.parse(month_begin.to_s)
        #   @nbegindates    =  begdate.strftime('%d-%b-%Y')
        #   month_ending    =  month_begin.end_of_month
        #   endingDate      =  Date.parse(month_ending.to_s)
        #   @enddate        =  endingDate.strftime('%d-%b-%Y')
        @HeadHrp         =  MstHrParameterHead.where("hph_compcode = ?",@compcodes).first
        @nbegindate      =  2021
        mymonths        =  Date.today.strftime('%m')
        myyears         =  Date.today.strftime('%Y')
        if mymonths.to_s.length <2
            newamonths = "0"+mymonths.to_s
        else
          newamonths = mymonths
        end
        if mymonths.to_i == 1
            years        = myyears.to_i-1
            @nbegindates = "26-12-"+years.to_s
        else
            nemonths     = newamonths.to_i-1
            nemonths     = nemonths.to_s.length <2 ? "0"+nemonths.to_s : nemonths
            @nbegindates = "26-"+nemonths.to_s+"-"+myyears.to_s
        end
        @enddates       = "25-"+newamonths.to_s+"-"+myyears.to_s
         ########## END INITIAL DUTY #######  
         @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compcodes).first
         @HrMonths          = nil
         @Hryears           = nil
         if @HeadHrp
           @HrMonths = @HeadHrp.hph_months
           @Hryears  = @HeadHrp.hph_years
         end  

    @mydepartcode      = ""
    mydeprtcode        = "" 
    @newsewdarList     =  nil
    selecteddp         = params[:sewadar_departments]!=nil && params[:sewadar_departments] !='' ? params[:sewadar_departments] : ''
          if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
            if session[:sec_sewdar_code] !=nil
                sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
                if sewobjs
                  @mydepartcode = mydeprtcode = sewobjs.sw_depcode
                end
            end
      elsif session[:requestuser_loggedintp]  && ( session[:requestuser_loggedintp] == 'ec' || session[:requestuser_loggedintp] == 'cod' )
        
          hodobjs = get_hod_listed_sewadar(session[:sec_ecmem_code])
          if hodobjs       
                ecodes     = hodobjs.lds_membno  
                fdepart    = ""          
                deprtobj = get_all_coordinate_department(ecodes)
                  if deprtobj.length >0
                      deprtobj.each do |newdpts|
                        fdepart += "'"+newdpts.departCode.to_s+"',"
                      end
                  end    
                  if fdepart !=nil && fdepart !=''
                      fdepart = fdepart.to_s.chop
                  end
                    @mydepartcode = mydeprtcode = fdepart             
               
          end
      end


         department  = params[:sewadar_departments] !=nil && params[:sewadar_departments]!='' ? params[:sewadar_departments] : session[:requests_xdepartment]
          
          if session[:requestuser_loggedintp]  && ( session[:requestuser_loggedintp] == 'ec' || session[:requestuser_loggedintp] == 'cod' ) 
            @sewDepart     = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment='' AND departCode IN(#{@mydepartcode})",@compcodes).order("departDescription ASC") 
            if selecteddp !=nil && selecteddp !=''
                  @Allsewobj   = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode =? and sw_depcode = ? AND sw_catcode<>'VIV'",@compcodes,selecteddp).order("sw_sewadar_name ASC") 
              else
                  @Allsewobj   = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode =? and sw_depcode IN(#{fdepart}) AND sw_catcode<>'VIV'",@compcodes).order("sw_sewadar_name ASC") 
              end
          else
                if selecteddp !=nil && selecteddp !=''
                    @Allsewobj   = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode =? and sw_depcode = ? AND sw_catcode<>'VIV'",@compcodes,selecteddp).order("sw_sewadar_name ASC") 
                end
                  @sewDepart     = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment=''",@compcodes).order("departDescription ASC")
          end
         @ListHeadoffice  = MstHeadOffice.where("hof_compcode = ? ",@compcodes).order("hof_description ASC")
         @AttendanceList  = get_attendance_list()

         if params[:id] !=nil && params[:id] != ''
                docs = params[:id].to_s.split("_")
                if docs[1].to_s == 'prt'

                    rooturl        = "#{root_url}"
                    @compDetail    = MstCompany.where(["cmp_companycode = ?", @compcodes]).first
                    printattend    = print_attendance_summary()
                    @frmdated      = ""
                    if session[:requests_xfromdate]  !=nil && session[:requests_xfromdate]  !=''
                      @frmdated = session[:requests_xfromdate] 
                    end
                      respond_to do |format|
                          format.html
                          format.pdf do
                            pdf = AttendancesummaryPdf.new(printattend,@compDetail,rooturl,session, @frmdated )
                            send_data pdf.render,:filename => "1_prt_attendance_summary.pdf", :type => "application/pdf", :disposition => "inline"
                          end
                      end

                end
         end
    end

    def get_attendance_list
        if params[:server_request] !=nil && params[:server_request] !=''
            session[:requests_xdepartment] = nil
            session[:requests_xmylocation] = nil
            session[:requests_xmyemployee] = nil
            session[:requests_xmonths]     = nil
            session[:requests_xmyyear]     = nil
            session[:requests_xuptodate]   =  nil
            session[:requests_xfromdate]   = nil
        else
          return false   
        end
        if params[:postdata] !=nil && params[:postdata] !='' && params[:postdata] == 'Y'
          process_attendance_paymonth();
            flash[:error] =  "Data posted successfully."
            isFlags = true         
        end

        months      = 0 #params[:mymonths] !=nil && params[:mymonths] !='' ? params[:mymonths] : session[:requests_xmonths]
        department  = params[:sewadar_departments] !=nil && params[:sewadar_departments]!='' ? params[:sewadar_departments] : session[:requests_xdepartment]
        mylocation  = params[:mylocation] !=nil && params[:mylocation]!='' ? params[:mylocation] : session[:requests_xmylocation]
        myemployee  = params[:myemployee] !=nil && params[:myemployee]!='' ? params[:myemployee] : session[:requests_xmyemployee]
        myyears     = params[:myyear] !=nil && params[:myyear]!='' ? params[:myyear] : session[:requests_xmyyear]
        fromdate    = params[:fromdate] !=nil && params[:fromdate]!='' ? year_month_days_formatted(params[:fromdate]) : session[:requests_xfromdate]
        uptodate    = params[:uptodate] !=nil && params[:uptodate]!='' ? year_month_days_formatted(params[:uptodate]) : session[:requests_xuptodate]

        if fromdate !=nil && fromdate !=''
            session[:requests_xfromdate] = fromdate
            @fromdate = fromdate
        end
        if uptodate !=nil && uptodate !=''
            session[:requests_xuptodate] = uptodate
            @uptodate = uptodate
        end

        if department !=nil && department !=''            
            session[:requests_xdepartment] = department
            @department = department
        end
        if mylocation !=nil && mylocation !='' 
            session[:requests_xmylocation] = mylocation
            @mylocation = mylocation
        end
        if myemployee !=nil && myemployee !=''             
            session[:requests_xmyemployee] = myemployee
            @myemployee = myemployee
        end
        
        arritem   =  []       
        sqls      = "call `attendance_summary` ('#{@compcodes}','#{fromdate}','#{uptodate}','#{department}','#{mylocation}','#{myemployee}')"  
        attndobj  = request_processor(sqls)
        if attndobj.length >0
            attndobj.each do |newdpt|
                empobj = get_mysewdar_list_details(newdpt.sw_depcode)
                if empobj
                newdpt.sw_sewadar_name = empobj.sw_sewadar_name
                newdpt.sw_joiningdate  = empobj.sw_joiningdate
                end
                dptobj =   get_department_detail(newdpt.sw_depcode)
                if dptobj
                newdpt.mydepartment = dptobj.departDescription
                end                
                hdobjs = get_location_detail(newdpt.sw_location)
                if hdobjs
                newdpt.location = hdobjs.hof_description
                end
                arritem.push newdpt
            end          
        end
      return arritem

    end

    private
    def get_perday_attendance(empcode,days,months="",years="")
      compcodes   = session[:loggedUserCompCode]
      sqls    = "call `employee_uptodatelist` ('#{compcodes}','#{empcode}','#{months}','#{years}','#{days}')"  
      attndobj = request_processor(sqls)     
      return attndobj
    end
    
    private
    def process_perday_list(empcode,days,months="",years="")
      htmls   = ""
      mdobjsx  = get_perday_attendance(empcode,days,months,years)
      shift   = ""
      timein  = ""
      timeout = ""
      othrs   = ""
      
      if mdobjsx && mdobjsx.length >0
        mdobjsx.each do |mdobjs|
        shift     = mdobjs.al_shift
        timein    = mdobjs.al_arrtime
        timeout   = mdobjs.all_deptime
        othrs     = mdobjs.al_overtime
        ppstatus  = mdobjs.al_presabsent
        workhrs   = mdobjs.al_workhrs
        mystatus = ""
        if ppstatus.to_s.upcase=='P'
          mystatus = "PP"
        elsif ppstatus.to_s.upcase=='WO'
            mystatus = "WO"
        elsif ppstatus.to_s.upcase=='HL'
            mystatus = "HL"
          elsif ppstatus.to_s.upcase=='A'
            mystatus = "AA"
        end
        htmls     = shift.to_s+"<br/>"+timein.to_s+"<br/>"+timeout.to_s+"<br/>"+workhrs.to_s+"<br/>"+othrs.to_s+"<br/>"+mystatus.to_s
      end
      end
    return htmls
  end

  private
  def get_calculate_hours(empcode,days,months="",years="")
     aplcounts = 0
     compcodes = session[:loggedUserCompCode]
     sqls      = "call `calculatehours` ('#{compcodes}','#{empcode}','#{months}','#{years}','#{days}')"  
     attndobj = request_processor(sqls)      
    if attndobj && attndobj.length >0
      thrs  = 0
      tmns  = 0
      ovhrs = 0
      ovmns = 0
      attndobj.each do |hrsn|
          ttimes  = hrsn.al_workhrs ? hrsn.al_workhrs.to_s.split(":") : ''
          ovtimes = hrsn.al_overtime ? hrsn.al_overtime.to_s.split(":") : ''
          thrs    +=  ttimes[0].to_f
          tmns    +=  ttimes[1].to_f
          ovhrs   +=  ovtimes[0].to_f
          ovmns   +=  ovtimes[1].to_f
      end
        if tmns.to_f >59
            newmints = "%.2f" % (tmns.to_f/60)
        else
          newmints  = "."+tmns.to_s
        end
        if ovmns.to_f >59
           newovmns = "%.2f" % (ovmns.to_f/60)
        else
           newovmns = "."+ovmns.to_s
        end
         newthrs   = "%.2f" % ( thrs.to_f+newmints.to_f).to_f
         newovhrs  = "%.2f" % ( ovhrs.to_f+newovmns.to_f).to_f
         pvshrs    = newthrs.gsub('.',':').to_s+"_"+newovhrs.gsub('.',':').to_s
         return pvshrs
    end
    

  end

  private
    def employee_attendance_counts(empcode,days,months="",type="",years="")
      aplcounts   = 0
      compcodes   = session[:loggedUserCompCode]
      sqls      = "call `calculateempcount` ('#{compcodes}','#{empcode}','#{months}','#{years}','#{type}')"  
      attndobj = request_processor(sqls) 
      if attndobj && attndobj.length >0
          attndobj.each do |newitem|
             aplcounts += newitem.totals.to_i
          end
      end
       return aplcounts
    end

    private
    def employee_leave_total(empcode,days,months="",type="",years="")
      aplcounts  = 0
       compcodes = session[:loggedUserCompCode]      
      sqls       = "call `calculateleavetoal` ('#{compcodes}','#{empcode}','#{months}','#{years}','#{type}')" 
      attndobj   = request_processor(sqls) 
      if attndobj && attndobj.length >0
          attndobj.each do |newitem|
             aplcounts += newitem.totals.to_i
          end
      end      
       return aplcounts
    end
private
def get_week_days(days,months,year)
  weekdays =""
  if days.to_i >0 && months.to_i >0 && year.to_i >0
    if( months.to_i <10 )
      months = "0"+months.to_s
    end
    if days.to_i <10
      days = "0"+days.to_s
    end
    dated = year.to_s+"-"+months.to_s+"-"+days.to_s
    weekdays = Date.parse(dated.to_s).strftime("%a")

  end
  return weekdays
end

def print_attendance_summary
  fromdate        = session[:requests_xfromdate]
  uptodate        = session[:requests_xuptodate]
  arritems         = []
  @AttendanceList = process_attendance_summary()

  if @AttendanceList && @AttendanceList.length >0
      @AttendanceList.each do |newattd|                    
         sewdar      = ""
         lds_profile = ""
         desicode    = ""
         department  = ""
         oldsewadar  = ""
         sw_catgeory = ""
         location    = ""
         sewnmaesobj = get_mysewdar_list_details(newattd.al_empcode)
         if sewnmaesobj                                                                                  
           lds_profile   = sewnmaesobj.sw_image
           sewdar        = sewnmaesobj.sw_sewadar_name
           desicode      = sewnmaesobj.sw_desigcode
           oldsewadar    = sewnmaesobj.sw_oldsewdarcode
           sw_gender     = sewnmaesobj.sw_gender
           sw_catgeory   = sewnmaesobj.sw_catgeory
           dobs          = sewnmaesobj.sw_date_of_birth
           deprtobj      = get_all_department_detail(sewnmaesobj.sw_depcode)
           if deprtobj
             department  = deprtobj.departDescription
           end
           locobj        = get_location_detail(sewnmaesobj.sw_location)
           if locobj
               location  = locobj.hof_description
           end

         end
         desiname  = ""
         sewdesobj = get_sewdar_designation_detail(desicode)
         if sewdesobj
           desiname = sewdesobj.ds_description
         end 
         
 
    whrsfirst     = 0
    whrsmnsfirst  = 0
    ovhrsfirst    = 0
    ovhrsmnsfirst = 0
    presents      = 0 
    absent        = 0  
    wo            = 0 ## weekly off
    hl            = 0 ## holiday
    lwp           = 0 ## leave withoy pay
    lp            = 0 ## leave with pay 
    hlfd          = 0 ## half days
    nebsents      = 0
    tholidy       = 0
    latecount     = 0
    earlycount    = 0
    mispuchcount  = 0
    mypaiddays    = 0
   adysobj        = get_perday_attendance(newattd.al_empcode,'',fromdate,uptodate)
    for c in 1..31 do
  
     if adysobj && adysobj.length >0
     adysobj.each do |newitem|
       if newitem.al_empcode.to_s == newattd.al_empcode && newitem.days.to_i==c
           shift     = newitem.al_shift
           timein    = newitem.al_arrtime
           timeout   = newitem.all_deptime
           othrs     = newitem.al_overtime
           ppstatus  = newitem.al_presabsent
           workhrs   = newitem.al_workhrs
           mystatus  = ppstatus.to_s
           presents  += newitem.al_present.to_f
           absent    += newitem.al_absent.to_f
           lp        += newitem.al_paidleave.to_f
           lwp       += newitem.al_unpaidleave.to_f
           
           if newitem.al_arrtime.to_s.gsub(":",".").to_f >0 && newitem.all_deptime.to_s.gsub(":",".").to_f <=0
             mispuchcount +=1
           end

           if newitem.al_latehrs.to_s.gsub(":",".").to_f >0
               latecount +=1    
           end
           if newitem.al_earlhrs.to_s.gsub(":",".").to_f >0
               earlycount +=1    
           end  
           if ppstatus.to_s=='WO'
             wo +=1
           end
           if ppstatus.to_s=='AP' || ppstatus.to_s=='PA' || ppstatus.to_s=='LP' || ppstatus.to_s=='PL'
             hlfd +=1
           end
           if ppstatus.to_s=='HL'
             hl +=1
           end
           
           ######## HRS & MNS & OVT SUM #########
               whrsfirst      += get_calculated_hours_minute(workhrs,'H').to_f
               whrsmnsfirst   += get_calculated_hours_minute(workhrs,'M').to_f

               #ovhrsfirst    += get_calculated_hours_minute(othrs,'H').to_f
               #ovhrsmnsfirst += get_calculated_hours_minute(othrs,'M').to_f                           
               ######### END HRMS ######################
          
               end                    
             end
          end
     end ### END ALL condition
          tholidy    = hl.to_i
          nebsents   = absent.to_f+lwp.to_f
          mypaiddays = presents.to_f+hl.to_f+wo.to_f+lp.to_f
          workhrs    = find_actual_hours_minuts(whrsfirst,whrsmnsfirst)
         # ovhrs     = find_actual_hours_minuts(ovhrsfirst,ovhrsmnsfirst)
         newattd.sewdar       = sewdar
         newattd.department   = department
         newattd.presents     = presents
         newattd.nebsents     = absent
         newattd.tholidy      = tholidy
         newattd.wo           = wo
         newattd.lp           = lp
         newattd.mypaiddays   = mypaiddays
         newattd.latecount    = latecount
         newattd.earlycount   = earlycount
         newattd.mispuchcount = mispuchcount
         arritems.push newattd
     end ## END EACH LOOP
   end ## end if
   return arritems
end

def process_attendance_summary
 
months      = 0 
department  = session[:requests_xdepartment]
mylocation  = session[:requests_xmylocation]
myemployee  = session[:requests_xmyemployee]
myyears     = session[:requests_xmyyear]
fromdate    = session[:requests_xfromdate]
uptodate    = session[:requests_xuptodate]


arritem   =  []       
sqls    = "call `attendance_summary` ('#{@compcodes}','#{fromdate}','#{uptodate}','#{department}','#{mylocation}','#{myemployee}')"  
attndobj = request_processor(sqls)
if attndobj.length >0
    attndobj.each do |newdpt|        
        arritem.push newdpt
    end          
end
return arritem


end

def process_attendance_paymonth
     i = 0
     months = params[:hph_months]
     years  = params[:hph_years]
    if params[:myempcode] != nil && params[:myempcode] != ''
     
          params[:myempcode].each do |newitem|
              empcode     = params[:myempcode][i]
              if params[:mypresent][i] !=nil && params[:mypresent][i] !=''
                 mypresent   = params[:mypresent][i]
              else
                 mypresent   = 0
              end
              if  params[:myabsent][i] !=nil &&  params[:myabsent][i] !=''
                myabsent    = params[:myabsent][i]
              else
                myabsent    = 0
              end
             if params[:myholiday][i] !=nil && params[:myholiday][i] !=''
               myholiday   = params[:myholiday][i]
             else
               myholiday   = 0
             end
              if params[:myweeklyoff][i] !=nil && params[:myweeklyoff][i] !=''
                myweeklyoff = params[:myweeklyoff][i]
              else
                myweeklyoff = 0 
              end

              if params[:myleave][i] !=nil && params[:myleave][i] !=''
                myleave = params[:myleave][i]
              else
                myleave = 0 
              end
                if params[:mypaiddays][i] !=nil && params[:mypaiddays][i] !=''
                   mypaiddays  = params[:mypaiddays][i]
                else
                    mypaiddays  = 0
                end
                if params[:mytotaldays][i] !=nil && params[:mytotaldays][i] !=''
                  mytotaldays = params[:mytotaldays][i]
                else
                  mytotaldays = 0
                end
                if params[:mymycatcode][i] !=nil && params[:mymycatcode][i] !=''
                  mymycatcode = params[:mymycatcode][i]
                else
                  mymycatcode = ''
                end
                #### PREVENTING POSTING DATA ASSOCIATE B(CODE IS : VIH) APPROVAL BY AMIT IT -27-OCT-2022
                if mymycatcode.to_s.upcase !='VIH'
                   save_data_in_paymonth(empcode,mypresent,myabsent,myholiday,myweeklyoff,mypaiddays,mytotaldays,myleave,months,years)
                end
              i +=1
          end

    end

end

def save_data_in_paymonth(sewacode,mypresent,myabsent,myholiday,myweeklyoff,mypaiddays,mytotaldays,myleave,mymonths,myyears)
    compcodes      = session[:loggedUserCompCode] 
    if mymonths.to_i >=4 
      genfinalyear = myyears.to_s+"-"+(myyears.to_i+1).to_s
    else
      genfinalyear = (myyears.to_i-1).to_s+"-"+myyears.to_s
    end 
     totmonthday   =  30
     mobjs         =  TrnPayMonthly.where("pm_compcode = ? AND pm_sewacode = ? AND pm_paymonth =? AND pm_payyear =? AND pm_financialyear =?",compcodes,sewacode,mymonths,myyears,genfinalyear).first
     if mobjs     
      mobjs.update(:pm_hl=>myholiday,:pm_workingday=>mypresent,:pm_absent=>myabsent,:pm_paidleave=>myleave,:pm_wo=>myweeklyoff,:pm_paymonth=>mymonths,:pm_payyear=>myyears,:pm_paydays=>mypaiddays,:pm_monthday=>totmonthday,:pm_financialyear=>genfinalyear,:pm_isposted=>'Y')
     
    else
        strobjs = TrnPayMonthly.new(:pm_compcode=>compcodes,:pm_sewacode=>sewacode,:pm_hl=>myholiday,:pm_workingday=>mypresent,:pm_absent=>myabsent,:pm_paidleave=>myleave,:pm_wo=>myweeklyoff,:pm_paymonth=>mymonths,:pm_payyear=>myyears,:pm_paydays=>mypaiddays,:pm_monthday=>totmonthday,:pm_financialyear=>genfinalyear,:pm_isposted=>'Y')
        strobjs.save
    end
end

end
