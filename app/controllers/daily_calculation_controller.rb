class DailyCalculationController < ApplicationController
  before_action :require_login  
  skip_before_action :verify_authenticity_token,:only=>[:index,:search,:ajax_process]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted
  helper_method :set_dct,:get_name_of_product,:get_user_list_name

  def index
    @compcodes      = session[:loggedUserCompCode]
    Time.zone       = "Kolkata"   
    cid             = '99'
    usersloginid    =  session[:logedUserId]
    @Curdated       =  Date.today
    month_number    =  Time.now.month
    month_begin     =  Date.new(Date.today.year, month_number)
    begdate         =  Date.parse(month_begin.to_s)
    @nbegindate     =  begdate.strftime('%d-%b-%Y')
    month_ending    =  month_begin.end_of_month
    endingDate      =  Date.parse(month_ending.to_s)
     @enddate       =  endingDate.strftime('%d-%b-%Y')
     @curmonths     =  month_number
     @sewDepart     = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment=''",@compcodes).order("departDescription ASC")
  end

  def create
  @compcodes = session[:loggedUserCompCode]
  
  end

def daily_calculation_refresh
  session[:request_params]        = nil
  session[:sales_search]          = nil
  session[:salessearchId]         = nil
  session[:req_prints]            = nil
  session[:newempsearch]          = nil
  session[:request_params]        = nil
  session[:isErrorhandled]        = nil
  session[:reqs_leadsource]       = nil
  session[:reqs_lds_time]         = nil
  session[:reqs_lds_clientname]   = nil
  session[:reqs_client_address]   = nil
  session[:reqs_client_pin]       = nil
  session[:reqs_lds_state]        = nil
  session[:reqs_lds_city]         = nil
  session[:reqs_lds_mobile]       = nil
  session[:reqs_lds_email]        = nil
  session[:reqs_lds_prodcode]     = nil
  session[:reqs_lds_interestlevel] = nil
  session.delete(:request_params)
  session.delete(:request_params)
  redirect_to "#{root_url}"+"daily_calculation"


end
def show
   @compcodes      = session[:loggedUserCompCode]
    
   
end

def ajax_process
    @compcodes  = session[:loggedUserCompCode]
    doneprocess = 0
    mysflgs   = 1 
    if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'PROCESS'
          compobjs   = MstCompany.select("cmp_processabort").where("cmp_companycode = ? ",@compcodes).first         
          if compobjs
              if compobjs.cmp_processabort.to_s == 'Y'
                  mysflgs = 2
              end
          end
          if mysflgs.to_i == 1
              update_abortprocess_status()
              doneprocess = process_attendance_calculation()  
              reverse_update_abortprocess_status()
          end   
    end
     respond_to do |format|
      format.json { render :json => { 'data'=>mysflgs, "message"=>'',:status=>doneprocess } }
     end
     return 
end

private
def update_abortprocess_status
    @compcodes = session[:loggedUserCompCode]
    compobjs   = MstCompany.where("cmp_companycode = ? ",@compcodes).first
    if compobjs
      compobjs.update(:cmp_processabort=>'Y')
    end
  
end


private
def reverse_update_abortprocess_status
    @compcodes = session[:loggedUserCompCode]
    compobjs   = MstCompany.where("cmp_companycode = ? ",@compcodes).first
    if compobjs
      compobjs.update(:cmp_processabort=>'')
    end
  
end

