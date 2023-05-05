class RawPunchController < ApplicationController
    before_action :require_login
    #before_action :is_allowed_location
    skip_before_action :verify_authenticity_token
    helper_method :get_mysewdar_list_details,:currency_formatted,:formatted_date,:year_month_days_formatted,:get_shift_listed_detail,:get_location_detail
 def index
  @compcodes     =  session[:loggedUserCompCode]
  @xLoc          =  session[:autherizedLoc]
  
  #### REDIRECT CASES ##########
      if session[:autherizedUserType] && session[:autherizedUserType] == 'store'
	    redirect_to "#{root_url}web_attendance"
	  end
	  @myloc        =  session[:autherizedLoc]
     @locname      =  ""
     if @myloc
         locobj =  get_location_detail(@myloc)
         if locobj
            @locname = locobj.hof_description
         end
     end
	
  #### END REDIRECT CASES ###
  @mydepartcode      = ''
      mydeprtcode        = ""
    if session[:sec_sewdar_code] != nil
          sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
          if sewobjs
              @mydepartcode = sewobjs.sw_depcode
              mydeprtcode   = sewobjs.sw_depcode
          end
     end
  if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
    
    @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment ='' AND departCode = ? ",@compcodes,mydeprtcode).order("departDescription ASC")
    if session[:requestuser_loggedintp].to_s == 'swd'
      @Allsewobj         = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_sewcode = ?",@compcodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")
    else
      @Allsewobj         = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_depcode = ?",@compcodes,mydeprtcode).order("sw_sewadar_name ASC")
    end

else
    
     @sewDepart        = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compcodes).order("departDescription ASC")
    
