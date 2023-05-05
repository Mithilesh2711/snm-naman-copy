## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all attendance list
class EmployeeAttendanceController < ApplicationController
  before_action :require_login  
  skip_before_action :verify_authenticity_token
  include ErpModule::Common
  helper_method :currency_formatted,:year_month_days_formatted,:formatted_date,:set_ent,:set_dct
  helper_method :get_department_detail,:get_designation_detail,:get_pending_list,:get_today_follow_leads
  helper_method :get_all_counts,:get_calculated_hours_minute,:get_all_department_detail
  helper_method :get_mysewdar_list_details,:get_sewdar_designation_detail
  def index
    loguserids      =  session[:autherizedUserId]
    @compcodes      =  session[:loggedUserCompCode]
    @emp_department =  nil
     
    # month_numbers =  Time.now.month
    # month_begins  =  Date.new(Date.today.year, month_numbers)
    # begdates      =  Date.parse(month_begins.to_s)
    # @nbegindates  =  Date.today.strftime('%d-%b-%Y') #begdates.strftime('%d-%b-%Y')
    # month_endings =  month_begins.end_of_month
    # endingdates   =  Date.parse(month_endings.to_s)
    # @enddates     =  Date.today.strftime('%d-%b-%Y') #endingdates.strftime('%d-%b-%Y')

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
   

    #@attendance   = process_attendance_calculation()
    @mydepartcode      = ""
    mydeprtcode        = "" 
    @newsewdarList     =  nil
    @listSewadars      = nil
    emplid             = params[:emp_listed]!=nil && params[:emp_listed] !='' ? params[:emp_listed] : ''
    selecteddp         = params[:emp_department]!=nil && params[:emp_department] !='' ? params[:emp_department] : ''
    if emplid !=nil && emplid !=''
       @listSewadars      =   MstSewadar.select("sw_sewadar_name as firstname,sw_sewcode as emp_cust_id").where("sw_compcode = ? AND sw_sewcode = ?",@compcodes,emplid).first
    end
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

     

    @processdetail = nil
    if params[:processdetail] != nil && params[:processdetail] != '' && params[:processdetail] == 'SMRY'
        if params[:emp_listed]!=nil && params[:emp_listed] !=''
          @SummListed   = summary_attendance_list()
        end      
        @processdetail = params[:processdetail]
    else
        if params[:emp_listed]!=nil && params[:emp_listed] !=''
          @listAttend   =  get_attendance_list()
        end
        @processdetail = params[:processdetail]
    end


       if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
           @mstXEmpEdit      = MstSewadar.select("sw_sewadar_name as firstname,sw_sewcode as emp_cust_id").where("sw_compcode = ? and sw_sewcode =? AND sw_catcode<>'VIV'",@compcodes,session[:sec_sewdar_code]).order("TRIM(sw_sewadar_name) ASC")  
           @Department    = Department.select("departDescription as dp_name,departCode,id").where("compCode = ? AND subdepartment='' AND departCode = ?",@compcodes,mydeprtcode).order("TRIM(departDescription) ASC")
       elsif session[:requestuser_loggedintp]  && ( session[:requestuser_loggedintp] == 'ec' || session[:requestuser_loggedintp] == 'cod' )
                if @mydepartcode != nil && @mydepartcode != ''
                  @Department        =   Department.select("compCode,departDescription, departDescription as dp_name,departCode").where("compCode = '#{@compcodes}' AND subdepartment ='' AND departCode IN(#{@mydepartcode})").order("departDescription ASC")
                end  
               if @emp_department !=nil && @emp_department !=''
                    @mstXEmpEdit      =   MstSewadar.select("sw_sewadar_name as firstname,sw_sewcode as emp_cust_id").where("sw_compcode= ? AND sw_depcode = ? AND sw_catcode<>'VIV'",@compcodes,@emp_department).order("sw_sewadar_name ASC")
               else
                    @mstXEmpEdit      =   MstSewadar.select("sw_sewadar_name as firstname,sw_sewcode as emp_cust_id").where("sw_compcode = ? AND sw_depcode = ? AND sw_catcode<>'VIV'",@compcodes,mydeprtcode).order("sw_sewadar_name ASC")
               end
                
        else
              if @emp_department !=nil && @emp_department !=''
                @mstXEmpEdit      = MstSewadar.select("sw_sewadar_name as firstname,sw_sewcode as emp_cust_id").where("sw_compcode = ? and sw_depcode =? AND sw_catcode<>'VIV'",@compcodes,@emp_department).order("TRIM(sw_sewadar_name) ASC")
              else
                @mstXEmpEdit      = MstSewadar.select("sw_sewadar_name as firstname,sw_sewcode as emp_cust_id").where("sw_compcode = ? and sw_sewadar_name<>'' AND sw_catcode<>'VIV'",@compcodes).order("TRIM(sw_sewadar_name) ASC")
              end
              @Department    = Department.select("departDescription as dp_name,departCode,id").where("compCode = ? AND subdepartment=''",@compcodes).order("TRIM(departDescription) ASC")

      end
    
    printpath     = "1_daily_attendance_report"
    @mypaths      = employee_attendance_path(printpath,:format=>"pdf")
  end

  def show
      @loguserids =  session[:autherizedUserId]
      @compcodes =  session[:loggedUserCompCode]
      printobj = print_attendance_list()
      if printobj.length >0
          @ExcelList   =  printobj
          send_data @ExcelList.to_attendancelist, :filename=> "attendance-list-#{Date.today}.csv"
          return
      end
  end
  def create
    
  end
  def employee_attendance_refresh
   session[:request_params] = nil
   session[:req_empattend] = nil
   session.delete(:request_params)
   redirect_to "#{root_url}"+"employee_attendance"
  end
  
  private
  def get_attendance_list
     
    frmbegindated  = params[:from_date] !=nil  && params[:from_date] != '' ? year_month_days_formatted(params[:from_date]) : year_month_days_formatted(@nbegindates)
    enddated       = params[:upto_date] !=nil  && params[:upto_date] != '' ? year_month_days_formatted(params[:upto_date]) : year_month_days_formatted(@nbegindates)
    emplid         = params[:emp_listed]!=nil && params[:emp_listed] !='' ? params[:emp_listed] : ''
    empdpt         = params[:emp_department]!=nil && params[:emp_department] !='' ? params[:emp_department] : ''
    iswhere        = "al_compcode='#{@compcodes}'"
      if frmbegindated !=nil && frmbegindated !=''
        iswhere  += " AND al_trandate >='#{frmbegindated}'"
        session[:req_fromattend] = frmbegindated
        @from_date = formatted_date(frmbegindated)
      end
      if enddated !=nil && enddated !=''
        iswhere  += " AND al_trandate <='#{enddated}'"
        session[:req_uptoattend] = enddated
        @upto_date = formatted_date(enddated)
      end
      if emplid !=nil && emplid !='' 
        iswhere  += " AND al_empcode ='#{emplid}'"
        session[:req_empattend] = emplid
        @emp_listed = emplid
      end
      
      if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
            iswhere  += " AND al_department ='#{@mydepartcode}'"
            session[:req_empdpt] = @mydepartcode
            @emp_department     = @mydepartcode
      else

            if empdpt !=nil && empdpt !=''
              iswhere  += " AND al_department ='#{empdpt}'"
              session[:req_empdpt] = empdpt
              @emp_department     = empdpt
            end
        end
      if empdpt.to_i >0
        jons = " LEFT JOIN mst_sewadars emp ON(sw_compcode = al_compcode AND sw_sewcode = al_empcode)"
        attndobj = TrnAttendanceList.joins(jons).where(iswhere).order("al_trandate ASC,al_empcode ASC")
      else
        attndobj = TrnAttendanceList.where(iswhere).order("al_trandate ASC,al_empcode ASC")
      end
      
      return attndobj
  end

  private
  def summary_attendance_list
    frmbegindated  = params[:from_date] !=nil  && params[:from_date] != '' ? year_month_days_formatted(params[:from_date]) : year_month_days_formatted(@nbegindates)
    enddated       = params[:upto_date] !=nil  && params[:upto_date] != '' ? year_month_days_formatted(params[:upto_date]) : year_month_days_formatted(@nbegindates)
    emplid         = params[:emp_listed]!=nil && params[:emp_listed] !='' ? params[:emp_listed] : ''
    empdpt         = params[:emp_department]!=nil && params[:emp_department] !='' ? params[:emp_department] : ''
      iswhere  = "al_compcode='#{@compcodes}'"
      if frmbegindated !=nil && frmbegindated !=''
        iswhere  += " AND al_trandate >='#{frmbegindated}'"
        session[:req_fromattend] = frmbegindated
        @from_date = formatted_date(frmbegindated)
      end
      if enddated !=nil && enddated !=''
        iswhere  += " AND al_trandate <='#{enddated}'"
        session[:req_uptoattend] = enddated
        @upto_date = formatted_date(enddated)
      end
      if emplid !=nil && emplid !=''
        iswhere  += " AND al_empcode ='#{emplid}'"
        session[:req_empattend] = emplid
        @emp_listed = emplid
      end
      if empdpt !=nil && empdpt !=''
        iswhere  += " AND al_department ='#{empdpt}'"
        session[:req_empdpt] = empdpt
        @emp_department      = empdpt
      end
       isselect  =  "GROUP_CONCAT(al_workhrs) as workinghrs,GROUP_CONCAT(al_overtime) as ovrtimes"
       isselect  += ",trn_attendance_lists.*,emp.id as empId,GROUP_CONCAT(al_latepelanty) as lateenalty"
       jons = " LEFT JOIN mst_sewadars emp ON(sw_compcode = al_compcode AND sw_sewcode = al_empcode)"
       attndobj  =  TrnAttendanceList.select(isselect).joins(jons).where(iswhere).group("al_empcode").order("sw_sewadar_name ASC")
      return attndobj
  end

  private
  def get_all_counts(emplid,types)
      frmbegindated  = params[:from_date] !=nil  && params[:from_date] != '' ? year_month_days_formatted(params[:from_date]) : year_month_days_formatted(@nbegindates)
      enddated       = params[:upto_date] !=nil  && params[:upto_date] != '' ? year_month_days_formatted(params[:upto_date]) : year_month_days_formatted(@nbegindates)
      empdpt         = params[:emp_department].to_i >0 ? params[:emp_department] : 0
      tcounts        = 0
      iswhere  = "al_compcode='#{@compcodes}'"
      if ( types  == 'A' || types == 'P' )
        iswhere  += " AND al_presabsent ='#{types}'"
      elsif ( types == 'E' )
        iswhere  += " AND REPLACE(al_earlhrs,':','.')>0"
      elsif ( types  == 'L'  )
        iswhere  += " AND REPLACE(al_latehrs,':','.')>0"
      end
      if frmbegindated !=nil && frmbegindated !=''
        iswhere  += " AND al_trandate >='#{frmbegindated}'"
      end
      if enddated !=nil && enddated !=''
        iswhere  += " AND al_trandate <='#{enddated}'"
      end
      if emplid.to_i >0
        iswhere  += " AND al_empcode ='#{emplid}'"
      end
      if empdpt.to_i >0
        iswhere  += " AND al_department ='#{empdpt}'"
      end
      isselect = "COUNT(*) as totalcounts"
      jons = " LEFT JOIN mst_sewadars emp ON(sw_compcode = al_compcode AND sw_sewcode = al_empcode)"
     countobjs = TrnAttendanceList.select(isselect).joins(jons).where(iswhere).first
     if countobjs
        tcounts = countobjs.totalcounts
     end
     return tcounts
  end
  