private
def process_attendance_calculation
    donestatus = 0
    years          = Time.now.strftime("%Y")
    amonth         = params[:amonth] !=nil  && params[:amonth] != '' ?  params[:amonth] : ''
    types          = params[:type] !=nil  && params[:type] != '' ?  params[:type] : ''
    depcode        = params[:depcode] !=nil  && params[:depcode] != '' ?  params[:depcode] : ''
    empcode        = params[:empcode] !=nil  && params[:empcode] != '' ?  params[:empcode] : ''

    if types == 'FMT'
          if amonth.to_i == 1
              params[:from_date] = "01-Jan-"+years.to_s
              params[:upto_date] = "31-Jan-"+years.to_s
          elsif amonth.to_i == 2
              params[:from_date] = "01-Feb-"+years.to_s
              params[:upto_date] = "28-Feb-"+years.to_s
          elsif amonth.to_i == 3
              params[:from_date] = "01-Mar-"+years.to_s
              params[:upto_date] = "31-Mar-"+years.to_s
          elsif amonth.to_i == 4
              params[:from_date] = "01-Apr-"+years.to_s
              params[:upto_date] = "30-Apr-"+years.to_s
          elsif amonth.to_i == 5
              params[:from_date] = "01-May-"+years.to_s
              params[:upto_date] = "31-May-"+years.to_s
          elsif amonth.to_i == 6
              params[:from_date] = "01-Jun-"+years.to_s
              params[:upto_date] = "30-Jun-"+years.to_s
          elsif amonth.to_i == 7
              params[:from_date] = "01-Jul-"+years.to_s
              params[:upto_date] = "31-Jul-"+years.to_s
          elsif amonth.to_i == 8
              params[:from_date] = "01-Aug-"+years.to_s
              params[:upto_date] = "31-Aug-"+years.to_s
          elsif amonth.to_i == 9
              params[:from_date] = "01-Sep-"+years.to_s
              params[:upto_date] = "30-Sep-"+years.to_s
          elsif amonth.to_i == 10
              params[:from_date] = "01-Oct-"+years.to_s
              params[:upto_date] = "31-Oct-"+years.to_s
          elsif amonth.to_i == 11
              params[:from_date] = "01-Nov-"+years.to_s
              params[:upto_date] = "30-Nov-"+years.to_s
          elsif amonth.to_i == 12
              params[:from_date] = "01-Dec-"+years.to_s
              params[:upto_date] = "31-Dec-"+years.to_s
          end
    elsif types == 'DYW'
          params[:from_date] = params[:from_date]
          params[:upto_date] = params[:from_date]
    elsif types == 'PRD'
          params[:from_date] = params[:from_date]
          params[:upto_date] = params[:upto_date]
    end

    frmbegindated  = params[:from_date] !=nil  && params[:from_date] != '' ? year_month_days_formatted(params[:from_date]) : ''
    enddated       = params[:upto_date] !=nil  && params[:upto_date] != '' ? year_month_days_formatted(params[:upto_date]) : ''
    #######check weekendays##########
      shifobjs       = get_shift_detail(@compcodes,'ST')
      mydaycounts    = 0
      firstsatcnt    = 0
      secsatcnt      = 0
      thirdsatcnt    = 0
      fourthsatcnt   = 0
      fifthsatcnt    = 0
      
      gmonths      = frmbegindated.to_s.split("-")    
      newstartdate = gmonths[0].to_s+"-"+gmonths[1].to_s+"-01"
      if newstartdate !=nil && newstartdate != ''  && enddated !=nil && enddated != ''
          newstartdate = Date.parse(newstartdate.to_s)
          newenddate   = Date.parse(enddated.to_s)
          (newstartdate).upto(newenddate).each do |cdays|   
            mweekdays = Date.parse(cdays.to_s).strftime("%A")  
            if( mweekdays.to_s.downcase =='saturday' ) 
                 mydaycounts +=1
                 if mydaycounts.to_i == 2                
                  secsatcnt = cdays
                end
             end
              # if mydaycounts.to_i == 1
              #   firstsatcnt = 1
              # end
              
              # if mydaycounts.to_i == 3
              #   thirdsatcnt = 1
              # end
              # if mydaycounts.to_i == 4
              #   fourthsatcnt = 1
              # end
              # if mydaycounts.to_i == 5
              #   fifthsatcnt = 1
              # end
          end
      end
    ########## end #################
    
    @emplid        = 0
   
    if frmbegindated !=nil && frmbegindated != ''  && enddated !=nil && enddated != ''
      
        start_date = Date.parse(frmbegindated.to_s)
        end_date   = Date.parse(enddated.to_s)
        process_entire_execute(start_date,end_date)
        mywhere = "al_compcode='#{@compcodes}' AND al_trandate >='#{frmbegindated}' AND al_trandate <='#{enddated}'"
        if depcode !=nil && depcode !=''
           mywhere += " AND al_department ='#{depcode}'"
        end
        if empcode !=nil && empcode !=''
            mywhere += " AND al_empcode ='#{empcode}'"          
        end
        TrnAttendanceList.where(mywhere).delete_all 

        (start_date).upto(end_date).each do |cday| 
            empdate    = year_month_days_formatted(cday)
            hldsobj    = get_holiday_list(@compcodes,empdate)           
           process_calculate_attend(cday,depcode,empcode,firstsatcnt,secsatcnt,thirdsatcnt,fourthsatcnt,fifthsatcnt,hldsobj,shifobjs)
           donestatus +=1
           
        end
        #######ADD PROCESS CHECK FINAL ABSENT ###########
          if start_date !=nil && start_date !=''  && end_date!=nil && end_date!=''
            get_weekof_sewadar_listed(start_date,end_date,depcode,empcode)
            get_before_after_sewadar_list(start_date,end_date,depcode,empcode)
          end

        ########## END PROCESS #################

    end
    return donestatus;
end

private
def process_calculate_attend(dates,depcode,empcode,firstsatcnt,secsatcnt,thirdsatcnt,fourthsatcnt,fifthsatcnt,hldsobj,shifobjs)
  nedates    = year_month_days_formatted(dates)
  sqls       = "CALL get_employee_process ('#{@compcodes}','#{nedates}','#{depcode}','#{empcode}')"
  empobj     = request_processor(sqls)     
  if empobj.length >0
    
       empobj.each do |emps|
          #  newemp    = TrnGeoLocation.select("gc_userimage").where("gc_compcode = ? AND gc_date = ? AND gc_user_id =?",@compcodes,nedates,emps.sw_sewcode).first
             mypunch   = false
             gcimg     = ""            
          #  if newemp !=nil
          #     mypunch = true
          #     gcimg   = newemp.gc_userimage
          #  end
           process_insert_calculated_attendance(@compcodes,emps.sw_sewcode,nedates,mypunch,gcimg,emps.sw_depcode,emps.sw_shiftcode,emps.sw_catcode,emps.sw_location,firstsatcnt,secsatcnt,thirdsatcnt,fourthsatcnt,fifthsatcnt,hldsobj,shifobjs)
       end
  end

end

private
def process_insert_calculated_attendance(compcode,empcode,empdate,checkpunch,gcimg,departid,shifxtcode,catid,locations,f1,f2,f3,f4,f5,hldsobj,shifobjs)
  entryreq   =  2
  entrymade  =  3
  departname =  ''
  shiftcode  =  ''
  categoryid =  ''
  shiftime   =  ''
  shiftend   =  ''
  hlfdaycal  =  0
  hids       =  0
  catid      =  catid !=nil && catid!='' ? catid : ''
  lathrs     =  0
  earlyhrs   =  0
  workhrs    =  0
  overtimes  =  0
  night      =  'N'
  shifxtcode = 0
  countmispunch = 0
  salary        = 0
  shifthrs      = ''
  locations     = ""
  depatment     = ""
  hdshiftime    = 0
  allowhalfday  = 0
  depatment     = departid
  
  # empobj     = get_employee_detail(compcode,empcode)
  # if empobj
  #     departid    = empobj.sw_depcode
  #     shifxtcode  = empobj.sw_shiftcode
  #     catid       = empobj.sw_catcode
  #     locations   = empobj.sw_location
  #     depatment   = empobj.sw_depcode
	#   salary     = 0
  #     ####LATE PENALITY RULE
	#   #empobjs    = get_office_information(compcode,empcode)
	#   #if empobjs
	# 	#salary     = empobj.emp_total
	#   #end
	#   ### END LATE PENALITY RULE
  #     hids      = 0
  #     if departid.to_i >0
  #           dpsoobj = get_department_list(compcode,departid)
  #           if dpsoobj
  #             departname = dpsoobj.dp_name
  #           end
  #     end
  # end
  departname = departid
  # if departid.to_i >0
  #   dpsoobj = get_department_list(compcode,departid)
  #   if dpsoobj
  #     departname = dpsoobj.dp_name
  #   end
  # end