end
  
  
  @chartsearch   =  nil
  @fromSDate     = ((Date.today)-30).strftime("%d-%b-%Y")
  @currDate      =  Date.today.strftime("%d-%b-%Y")
  @fromDate1     = ((Date.today)-30).strftime("%Y-%m-%d")
  @currDate1     =  Date.today.strftime("%Y-%m-%d")
  if params[:charts_year].to_s!=nil && params[:charts_year].to_s!=''
    @chartsearch    = params[:charts_year].to_s
  end
   @LastTransaction        = []
   @isTrackLoc             = []
   @printControll          =  "1_track_location_report"
   @mypaths                =  customer_path(@printControll,:format=>"pdf")
   session[:gcdownload]    =  'Y'
   if params[:server_request] !=nil && params[:server_request] !=''
    session[:department]  = nil
    session[:mylocfrdate] = nil 
    session[:mylocupdate] = nil
   else
    return
 end
   department   = params[:department] !=nil && params[:department] !='' ? params[:department] : session[:department]
   mylocfrdate  = params[:mylocfrdate] !=nil && params[:mylocfrdate] !='' ? params[:mylocfrdate] : session[:mylocfrdate]
   mylocupdate  = params[:mylocupdate] !=nil && params[:mylocupdate] !='' ? params[:mylocupdate] : session[:mylocupdate]
    
            ########### LOAD GEO LOCATION #######
            myselct     = "gc_userimage,gc_user_id,gc_location as newloc,sw_shiftcode,sw_sewadar_name as emp_name,sw_mobile as emp_mobile,emp.id as empId,gc_address,DATE_FORMAT(gc_date,'%d-%m-%y') as gcdate,gc_time,'' as etp_name,'' as emtId,gc_local_time"
            myselct     += " ,(CASE WHEN gc_duty='S' THEN 'ON DUTY'
                                  WHEN gc_duty='V' THEN 'VISIT IN'
                                  WHEN gc_duty='OFF' THEN 'OFF DUTY'
                                  WHEN gc_duty='OUT' THEN 'VISIT OUT'
                                  ELSE ''
                                  END) as gcduty,
                                  gc_latitude,gc_longitude
                           "
            jons        =  " LEFT JOIN mst_sewadars emp ON(sw_compcode = gc_compcode AND emp.sw_sewcode = gc_user_id)"

            mywhere     = "gc_compcode='#{@compcodes}' AND gc_punchtype<>'M'"
            if department !=nil && department !='' 
                mywhere  += " AND sw_depcode='#{department}'"
                session[:department]  = department
                @department = department
            end
            if mylocfrdate !=nil && mylocfrdate !=''
                mywhere  += " AND gc_date >='#{year_month_days_formatted(mylocfrdate)}'"
                @mylocfrdate = mylocfrdate                
                session[:mylocfrdate] = mylocfrdate 
            end
            if mylocupdate !=nil && mylocupdate !=''
                mywhere  += " AND gc_date <='#{year_month_days_formatted(mylocupdate)}'"
                @mylocupdate = mylocupdate              
                session[:mylocupdate] = mylocupdate
            end

            @isTrackLoc = TrnGeoLocation.select(myselct).joins(jons).where(mywhere).order("TRIM(gc_date) DESC,TRIM(gc_time) DESC")
			@AssignVsit = MstSewadar.select("sw_sewadar_name as emp_name,id,sw_sewcode,sw_image,sw_shiftcode").where("sw_compcode = ? AND sw_location = ?",@compcodes,@myloc).order("sw_sewadar_name ASC")
            
            @isOnDuty   = false
            @isOffDuty  = false
            @isOVisin   = false
            @isOVisout  = false
            @isgvalues  = ''
            @logedIds   = session[:autherizedLoginId]            
            isdutyon    = TrnGeoLocation.select("gc_duty,NOW() as dates").where("gc_compcode=? AND DATE(gc_date)=CURDATE() AND gc_user_id=?",@compcodes,@logedIds).last
            @Tanst      = isdutyon
            if isdutyon
              @isgvalues = isdutyon.gc_duty
              if isdutyon.gc_duty!=nil && isdutyon.gc_duty!='' && isdutyon.gc_duty.upcase == 'S'
                @isOVisin  = true
                @isOffDuty = true               
              elsif isdutyon.gc_duty!=nil && isdutyon.gc_duty!='' && isdutyon.gc_duty.upcase == 'OFF'                
                @isOnDuty  = true                                
              elsif isdutyon.gc_duty!=nil && isdutyon.gc_duty!='' && isdutyon.gc_duty.upcase == 'V'
                @isOVisout = true                
             elsif isdutyon.gc_duty!=nil && isdutyon.gc_duty!='' && isdutyon.gc_duty.upcase == 'OUT'
                @isOVisin  = true
                @isOffDuty = true
                
             end
            else           
             # @isOffDuty    = true
              @isOnDuty     = true
             # @isOVisin   = true
             # @isOVisout  = true
            end
             
            
            @empdetail = []
			@ListDepart  = MstHeadOffice.where("hof_compcode =?",@compcodes).order("hof_description ASC")
       ######## END LOAD GEO LOCATION ###########
       

end



def create

end

