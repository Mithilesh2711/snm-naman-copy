class DailyDashboardController < ApplicationController
before_action :require_login  
    skip_before_action :verify_authenticity_token,:only=>[:index,:search,:ajax_process]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted
    helper_method :set_dct,:get_name_of_product,:get_user_list_name

    def index
        @compcodes            = session[:loggedUserCompCode]
        @ListDepart           = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compcodes).order("departDescription ASC") #MstHeadOffice.where("hof_compcode =?",@compcodes).order("hof_description ASC")
        @TotalStrength        = get_total_strength(@deprtment,@loc,@types)
        @TotalPresent         = daily_attendance_list('PT',@loc,@empdpt)
        @TotalAbsent          = daily_attendance_list('AB',@loc,@empdpt)
        @TotalOnLeave         = daily_attendance_list('OL',@loc,@empdpt)
        @TotalLTCount         = daily_attendance_list('LT',@loc,@empdpt)
        @LocWiseSummary       = location_wise_summary_list('LOC',@loc,@empdpt)
        @LocTotalStrength     = 0
        @LocTotalPresent      = 0
        @LocTotalAbsent       = 0
        @LocTotalOnLeave      = 0
        @LocTotalLTCount      = 0
        @LocTotalErlOutCount  = 0
        @LocOverTimeCount     = 0
        @LocMisPunch          = 0
        @DateLocWiseList      = nil
        @search_loc           = nil
        if params[:search_loc] !=nil && params[:search_loc] !='' || params[:search_dated] !=nil && params[:search_dated] !=''
             @LocTotalStrength       = get_total_strength(@deprtment,params[:search_loc],'DEPART')            
             @LocTotalPresent        = location_wise_list('PT',params[:search_loc],@empdpt,params[:search_dated])
             @LocTotalAbsent         = location_wise_list('AB',params[:search_loc],@empdpt,params[:search_dated])
             @LocTotalOnLeave        = location_wise_list('OL',params[:search_loc],@empdpt,params[:search_dated])
             @LocTotalLTCount        = location_wise_list('LT',params[:search_loc],@empdpt,params[:search_dated])
             @LocTotalErlOutCount    = location_wise_list('ELO',params[:search_loc],@empdpt,params[:search_dated])
             @LocOverTimeCount       = location_wise_list('OVT',params[:search_loc],@empdpt,params[:search_dated])
             @LocMisPunch            = location_wise_list('MSP',params[:search_loc],@empdpt,params[:search_dated])
             @DateLocWiseList        = datewise_location_wise_list('LOC',params[:search_loc],@empdpt,params[:search_dated])
             @search_loc             = params[:search_loc]
             @search_dated           = params[:search_dated]
        end
    end
    def create

    end
### ATTENDANCE SUMMARY 
private
def daily_attendance_list(type,loc,empdpt)
  compcodes  =  session[:loggedUserCompCode]
  empdpt    = loc
  mycounts = 0
    iswhere = "al_compcode ='#{compcodes}' AND sw_leavingdate='0000-00-00' AND DATE(al_trandate)=DATE(NOW()) AND YEAR(al_trandate)=YEAR(NOW())"   
    isflags = false
    
    if empdpt !=nil && empdpt !=''
      iswhere  += " AND sw_depcode ='#{empdpt}'"       
      isflags = true        
    end
    
    # if loc !=nil && loc !=''
    #     iswhere  += " AND sw_location ='#{loc}'"        
    #     isflags = true        
    # end
    if type =='PT'
      iswhere  += " AND al_present >0"
    elsif type =='AB'
        iswhere  += " AND al_absent >0"
    elsif type =='OL'
        iswhere  += " AND (al_paidleave+al_unpaidleave) >0"
    elsif type =='LT'
        iswhere  += " AND al_latehrs <>'0'"
    end
     
      iselect  =   "COUNT(*) as latecount,SUM(al_present) as presents,SUM(al_absent) as absents,( SUM(al_paidleave)+SUM(al_unpaidleave) ) as onleave"
      jons     =  " LEFT JOIN mst_sewadars emp ON(sw_compcode = al_compcode AND sw_sewcode = al_empcode)"
      if loc !=nil && loc !=''
        jons     += " LEFT JOIN departments dpt ON(compCode = sw_compcode AND sw_depcode = departCode)"
      end
      attndobj = TrnAttendanceList.select(iselect).joins(jons).where(iswhere).first
      if attndobj
        if type =='PT'
          mycounts = attndobj.presents
        elsif type =='AB'
          mycounts = attndobj.absents
        elsif type =='OL'
           mycounts = attndobj.onleave
        elsif type =='LT'  
           mycounts = attndobj.latecount 
        end           
      end
    return mycounts
end


### END ATTENDANCE SUMMARY DEPARTMENTWISE
private
def get_total_strength(deprtment,loc,types)
    counts     =  0
    compcodes  =  session[:loggedUserCompCode]
    if types.to_s == 'LOC'
        sewdobj    =  MstSewadar.where("sw_compcode = ? AND sw_location = ? AND sw_leavingdate='0000-00-00'",compcodes,loc)
    elsif types.to_s == 'DEPART'
        sewdobj    =  MstSewadar.where("sw_compcode = ? AND sw_depcode = ? AND sw_leavingdate='0000-00-00'",compcodes,deprtment)
    else
        sewdobj    =  MstSewadar.where("sw_compcode = ? AND sw_leavingdate='0000-00-00'",compcodes)
     end    
    if sewdobj.length >0
        counts = sewdobj.length
    end
    return counts
end
### END ATTENDANCE SUMMARY DEPARTMENTWISE