firstweekname   = ""
secondweekname  = ""
numbweekdays    = 0
fstsaturdayoff  = ''
secsaturdayoff  = ''
thsaturdayoff   = ''
foursaturdayoff = ''
fifsaturdayoff  = ''
satfirsthlf     = ''
satsechlf       = ''
satthrhlf       = ''
satforhlf       = ''
satfivhlf       = ''
leavetype       = ""
 # 
  if shifobjs
      shiftime        = formatted_times(shifobjs.attend_shfintime)
      shiftend        = formatted_times(shifobjs.attend_shfout)
      hlfdaycal       = formatted_times(shifobjs.attend_endhours)
      shiftcode       = shifobjs.attend_shiftcode
      shifthrs        = shifobjs.attend_shfhrs
      overtimechk     = shifobjs.attend_otdeductafterhrs
      hdshiftime      = shifobjs.attend_presentforwork ### HALF DAY SHIFT TIME
      allowhalfday    = (hdshiftime.to_s.gsub(":",".")).to_f+(shiftime.to_s.gsub(":",".")).to_f
      restouttime     = shifobjs.attend_outtime

      firstweekoff    = shifobjs.attend_ist
      secweekoff      = shifobjs.attend_2nd

      fstsaturdayoff  = shifobjs.attend_sat1st
      secsaturdayoff  = shifobjs.attend_sat2nd
      thsaturdayoff   = shifobjs.attend_sat3rd
      foursaturdayoff = shifobjs.attend_sat4th
      fifsaturdayoff  = shifobjs.attend_sat5th

      satfirsthlf     = shifobjs.attend_sathaf1st
      satsechlf       = shifobjs.attend_sathaf2nd
      satthrhlf       = shifobjs.attend_sathaf3rd
      satforhlf       = shifobjs.attend_sathaf4th
      satfivhlf       = shifobjs.attend_sathaf5th
      firstweekname   = get_days_name(firstweekoff)
      secondweekname  = get_days_name(secweekoff)
      if firstweekname !=nil && firstweekname !='' && secondweekname !=nil && secondweekname !=''
        numbweekdays = 5
      elsif firstweekname !=nil && firstweekname !=''
        numbweekdays = 6
      elsif secondweekname !=nil && secondweekname !=''
        numbweekdays = 6
      end
  end



########## END PROCESS OF ################ 
   
  absentstus   = 0
  arrvtime     = get_common_arrival_time(compcode,empcode,empdate,'A') #get_arrival_time(compcode,empcode,empdate)
  deprtime     = get_common_arrival_time(compcode,empcode,empdate,'D')  #get_departure_time(compcode,empcode,empdate)
  # if countpunches.to_i == 1
  #   deprtime = 0
  # end
  if arrvtime.to_s.gsub(":",".").to_f >0 && deprtime.to_s.gsub(":",".").to_f >0
        if arrvtime.to_s.gsub(":",".").to_f.round(2) == deprtime.to_s.gsub(":",".").to_f.round(2)
            deprtime = 0
        end    
  end
  if arrvtime.to_s.gsub(":",".").to_f >0 || deprtime.to_s.gsub(":",".").to_f >0
     checkpunch = true
  end
  
  if arrvtime.to_s.gsub(":",".").to_f >0 && deprtime.to_s.gsub(":",".").to_f<=0
      countmispunch +=1

  end
  if arrvtime.to_s.gsub(":",".").to_f <=0 && deprtime.to_s.gsub(":",".").to_f<=0
    absentstus =1   
  end
  mnulfirst     = ''
  mnullast      = ''
  manulpunches  = ''
  
  # mnulfirstobj  =  get_manual_punches(compcode,empcode,empdate,"F")
  # mnullastobj   =  get_manual_punches(compcode,empcode,empdate,"L")
  # if mnulfirstobj
  #    if mnulfirstobj.gc_punchtype == 'M'
  #      mnulfirst = mnulfirstobj.gc_local_time
  #      arrvtime  = mnulfirst
  #    end
  # end
  # if mnullastobj
  #   if mnullastobj.gc_punchtype == 'M'
  #     mnullast = mnullastobj.gc_local_time
  #     deprtime = mnullast
  #   end

  # end
   lateminuts = 0.15

  if shiftime !=nil && shiftime != '' && arrvtime !=nil && arrvtime !=''
      strtshiftime = shiftime.to_s.gsub(":",".")
      strtshiftime = strtshiftime.to_f+lateminuts.to_f
      newarvtime   = arrvtime.to_s.gsub(":",".")

      if newarvtime.to_f >strtshiftime.to_f && newarvtime.to_f >0
          lathrs  = calc_time_mydiff(shiftime,arrvtime)
          #lmnts  = lathrs ? lathrs.to_s.split(":") : nil
          # if lmnts && lmnts[1].to_f >lateminuts.to_f
          #   ### check late hours
          # else
          #   lathrs = 0
          # end
      else
           lathrs = 0
      end
  end
  findepment     = deprtime.to_s.gsub(":",".")
   if findepment.to_f >0 
        if shiftend !=nil && shiftend != '' && deprtime !=nil && deprtime !='' 
            newshftend   = shiftend.to_s.gsub(":",".")
            newdeptm     = deprtime.to_s.gsub(":",".")
            deprtimes   = time_formatted_setup(deprtime.to_s)
            newdeptm    = deprtimes.to_s.gsub(":",".")
            if newshftend.to_f >newdeptm.to_f && newdeptm.to_f  >0         
                  earlyhrs  = calc_time_mydiff(deprtimes,shiftend)          
            else
                  earlyhrs = 0
            end
        end
    end   
  workhrs       = calc_time_mydiff(arrvtime,deprtime)
  presabstats   = 0
  absentsats    = 0
  presenyabstus = ""
  paidleave     = 0
  unpaidleave   = 0

  if shiftend !=nil && shiftend != '' && deprtime !=nil && deprtime !=''
      calcovts      = overtimechk
      newshftends   = shiftend.to_s.gsub(":",".")
      newshftends   = newshftends.to_f+calcovts.to_f
      newdeptms     = deprtime.to_s.gsub(":",".")
      if findepment.to_f >0
        deprtimes     = time_formatted_setup(deprtime.to_s)
      else
        deprtimes = 0 
      end     
      newdeptms     = deprtimes.to_s.gsub(":",".")
      if findepment.to_f >0 && newdeptms.to_f>newshftends.to_f
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

  if absentstus.to_i>0
      absentsats   =1
      presabstats  = 0
      presenyabstus ="AA"
     
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
         presabstats =0
         presenyabstus ="AA"
      elsif chkhrs.to_i >0 && format_hh_mm_points(workhrs).to_f < format_hh_mm_points(hdshiftime).to_f
        ## allowhalfday
          presabstats   = "0.5"  
          absentsats    = 0        
          if format_hh_mm_points(arrvtime).to_f >format_hh_mm_points(restouttime).to_f
            presenyabstus = "PA"  ### SECOND HALF
            absentsats = 0
          else
            presenyabstus = "AP" ## FIRST HALF
            absentsats =0
          end          
      else
          presabstats   = "1"
          presenyabstus = "PP"
          absentsats     = 0
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

  # catobj    = get_category_detail(compcode,catid)
  # if catobj
  #   categoryid = 0 #catobj.id
  # end

  
  weekdays = ""
  myweekd  = true