private
def process_attendance_calculation
    frmbegindated  = params[:from_date] !=nil  && params[:from_date] != '' ? year_month_days_formatted(params[:from_date]) : @nbegindates
    enddated       = params[:upto_date] !=nil  && params[:upto_date] != '' ? year_month_days_formatted(params[:upto_date]) : @enddates
    @emplid        = params[:emp_listed].to_i >0 ? params[:emp_listed] : 0
    
    if frmbegindated !=nil && frmbegindated != ''  && enddated !=nil && enddated != ''
       start_date = Date.parse(frmbegindated.to_s)
        end_date   = Date.parse(enddated.to_s)
        (start_date).upto(end_date).each do |cday|
           process_calculate_attend(cday)
          # donestatus +=1
        end
    end
    
end

private
def process_calculate_attend(dates)
  nedates   = year_month_days_formatted(dates)
  empobj    = MstEmployee.where("emp_compcode = ?  AND emp_joindate<>'000:00:00' AND emp_joindate <= ? AND emp_leavingdate<>?",@compcodes,nedates,nedates).order("emp_name ASC,emp_joindate ASC")
  if empobj.length >0
       empobj.each do |emps|
           newemp    = TrnGeoLocation.where("gc_compcode = ? AND gc_date = ? AND gc_user_id =?",@compcodes,nedates,emps.id).first
           mypunch   = false
           gcimg     = ""           
           if newemp !=nil
              mypunch = true
              gcimg   = newemp.gc_userimage
           end
           userempobj = check_user_employee_existed(emps.id)
           if userempobj
             process_insert_calculated_attendance(@compcodes,emps.id,nedates,mypunch,gcimg)
           end
       end
  end