### LOCATION WISE SUMMARY
private
  def location_wise_summary_list(type,loc,empdpt)
    empdpt    = loc
      iswhere        = "al_compcode ='#{@compcodes}' AND DATE(al_trandate) = DATE(NOW()) AND YEAR(al_trandate) = YEAR(NOW())"
      if empdpt !=nil && empdpt !=''
        iswhere  += " AND sw_depcode ='#{empdpt}'"     
      end     
      # if loc !=nil && loc !=''
      #   iswhere  += " AND sw_location ='#{loc}'"       
      #  end
        arritem  =  []
        iselect  =  "trn_attendance_lists.*,sw_depcode,sw_location,sw_joiningdate,emp.id as empsId,'' as mydepartment"
        iselect  += ",COUNT(*) as totalstrengthm, SUM(al_present) as presents,SUM(al_absent) as absents,( SUM(al_paidleave)+SUM(al_unpaidleave) ) as onleave"
        jons     =  " LEFT JOIN mst_sewadars emp ON(sw_compcode = al_compcode AND sw_sewcode = al_empcode)"
        jons     += " LEFT JOIN departments dpt ON(compCode = sw_compcode AND sw_depcode = departCode)"

        attndobj = TrnAttendanceList.select(iselect).joins(jons).where(iswhere).group("sw_depcode").order("departDescription ASC")
        if attndobj.length >0
            attndobj.each do |newdpt|
               dptobj =   get_department_detail(newdpt.sw_depcode)
                if dptobj
                  newdpt.mydepartment = dptobj.departDescription
                end                
                
                arritem.push newdpt
            end          
        end
      return arritem
  end

  ####### GET LOCATION AND DATEWISE FILTER #########
  private
def location_wise_list(type,loc,empdpt,dated)
  compcodes  =  session[:loggedUserCompCode]
  empdpt    = loc
  newdated   =  dated !=nil && dated !='' ? year_month_days_formatted(dated) : ''
  mycounts   =  0
    iswhere  =  "al_compcode ='#{compcodes}'  AND DATE(al_trandate) = '#{newdated}'"   
    isflags  =  false
    
    if empdpt !=nil && empdpt !=''
      iswhere  += " AND sw_depcode ='#{loc}'"       
      isflags = true        
    end    
    # if loc !=nil && loc !=''
    #     iswhere  += " AND sw_location ='#{loc}'"        
    #     isflags = true        
    # end
    if type =='PT'
      iswhere  += " AND al_present >0"
    elsif type =='AB'
        iswhere  += " AND al_absent >0"
    elsif type =='OL'
        iswhere  += " AND (al_paidleave+al_unpaidleave) >0"
    elsif type =='LT'
        iswhere  += " AND al_latehrs <>'0'"
    elsif type =='ELO'
        iswhere  += " AND al_earlhrs <>'0'"
    elsif type =='OVT'
        iswhere  += " AND al_overtime <>'0'"
    elsif type =='MSP'
        iswhere  += " AND al_misspunch ='Y'"
    end
    

      iselect  =   "COUNT(*) as latecount,SUM(al_present) as presents,SUM(al_absent) as absents,( SUM(al_paidleave)+SUM(al_unpaidleave) ) as onleave"
      jons     =  " LEFT JOIN mst_sewadars emp ON(sw_compcode = al_compcode AND sw_sewcode = al_empcode)"
      if loc !=nil && loc !=''
        jons     += " LEFT JOIN departments dpt ON(compCode = sw_compcode AND sw_depcode = departCode)"
      end
      attndobj = TrnAttendanceList.select(iselect).joins(jons).where(iswhere).first
      if attndobj
            if type =='PT'
            mycounts = attndobj.presents
            elsif type =='AB'
            mycounts = attndobj.absents
            elsif type =='OL'
            mycounts = attndobj.onleave
            elsif type =='LT'  
            mycounts = attndobj.latecount 
            elsif type =='ELO'
            mycounts = attndobj.latecount 
            elsif type =='OVT'
            mycounts = attndobj.latecount 
            elsif type =='MSP'
            mycounts = attndobj.latecount 
            end           
      end
    return mycounts
end

private
  def datewise_location_wise_list(type,loc,empdpt,dated)
      empdpt     = loc
      newdated   =  dated !=nil && dated !='' ? year_month_days_formatted(dated) : ''
      iswhere    = "al_compcode ='#{@compcodes}' AND DATE(al_trandate) = '#{newdated}'"
      if empdpt !=nil && empdpt !=''
        iswhere  += " AND sw_depcode ='#{loc}'"     
      end     
      # if loc !=nil && loc !=''
      #   iswhere  += " AND sw_location ='#{loc}'"       
      #  end
        arritem = []
        iselect  = "trn_attendance_lists.*,sw_depcode,sw_location,sw_joiningdate,emp.id as empsId,'' as mydepartment,'' as location"
        iselect  += ",'' as totalstrengthm"
        iselect  += ",sw_sewadar_name,sw_joiningdate"
        jons     = " LEFT JOIN mst_sewadars emp ON(sw_compcode = al_compcode AND sw_sewcode = al_empcode)"
        jons     += " LEFT JOIN departments dpt ON(compCode = sw_compcode AND sw_depcode = departCode)"
        attndobj = TrnAttendanceList.select(iselect).joins(jons).where(iswhere).group("al_empcode,al_trandate,sw_depcode").order("departDescription ASC")
        if attndobj.length >0
            attndobj.each do |newdpt|
               dptobj =   get_department_detail(newdpt.sw_depcode)
                if dptobj
                  newdpt.mydepartment = dptobj.departDescription
                end                
                newdpt.totalstrengthm = get_total_strength(newdpt.sw_depcode,newdpt.sw_location,type)
                arritem.push newdpt
            end          
        end
      return arritem
  end
end