########## GET ABSENT IN LAST FIVE OR SIX DAYS WORKING ###########
absentstatus = nil# get_last_working_status(compcode,empcode,empdate,numbweekdays)
mydayss = empdate.to_s.split("-")
#########CHECK WEEK DAY OFF AND HALF SATURDAY########
  if empdate !=nil && empdate !=''
      weekdays = Date.parse(empdate.to_s).strftime("%A")
      if weekdays.to_s.downcase == firstweekname.to_s.downcase
    
         absentstatus = get_last_working_status(compcode,empcode,empdate,numbweekdays,catid)
         if absentstatus.to_i >0
          presenyabstus = "AA"            
          absentsats   = 1
          presabstats  = 0
         
        else  
          absentsats   = 0
          presabstats  = 0
          presenyabstus = "WO"
        end
          #presenyabstus = "WO"
           misspunch     = ""
           myweekd       = false
           
      elsif weekdays.to_s.downcase == secondweekname.to_s.downcase
        absentstatus = get_last_working_status(compcode,empcode,empdate,numbweekdays,catid)
        if absentstatus.to_i >0
            presenyabstus = "AA"
            absentsats   = 1
           presabstats  = 0
          else
            absentsats   = 0
            presabstats  = 0
            presenyabstus = "WO"
          end
           
       # presenyabstus = "WO"
         misspunch     = ""
         myweekd       = false
      elsif weekdays.to_s.downcase == 'saturday' && fstsaturdayoff.to_s=='Y'  && f1.to_i == 1
        numbweekdays = 5
        absentstatus = get_last_working_status(compcode,empcode,empdate,numbweekdays,catid)
        if absentstatus.to_i >0
            presenyabstus = "AA"
            absentsats    = 1
            presabstats   = 0
            presenyabstus = ""
        else
          absentsats    = 0
          presabstats   = 0
          presenyabstus = "WO"
        end
          
          misspunch     = ""
          myweekd       = false
      elsif weekdays.to_s.downcase == 'saturday' && secsaturdayoff.to_s=='Y' && year_month_days_formatted(f2).to_date == year_month_days_formatted(empdate).to_date
        numbweekdays = 5   
        absentstatus = get_last_working_status(compcode,empcode,empdate,numbweekdays,catid)
           if absentstatus.to_i >0
            presenyabstus  = "AA"
            absentsats     =1
            presabstats    = 0
          else
            absentsats     =0
            presabstats    = 0
            presenyabstus = "WO"
          end
        
           
           #presenyabstus  = "WO"
          misspunch       = ""
          myweekd         = false
      elsif weekdays.to_s.downcase == 'saturday' && thsaturdayoff.to_s=='Y' && f3.to_i == 1
        numbweekdays = 5
        # if absentstatus
        #   presenyabstus = "AA"
        # else
        #   presenyabstus = "WO"
        # end
        absentsats   =0
       presabstats  = 0
        presenyabstus = "WO"
          misspunch     = ""
          myweekd       = false
      elsif weekdays.to_s.downcase == 'saturday' && foursaturdayoff.to_s=='Y' && f4.to_i == 1
          presenyabstus = "WO"
          misspunch     = ""
          myweekd       = false
          absentsats   =0
        presabstats  = 0
      elsif weekdays.to_s.downcase == 'saturday' && fifsaturdayoff.to_s=='Y' && f5.to_i == 1
        # if absentstatus
        #   presenyabstus = "AA"
        # else
        #   presenyabstus = "WO"
        # end
        absentsats   =0
        presabstats  = 0
        presenyabstus = "WO"
          misspunch     = ""
          myweekd       = false
      elsif weekdays.to_s.downcase == 'saturday' && satfirsthlf.to_s=='Y' && f1.to_i == 1
          presenyabstus = "AP"
          misspunch     = ""
          myweekd       = false          
          presabstats   = "0.5"
          misspunch     = ""
           absentsats   =0
      elsif weekdays.to_s.downcase == 'saturday' && satsechlf.to_s=='Y' && f2.to_i == 1
          presenyabstus = "AP"
          misspunch     = ""
          myweekd       = false          
          presabstats   = "0.5"
          misspunch     = ""
          absentsats   =0
      elsif weekdays.to_s.downcase == 'saturday' && satthrhlf.to_s=='Y' && f3.to_i == 1
          presenyabstus = "AP"
          misspunch     = ""
          myweekd       = false          
          presabstats   = "0.5"
          misspunch     = ""
          absentsats   =0
      elsif weekdays.to_s.downcase == 'saturday' && satforhlf.to_s=='Y' && f4.to_i == 1
          presenyabstus = "AP"
          misspunch     = ""
          myweekd       = false          
          presabstats   = "0.5"
          misspunch     = ""
          absentsats   =0
      elsif weekdays.to_s.downcase == 'saturday' && satfivhlf.to_s=='Y' && f5.to_i == 1
          presenyabstus = "AP"
          misspunch     = ""
          myweekd       = false          
          presabstats   = "0.5"
          misspunch     = ""
          absentsats    =0
      end

  end
  #########END CHECK WEEK DAY OFF AND HALF SATURDAY########
  
  if hldsobj
        absentstatus    = get_last_working_status(compcode,empcode,empdate,numbweekdays,catid)
       if arrvtime.to_s.gsub(":",".").to_f >0 || deprtime.to_s.gsub(":",".").to_f >0
         #########echeck
              presenyabstus = "HL"
              presabstats   = 0
              misspunch     = ""
              absentsats    = 0
              myweekd       = false
             
       else
        
            if absentstatus.to_i >0
                
                presenyabstus = "AA"
                presabstats   = 0
                misspunch     = ""
                absentsats    = 1
                myweekd       = false
            else
                presenyabstus = "HL"
                presabstats   = 0
                misspunch     = ""
                absentsats    = 0
                myweekd       = false

            end

      end
  end
  if !checkpunch && myweekd
    absentsats     = 1
    presenyabstus  = "AA"
    misspunch      = ""
    presabstats    = 0
  