def show
  @compcodes =  session[:loggedUserCompCode]
  if params[:fetchCalendarView]!='' && params[:fetchCalendarView]!=nil && params[:fetchCalendarView]=='Y'
       get_credits_details_for_calendar()
  elsif params[:isgeneratebilled]!='' && params[:isgeneratebilled]!=nil && params[:isgeneratebilled]=='Y'
       session[:generatecustid]  =  params[:customerId]
       session[:generateshipid]  =  params[:shipid]
       respond_to do |format|
       format.json { render :json => { :gostatus=>1} }
       end
  elsif params[:isupdatedcredits]!='' && params[:isupdatedcredits]!=nil && params[:isupdatedcredits]=='Y'
     set_update_credits_days
   elsif params[:sendgeolocationdetails]!='' && params[:sendgeolocationdetails]!=nil && params[:sendgeolocationdetails]=='Y'
     start_login_visit_details
     return
   elsif params[:getallgeolocationdetails]!='' && params[:getallgeolocationdetails]!=nil && params[:getallgeolocationdetails]=='Y'
     get_all_tracking_geoloc_details_by_user
     return
  elsif params[:updateallgeoblankaddress]!='' && params[:updateallgeoblankaddress]!=nil && params[:updateallgeoblankaddress]=='Y'
     get_geo_details
     return
  elsif params[:processupdateallgeoblankaddress]!='' && params[:processupdateallgeoblankaddress]!=nil && params[:processupdateallgeoblankaddress]=='Y'
     process_update_blank_geo_address
     return
  elsif params[:fetchBirthdaysView]!='' && params[:fetchBirthdaysView]!=nil && params[:fetchBirthdaysView]=='Y'
     get_birth_todolist_for_calendar
  elsif params[:isbirthdaywishes]!='' && params[:isbirthdaywishes]!=nil && params[:isbirthdaywishes]=='Y'
     send_birthday_wishes
  elsif params[:isdetailmonthwise]!='' && params[:isdetailmonthwise]!=nil && params[:isdetailmonthwise]=='Y'
     call_calendar_by_month_wise()
  elsif params[:isupdateunbilled]!='' && params[:isupdateunbilled]!=nil && params[:isupdateunbilled]=='Y'
      unbilled_list_update()
  elsif params[:visitCalendarView]!='' && params[:visitCalendarView]!=nil && params[:visitCalendarView]=='Y'
      get_visit_schedule_by_date()
      return
  elsif params[:processupdateallgeoblankaddress]!='' && params[:processupdateallgeoblankaddress]!=nil && params[:processupdateallgeoblankaddress]=='ATC'
     get_employee_attendance_details
     return
  elsif params[:processupdateallgeoblankaddress]!='' && params[:processupdateallgeoblankaddress]!=nil && params[:processupdateallgeoblankaddress]=='SMATC'
     get_summary_employee_attendance
     return
  end


end



private
 def start_login_visit_details
    @compcodes  =  session[:loggedUserCompCode]
    @logedId    =  session[:autherizedLoginId]
    isFlags     =  true
    messages    =  ""
    if  params[:vln]!=nil &&  params[:vln]!='' && params[:vlt]!=nil && params[:vlt]!=''

           if params[:vlt_duty]!=nil && params[:vlt_duty]!='' && params[:vlt_duty].upcase=='S'
               @saveNGeoloc = TrnGeoLocation.new(save_track_location)
               @saveNGeoloc.save
               messages = "Duty started successfully."
               isFlags  = true
           elsif params[:vlt_duty]!=nil && params[:vlt_duty]!='' && params[:vlt_duty].upcase=='V'
               @saveGeoloc = TrnGeoLocation.new(save_track_location)
               @saveGeoloc.save
               messages = "Visit In done successfully."
               isFlags  = true
           elsif params[:vlt_duty]!=nil && params[:vlt_duty]!='' && params[:vlt_duty].downcase=='off'
               @saveXGeoloc = TrnGeoLocation.new(save_track_location)
               isFlags      = true
               @saveXGeoloc.save
               messages = "Off duty done successfully."
          elsif params[:vlt_duty]!=nil && params[:vlt_duty]!='' && params[:vlt_duty].downcase=='out'
               @saveXGeoloc = TrnGeoLocation.new(save_track_location)
               isFlags      = true
               @saveXGeoloc.save
               messages = "Visit Out done successfully."
           else
               messages = "Sorry!! Failed due to invalid resources."
           end

      end      
     respond_to do |format|
     format.json { render :json => { :sendstatus=>isFlags,:messages=>messages} }
     end
 end

  private
  def save_track_location
    @logedId               = session[:autherizedLoginId]
    Time.zone = "Kolkata"
    billtimes = Time.zone.now.strftime('%I:%M%p')
    params[:gc_local_time] = billtimes
    params[:gc_user_id]    = @logedId
    params[:gc_compcode]   = session[:loggedUserCompCode]
    params[:gc_time]       = Time.zone.now.to_time
    params[:gc_date]       = Time.zone.now.to_date
    params[:gc_longitude]  = params[:vln]!=nil && params[:vln]!='' ? params[:vln] : ''
    params[:gc_latitude]   = params[:vlt]!=nil && params[:vlt]!='' ? params[:vlt] : ''
    params[:gc_address]    = params[:vlt_add]!=nil && params[:vlt_add]!='' ? params[:vlt_add] : ''
    params[:gc_duty]       = params[:vlt_duty]!=nil && params[:vlt_duty]!='' ? params[:vlt_duty].upcase : ''
    params.permit(:gc_compcode,:gc_latitude,:gc_longitude,:gc_address,:gc_user_id,:gc_date,:gc_time,:gc_duty,:gc_local_time)

  end
  private
  def save_off_duty_track
    @logedId                = session[:autherizedLoginId]
    params[:god_user_id]    = @logedId
    params[:god_compcode]   = session[:loggedUserCompCode]
    params[:god_lon]        = params[:vln]!=nil && params[:vln]!='' ? params[:vln] : ''
    params[:god_lat]        = params[:vlt]!=nil && params[:vlt]!='' ? params[:vlt] : ''
    params[:god_address]    = params[:vlt_add]!=nil && params[:vlt_add]!='' ? params[:vlt_add] : ''
    params.permit(:god_compcode,:god_lat,:god_lon,:god_address,:god_user_id)

  end

