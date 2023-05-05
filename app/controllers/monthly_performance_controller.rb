class MonthlyPerformanceController < ApplicationController
 before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_mysewdar_list_details,:get_month_listed_data,:find_actual_hours_minuts
    helper_method :get_perday_attendance,:process_perday_list,:get_mysewdar_list_details,:get_all_department_detail,:get_sewdar_designation_detail
    helper_method :employee_attendance_counts,:employee_leave_total,:get_calculate_hours,:get_perday_attendance,:get_calculated_hours_minute
    helper_method :get_week_days,:get_total_days_of_month,:get_location_detail
    def index
        @compcodes   = session[:loggedUserCompCode]
        @Allsewobj   = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode =?",@compcodes).order("sw_sewadar_name ASC")
        @sewDepart   = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment=''",@compcodes).order("departDescription ASC")
        #@weeks       = week_of_month(31,2021,12)
         @nbegindate   =  2021
         @currentYear  = Date.today.year
          ######### GET INITIAL DUTY ##########
          month_number  =  Time.now.month
          @myCurrentMonth = month_number
          month_begin   =  Date.new(Date.today.year, month_number)
          begdate       =  Date.parse(month_begin.to_s)
          @nbegindates  =  begdate.strftime('%d-%b-%Y')
          month_ending  =  month_begin.end_of_month
          endingDate    =  Date.parse(month_ending.to_s)
          @enddate      =  endingDate.strftime('%d-%b-%Y')
    ########## END INITIAL DUTY #######  
         @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compcodes).first
         @HrMonths          = nil
         @Hryears           = nil
         if @HeadHrp
           @HrMonths = @HeadHrp.hph_months
           @Hryears  = @HeadHrp.hph_years
         end    
         @ListHeadoffice  = MstHeadOffice.where("hof_compcode = ? ",@compcodes).order("hof_description ASC")
         @AttendanceList  = get_attendance_list()
    end

    def get_attendance_list
        if params[:server_request] !=nil && params[:server_request] !=''
            session[:requests_department] = nil
            session[:requests_mylocation] = nil
            session[:requests_myemployee] = nil
            session[:requests_months]     = nil
            session[:requests_myyear]     = nil
        else
          return false   
        end
        months      = params[:mymonths] !=nil && params[:mymonths] !='' ? params[:mymonths] : session[:requests_months]
        department  = params[:sewadar_departments] !=nil && params[:sewadar_departments]!='' ? params[:sewadar_departments] : session[:requests_department]
        mylocation  = params[:mylocation] !=nil && params[:mylocation]!='' ? params[:mylocation] : session[:requests_mylocation]
        myemployee  = params[:myemployee] !=nil && params[:myemployee]!='' ? params[:myemployee] : session[:requests_myemployee]
        myyears     = params[:myyear] !=nil && params[:myyear]!='' ? params[:myyear] : session[:requests_myyear]

        if months.to_i >0           
            @mymonths                 = months
            session[:requests_months] = months 
        end
        if department !=nil && department !=''            
            session[:requests_department] = department
            @department = department
        end
        if mylocation !=nil && mylocation !='' 
            session[:requests_mylocation] = mylocation
            @mylocation = mylocation
        end
        if myemployee !=nil && myemployee !=''             
            session[:requests_myemployee] = myemployee
            @myemployee = myemployee
        end
        
        arritem   =  []       
        sqls    = "call `monthlyperformance` ('#{@compcodes}','#{months}','#{myyears}','#{department}','#{mylocation}','#{myemployee}')"  
        attndobj = request_processor(sqls)
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
      sqls    = "call `employeeperdaylist` ('#{compcodes}','#{empcode}','#{months}','#{years}','#{days}')"  
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
      #  iswhere     = "al_compcode1 ='#{compcodes}' AND al_empcode='#{empcode}'"       
      #  if months.to_i >0
      #   iswhere    += " AND MONTH(al_trandate) ='#{months}'"
      #   else
      #   iswhere    += " AND MONTH(al_trandate) = MONTH(NOW())"
      #   end  
      #   if years.to_i >0
      #   iswhere    += " AND YEAR(al_trandate) ='#{years}'"
      #   else
      #   iswhere    += " AND YEAR(al_trandate) = YEAR(NOW())"
      #   end 
      #  if type.to_s =='LV'  
      #     iswhere += " AND al_unpaidleave >0 "
      #     isselect = "SUM(al_unpaidleave)  as totals"
      #  elsif type.to_s =='LP' 
      #     iswhere += " AND al_paidleave >0 "
      #     isselect = "SUM(al_paidleave)  as totals" 
      #  end
      # attndobj  = TrnAttendanceList.select(isselect).where(iswhere).first
      # if attndobj
      #    aplcounts = attndobj.totals
      # end
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

end