end
  if presenyabstus == "WO" || presenyabstus == "HL"
      if arrvtime.to_s.gsub(":",".").to_f >0 
          absentsats     = 0
          presenyabstus  = "OD"
          misspunch      = ""
          presabstats    = 1
      end
  end
  
  ########CHECK LEAVE TAKEN IF ANY ##########
  #isselect =  "ls_leave_code,ls_nodays,ls_period,ls_avail"
  lvsobj    = get_approved_leave_status(compcode,empcode,empdate)
  
  if lvsobj.length >0
   
       leavetype = lvsobj[0].ls_leave_code
       availeave = lvsobj[0].ls_avail
       leavepd   = lvsobj[0].ls_period
      if lvsobj[0].ls_leave_code.to_s !='LWM' 
            if availeave.to_s == 'H' ### CHECK HALF DAYS
            
                 if  leavetype.to_s != 'OD' && leavetype.to_s != 'SL' 
                      if leavepd.to_s == 'F'  
                            presenyabstus = "LP" ### FOR FIRST HALF
                            paidleave     =  0.5
                            misspunch     =  ""
                            absentsats    =  0
                            presabstats   =  0.5 
                      elsif leavepd.to_s == 'S'
                            presenyabstus = "PL" ### FOR SECOND HALF
                            paidleave     = 0.5
                            misspunch     = ""
                            absentsats    = 0
                            presabstats   = 0.5      
                      end
                  elsif leavetype.to_s == 'OD'
                      if leavepd.to_s == 'F'  
                          presenyabstus = "AP"
                          paidleave     = 0
                          misspunch     = ""
                          absentsats    = 0
                          presabstats   = 1
                      elsif leavepd.to_s == 'OD'
                          presenyabstus = "PA"
                          paidleave     = 0
                          misspunch     = ""
                          absentsats    = 0
                          presabstats   = 1

                      end
                 end   
            else
          
                      if leavetype.to_s != 'SL' && leavetype.to_s != 'OD'
                            presenyabstus = "LL"
                            paidleave     = 1
                            misspunch     = ""
                            absentsats    = 0
                            presabstats   = 0 
                      elsif leavetype.to_s == 'OD'
                            presenyabstus = "PP"
                            paidleave     = 0
                            misspunch     = ""
                            absentsats    = 0
                            presabstats   = 1 
                      
                      end   
                  
                  
            end 
      else
            if lvsobj[0].ls_leave_code.to_s =='LWM'
                  presenyabstus = "AA"
                  paidleave     = 0
                  misspunch     = ""
                  absentsats    = 1
                  presabstats   = 0  
               
            end    
      end
        if lvsobj[0].ls_leave_code.to_s =='SL'
            if leavepd.to_s == 'F'  
              lathrs = 0
            elsif leavepd.to_s == 'S' 
               earlyhrs = 0
            end       

        end
  end
 
  ############ END CHECK LEAVE TAKEN IF ANY #######
  ### CALCULATE LATE PLENTY #####
  numberofdays  = 0
  if empdate != nil && empdate != ''
      myymonths    = empdate.to_s.split("-")
      nemonth       = myymonths[2] #Date.parse(empdate.to_s).strftime("%m")
      nemonth       = nemonth.to_i
      newyears      = myymonths[1] #Date.parse(empdate.to_s).strftime("%Y")
      if nemonth.to_i >0 && newyears.to_i >0
         numberofdays  = get_total_days_of_month(nemonth,newyears) #Time.days_in_month(nemonth, newyears)
      end
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
    
  if compcode !=nil && compcode !='' && empcode !=nil && empcode != ''
     save_attendance_detail(compcode,empcode,empdate,entryreq,entrymade,shiftcode,categoryid,arrvtime,lathrs,deprtime,earlyhrs,workhrs,overtimes,presabstats,absentsats,presenyabstus,paidleave,unpaidleave,manulpunches,night,departname,misspunch,gcimg,latepenalty,depatment,locations,leavetype)
  end