end

private
def process_insert_calculated_attendance(compcode,empcode,empdate,checkpunch,gcimg)
  entryreq   =  2
  entrymade  =  3
  departname =  ''
  shiftcode  =  ''
  categoryid =  ''
  shiftime   =  ''
  shiftend   =  ''
  hlfdaycal  =  0
  hids       =  0
  catid      =  0
  lathrs     =  0
  earlyhrs   =  0
  workhrs    =  0
  overtimes  =  0
  night      =  'N'
  shifxtcode = 0
  countmispunch = 0
  salary        = 0
  shifthrs      = ''
  empobj     = get_employee_detail(compcode,empcode)
  if empobj
      departid   = empobj.emp_department
      shifxtcode = empobj.emp_shift
      catid      = empobj.emp_category
      salary     = empobj.emp_total
      hids      = 0
      if departid.to_i >0
            dpsoobj = get_department_list(compcode,departid)
            if dpsoobj
              departname = dpsoobj.dp_name
            end
      end
  end
  shifobjs  = get_shift_detail(compcode,shifxtcode)
  if shifobjs
      shiftime    = formatted_times(shifobjs.attend_shfintime)
      shiftend    = formatted_times(shifobjs.attend_shfout)
      hlfdaycal   = formatted_times(shifobjs.attend_endhours)
      shiftcode   = shifobjs.attend_shiftcode
      shifthrs    = shifobjs.attend_shfhrs
      overtimechk = shifobjs.attend_otdeductafterhrs
  end

  absentstus = 0
  arrvtime  = get_arrival_time(compcode,empcode,empdate)
  deprtime  = get_departure_time(compcode,empcode,empdate)
  if arrvtime != nil && arrvtime !=''
    absentstus +=1
  else
    countmispunch +=1
  end
  if deprtime != nil && deprtime !=''
    absentstus +=1
  else
    countmispunch +=1
  end
  mnulfirst     = ''
  mnullast      = ''
  manulpunches  = ''
  mnulfirstobj  =  get_manual_punches(compcode,empcode,empdate,"F")
  mnullastobj   =  get_manual_punches(compcode,empcode,empdate,"L")
  if mnulfirstobj
     if mnulfirstobj.gc_punchtype == 'M'
       mnulfirst = mnulfirstobj.gc_local_time
       arrvtime  = mnulfirst
     end
  end
  if mnullastobj
    if mnullastobj.gc_punchtype == 'M'
      mnullast = mnullastobj.gc_local_time
      deprtime = mnullast
    end

  end


  if shiftime !=nil && shiftime != '' && arrvtime !=nil && arrvtime !=''
      strtshiftime = shiftime.to_s.gsub(":",".")
      newarvtime   = arrvtime.to_s.gsub(":",".")
      if newarvtime.to_f >strtshiftime.to_f
        lathrs = calc_time_mydiff(shiftime,arrvtime)
      else
        lathrs = 0
      end
  end

   if shiftend !=nil && shiftend != '' && deprtime !=nil && deprtime !=''
      newshftend   = shiftend.to_s.gsub(":",".")
      newdeptm     = deprtime.to_s.gsub(":",".")
       deprtimes   = time_formatted_setup(deprtime.to_s)
       newdeptm    = deprtimes.to_s.gsub(":",".")
      if newshftend.to_f >newdeptm.to_f
        
         earlyhrs  = calc_time_mydiff(deprtimes,shiftend)
      else
        earlyhrs = 0
      end
  end
  workhrs       = calc_time_mydiff(arrvtime,deprtime)
  presabstats   = 0
  absentsats    = 0
  presenyabstus = ""
  paidleave     = 0
  unpaidleave   = 0

  if shiftend !=nil && shiftend != '' && deprtime !=nil && deprtime !=''

      newshftends   = shiftend.to_s.gsub(":",".")
      newdeptms     = deprtime.to_s.gsub(":",".")
      deprtimes     = time_formatted_setup(deprtime.to_s)
      newdeptms      = deprtimes.to_s.gsub(":",".")
      if newdeptms.to_f>newshftends.to_f

         overtimes = calc_time_mydiff(shiftend,deprtime)
      else
        overtimes = 0
      end

      overtimechks = overtimechk.to_s.gsub(":",".")
      myovertimes  = overtimes.to_s.gsub(":",".")
      if myovertimes.to_f >overtimechks.to_f
         ### execute function if required
      else
        overtimes = 0
      end
  end

  if absentstus.to_i<=0
      absentsats =1
      presenyabstus ="A"
  else
      chkhrs = 0
     # hdhrs  = 0
     if workhrs !=nil && workhrs !=''
       chkhrs =   calc_hours_diff(chkhrs)
     end
     if hlfdaycal !=nil && hlfdaycal !=''
      # hdhrs =   calc_hours_diff(hlfdaycal)
     end
      if chkhrs.to_i >0 && chkhrs.to_i <=2
         absentsats =1
         presenyabstus ="A"
      elsif chkhrs.to_i >0 && chkhrs.to_i >4 && chkhrs.to_i<6
          presabstats   = "0.5"
          presenyabstus = "HD"
      else
          presabstats   = "1"
          presenyabstus = "P"
      end
  end

  if mnulfirst !=nil && mnulfirst !='' && mnullast !=nil && mnullast != ''
    manulpunches ="A*,D*"
    countmispunch = 0
  elsif mnulfirst !=nil && mnulfirst !=''
    manulpunches = "A*"
    countmispunch =0
  elsif mnullast !=nil && mnullast != ''
    manulpunches = "D*"
    countmispunch = 0
  end

  misspunch     = ""
  if countmispunch.to_i == 1
     misspunch ="*"
  elsif countmispunch.to_i >1
     misspunch ="**"
  end

  catobj    = get_category_detail(compcode,catid)
  if catobj
    categoryid = catobj.cat_categoryid
  end
  weekdays = ""
  myweekd  = true
  if empdate !=nil && empdate !=''
      weekdays = Date.parse(empdate.to_s).strftime("%A")
      if weekdays.to_s.downcase == 'sunday'
        presenyabstus = "WO"
         misspunch     = ""
         myweekd       = false
      end
  end

  hldsobj = get_holiday_list(compcode,empdate)
  if hldsobj
      presenyabstus = "HL"
      presabstats   = "1"
      misspunch     = ""
  end
  if !checkpunch && myweekd
      absentsats    = 1
      presenyabstus = "A"
      misspunch     = ""
  end

  ### CALCULATE LATE PLENTY #####
  numberofdays  = 0
  if empdate != nil && empdate != ''
      nemonth       = Date.parse(empdate.to_s).strftime("%m")
      nemonth       = nemonth.to_i
      newyears      = Date.parse(empdate.to_s).strftime("%Y")
      numberofdays  = Time.days_in_month(nemonth, newyears)
  end
  newshithrs    = shifthrs.to_s.gsub(":",".")
  monthdaysval  = salary.to_f/numberofdays.to_f
  totalvl       = monthdaysval.to_f/newshithrs.to_f
  newminutes    = totalvl.to_f/60
  newminutes    = currency_formatted(newminutes)
  nlatehrsx     = lathrs.to_s.split(":")
  nlatehrmy     = nlatehrsx ? nlatehrsx[0] : 0
  myltmnst      = nlatehrsx ? nlatehrsx[1] : 0
  nlatehrs      = (nlatehrmy.to_i*60).to_i+myltmnst.to_i
  finalltp      = newminutes.to_f*nlatehrs.to_f
  finalltp      = currency_formatted(finalltp)
  latepenalty   = ""
  if finalltp.to_f >0 && finalltp.to_f <120
    latepenalty = finalltp.to_s.gsub(".",":")
    #die
  end
  #### END LATE PELANTY #########
  
  if compcode !=nil && compcode !='' && empcode.to_i >0
     save_attendance_detail(compcode,empcode,empdate,entryreq,entrymade,shiftcode,categoryid,arrvtime,lathrs,deprtime,earlyhrs,workhrs,overtimes,presabstats,absentsats,presenyabstus,paidleave,unpaidleave,manulpunches,night,departname,misspunch,gcimg,latepenalty)
  end