private
def get_all_tracking_geoloc_details_by_user
  locations        = params[:locations]!=nil && params[:locations]!='' ? params[:locations] : 0
  frmdate        = params[:mylocfrdate]!=nil && params[:mylocfrdate]!='' ? params[:mylocfrdate] : ''
  update         = params[:mylocupdate]!=nil && params[:mylocupdate]!='' ? params[:mylocupdate] : ''
  session[:frmdate]    = nil
  session[:update]     = nil
  session[:usersid]    = nil
  
  ndt     = ""
  undt    = ""
  iswhere = "gc_compcode='#{@compcodes}' AND gc_punchtype<>'M'"
  
  if frmdate!=nil && frmdate!=''
    dt      = Date.parse(frmdate.to_s)
    ndt     = dt.strftime("%Y-%m-%d")
    iswhere += " AND DATE(gc_date)>='#{ndt}'"
    session[:frmdate] = ndt
    
  end
  if update!=nil && update!=''
    udt     = Date.parse(update.to_s)
    undt    = udt.strftime("%Y-%m-%d")
    iswhere += " AND DATE(gc_date)<='#{undt}'"
    session[:update] = undt
  end
  if locations !=nil && locations != ''
    iswhere += "AND gc_location ='#{locations}'"
	session[:geouserloc]= locations
    #session[:usersid] = usersid
  end
  
            myselct     = "gc_userimage,gc_user_id,'' as newlocation,gc_location,'' as shiftname,sw_shiftcode,sw_sewadar_name as emp_name,sw_mobile as emp_mobile,emp.id as empId,gc_address,DATE_FORMAT(gc_date,'%d-%m-%y') as gcdate,gc_time,'' as etp_name,'' as emtId,gc_local_time"
            myselct     += " ,(CASE WHEN gc_duty='S' THEN 'ON DUTY'
                                  WHEN gc_duty='V' THEN 'VISIT IN'
                                  WHEN gc_duty='OFF' THEN 'OFF DUTY'
                                  WHEN gc_duty='OUT' THEN 'VISIT OUT'
                                  ELSE ''
                                  END) as gcduty,
                                  gc_latitude,gc_longitude
                           "
            jons        =  " LEFT JOIN mst_sewadars emp ON(sw_compcode = gc_compcode AND emp.sw_sewcode = gc_user_id)"
  
  
  

	   arr         = []
	  isFlags      = false
	  loattendobj  = TrnGeoLocation.select(myselct).joins(jons).where(iswhere).order("TRIM(gc_date) DESC,TRIM(gc_time) DESC")
	  if loattendobj.length >0
			loattendobj.each do |myvloc|			   																
				shifobjs  = get_shift_listed_detail(myvloc.sw_shiftcode)
				if shifobjs
					timings          = shifobjs.attend_shfintime.to_s+"-"+shifobjs.attend_shfout.to_s
					shiftname        = myvloc.sw_shiftcode.to_s+"("+timings.to_s+")";
					myvloc.shiftname = shiftname
				end	
				locxobj = get_location_detail(myvloc.gc_location)
				if locxobj
					myvloc.newlocation = locxobj.hof_description
				end
				
			   arr.push myvloc
		  end
		isFlags = true
	  end
	  
	  
	  
	  
     respond_to do |format|
      format.json { render :json => { :status=>isFlags,:data=>arr} }
     end