end

private
def get_last_working_status(compcode,empcode,dated,days,catcode="")
  #  if catcode.to_s !='SDR'
  #     return 0
  #  else
  #    return 1
  #  end
  return 0
      allowweek   = 0
      countabsent = 0
      days = days.to_i >0 ? days.to_i-1 : 0
      if days.to_i >0 && dated !=nil && dated !=''
        sqls       = "CALL get_last_working_day_status ('#{compcode}','#{empcode}','#{dated}','#{days.to_i}')"
        chekattd   = request_processor(sqls)      
            if chekattd.length >0
                    # countabsent = 0
                    # chekattd.each do |newdys|
                    #     if newdys.al_absent.to_i >0
                    #       countabsent +=1
                    #     end
                    # end
                    countabsent = chekattd[0].tabsent
                    if countabsent.to_i>3
                      allowweek = 1
                    end

            end
        end   
      return allowweek #REQUEST BY AMIT HR & PINK HR
  
end


##### WEEKOF ABSENT CALCULATION
private
def get_last_weekof_absent_status(compcode,empcode,dated,daysfirst,dayssecond)
  allowweek   = 0
  countabsent = 0
  days        = days.to_i >0 ? days : 0
  dayssecond = dayssecond.to_i >0 ? dayssecond : 0
   if days.to_i >0 && dated !=nil && dated !=''
    sqls       = "CALL get_last_working_day_status ('#{compcode}','#{empcode}','#{dated}','#{days.to_i}','#{dayssecond.to_i}')"
    chekattd   = request_processor(sqls)      
        if chekattd.length >0               
                countabsent = chekattd[0].tabsent
                if countabsent.to_i>2
                  allowweek = 1
                end

        end
    end   
   return allowweek

end

private
def get_approved_leave_status(compcodes,empcode,transdated)
  # iswhere     =  "ls_compcode ='#{compcodes}' AND ls_empcode ='#{empcode}'  AND ls_status='A' AND LOWER(ls_leavereson)<>LOWER('Forfeit')"
  # iswhere     += " AND '#{transdated}' BETWEEN ls_fromdate AND ls_todate"   ### required store processdure
 #  iswhere     += " AND ls_fromdate >='#{transdated}' AND ls_todate<='#{transdated}'"
  # iswhere      += "  AND (( ls_fromdate >='#{year_month_days_formatted(transdated)}' AND ls_fromdate<='#{year_month_days_formatted(transdated)}')"
  # iswhere      += "  OR ( ls_todate >='#{year_month_days_formatted(transdated)}' AND ls_todate<='#{year_month_days_formatted(transdated)}' ))"
  # isselect    =  "ls_leave_code,ls_nodays,ls_period,ls_avail"
  # sbsobj      =  TrnLeave.select(isselect).where(iswhere).first

    dated      = year_month_days_formatted(transdated)
    sqls       = "CALL  get_employee_leaves ('#{compcodes}','#{dated}','#{empcode}')"
    sbsobj     = request_processor(sqls)     
    return sbsobj

end

private
  def get_office_information(compcode,empcode)
         sewdarobj =  MstSewadarOfficeInfo.where("so_compcode =? AND so_sewcode =?",compcode,empcode).first
         return sewdarobj
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
  catobj = MstSewadarCategory.where("sc_compcode = ? AND sc_catcode = ?",compcode,catid).first
  return catobj
end

private
def get_shift_detail(compcode,shiftcode)
  shifobj =  MstShift.where("attend_compcode = ? AND attend_shiftcode = ?",compcode,shiftcode).first
  return shifobj
end

private
def get_employee_detail(compcode,empcode)
    empobj = MstSewadar.where("sw_compcode =? AND sw_sewcode = ?",compcode,empcode).first
    return empobj
end

private
def get_department_list(compcode,depid)
  depobj =  MstDepartment.select("dp_name").where("dp_compcode= ? AND id =?",compcode,depid).first
  return depobj
end


private
def get_common_arrival_time(compcodes,users,dates,types)
  intimes = 0
    if types =='A'
      sqls = "CALL arrival_timing ('#{compcodes}','#{users}','#{dates}','created_at ASC')"
    else
      sqls = "CALL departure_timing ('#{compcodes}','#{users}','#{dates}','created_at DESC')"
    end
       listobj   = request_processor(sqls)
      if listobj && listobj.length >0
        intimes = listobj[0].myintime
      end
   
     return intimes