end


private
def get_holiday_list(compcode,empdate)
  hldobj  = Holiday.where("compCode =? AND dateYear = ?",compcode,empdate).first
  return hldobj
end

private
def get_manual_punches(compcode,empcode,dated,lftyp)
  trnmnobj = nil
  if lftyp == 'F'
     trnmnobj =  TrnGeoLocation.select("gc_local_time,gc_punchtype").where("gc_compcode = ? AND gc_date = ? AND gc_user_id =?",compcode,dated,empcode).order("created_at ASC").first
  elsif lftyp == 'L'
     trnmnobj =  TrnGeoLocation.select("gc_local_time,gc_punchtype").where("gc_compcode = ? AND gc_date = ? AND gc_user_id =?",compcode,dated,empcode).order("created_at DESC").first
  end
    return trnmnobj
end

private
def get_category_detail(compcode,catid)
  catobj = MstCategory.where("cat_compcode = ? AND id=?",compcode,catid).first
  return catobj
end

private
def get_shift_detail(compcode,shiftcode)
  shifobj =  MstShift.where("attend_compcode = ? AND id = ?",compcode,shiftcode).first
  return shifobj
end

private
def get_employee_detail(compcode,empcode)
    empobj = MstEmployee.where("emp_compcode =? AND id = ?",compcode,empcode).first
    return empobj