end



private
def get_geo_details
  usersid        = params[:userId]!=nil && params[:userId]!='' ? params[:userId] : 0
  frmdate        = params[:mylocfrdate]!=nil && params[:mylocfrdate]!='' ? params[:mylocfrdate] : ''
  update         = params[:mylocupdate]!=nil && params[:mylocupdate]!='' ? params[:mylocupdate] : ''
  ndt     = ""
  undt    = ""
  iswhere = "gc_compcode='#{@compcodes}' AND gc_address=''"

  if frmdate!=nil && frmdate!=''
    dt      = Date.parse(frmdate.to_s)
    ndt     = dt.strftime("%Y-%m-%d")
    iswhere += " AND DATE(gc_date)>='#{ndt}'"
  end
  if update!=nil && update!=''
    udt     = Date.parse(update.to_s)
    undt    = udt.strftime("%Y-%m-%d")
    iswhere += " AND DATE(gc_date)<='#{undt}'"
  end
  if usersid.to_i >0
    iswhere += "AND gc_user_id='#{usersid}'"
  end
    arr_loc    = []
    isflags    = false;
    istrackloc = TrnGeoLocation.select('gc_latitude,gc_longitude,id').where(iswhere)
    if istrackloc.length >0
      arr_loc = istrackloc;
      isflags = true;
    
    end
     respond_to do |format|
     format.json { render :json => { :status=>isflags,:data=>arr_loc} }
     end
end

private
def process_update_blank_geo_address
    mid         = params[:mid]!=nil && params[:mid]!='' ? params[:mid] : 0
    gaddress    = params[:address]!=nil && params[:address]!='' ? params[:address] : ''
    iswhere     = "gc_compcode='#{@compcodes}' AND id='#{mid}'"
    isflags     = false
    @isprocesUpdate = TrnGeoLocation.where(iswhere).first
    if @isprocesUpdate
      @isprocesUpdate.update(:gc_address=>gaddress)
      isflags = true
    end
     respond_to do |format|
     format.json { render :json => { :status=>isflags,:data=>''} }
     end
end