end

  private
  def get_arrival_time(compcodes,users,dates)
    
    #  iswhere   = "gc_compcode='#{compcodes}'"
    #  iswhere   +=" AND gc_user_id='#{users}'  AND gc_date ='#{dates}'"
    #  isselect  = "gc_local_time as myintime"
    #  intimes   = ''
    #  isgeoloc  = TrnGeoLocation.select(isselect).where(iswhere).order("created_at ASC").first
    #  if isgeoloc!=nil
    #   intimes = isgeoloc.myintime
    #  end
    #  return intimes
  end
  private
  def get_departure_time(compcodes,users,dates)
    #  iswhere   = "gc_compcode='#{compcodes}'"
    #  iswhere   +=" AND gc_user_id='#{users}'  AND gc_date='#{dates}'"
    #  isselect  = "gc_local_time as outtime"
    #  outimes   = ''
    #  isgeoloc  = TrnGeoLocation.select(isselect).where(iswhere).order("created_at DESC").first
    #  if isgeoloc!=nil
    #   outimes = isgeoloc.outtime
    #  end
    #  return outimes
  end

  private
  def save_attendance_detail(compcode,empcode,trndated,entryenq,entrymade,shift,catid,arvtime,latehrms,dephrm,earlhrms,wrkhrms,ovtime,presents,absents,presabs,paidleave,unpaidleave,manulpunch,night,dept,mispunch,gcimg,latepenalty,depatment,locations,leavetype)
      # chekattd = TrnAttendanceList.where("al_compcode = ? AND al_empcode = ? AND al_trandate = ?",compcode,empcode,trndated).first
      # if chekattd
      #    chekattd.update(:al_entryreq=>entryenq,:al_department=>depatment,:al_location=>locations,:al_latepelanty=>latepenalty,:al_userimage=>gcimg,:al_entrymade=>entrymade,:al_shift=>shift,:al_catid=>catid,:al_arrtime=>arvtime,:al_latehrs=>latehrms,:all_deptime=>dephrm,:al_earlhrs=>earlhrms,:al_workhrs=>wrkhrms,:al_overtime=>ovtime,:al_present=>presents,:al_absent=>absents,:al_presabsent=>presabs,:al_paidleave=>paidleave,:al_unpaidleave=>unpaidleave,:al_manualpunch=>manulpunch,:al_nightshift=>night,:al_departid=>dept,:al_misspunch=>mispunch)
      # else
      #     svsatnd = TrnAttendanceList.new(:al_compcode=>compcode,:al_department=>depatment,:al_location=>locations,:al_latepelanty=>latepenalty,:al_userimage=>gcimg,:al_empcode=>empcode,:al_trandate=>trndated,:al_entryreq=>entryenq,:al_entrymade=>entrymade,:al_shift=>shift,:al_catid=>catid,:al_arrtime=>arvtime,:al_latehrs=>latehrms,:all_deptime=>dephrm,:al_earlhrs=>earlhrms,:al_workhrs=>wrkhrms,:al_overtime=>ovtime,:al_present=>presents,:al_absent=>absents,:al_presabsent=>presabs,:al_paidleave=>paidleave,:al_unpaidleave=>unpaidleave,:al_manualpunch=>manulpunch,:al_nightshift=>night,:al_departid=>dept,:al_misspunch=>mispunch)
      #     if svsatnd.save
      #         ## execute save message
      #     end
      # end
      svsatnd = TrnAttendanceList.new(:al_compcode=>compcode,:al_leavecode=>leavetype,:al_department=>depatment,:al_location=>locations,:al_latepelanty=>latepenalty,:al_userimage=>gcimg,:al_empcode=>empcode,:al_trandate=>trndated,:al_entryreq=>entryenq,:al_entrymade=>entrymade,:al_shift=>shift,:al_catid=>catid,:al_arrtime=>arvtime,:al_latehrs=>latehrms,:all_deptime=>dephrm,:al_earlhrs=>earlhrms,:al_workhrs=>wrkhrms,:al_overtime=>ovtime,:al_present=>presents,:al_absent=>absents,:al_presabsent=>presabs,:al_paidleave=>paidleave,:al_unpaidleave=>unpaidleave,:al_manualpunch=>manulpunch,:al_nightshift=>night,:al_departid=>dept,:al_misspunch=>mispunch)
      if svsatnd.save
          ## execute save message
      end
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

####### BACK DATE & AHEAD DATE ABSENT CALCULATION ####
private
def get_weekof_sewadar_listed(frmdate,uptodate,depcode,empcode)
  compcodes   =  session[:loggedUserCompCode]
  mycounts    =  0
  mywhere     =  " al_compcode='#{compcodes}' AND DATE(al_trandate)>='#{year_month_days_formatted(frmdate)}' AND DATE(al_trandate)<='#{year_month_days_formatted(uptodate)}' AND al_trandate<>'0000-00-00'"
  mywhere     += " AND UPPER(al_presabsent) IN('WO','HL')"
  if depcode !=nil && depcode !=''
      mywhere += " AND al_department ='#{depcode}'"
  end
  if empcode !=nil && empcode !=''
      mywhere += " AND al_empcode ='#{empcode}'"          
  end
 issselect   = "al_empcode,al_trandate,al_department"
 attobjs     = TrnAttendanceList.select(issselect).where(mywhere).order("al_empcode ASC")
 if attobjs.length >0
      attobjs.each do |newsd|
          allowstatus =  get_back_date_head_absent_count(newsd.al_trandate,newsd.al_department,newsd.al_empcode)
          if allowstatus
              process_update_absent_satus(compcodes,newsd.al_empcode,newsd.al_trandate,'AA')
              mycounts +=1
          end
      end
 end
  return mycounts

end

private
def get_back_date_head_absent_count(processdate,depcode,empcode)
  compcodes   =  session[:loggedUserCompCode]
  allowabsent =  false
  mywhere     = "al_compcode='#{compcodes}' AND ( DATE(al_trandate) >= DATE_SUB('#{processdate}', INTERVAL 1 DAY) AND  DATE(al_trandate) <= DATE_ADD( DATE('#{processdate}'), INTERVAL 1 DAY) )  and al_trandate<>'0000-00-00'"
  if depcode !=nil && depcode !=''
     mywhere += " AND al_department ='#{depcode}'"
  end
  if empcode !=nil && empcode !=''
      mywhere += " AND al_empcode ='#{empcode}'"          
  end
  issselect  = "SUM(al_absent) as tabsent"
 attobjs     = TrnAttendanceList.select(issselect).where(mywhere).first
 if attobjs
    if attobjs.tabsent >=2
        allowabsent = true
    end    
 end
  return allowabsent