end

private
def get_department_list(compcode,depid)
  depobj =  MstDepartment.where("dp_compcode= ? AND id =?",compcode,depid).first
  return depobj
end

  private
  def get_arrival_time(compcodes,users,dates)
     iswhere   = "gc_compcode='#{compcodes}'"
     iswhere   +=" AND gc_user_id='#{users}'  AND gc_date ='#{dates}'"
     isselect  = "gc_local_time as myintime"
     intimes   = ''
     isgeoloc  = TrnGeoLocation.select(isselect).where(iswhere).order("created_at ASC").first
     if isgeoloc!=nil
      intimes = isgeoloc.myintime
     end
     return intimes
  end
  private
  def get_departure_time(compcodes,users,dates)
     iswhere   = "gc_compcode='#{compcodes}'"
     iswhere   +=" AND gc_user_id='#{users}'  AND gc_date='#{dates}'"
     isselect  = "gc_local_time as outtime"
     outimes   = ''
     gsobj     = TrnGeoLocation.select(isselect).where(iswhere)
     if gsobj.length >1
         isgeoloc  = TrnGeoLocation.select(isselect).where(iswhere).order("created_at DESC").first
         if isgeoloc!=nil
          outimes = isgeoloc.outtime
         end
     end
     return outimes
  end

  private
  def save_attendance_detail(compcode,empcode,trndated,entryenq,entrymade,shift,catid,arvtime,latehrms,dephrm,earlhrms,wrkhrms,ovtime,presents,absents,presabs,paidleave,unpaidleave,manulpunch,night,dept,mispunch,gcimg,latepenalty)
      chekattd = TrnAttendanceList.where("al_compcode = ? AND al_empcode = ? AND al_trandate = ?",compcode,empcode,trndated).first
      if chekattd
         chekattd.update(:al_entryreq=>entryenq,:al_latepelanty=>latepenalty,:al_userimage=>gcimg,:al_entrymade=>entrymade,:al_shift=>shift,:al_catid=>catid,:al_arrtime=>arvtime,:al_latehrs=>latehrms,:all_deptime=>dephrm,:al_earlhrs=>earlhrms,:al_workhrs=>wrkhrms,:al_overtime=>ovtime,:al_present=>presents,:al_absent=>absents,:al_presabsent=>presabs,:al_paidleave=>paidleave,:al_unpaidleave=>unpaidleave,:al_manualpunch=>manulpunch,:al_nightshift=>night,:al_departid=>dept,:al_misspunch=>mispunch)
      else
          svsatnd = TrnAttendanceList.new(:al_compcode=>compcode,:al_latepelanty=>latepenalty,:al_userimage=>gcimg,:al_empcode=>empcode,:al_trandate=>trndated,:al_entryreq=>entryenq,:al_entrymade=>entrymade,:al_shift=>shift,:al_catid=>catid,:al_arrtime=>arvtime,:al_latehrs=>latehrms,:all_deptime=>dephrm,:al_earlhrs=>earlhrms,:al_workhrs=>wrkhrms,:al_overtime=>ovtime,:al_present=>presents,:al_absent=>absents,:al_presabsent=>presabs,:al_paidleave=>paidleave,:al_unpaidleave=>unpaidleave,:al_manualpunch=>manulpunch,:al_nightshift=>night,:al_departid=>dept,:al_misspunch=>mispunch)
          if svsatnd.save
              ## execute save message
          end
      end


  end

  private
  def print_attendance_list
    frmbegindated  = session[:req_fromattend]
    enddated       = session[:req_uptoattend]
    emplid         = session[:req_empattend]
      iswhere  = "al_compcode = '#{@compcodes}'"
      if frmbegindated !=nil && frmbegindated !=''
        iswhere  += " AND al_trandate >='#{frmbegindated}'"        
      end
      if enddated !=nil && enddated !=''
        iswhere  += " AND al_trandate <='#{enddated}'"        
      end
      if emplid.to_i >0
        iswhere  += " AND al_empcode ='#{emplid}'"        
      end
      isselect = "'' as departname,'' as desnation,'' as empname,trn_attendance_lists.*,DATE_FORMAT(al_trandate,'%d-%b-%Y') as bdated,'' as remark"
      attndobj = TrnAttendanceList.select(isselect).where(iswhere).order("al_trandate DESC,al_empcode ASC")
      return attndobj
  end
  private
  def get_department_detail(compcode,id)
    depobj =  MstDepartment.where("dp_compcode = ? AND id= ?",compcode,id).first
    return depobj
end
private
def get_designation_detail(compcode,id)
depobj =  Designation.select("description as mydescript").where("compCode = ? AND id= ?",compcode,id).first
  return depobj
end
end