private
  def get_employee_attendance_details
     users                          = params[:iscustomer]!=nil && params[:iscustomer]!='' ? params[:iscustomer] : 0
     billyear                       = params[:billyear]!=nil && params[:billyear]!='' ? params[:billyear] : 0
     billmonth                      = params[:billmonth]!=nil && params[:billmonth]!='' ? params[:billmonth] : ''
     session[:attendance_customers] = users
     session[:attendance_billyear]  = billyear
     session[:attendance_billmonth] = billmonth
     session[:attendance_rptype]    = 'register'
     isseacrhflag = true
     iswhere   = "gc_compcode='#{@compcodes}'"
     if users.to_i >0
      iswhere   += " AND gc_user_id='#{users}'"
     end
     if billyear!=nil && billyear!=''
       iswhere   += " AND YEAR(gc_date)='#{billyear}'"
       isseacrhflag = false
     end
     if billmonth!=nil && billmonth!=''
       iswhere   += " AND MONTH(gc_date)='#{billmonth}'"
       isseacrhflag = false
     end
     if isseacrhflag
        iswhere   += " AND YEAR(gc_date) =  YEAR(CURDATE()) AND MONTH(gc_date) = MONTH(CURDATE())"
     end
          
     isselect     = "trn_geo_locations.*,'' as inTime,'' as outTime,'' as visitIn,'' as visitOut,'' as totalAHrs,'' as totalVHrs,DATE_FORMAT(gc_date,'%d-%b-%Y') as mdates"
     isgeoloc     = TrnGeoLocation.select(isselect).where(iswhere).group('gc_date').order("TRIM(gc_date) ASC")
     intimesh     = 0
     outtimesh    = 0
     vsintimesh   = 0
     vsouttimesh  = 0

     newthrs      = 0
     newtmns      = 0
     vnewhrs      = 0
     vnewtmns     = 0
     nvnewhrs     = 0
     isflags      = false
     arr          = []
     if isgeoloc.length >0
         isgeoloc.each do |gloc|
           ############ GET START TIME AND OUT TIME #########
           inobj  =  get_in_time(users,gloc.gc_date,billyear,billmonth)
           if inobj!=''
             gloc.inTime = intimesh = Time.parse(inobj.myintime).strftime("%H:%M")
           end
           outobj =  get_out_time(users,gloc.gc_date,billyear,billmonth)
           if outobj!=''
             gloc.outTime =  outtimesh = Time.parse(outobj.myouttime).strftime("%H:%M")
           end
           if inobj!='' && outobj!=''
             gloc.totalAHrs = atttotalahrs = calc_time_diff(intimesh,outtimesh)

           end
          ######## END START TIME AMD OUT TIME ################
          ############ GET VISIT IN TIME AND VISIT OUT TIME #########
           inobjx  =  get_visit_in_time(users,gloc.gc_date,billyear,billmonth)
           if inobjx!=''
             gloc.visitIn = vsintimesh = Time.parse(inobjx.myintime).strftime("%H:%M")
           end
           outobjx =  get_visit_out_time(users,gloc.gc_date,billyear,billmonth)
           if outobjx!=''
             gloc.visitOut =  vsouttimesh = Time.parse(outobjx.myouttime).strftime("%H:%M")
           end
           if inobjx!='' && outobjx!=''
             gloc.totalVHrs = atttotalvhrs = calc_time_diff(vsintimesh,vsouttimesh)
           end

          ######## END  VISIT IN TIME AND VISIT OUT TIME  ################
          if atttotalahrs!=nil && atttotalahrs!=''
            ttimes  =  atttotalahrs.to_s.split(":")
            thrs    =  ttimes[0]
            tmns    =  ttimes[1]
          else
            thrs    =  0
            tmns    =  0
          end
          if atttotalvhrs!=nil && atttotalvhrs!=''
            vtimes  = atttotalvhrs.to_s.split(":")
            vthrs   =  vtimes[0]
            vtmns   =  vtimes[1]
          else
             vthrs   =  0
             vtmns   =  0
          end
          
          if thrs.to_i >0
           newthrs += thrs.to_i
          end
          if tmns.to_i >0
           newtmns += tmns.to_i
          end
         
          if vthrs.to_i >0
           vnewhrs  += vthrs.to_i
          end
          if vtmns.to_i >0
             vnewtmns += vtmns.to_i
          end
          
          ######## CALL TOTAL VISITIS #########
           arr.push gloc

         end
         
          newthrs   =  minuts_hour_calculation(newthrs,newtmns)
          nvnewhrs   = minuts_hour_calculation(vnewhrs,vnewtmns)
         isflags = true
     end
     respond_to do |format|
      format.json { render :json => { :status=>isflags,:data=>arr,"newthrs"=>newthrs,"vnewhrs"=>nvnewhrs} }
     end
  end

  

  private
  def get_in_time(users,dates,billyear,billmonth)
     iswhere   = "gc_compcode='#{@compcodes}'"
     if billyear!=nil && billyear!=''
       iswhere   += " AND YEAR(gc_date)='#{billyear}'"
       isseacrhflag = false
     end
     if billmonth!=nil && billmonth!=''
       iswhere   += " AND MONTH(gc_date)='#{billmonth}'"
       isseacrhflag = false
     end
     if isseacrhflag
        iswhere   += " AND YEAR(gc_date) =  YEAR(CURDATE()) AND MONTH(gc_date) = MONTH(CURDATE())"
     end
     
     iswhere   +=" AND gc_user_id='#{users}' AND gc_duty='S' AND gc_date='#{dates}'"
     isselect  = "gc_local_time as myintime"
     intimes   = ""
     isgeoloc  = TrnGeoLocation.select(isselect).where(iswhere).first 
     if isgeoloc!=nil
      intimes = isgeoloc
     end
     return intimes
  end

  private
  def get_out_time(users,dates,billyear,billmonth)
     iswhere   = "gc_compcode='#{@compcodes}'"
     if billyear!=nil && billyear!=''
       iswhere   += " AND YEAR(gc_date)='#{billyear}'"
       isseacrhflag = false
     end
     if billmonth!=nil && billmonth!=''
       iswhere   += " AND MONTH(gc_date)='#{billmonth}'"
       isseacrhflag = false
     end
     if isseacrhflag
        iswhere   += " AND YEAR(gc_date) =  YEAR(CURDATE()) AND MONTH(gc_date) = MONTH(CURDATE())"
     end    
     iswhere   += " AND gc_user_id='#{users}' AND gc_duty='OFF' AND gc_date='#{dates}'"
     isselect  = "gc_local_time as myouttime"
     outtimes  = ""
     isgeoloc  = TrnGeoLocation.select(isselect).where(iswhere).last 
     if isgeoloc!=nil
      outtimes = isgeoloc
     end
     return outtimes
  end

 private
  def get_visit_in_time(users,dates,billyear,billmonth)
     iswhere  = "gc_compcode='#{@compcodes}'"
     if billyear!=nil && billyear!=''
       iswhere   += " AND YEAR(gc_date)='#{billyear}'"
       isseacrhflag = false
     end
     if billmonth!=nil && billmonth!=''
       iswhere   += " AND MONTH(gc_date)='#{billmonth}'"
       isseacrhflag = false
     end
     if isseacrhflag
        iswhere   += " AND YEAR(gc_date) =  YEAR(CURDATE()) AND MONTH(gc_date) = MONTH(CURDATE())"
     end
     
     iswhere   +=" AND gc_user_id='#{users}' AND gc_duty='V' AND gc_date='#{dates}'"
     isselect  = "gc_local_time as myintime"
     intimes   = ""
     isgeoloc  = TrnGeoLocation.select(isselect).where(iswhere).first
     if isgeoloc!=nil
      intimes = isgeoloc
     end
     return intimes
  end

  private
  def get_visit_out_time(users,dates,billyear,billmonth)
     iswhere   = "gc_compcode='#{@compcodes}'"
     if billyear!=nil && billyear!=''
       iswhere   += " AND YEAR(gc_date)='#{billyear}'"
       isseacrhflag = false
     end
     if billmonth!=nil && billmonth!=''
       iswhere   += " AND MONTH(gc_date)='#{billmonth}'"
       isseacrhflag = false
     end
     if isseacrhflag
        iswhere   += " AND YEAR(gc_date) =  YEAR(CURDATE()) AND MONTH(gc_date) = MONTH(CURDATE())"
     end 
     iswhere   += " AND gc_user_id='#{users}' AND gc_duty='OUT' AND gc_date='#{dates}'"
      isselect = "gc_local_time as myouttime"
     outtimes  = ""
     isgeoloc  = TrnGeoLocation.select(isselect).where(iswhere).last
     if isgeoloc!=nil
      outtimes = isgeoloc
     end
     return outtimes
  end