end

private
def process_update_absent_satus(compcode,empcode,trndated,prststus)
  trndateds = year_month_days_formatted(trndated)
  chekattd = TrnAttendanceList.where("al_compcode = ? AND al_empcode = ? AND al_trandate = ?",compcode,empcode,trndateds).first
    if chekattd
        chekattd.update(:al_presabsent=>prststus,:al_present=>0,:al_absent=>1)
    end
end

###Check before after ABSENT #############

private
def get_before_after_sewadar_list(frmdate,uptodate,depcode,empcode)
  compcodes   =  session[:loggedUserCompCode]
  # frmdate      = '2023-01-26'
  # uptodate     = '2023-01-26'
  mycounts    =  0
  mywhere     =  " al_compcode='#{compcodes}' AND DATE(al_trandate)>='#{year_month_days_formatted(frmdate)}' AND DATE(al_trandate)<='#{year_month_days_formatted(uptodate)}' AND al_trandate<>'0000-00-00'"
  mywhere     += " AND UPPER(al_presabsent) IN('WO','HL')"
  if depcode !=nil && depcode !=''
      mywhere += " AND al_department ='#{depcode}'"
  end
  if empcode !=nil && empcode !=''
      mywhere += " AND al_empcode ='#{empcode}'"          
  end
  
 issselect   = "al_empcode,al_trandate,al_department,al_leavecode"
 attobjs     = TrnAttendanceList.select(issselect).where(mywhere).order("al_empcode ASC,al_trandate ASC")
 if attobjs.length >0
      attobjs.each do |newsd| 
        bscs       = 0
        ahbc       = 0
        prevdate   = 0
            for i in 1..6  do
                prevdate = year_month_days_formatted(Date.parse(newsd.al_trandate.to_s)-i )           
                backobjs = get_absent_remarks_status(prevdate,newsd.al_empcode,newsd.al_department,'B')  
                if backobjs && backobjs.al_presabsent.to_s.upcase == 'AA'                                  
                    bscs +=1 ###
                    break;
                elsif backobjs && ( backobjs.al_presabsent.to_s.upcase == 'LL' &&  backobjs.al_leavecode.to_s.upcase == 'EL')
                  
                    prevdate  = year_month_days_formatted(Date.parse(prevdate)+1 ) 
                    bscs +=1 ###
                    break;   
                elsif backobjs && backobjs.al_presabsent.to_s.upcase == 'HL' || backobjs && backobjs.al_presabsent.to_s.upcase == 'WO'  
                    ### DO NOTHING 
                    #prevdate = year_month_days_formatted(Date.parse(prevdate)-1 )
                    #backobjs = get_absent_remarks_status(prevdate,newsd.al_empcode,newsd.al_department,'B')   
                else                   
                    bscs =0
                    break; 
                    ### DO NOTHING  
                end 
              
            end
            #### AHEAD CHECKING IF  ABSENT #########
            if bscs.to_i >0
                for j in 1..6 do
                      forwvdate = year_month_days_formatted(Date.parse(newsd.al_trandate.to_s)+j )           
                      backobjs = get_absent_remarks_status(forwvdate,newsd.al_empcode,newsd.al_department,'F')  
                      if backobjs && backobjs.al_presabsent.to_s.upcase == 'AA'
                          ahbc +=1 ###
                          process_update_absent_all(compcodes,newsd.al_empcode,prevdate,forwvdate)
                          break;
                      elsif backobjs && ( backobjs.al_presabsent.to_s.upcase == 'LL' &&  backobjs.al_leavecode.to_s.upcase == 'EL')
                          ahbc +=1 ###
                          forwvdate = year_month_days_formatted(Date.parse(forwvdate.to_s)-j ) 
                          process_update_absent_all(compcodes,newsd.al_empcode,prevdate,forwvdate)
                          break;
                      elsif backobjs && backobjs.al_presabsent.to_s.upcase == 'HL' || backobjs && backobjs.al_presabsent.to_s.upcase == 'WO'  
                          ### DO NOTHING 
                          #prevdate = year_month_days_formatted(Date.parse(prevdate)-1 )
                          #backobjs = get_absent_remarks_status(prevdate,newsd.al_empcode,newsd.al_department,'B')   
                      else 
                          break; 
                          ahbc =0
                          ### DO NOTHING  
                      end 
                
                end
          end 
          ### END AHEAD CHECKING IF ABSENT ########    

      end
 end
  return mycounts

end
####### ABSENT CALCULATION AGAIN ##########
private
def get_absent_remarks_status(dated,empcode,depcode,checlist)
  compcodes   =  session[:loggedUserCompCode]
  mycounts    =  0
  mywhere     =  " al_compcode='#{compcodes}' AND DATE(al_trandate)='#{dated}' AND al_trandate<>'0000-00-00'"
  if depcode !=nil && depcode !=''
      mywhere += " AND al_department ='#{depcode}'"
  end
  if empcode !=nil && empcode !=''
      mywhere += " AND al_empcode ='#{empcode}'"          
  end
 issselect   = "al_empcode,al_trandate,al_department,al_presabsent,al_leavecode"
 attobjs     = TrnAttendanceList.select(issselect).where(mywhere).first
 return attobjs

end

private
def process_update_absent_all(compcode,empcode,fromdates,uptodates)
  fromdate = year_month_days_formatted(fromdates)
  uptodate = year_month_days_formatted(uptodates)
  chekattd = TrnAttendanceList.where("al_compcode = ? AND al_empcode = ? AND al_trandate >= ? AND al_trandate <= ?",compcode,empcode,fromdate,uptodate)
    if chekattd
        chekattd.update_all(:al_presabsent=>'AA',:al_present=>0,:al_absent=>1)
    end
end


end ### End class