private
def get_summary_employee_attendance
   users                          = params[:iscustomer]!=nil && params[:iscustomer]!='' ? params[:iscustomer] : 0
   from_date                      = params[:from_date]!=nil && params[:from_date]!='' ? params[:from_date] : ''
   upto_date                      = params[:upto_date]!=nil && params[:upto_date]!='' ? params[:upto_date] : ''
   session[:attendance_customers] = nil
   session[:attendance_from_date] = nil
   session[:attendance_upto_date] = nil
   session[:attendance_rptype]    = 'summary'
   iswhere   = "gc_compcode='#{@compcodes}'"
   if users.to_i >0
     iswhere   += " AND gc_user_id='#{users}'"
      session[:attendance_customers] = users
   end
    dt  = ''
    udt = ''
   if from_date!=nil && from_date!=''
     ndts = Date.parse(from_date.to_s)
     dt   = ndts.strftime("%Y-%m-%d")
     iswhere   += " AND gc_date >='#{dt}'"
     session[:attendance_from_date] = dt
   end
   if upto_date!=nil && upto_date!=''
     undts = Date.parse(upto_date.to_s)
     udt   = undts.strftime("%Y-%m-%d")
     iswhere   += " AND gc_date <='#{udt}'"
     session[:attendance_upto_date] = udt
   end
   arr       = []
   isflags   = false
   isselect  = "gc_date,gc_user_id,'' as totalworkinghours, emp.emp_name as employee,emp.id as empId"
   jons     = " LEFT JOIN mst_employees emp ON(emp.emp_compcode =gc_compcode AND emp.id = gc_user_id)"
   isgeoloc  = TrnGeoLocation.select(isselect).joins(jons).where(iswhere).group('gc_user_id').order("TRIM(emp.emp_name) ASC")
   tinoutworkhrs = 0
   tinoutmns     = 0
  
   if isgeoloc.length >0
     isflags = true
      isgeoloc.each do |sumry|
       newthrs      = 0
       newtmns      = 0
       vnewhrs      = 0
       vnewtmns     = 0       
       
        myuser = sumry.gc_user_id
        obuser = get_summary_attendance_employee(myuser,dt,udt)
        if obuser.length >0
            obuser.each do |atd|
                  atttotalahrs  = atd.totalAHrs
                  atttotalvhrs  = atd.totalVHrs
                  if atttotalahrs!=nil && atttotalahrs!=''
                    ttimes  = atttotalahrs.to_s.split(":")
                    thrs    =  ttimes[0]
                    tmns    =  ttimes[1]
                  else
                    thrs    =  0
                    tmns    =  0
                  end
                  if atttotalvhrs!=nil && atttotalvhrs!=''
                    vtimes  = atttotalvhrs.to_s.split(":")
                    vthrs   =  vtimes[0]
                    vtmns   =  vtimes[1]
                  else
                     vthrs   =  0
                     vtmns   =  0
                  end

                  if thrs.to_i >0
                   newthrs += thrs.to_i
                  end
                  if tmns.to_i >0
                   newtmns += tmns.to_i
                  end

                  if vthrs.to_i >0
                   vnewhrs  += vthrs.to_i
                  end
                  if vtmns.to_i >0
                     vnewtmns += vtmns.to_i
                  end
            end
        end
          tinoutworkhrs += newthrs.to_i
          tinoutmns     += newtmns.to_i         
          newthrs       =  minuts_hour_calculation(newthrs,newtmns)
          vnewhrs       =  minuts_hour_calculation(vnewhrs,vnewtmns)
          sumry.totalworkinghours = newthrs
          arr.push sumry
      end      
      tinoutworkhrs  = minuts_hour_calculation(tinoutworkhrs,tinoutmns)

   end
  respond_to do |format|
      format.json { render :json => { :status=>isflags,:data=>arr,"newthrs"=>tinoutworkhrs} }
  end
end
end
