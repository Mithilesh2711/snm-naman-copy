class ApplicationController < ActionController::Base
   protect_from_forgery with: :exception
   rescue_from ActiveRecord::RecordNotFound, :with => :render_404
   include ErpModule::Common
   helper_method :get_global_university,:get_global_qualification,:get_dob_calculate,:page_linked,:set_ent,:set_dct,:get_global_sewadar_listed,:get_leave_balances
   helper_method :get_leave_taken,:get_category_names,:get_total_deduction_month,:get_all_birthday_listed,:get_member_listed,:get_number_month_data,:get_mysewdar_list_details
   helper_method :get_request_type_listed,:get_hours_calculation
   private
  def require_login
      @securedlogged = false
      @annualLeave   = 20
      current_user
      if !@securedlogged
           redirect_to :controller=> :login
      elsif session[:idle_timelineout] == 'Y'
          if session[:load_current_user] != 'Y'
            session[:idle_timelineout] = nil
            session[:load_current_user] = nil
            redirect_to :controller=> :login
          end 
      end
 end

 def current_user
   secured_login_passd  = session[:SECURED_LOGIN_CHK]!=nil && session[:SECURED_LOGIN_CHK]!='' ? session[:SECURED_LOGIN_CHK] : nil
   isloggeduserid       = session[:logedUserId]!=nil && session[:logedUserId]!='' ? session[:logedUserId] : 0
   compcode             = session[:loggedUserCompCode]
   @markedAllowed       = true
   @markedFieldAlw      = false
   @allowedCaseduser    = true
   @AllowedHrOption     = nil
   @ManageActionList    = nil
   @ListGlobalModule    = MstListModule.where("lm_compcode = ? AND lm_status='Y'",compcode).order("lm_modules ASC")
  
   if isloggeduserid
         curr_user  = User.where("id=? AND userstatus='Y'",isloggeduserid)
         if curr_user.length >0
             dbpassword         = curr_user[0].userpassword
             @listModule        = curr_user[0].listmodule
             @ManageActionList  = curr_user[0].managetype
             @AllowedHrOption   = curr_user[0].allowhrparameter ? curr_user[0].allowhrparameter.to_s.split(",") : ''
              if secured_login_passd!=nil && secured_login_passd!='' && dbpassword !=nil && dbpassword!='' && dbpassword == secured_login_passd
                @securedlogged = true
              end
         end
   end
   ######### AUTHORIZED SCREEN ########
    if session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
        @markedAllowed = false
    end
     
     if session[:requestuser_loggedintp].to_s == 'swd'
        @allowedCaseduser = false
    end
   ######## END AUTHORIZED SCREEN ##########
 end

 def get_global_users(isloggeduserid)
     usrobj  = User.where("id=? AND userstatus='Y'",isloggeduserid).first
     return usrobj;
 end
 def get_class_series(number)
          clasth = ""
          if( number.to_i ==1 ) 
               clasth = number.to_s+"st"
          elsif( number.to_i ==2 ) 
               clasth = number.to_s+"nd" 
          elsif( number.to_i ==3 ) 
               clasth = number.to_s+"rd"         
           elsif( number.to_i >3 && number.to_i<=12)
               clasth = number.to_s+"th"
           elsif( number.to_i == 13 )  
               clasth ="U1" 
          elsif( number.to_i == 14 )  
               clasth ="U2"
          elsif( number.to_i == 15 )  
               clasth ="U3" 
          elsif( number.to_i == 16 )  
               clasth ="U4"  
          elsif( number.to_i == 17 )  
               clasth ="U5"                
          end
          return clasth
 end
 def get_leap_years(startyears,endyears)
     leapcounts = 0
     if startyears.to_i >0 && endyears.to_i >0
          for i in startyears.to_i..endyears.to_i do 
               if i.to_i%4 == 0
                    leapcounts +=1
               end
          end
     end 
     return leapcounts
end

 def get_month_formatts(months)
     newmonths = ""
     if months.to_s.length <9
     newmonths = '0'+ months.to_s
     end
     return newmonths
 end

def get_number_month_data(months)
     monthsstr = 0
     if  months.to_s == "January"
          monthsstr = 1
     elsif  months.to_s == "February"
          monthsstr = 2
     elsif  months.to_s == "March"
          monthsstr = 3
     elsif  months.to_s == "April"
          monthsstr = 4
     elsif  months.to_s == "May"
          monthsstr = 5
     elsif  months.to_s == "June"
          monthsstr = 6
     elsif  months.to_s == "July"
          monthsstr = 7
     elsif  months.to_s == "August"
          monthsstr = 8
     elsif  months.to_s == "September"
          monthsstr = 9
     elsif  months.to_s == "October"
          monthsstr = 10
     elsif  months.to_s == "November"
          monthsstr = 11
     elsif  months.to_s == "December"
          monthsstr = 12
     end
     return monthsstr

end

def get_month_listed_data(months)
     monthsstr = ""
     if  months.to_i == 1
          monthsstr = "January"
     elsif  months.to_i == 2
          monthsstr = "February"
     elsif  months.to_i == 3
          monthsstr = "March"
     elsif  months.to_i == 4
          monthsstr = "April"
     elsif  months.to_i == 5
          monthsstr = "May"
     elsif  months.to_i == 6
          monthsstr = "June"
     elsif  months.to_i == 7
          monthsstr = "July"
     elsif  months.to_i == 8
          monthsstr = "August"
     elsif  months.to_i == 9
          monthsstr = "September"
     elsif  months.to_i == 10
          monthsstr = "October"
     elsif  months.to_i == 11
          monthsstr = "November"
     elsif  months.to_i == 12
          monthsstr = "December"
     end
     return monthsstr

end

def get_total_days_of_month(months,years)
     monthsstr = 0
     if  months.to_i == 1
          monthsstr = 31
     elsif  months.to_i == 2
          ### check leap years
          if years.to_i >0
              if years.to_i%4 == 0
                 monthsstr = 29
              else
                 monthsstr = 28
              end
          else
               monthsstr = 28
          end
     elsif  months.to_i == 3
          monthsstr = 31
     elsif  months.to_i == 4
          monthsstr = 30
     elsif  months.to_i == 5
          monthsstr = 31
     elsif  months.to_i == 6
          monthsstr = 30
     elsif  months.to_i == 7
          monthsstr = 31
     elsif  months.to_i == 8
          monthsstr = 31
     elsif  months.to_i == 9
          monthsstr = 30
     elsif  months.to_i == 10
          monthsstr = 31
     elsif  months.to_i == 11
          monthsstr = 30
     elsif  months.to_i == 12
          monthsstr = 31
     end
    return monthsstr

end

 private
 def age_calculated(dob)
      unless dob.nil?
      dob = Date.parse(dob.to_s)
      years = Date.today.year - dob.year
      if Date.today.month < dob.month
      years = years + 1
      end
      if (Date.today.month == dob.month and
      Date.today.day < dob.day)
      years = years - 1
      end
      return years
      end
      nil
end

 private
 def get_dob_calculate(dob,leavingdate="",others="")
     messages  =  ""
     myparam   =  ""
     joindate  = dob 

     ###

      
     

     leavingdt = leavingdate !=nil && leavingdate !='' ? leavingdate :  ''  
     if leavingdt != nil && leavingdt != '' && joindate !=nil && joindate !=''         
          # if others.to_s=='S'
          #      myparam    = called_between_days(joindate,leavingdt,0);
          #      #diff      = (Date.parse(joindate)-Date.parse(leavingdt)).to_i #+1;
          # else
          #      #diff      = (Date.parse(leavingdt)-Date.parse(joindate)).to_i #+1;
          #      myparam    = called_between_days(leavingdt,joindate,0);
          # end
         # myparam    = called_between_days(joindate,leavingdt,0);
          if  joindate.to_date >leavingdt.to_date
              myparam    = called_between_days(leavingdt,joindate,0)
          else
               myparam    = called_between_days(joindate,leavingdt,0)
          end
     else
          leavingdt = Date.current
          if joindate !=nil && joindate !=''
             
               # if others.to_s=='S'
               #     # diff      = (Date.parse(joindate)-leavingdt).to_i
               #     myparam    = called_between_days(joindate,leavingdt,0);
                    
               # else
               #      #diff      = (leavingdt-Date.parse(joindate)).to_i #+1;
               #      myparam    = called_between_days(leavingdt,joindate,0);
               # end
               if  joindate.to_date >leavingdt.to_date
                    myparam    = called_between_days(leavingdt,joindate,0)
               else
                    myparam    = called_between_days(joindate,leavingdt,0)
               end
               
          else
              return messages
          end
          
     end
     if myparam !=nil && myparam !=''
          myparams = myparam.to_s.split("-")  
          years    =  myparams[0]   
          months   =  myparams[1]
          newdays  =  myparams[2] 
     end
     # years     = (diff / (365)).floor;
     # months    = ((diff - years * 365)/(30)).floor;
     # days      = ((diff - years * 365 - months*30)).floor;
     # newdays   = days.to_i-get_total_days(months).to_i
     # leapcount = 0
     # if joindate !=nil && joindate !=''  && leavingdt !=nil && leavingdt !=''
     #      joiningyears = Date.parse(joindate.to_s).strftime("%Y")
     #      leftyears    = Date.parse(leavingdt.to_s).strftime("%Y")
     #      leapcount    = get_leap_years(joiningyears,leftyears)
     # end    
     # if leapcount.to_i >0
     #      newdays = newdays.to_i-leapcount.to_i
     # end
     newyear  = ""
     newmonth = ""
     mydays   = ""
     if years.to_i == 1
          newyear = " 1 Year"
     elsif years.to_i >1
          newyear = years.to_s+" Years"  
     end
     if months.to_i == 1
          newmonth = " 1 Month"
      elsif months.to_i >1
          newmonth = months.to_s+" Months"  
      end
      if newdays.to_i == 1
          mydays = " 1 Day"
      elsif newdays.to_i >1
          mydays = newdays.to_s+" Days"  
      end
      if newdays.to_i >0 && months.to_i >0 && years.to_i >0
          messages =  [newyear,newmonth,mydays].compact.join(', ')
      elsif months.to_i >0 && years.to_i >0    
          messages =  [newyear,newmonth].compact.join(', ')
      elsif newdays.to_i >0 && months.to_i >0 
          messages =  [newmonth,mydays].compact.join(', ')  
      elsif newdays.to_i >0 && years.to_i >0  
          messages =  [newyear,mydays].compact.join(', ')   
      elsif years.to_i >0    
          messages =  newyear
     elsif months.to_i >0    
          messages =  newmonth 
     elsif newdays.to_i >0    
          messages =  mydays        
     end
     
     return messages


 end

 private
 def get_graita_calculate(joindate,leavingdt,lwm="")
      messages =  ""
      years    = 0
      months   = 0
      days     = 0
     if leavingdt !=nil && leavingdt !='' && joindate !=nil && joindate !=''
          if  joindate.to_date >leavingdt.to_date
               myparam    = called_between_days(leavingdt,joindate,lwm)
          else
               myparam    = called_between_days(joindate,leavingdt,lwm)
          end
         
          if myparam !=nil && myparam !=''
               myparams = myparam.to_s.split("-")  
               years    =  myparams[0]   
               months   =  myparams[1]
               newdays  =  myparams[2] 
          end

          # diff      = (Date.parse(leavingdt)-Date.parse(joindate)).to_i #+1;
          # if lwm.to_i >0
          #      diff     = diff.to_i-lwm.to_i               
          # end
          # years     = (diff / (365)).floor;
          # months    = ((diff - years * 365)/(30)).floor;
          # days      = ((diff - years * 365 - months*30)).floor;
          # newdays   = days.to_i-get_total_days(months).to_i
          # leapcount = 0
          # if joindate !=nil && joindate !=''  && leavingdt !=nil && leavingdt !=''
          #      joiningyears = Date.parse(joindate.to_s).strftime("%Y")
          #      leftyears    = Date.parse(leavingdt.to_s).strftime("%Y")
          #      leapcount = get_leap_years(joiningyears,leftyears)
          # end    
          # if leapcount.to_i >0
          #      newdays = newdays.to_i-leapcount.to_i
          # end
          newyear  = ""
          newmonth = ""
          mydays   = ""
          if years.to_i == 1
               newyear = " 1 Year"
          elsif years.to_i >1
               newyear = years.to_s+" Years"  
          end
          if months.to_i == 1
               newmonth = " 1 Month"
          elsif months.to_i >1
               newmonth = months.to_s+" Months"  
          end
          if newdays.to_i == 1
               mydays = " 1 Day"
          elsif newdays.to_i >1
               mydays = newdays.to_s+" Days"  
          end
          messages =  [newyear,newmonth].compact.join('.')
     end
     return messages

 end

 private
 def get_sewa_calated_yers(dob)

    messages = ""

    # if a date of birth is not nil
    if dob != nil && dob !=''
      dob = Date.parse(dob.to_s)
      # get current date
      today ||= Date.current
      month_diff = (12 * today.year + today.month) - (12 * dob.year + dob.month)
      y, m = month_diff.divmod 12
      y_text   =  (y == 0) ? nil : (y == 1) ? '1 year'  : "#{y} years"
      m_text   =  y && (m == 0) ? nil : (m == 1) ? '1 month' : "#{m} months"
      messages =  y_text #[y_text, m_text].compact.join(' and ')
    end
    return messages

 end

 private
 def called_between_days(startdate,enddate,days)        
      recounts   = ''
      days       = days.to_i >0 ? days : 0  
       sqls      = "CALL get_years_month_days ('#{year_month_days_formatted(startdate)}','#{year_month_days_formatted(enddate)}','#{days.to_i}')"
       listobj   = request_processor(sqls)
      if listobj && listobj.length >0
         recounts = listobj[0].monthyeardays
      end
      return recounts
 end

 private
 def get_monthyeardays_diffdate(joindate,leavingdt,lwm="")
      messages =  ""
      years    = 0
      months   = 0
      days     = 0
     if leavingdt !=nil && leavingdt !='' && joindate !=nil && joindate !=''
         # myparam = called_between_days(joindate,leavingdt,lwm); 
          if  joindate.to_date >leavingdt.to_date
               myparam    = called_between_days(leavingdt,joindate,lwm)
          else
               myparam    = called_between_days(joindate,leavingdt,lwm)
          end
          if myparam !=nil && myparam !=''
               myparams = myparam.to_s.split("-")  
               years    =  myparams[0]   
               months   =  myparams[1]
               newdays  =  myparams[2] 
          end
               # diff     = (Date.parse(leavingdt)-Date.parse(joindate)).to_i #+1;
               # if lwm.to_i >0
               #      diff     = diff.to_i-lwm.to_i               
               # end
               # years    = (diff / (365)).floor;
               # months   = ((diff - years * 365)/(30)).floor;
               # days     = ((diff - years * 365 - months*30.4375)).floor;
               # newdays  = days.to_i-get_total_days(months).to_i
               # leapcount = 0
               # if joindate !=nil && joindate !=''  && leavingdt !=nil && leavingdt !=''
               #      joiningyears = Date.parse(joindate.to_s).strftime("%Y")
               #      leftyears    = Date.parse(leavingdt.to_s).strftime("%Y")
               #      leapcount    = get_leap_years(joiningyears,leftyears)
               # end    
               # if leapcount.to_i >0
               #      newdays = newdays.to_i-leapcount.to_i
               # end

               newyear  = ""
               newmonth = ""
               mydays   = ""
               if years.to_i == 1
                    newyear = " 1 Year"
               elsif years.to_i >1
                    newyear = years.to_s+" Years"  
               end
               if months.to_i == 1
                    newmonth = " 1 Month"
               elsif months.to_i >1
                    newmonth = months.to_s+" Months"  
               end
               if newdays.to_i == 1
                    mydays = " 1 Day"
               elsif newdays.to_i >1
                    mydays = newdays.to_s+" Days"  
               end
               if newdays.to_i >0 && months.to_i >0 && years.to_i >0
                    messages =  [newyear,newmonth,mydays].compact.join(', ')
               elsif months.to_i >0 && years.to_i >0    
                    messages =  [newyear,newmonth].compact.join(', ')
               elsif newdays.to_i >0 && months.to_i >0 
                    messages =  [newmonth,mydays].compact.join(', ')  
               elsif newdays.to_i >0 && years.to_i >0  
                    messages =  [newyear,mydays].compact.join(', ')   
               elsif years.to_i >0    
                    messages =  newyear
               elsif months.to_i >0    
                    messages =  newmonth 
               elsif newdays.to_i >0    
                    messages =  mydays        
               end
     end
     return messages
 end
 
 private
 def get_total_days(months)
       c= 0
       months = months.to_i+1
      for i in 1..months.to_i do
         if i.to_i== 1 || i.to_i== 3 || i.to_i== 5 || i.to_i== 7 || i.to_i== 8  || i.to_i== 10 || i.to_i== 12
               c +=1
         end

     end
     return c
 end
 
   
 private
def allowed_security
  set_cache_headers
end
#### CALCULATE TIME DIFERENCE ########
private
def time_formatted_setup(mytime)
   if mytime !=nil && mytime != ''
     #Time.strptime(mytime, "%I%P").strftime("%H:%M")
     DateTime.parse(mytime).strftime("%H:%M")
   end

end
private
  def process_files(attfile,currfile,cdirect)
    file_names     =  attfile.original_filename  if  ( attfile !='' && attfile !=nil )
    files          =  attfile.read
    file_types     =  file_names.split('.').last
    new_name_files =  Time.now.to_i
    new_file_name  = "#{new_name_files}." + file_types    
    paths1         = Rails.root.join "public", "images", cdirect
    #### Delete Origins#############
    if attfile != '' && attfile!= nil
         if currfile != '' && currfile != nil
           curpath = Rails.root.join "public", "images", cdirect,currfile
           process_unlinks_the_files(curpath)
         end
    end
    ######### Upload here ######################
    File.open("#{paths1}/" + new_file_name, "wb")  do |f|
       f.write(files)
    end
    #corp_image_size_signs
    return new_file_name
  end


  private
  def process_files_new(attfile,currfile,cdirect,cnt)
    file_names     =  attfile.original_filename  if  ( attfile !='' && attfile !=nil )
    files          =  attfile.read
    file_types     =  file_names.split('.').last
    new_name_files =  Time.now.to_i+cnt.to_i
    new_file_name  = "#{new_name_files}." + file_types
    paths1         = Rails.root.join "public", "images", cdirect
    #### Delete Origins#############
    if attfile != '' && attfile!= nil
         if currfile != '' && currfile != nil
           curpath = Rails.root.join "public", "images", cdirect,currfile
           process_unlinks_the_files(curpath)
         end
    end
    ######### Upload here ######################
    File.open("#{paths1}/" + new_file_name, "wb")  do |f|
       f.write(files)
    end
    #corp_image_size_signs
    return new_file_name
  end


private
def get_sanction_detail(voucherno)
     compcodes  = session[:loggedUserCompCode]
     iswhere = "vd_compcode ='#{compcodes}' AND vd_voucherno ='#{voucherno}'"
     loansobj = TrnVoucherDetail.select("vd_voucherno,vd_voucherdate").where(iswhere).first
     return loansobj

end

  private
def get_leave_balances(leavecode,sewdarcode)   
     compcodes  = session[:loggedUserCompCode]
     tleaves    = 0
     leaveobj   = TrnLeaveBalance.select("SUM(lb_closingbal) as totals,SUM(lb_openbal) as opbalances").where("lb_compcode = ? AND lb_empcode = ? AND lb_leavecode = ?",compcodes,sewdarcode,leavecode).first
     if leaveobj
          tleaves = leaveobj.totals
     end
     return tleaves
end

   private
   def get_oustanding_balance(sewacode)
          compcodes       = session[:loggedUserCompCode]
          totaloustanding = 0
          isselect        = "SUM(al_balances) as totaloustanding,SUM(al_installpermonth) as totalemi"
          iswhere         = "al_compcode='#{compcodes}' AND al_requesttype <>'Ex-gratia' AND ( al_broucherno<>'' OR al_openingdata ='Y' ) AND al_sewadarcode ='#{sewacode}' AND al_balances>0"
          loansobj        = TrnAdvanceLoan.select(isselect).where(iswhere).first
          return loansobj
   end

   private
   def get_maadvance_oustanding_balance(sewacode,type="")
          compcodes       = session[:loggedUserCompCode]
          totaloustanding = 0
          isselect        = "SUM(al_balances) as totaloustanding,SUM(al_installpermonth) as totalemi"
          if type !=nil && type !=''
               iswhere         = "al_compcode='#{compcodes}' AND al_requesttype='#{type}' AND ( al_broucherno<>'' OR al_openingdata ='Y' ) AND al_sewadarcode ='#{sewacode}' AND al_balances>0"
          else
               iswhere         = "al_compcode='#{compcodes}' AND ( al_broucherno<>'' OR al_openingdata ='Y' ) AND al_sewadarcode ='#{sewacode}' AND al_balances>0"    
          end          
          loansobj        = TrnAdvanceLoan.select(isselect).where(iswhere).first
          return loansobj
   end

   private
   def get_check_guarantor(sewacode)
          compcodes       = session[:loggedUserCompCode]
          totaloustanding = 0
          isselect        = "al_balances as totaloustanding"
          iswhere         = "al_compcode='#{compcodes}' AND al_approvestatus NOT IN('R','C','H') AND al_sewadarcode ='#{sewacode}' AND al_guarantorname<>''"
          loansobj        = TrnAdvanceLoan.select(isselect).where(iswhere)
          if loansobj.length >0
               totaloustanding =1
          end
          return totaloustanding
   end

   private
   def get_check_total_exgratia(sewacode)
          compcodes       = session[:loggedUserCompCode]
          totaloustanding = 0
          isselect        = "(SUM(al_advanceamt)+SUM(al_loanamount)) as totaloustanding"
          iswhere         = "al_compcode='#{compcodes}' AND al_approvestatus ='A' AND al_sewadarcode ='#{sewacode}'"
          loansobj        = TrnAdvanceLoan.select(isselect).where(iswhere).first
          if loansobj
               totaloustanding = loansobj.totaloustanding
          end
          return totaloustanding
   end

   private
   def final_check_total_exgratia(sewacode)
          compcodes       = session[:loggedUserCompCode]
          totaloustanding = 0
          isselect        = "(SUM(al_advanceamt)+SUM(al_loanamount)) as totaloustanding"
          iswhere         = "al_compcode='#{compcodes}' AND al_approvestatus ='A' AND al_sewadarcode ='#{sewacode}' AND LOWER(al_requesttype)=LOWER('Ex-gratia')"
          loansobj        = TrnAdvanceLoan.select(isselect).where(iswhere).first
          if loansobj
               totaloustanding = loansobj.totaloustanding
          end
          return totaloustanding
   end

   private
   def get_loan_adavnce_total_amount(sewacode)
          compcodes       = session[:loggedUserCompCode]
          totaloustanding = 0
          isselect        = "(SUM(al_advanceamt)+SUM(al_loanamount)) as totaloustanding"
          iswhere         = "al_compcode='#{compcodes}' AND ( al_broucherno<>'' OR al_openingdata ='Y' ) AND al_sewadarcode ='#{sewacode}'"
          loansobj        = TrnAdvanceLoan.select(isselect).where(iswhere).first
          if loansobj
               totaloustanding = loansobj.totaloustanding
          end
          return totaloustanding
   end

  private
  def repaid_new_balances(sewacode,month,year)
     compcodes = session[:loggedUserCompCode]
     total     = 0
     iswhere   = "pma_compcode='#{compcodes}' AND pma_sewacode='#{sewacode}' AND pma_month='#{month}' AND pma_year='#{year}'"
     isselect  = "SUM(pma_installment) as totaldeduct"
     sewobj    = TrnProcessMonthlyAdvance.select(isselect).where(iswhere).first
     if sewobj
     total = sewobj.totaldeduct
     end
     return total
  end

  private
  def advance_transaction_list(sewacode,types,month,year)
     compcodes = session[:loggedUserCompCode]
     total     = 0
     iswhere   = "pma_compcode='#{compcodes}' AND pma_type ='#{types}' AND pma_sewacode='#{sewacode}' "
     if month.to_i >0
          iswhere   += " AND pma_month='#{month}' "
     end
     if year.to_i >0
          iswhere   += " AND pma_year='#{year}' "
     end
     isselect  = "SUM(pma_installment) as totaldeduct"
     sewobj    = TrnProcessMonthlyAdvance.select(isselect).where(iswhere).first
     if sewobj
     total = sewobj.totaldeduct
     end
     return total
  end

  private
  def process_unlinks_the_files(path_to_file)
      File.delete(path_to_file) if File.exist?(path_to_file)
  end
  private
  def get_global_office_detail(empcode)
         compcode   = session[:loggedUserCompCode]
         sewdarobj =  MstSewadarOfficeInfo.where("so_compcode =? AND so_sewcode =?",compcode,empcode).first
         return sewdarobj
  end
  private
  def get_member_listed(memberid)
      compcode   = session[:loggedUserCompCode]
      ldsobj     = MstLedger.where("lds_compcode = ? AND id = ?",compcode,memberid).first
      return  ldsobj
  end
 
  private
  def get_unapproved_leave_request(sewcode,type)
    compcode   = session[:loggedUserCompCode]
    iswhere    = "ls_compcode = '#{compcode}' AND ls_empcode = '#{sewcode}' AND ls_status = '#{type}'"
    leavobj    = TrnLeave.where(iswhere).order("id DESC")
    return leavobj
  end

  private
  def get_merge_leave_status(category,leavecode)
    compcode   = session[:loggedUserCompCode]
    mergallow  = false
    leaveobj   = MstLeave.select("attend_mergeleave").where("attend_compcode=? AND attend_category = ? AND attend_leaveCode =? ",compcode,category,leavecode).first
    if leaveobj
          if leaveobj.attend_mergeleave == 'Y'
               mergallow = true      
          end
    end
     return mergallow
  end

  private
  def get_unapproved_advance_loan(sewcode)
    compcode   = session[:loggedUserCompCode]
    iswhere    = "al_compcode = '#{compcode}' AND al_sewadarcode = '#{sewcode}' AND al_broucherno = ''"
    loansobj   = TrnAdvanceLoan.where(iswhere).order("al_sewadarcode asc")
    return loansobj
  end

  private
  def get_selected_advance_listing(sewcode,reqno)
    compcode   = session[:loggedUserCompCode]
    iswhere    = "al_compcode = '#{compcode}' AND al_sewadarcode = '#{sewcode}' AND al_requestno = '#{reqno}'"
    loansobj   = TrnAdvanceLoan.where(iswhere).first
    return loansobj
  end

  private
  def get_all_birthday_listed
      compcode      = session[:loggedUserCompCode]
      arrbirth      = []
      lcdate        = get_local_dated()
      iswhere       = "sw_compcode='#{compcode}' AND DATE_FORMAT(sw_date_of_birth,'%m-%d') = DATE_FORMAT('#{lcdate}','%m-%d') AND sw_leavingdate='0000-00-00'"
      listsewbobj   = MstSewadar.select("sw_sewcode,sw_sewadar_name,sw_gender,sw_image,sw_depcode,'sewa' as types").where(iswhere).order("sw_date_of_birth ASC")
       if listsewbobj.length >0
               listsewbobj.each do |newbrtd|
                    arrbirth.push newbrtd
               end
       end
       orgobj = get_birth_of_organization()
       if orgobj.length >0
          orgobj.each do |orgmemb|
               arrbirth.push orgmemb
          end
       end
       return arrbirth
  end

   def get_birth_of_organization
          compcode   = session[:loggedUserCompCode]
          lcdate     = get_local_dated()
          iswhere    = "lds_compcode ='#{compcode}' AND DATE_FORMAT(lds_dob,'%m-%d') = DATE_FORMAT('#{lcdate}','%m-%d') "
          isselect   = "lds_membno as sw_sewcode,lds_name as sw_sewadar_name,'' as sw_gender,lds_profile as sw_image,'' as sw_depcode,'memb' as types"
          birthsobj  = MstLedger.select(isselect).where(iswhere).order("lds_dob ASC")
          return birthsobj
   
   end

  private
  def get_birth_of_sewadar(sewcode)
    compcode         = session[:loggedUserCompCode]
    lcdate           = get_local_dated()
    iswhere          = "sw_compcode='#{compcode}' AND sw_sewcode='#{sewcode}' AND DATE_FORMAT(sw_date_of_birth,'%m-%d') = DATE_FORMAT('#{lcdate}','%m-%d') AND sw_leavingdate='0000-00-00'"
    birthsobj        = MstSewadar.select("sw_sewcode,sw_sewadar_name,sw_gender").where(iswhere).first
    return birthsobj
  end

  private
  def get_birth_of_orgmember(sewcode)
    compcode         = session[:loggedUserCompCode]
    lcdate           = get_local_dated()
    iswhere          = "lds_compcode='#{compcode}' AND id='#{sewcode}' AND DATE_FORMAT(lds_dob,'%m-%d') = DATE_FORMAT('#{lcdate}','%m-%d') "
    birthsobj        = MstLedger.select("lds_membno as sw_sewcode,lds_name as sw_sewadar_name,'' assw_gender").where(iswhere).first
    return birthsobj
  end

  private
  def get_local_dated()
     Time.zone        = "Kolkata"
     lcdate           = Time.zone.now.strftime('%Y-%m-%d')
     return lcdate     
  end

private
def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
def render_404
  render :template => "errors/error_404", :status => 404
end

private
def get_education_voucher(newreqid)
     compcode = session[:loggedUserCompCode]
     iswhere  = "vd_compcode ='#{compcode}' AND vd_requestno ='#{newreqid}' AND LOWER(vd_requestfor)='education'"
     loansobj = TrnVoucherDetail.where(iswhere).first
    return loansobj

end

 private
  def global_sewadar_kyc_information(sewcode)
      compcode      =  session[:loggedUserCompCode]
       sewdarobj    =  MstSewadarKyc.where("sk_compcode =? AND sk_sewcode =?",compcode,sewcode).first
       return sewdarobj
  end
private
 def get_university_deegre_listed(qualification)
     compcode      = session[:loggedUserCompCode]
     iswhere       = "un_compcode ='#{compcode}' AND FIND_IN_SET('#{qualification.to_s.strip}',un_qltype) >0"
     unobj         = MstUniversity.where(iswhere).group("un_description").order("un_description ASC")
     return unobj
 end

private
def get_global_university(qualification)
   compcode = session[:loggedUserCompCode]
   unobj     =  MstUniversity.where("un_compcode = ? AND LOWER(un_qltype) = ?",compcode,qualification.to_s.strip.downcase).order("un_description ASC")
   return unobj
end

private
def get_name_global_university(unvid)
   compcode = session[:loggedUserCompCode]
   unobj     =  MstUniversity.where("un_compcode = ? AND id = ?",compcode,unvid).first
   return unobj
end

private
def get_first_my_sewadar(hods)
   compcode = session[:loggedUserCompCode]
   seobj   = MstLedger.select("lds_name,lds_profile,lds_membno").where("lds_compcode =? and lds_membno = ?",compcode,hods).first
   return seobj
end

private
def get_hod_listed_sewadar(hods)
   compcode = session[:loggedUserCompCode]
   seobj   = MstLedger.where("lds_compcode =? and id = ?",compcode,hods).first
   return seobj
end


private
def get_global_qualification(qualification)
    compcode = session[:loggedUserCompCode]
    qlfobj = MstQualification.where("ql_compcode = ? AND  LOWER(ql_qualification) = ?",compcode,qualification.to_s.strip.downcase).order("ql_qualdescription ASC")
    return qlfobj
end

private
def get_name_global_qualification(qlid)
    compcode = session[:loggedUserCompCode]
    qlfobj = MstQualification.where("ql_compcode = ? AND  id = ?",compcode,qlid).first
    return qlfobj
end

private
def user_detail(id)
    compcode = session[:loggedUserCompCode]
    userobj  = User.where("usercompcode = ? AND id = ?",compcode,id).first
    return userobj
end

private
def get_zone_district_listed(distcode)
   compcode = session[:loggedUserCompCode]
   stsobj   = MstZoneDistrict.where(["zd_compcode = ? AND zd_distcode = ?", compcode,distcode]).first
   return stsobj
end

private
def get_zone_name_detail(scode)
  compcode = session[:loggedUserCompCode]
  stsobj   = MstZone.where("zn_compcode = ? AND zn_zonecode =?",compcode,scode).first
  return stsobj
end

private
def get_state_detail(scode)
  compcode = session[:loggedUserCompCode]
  stsobj   = MstState.where("sts_compcode =? AND sts_code =?",compcode,scode).first
  return stsobj
end
def get_district_detail(dscode)
    compcode = session[:loggedUserCompCode]
    disobj   =  MstDistrict.where("dts_compcode = ? AND dts_districtcode = ?",compcode,dscode).first
    return disobj
end
def get_city_detail(ccode)
    compcode = session[:loggedUserCompCode]
    ctobj   = MstCity.where("ct_compcode =? AND ct_citycode =?",compcode,ccode).first
    return ctobj
  end

private
def get_currency_detail(curcode)
    compcode = session[:loggedUserCompCode]
    curobj   =  MstCurrency.where("cur_compcode = ? AND cur_code = ?",compcode,curcode).first
    return curobj
end

def get_subscription_type_detail(subcode)
    compcode = session[:loggedUserCompCode]
    subobj   =  MstSubscriptionType.where("subtyp_compcode = ? AND subtyp_code = ?",compcode,subcode).first
    return subobj
end

def get_magazine_detail(magcode)
    compcode = session[:loggedUserCompCode]
    magobj   =  MstMagazine.where("mag_compcode = ? AND mag_code = ?",compcode,magcode).first
    return magobj
end

private
def get_subs_location(locid)
  compcode =  session[:loggedUserCompCode]
  locobj   =  MstSubLocation.where("sl_compcode =? AND id = ?",compcode,locid).first
  return locobj
end

private
def get_ho_location(locid)
  compcode =  session[:loggedUserCompCode]
  locobj   =  MstHeadOffice.where("hof_compcode =? AND id = ?",compcode,locid).first
  return locobj
end

private
def get_my_selected_department_code(hodcode)
    compcode =  session[:loggedUserCompCode]
    disobj   =  Department.where("compCode = ? AND departHod = ?",compcode,hodcode).first
    return disobj
end
private
def get_my_coordinate_department_code(hodcode)
    compcode =  session[:loggedUserCompCode]
    iswhere  = "compCode ='#{compcode}' AND ( departHod ='#{hodcode}' OR  cordinatevalue='#{hodcode}' OR cordnatorthird='#{hodcode}')"
    disobj   =  Department.where(iswhere).first
    return disobj
end 

private
def get_all_coordinate_department(hodcode)
    compcode =  session[:loggedUserCompCode]
    iswhere  = "compCode ='#{compcode}' AND ( departHod ='#{hodcode}' OR  cordinatevalue='#{hodcode}' OR cordnatorthird='#{hodcode}')"
    disobj   =  Department.where(iswhere).order("departDescription ASC")
    return disobj
end 

private
def get_department_detail(dscode)
    compcode =  session[:loggedUserCompCode]
    disobj   =  Department.where("compCode= ? AND departCode = ? AND subdepartment=''",compcode,dscode).first
    return disobj
end

private
def get_all_department_detail(dscode)
    compcode =  session[:loggedUserCompCode]
    disobj   =  Department.where("compCode = ? AND departCode = ? AND subdepartment=''",compcode,dscode).first
    return disobj
end
private
  def get_sewdar_designation_detail(desicode)
      compcode   = session[:loggedUserCompCode]
      designobj  = Designation.where("compcode = ? AND desicode = ?",compcode,desicode).first
      return designobj
  end

    private
    def get_my_all_designation
        compcode =  session[:loggedUserCompCode]
        disobj   =  Designation.where("compcode = ? AND ds_type ='Organization'",compcode).order("ds_description ASC")
        return disobj
    end
private
def get_common_prefix(sn_type)
    compcode =  session[:loggedUserCompCode]
    msobj    =  MstSerialNumber.where("sn_compcode =? AND sn_type = ?",compcode,sn_type).first
    return msobj
end

private
def get_category_names(catcode)
    compcode =  session[:loggedUserCompCode]
    msobj    =  MstSewadarCategory.where("sc_compcode =? AND sc_catcode = ?",compcode,catcode).first
    return msobj
end

private
def get_leavemaster_detail(leavecode)
  compcode  =  session[:loggedUserCompCode]
  lesmstobj = MstLeave.where("attend_compcode = ? AND attend_leaveCode = ?",compcode,leavecode).first
  return lesmstobj
end

private
def get_leavemaster_bycategory(catcode,leavecode)
  compcode  =  session[:loggedUserCompCode]
  lesmstobj = MstLeave.where("attend_compcode = ? AND attend_category = ? AND attend_leaveCode = ?",compcode,catcode,leavecode).first
  return lesmstobj
end

private
def get_creditleave_detail(leavecode)
  compcode  = session[:loggedUserCompCode]
  lesmstobj = TrnCreditLeave.select("SUM(cl_creditdays) as credited").where("cl_compcode = ? AND cl_leavecode = ? AND YEAR(cl_creditdate)=YEAR(NOW())",compcode,leavecode).first
  return lesmstobj
end

private
def get_family_relation_detail(fid)
     compcode  = session[:loggedUserCompCode]
     sewdarobj =  MstSewdarKycFamilyDetail.where("skf_compcode = ? AND id = ?",compcode,fid).first
     return sewdarobj
end

private
def get_family_helathcalculation(sewacode,types)
     compcode  = session[:loggedUserCompCode]
     tcounts   = 0
     isselect  = "COUNT(*) as totalsmeb"
     iswhere   = ""
     if( types == 'D')
          iswhere   = "skf_compcode='#{compcode}'  AND skf_sewcode ='#{sewacode}' AND skf_optedpolicy='Y' AND LOWER(skf_relation) IN('daughter','son')"
     elsif  ( types == 'S')  
          iswhere   = "skf_compcode='#{compcode}'  AND skf_sewcode ='#{sewacode}' AND skf_optedpolicy='Y' AND LOWER(skf_relation) IN('spouse')" 
     elsif  ( types == 'P')  
           iswhere   = "skf_compcode='#{compcode}' AND skf_sewcode ='#{sewacode}' AND skf_optedpolicy='Y' AND LOWER(skf_relation) NOT IN('spouse','daughter','son')" 
     end
     if iswhere !=nil && iswhere !=''
         sewdarobj =  MstSewdarKycFamilyDetail.select(isselect).where(iswhere).first
         if sewdarobj
          tcounts = sewdarobj.totalsmeb
         end
     end
    return tcounts
  
end

private
def get_accomodation_type(leavecode)
  compcode  =  session[:loggedUserCompCode]
  lesmstobj = MstAccomodationType.where("at_compcode =? AND id = ?",@compcodes,leavecode).first
  return lesmstobj
end
private
def get_link_image(linkimage,dirs,unlinkimg)
      myimages = unlinkimg
      if linkimage !=nil && linkimage !=''
          chekpath = "#{Rails.root}/public/images/"+dirs.to_s+"/"+linkimage.to_s
          if File.file?(chekpath)
             myimages = "#{root_url}images/"+dirs.to_s+"/"+linkimage.to_s
          end
      end
      return myimages
end

private
def get_leave_taken(leavecode="",types)
   sewdarcode = session[:sec_sewdar_code]
   compcodes  = session[:loggedUserCompCode]
   tleaves = 0
   if types == 'TKN'
     leaveobj = TrnLeaveBalance.select("SUM(lb_closingbal) as totals,SUM(lb_openbal) as opbalances").where("lb_compcode = ? AND lb_empcode = ? AND lb_leavecode IN('EL','CL')",compcodes,sewdarcode,).first
   else
     leaveobj = TrnLeaveBalance.select("SUM(lb_closingbal) as totals,SUM(lb_openbal) as opbalances").where("lb_compcode = ? AND lb_empcode = ? AND lb_leavecode = ?",compcodes,sewdarcode,leavecode).first
   end
   if leaveobj
     tleaves = leaveobj.totals
   end
  return tleaves
end

def serial_global_number(lgth)
     chracters = ""
    for i in 1..lgth
        chracters +="0"
    end
    return chracters
    
end

private
def get_banking_detail_kyc_bankdetail(sewcode)
     compcode  =  session[:loggedUserCompCode]
     sewdarobj =  MstSewadarKycBank.where("skb_compcode =? AND sbk_sewcode =?",compcode,sewcode).first
     return sewdarobj
end

private
def get_shift_listed_detail(shcode)
  compcode  =  session[:loggedUserCompCode]
  lesmstobj = MstShift.where("attend_compcode = ? AND attend_shiftcode = ?",compcode,shcode).first
  return lesmstobj
end
private
def get_location_detail(lcid)
     compcode  = session[:loggedUserCompCode]
     unobj     = MstHeadOffice.where("hof_compcode = ? AND id = ?",compcode,lcid).first
     return unobj
end
private
def get_mysewdar_list_details(sewcodes)
  compcodes  = session[:loggedUserCompCode]
  sewdobj    = MstSewadar.where("sw_compcode =? AND sw_sewcode =?",compcodes,sewcodes).first
  return sewdobj
end
private
def get_global_sewadar_listed(sewcodes)
  compcodes  = session[:loggedUserCompCode]
  sewdobj    = MstSewadar.select("sw_sewadar_name,sw_image,sw_depcode,sw_oldsewdarcode").where("sw_compcode =? AND sw_sewcode =?",compcodes,sewcodes).first
  return sewdobj
end
private
def get_accomodation_types(id)
   compcodes  = session[:loggedUserCompCode]
   acoobjs    = MstAccomodationType.where("at_compcode =? AND id =?",compcodes,id).first
   return acoobjs
end

private
def get_accomodation_addresslisted(id)
   compcodes  = session[:loggedUserCompCode]
   acoobjs    = MstAccomodationDetail.where("ad_compcode =? AND id =?",compcodes,id).first
   return acoobjs
end
private
def get_office_global_data(empcode)
     compcode  = session[:loggedUserCompCode]
     sewdarobj =  MstSewadarOfficeInfo.where("so_compcode =? AND so_sewcode =?",compcode,empcode).first
     return sewdarobj
end
#### REFELECT BALANCE ############
private
   def process_deduction_balance(sewacode,month,year)
      compcodes = session[:loggedUserCompCode]
      iswhere   = "pma_compcode='#{compcodes}' AND pma_sewacode='#{sewacode}' AND pma_month ='#{month}' AND pma_year='#{year}'"
      sewobj    = TrnProcessMonthlyAdvance.where(iswhere)
      if sewobj.length >0
              sewobj.each do |newpms|
                  process_update_deductions(newpms.pma_sewacode,newpms.pma_requestno,newpms.pma_installment)
              end
      end

   end

  private
  def process_update_deductions(sewacode,requestno,installmentamt)
        compcodes   = session[:loggedUserCompCode]
        iswhere     = "al_compcode ='#{compcodes}' AND al_requesttype<>'Ex-gratia' AND al_sewadarcode ='#{sewacode}' AND al_requestno='#{requestno}' AND al_balances >0" 
        advobj      = TrnAdvanceLoan.where(iswhere).first
        if advobj
            dbbalanceamy   = advobj.al_balances            
            if installmentamt.to_f >dbbalanceamy.to_f
                 effectbalance  = dbbalanceamy.to_f
            else
                 effectbalance  = installmentamt.to_f
            end
            finalinstallment = dbbalanceamy.to_f-effectbalance.to_f 
            advobj.update(:al_balances=>finalinstallment)
        end
  end

#### END REFELECT BALANCE ############

private
def get_monthly_processed_salary_detail(sewacode)
   compcodes  = session[:loggedUserCompCode]
   arrsalary  = []
   isselect   = "pm_sewacode,pm_paymonth,pm_payyear,pm_monthday,pm_paidleave,pm_absent,pm_wo,pm_hl,pm_workingday,pm_paydays,pm_ded_repaidadvance,pm_ded_repaidloan"
   isselect   += ",'' as holdays,'' as monthdays,'' as weekoff,'' as myabsent,pm_areaprvmonths,pm_areaprvyears,pm_areardays,pm_arear,pm_fixarear"
   isselect   += ",pm_ded_licemployee,pm_ded_healthsewdarpay,pm_ded_electricamount,pm_dedaccomodatamount,pm_incometaxamount"
   isselect   += ",pm_allowancefirst,pm_allowanremarkfirst, pm_allowancesecond, pm_allowanceremksecond, pm_dedfirst,pm_totaltds"
   isselect   += ", pm_dedremarkfirst, pm_dedsecond, pm_dedremarksecond,pm_hold as myholds,pm_isposted,pm_arearremarks"
   years      = ""
   months     = ""
   hrsobj     = get_hr_parameters_head(compcodes)
   if hrsobj
     months       = hrsobj.hph_months
     years        = hrsobj.hph_years
   end
   if months.to_i >=4 
      genfinalyear = years.to_s+"-"+(years.to_i+1).to_s
   else
      genfinalyear = (years.to_i-1).to_s+"-"+years.to_s
   end 

   mthsobj    = TrnPayMonthly.select(isselect).where("pm_compcode =? AND pm_sewacode =? AND pm_paymonth =? AND pm_payyear =? AND pm_financialyear =?",compcodes,sewacode,months,years,genfinalyear).first
   if mthsobj
      monthsdays  = 0
      myweekoff   = 0
      myholidays  = 0
      periods     = 0
      paiddays    = 0
      wrokingdays = 0
      paileaves   = 0
      mymonths    = get_number_month_data(mthsobj.pm_paymonth)
     #  if mthsobj.pm_monthday.to_f <=0
     #    mthsobj.monthdays = monthsdays = get_total_days_of_month(mymonths,mthsobj.pm_payyear)
     #  else
     #    monthsdays        = mthsobj.pm_monthday
     #    mthsobj.monthdays = mthsobj.pm_monthday
     #  end
     monthsdays        = mthsobj.pm_monthday
     mthsobj.monthdays = mthsobj.pm_monthday

     #  if mthsobj.pm_wo.to_f <=0
     #     mthsobj.weekoff   = myweekoff = week_of_month(monthsdays,mthsobj.pm_payyear,mthsobj.pm_paymonth)
     #  else
     #     mthsobj.weekoff   = myweekoff = mthsobj.pm_wo
     #  end
     mthsobj.weekoff   = myweekoff = mthsobj.pm_wo
     #  if mthsobj.pm_hl.to_f <=0
     #     mthsobj.holdays   = myholidays = get_no_of_holidays(mymonths,mthsobj.pm_payyear)
     #  else
     #    mthsobj.holdays   = myholidays = mthsobj.pm_hl
     #  end
     mthsobj.holdays   = myholidays = mthsobj.pm_hl
     
     #  if  mthsobj.pm_paidleave.to_f <=0
     #      paileaves            =  get_apply_leave(sewacode,periods,mymonths,mthsobj.pm_payyear,mthsobj.pm_monthday)
     #      mthsobj.pm_paidleave =  paileaves
     # end
    # mthsobj.pm_paidleave =  paileaves
     # if mthsobj.pm_workingday.to_f <=0
     #      wrokingdays           = monthsdays.to_f-(myweekoff.to_f+myholidays.to_f+paileaves.to_f).to_f
     #      mthsobj.pm_workingday = wrokingdays
     # end
     #mthsobj.pm_workingday = wrokingdays
     

     # if mthsobj.pm_paydays.to_f <=0
     #      paiddays           = paileaves.to_f+wrokingdays.to_f+myweekoff.to_f+myholidays.to_f
     #      mthsobj.pm_paydays = paiddays
     # end
    # mthsobj.pm_paydays = paiddays

     #  if mthsobj.pm_absent.to_f <=0         
     #      myabsent         = monthsdays.to_f-paiddays.to_f
     #      mthsobj.myabsent = myabsent
     #  else
     #    mthsobj.myabsent = mthsobj.pm_absent
     #  end
     #mthsobj.myabsent = mthsobj.pm_absent
     if mthsobj.pm_absent.to_f <=0     
          if mthsobj.pm_isposted.to_s != 'Y' 
               paileaves        = mthsobj.pm_paidleave
               wrokingdays      = mthsobj.pm_workingday  
               paiddays         = paileaves.to_f+wrokingdays.to_f+myweekoff.to_f+myholidays.to_f 
               myabsent         = monthsdays.to_f-paiddays.to_f
               mthsobj.myabsent = myabsent
          end
     else
          mthsobj.myabsent =  mthsobj.pm_absent  
      end   
      arrsalary.push mthsobj
   end
   return arrsalary
end
 def week_of_month(mondays,years,months)
    noweeks = ((mondays.to_i + Date.new(years.to_i, months.to_i, 1).wday - 1) / 7) #(((30 + Date.new(2021, 11, 1).wday - 1) / 7) + 1)
    return noweeks
  end

 private
 def get_no_of_holidays(months,years,leftdate="")
       noholidays = 0
       compcodes  = session[:loggedUserCompCode]
       if leftdate !=nil && leftdate !=''
          iswhere = "compCode ='#{compcodes}' AND dateYear<>'' AND  MONTH(dateYear)='#{months}' AND YEAR(dateYear)='#{years}' AND DATE(dateYear)<=DATE('#{leftdate}')"
       else
          iswhere = "compCode ='#{compcodes}' AND dateYear<>'' AND  MONTH(dateYear)='#{months}' AND YEAR(dateYear)='#{years}'"
       end
       
       nodsobj = Holiday.where(iswhere)
       if nodsobj.length >0
           noholidays = nodsobj.length
       end
       return noholidays
 end

 private
 def get_previous_arear_month(compcodes,sewacode,months,years)
     isselect   = "pm_arear,pm_areardays,pm_areaprvmonths,pm_areaprvyears,pm_monthday"
     mthsobj    = TrnPayMonthly.select(isselect).where("pm_compcode =? AND pm_sewacode =? AND pm_areaprvmonths =? AND pm_areaprvyears =?",compcodes,sewacode,months,years).first
     return mthsobj
 end

 private
 def get_total_deduction_month(compcodes,sewacode,months,years)
     isselect   = "(SUM(pm_ded_repaidadvance)+SUM(pm_ded_repaidloan)) as totalpaid"
     mthsobj    = TrnPayMonthly.select(isselect).where("pm_compcode =? AND pm_sewacode =? AND pm_areaprvmonths =? AND pm_areaprvyears =?",compcodes,sewacode,months,years).first
     return mthsobj
 end
 
  private
  def page_linked
    return self.controller_name
  end

  private
  def _random_string_(len)
    charset = %w{ 2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
    newpasswor = (0...len).map{ charset.to_a[rand(charset.size)] }.join
    return newpasswor
  end

  private
  def get_singled_monthly_advance_detail(sewacode)
     compcodes   = session[:loggedUserCompCode]
     arrcalc     = []
     ### YEARS & MONTH FROM HR PARAMETERS####
          hrsobjx     = MstHrParameterHead.where("hph_compcode = ?",compcodes).first
          hrmonthx    = 0
          hryearx     = 0
          if hrsobjx
               hrmonthx = hrsobjx.hph_months
               hryearx  = hrsobjx.hph_years
          end
    ######## END YEARS & MONTH ######
     
     isselect   = "'' as pm_sewacode,'' as pm_paymonth,'' as pm_payyear,'' as pm_monthday,'' as pm_paidleave,'' as pm_absent,'' as pm_wo,'' as pm_hl,'' as pm_workingday,'' as pm_paydays,'' as pm_ded_repaidadvance,'' as pm_ded_repaidloan"
     isselect   += ",'' as holdays,'' as monthdays,'' as weekoff,'' as myabsent,'' as pm_areaprvmonths,'' as pm_areaprvyears,'' as pm_areardays,'' as pm_arear,'' as pm_fixarear"
     isselect   += ",'' as pm_ded_licemployee,'' as pm_ded_healthsewdarpay,'' as pm_ded_electricamount,'' as pm_dedaccomodatamount,'' as pm_incometaxamount"
     isselect   += ",'' as pm_allowancefirst,'' as pm_allowanremarkfirst,'' as pm_allowancesecond,'' as pm_allowanceremksecond,'' as pm_dedfirst"
     isselect   += ", '' as pm_dedremarkfirst,'' as pm_dedsecond,'' as pm_dedremarksecond,'' as pm_totaltds,'' as myholds,'' as pm_arearremarks"
     mthsobj    = MstSewadar.select(isselect).where("sw_compcode =? AND sw_sewcode =?",compcodes,sewacode).first
     if mthsobj
        monthsdays  = 0
        myweekoff   = 0
        myholidays  = 0
        wrokingdays = 0
        paiddays    = 0
        paileaves   = 0
        periods     = 0
        mymonths    = hrmonthx #get_number_month_data(hrmonthx)
          if mthsobj.pm_monthday.to_f <=0
             mthsobj.monthdays = monthsdays = get_total_days_of_month(mymonths,hryearx)        
          end 
          if mthsobj.pm_wo.to_f <=0         
            mthsobj.weekoff   = myweekoff = week_of_month(monthsdays,hryearx,mymonths)       
          end
          if mthsobj.pm_hl.to_f <=0
           mthsobj.holdays   = myholidays = get_no_of_holidays(mymonths,hryearx)        
          end
          if  mthsobj.pm_paidleave.to_f <=0
               paileaves            =  get_apply_leave(sewacode,periods,mymonths,hryearx,monthsdays)
               mthsobj.pm_paidleave =  paileaves
          end
          if mthsobj.pm_workingday.to_f <=0
               wrokingdays           = monthsdays.to_f-(myweekoff.to_f+myholidays.to_f+paileaves.to_f).to_f
               mthsobj.pm_workingday = wrokingdays
          end
          
          

          if mthsobj.pm_paydays.to_f <=0
               paiddays           = paileaves.to_f+wrokingdays.to_f+myweekoff.to_f+myholidays.to_f
               mthsobj.pm_paydays = paiddays
          end
          if mthsobj.pm_absent.to_f <=0            
               myabsent         = monthsdays.to_f-paiddays.to_f
               mthsobj.myabsent = myabsent       
          end        
          arrcalc.push mthsobj
     end
      return arrcalc
  end

  private
  def get_apply_leave(empcode,periods,months,years,days)
      compcodes  = session[:loggedUserCompCode]
      stardate   =  years.to_s+"-"+months.to_s+"-01"
      enddate    =  years.to_s+"-"+months.to_s+"-"+days.to_s

      iswhere    =  "ls_compcode ='#{compcodes}' AND ls_empcode ='#{empcode}'  AND ls_status='A' AND attend_paidleave='Y'"
      iswhere    += " AND (( ls_fromdate BETWEEN '#{stardate}' AND '#{enddate}') OR (ls_todate BETWEEN '#{stardate}' AND '#{enddate}') )"
     paidleave   = 0
     jons        = " LEFT JOIN mst_leaves mslv ON(ls_compcode = attend_compcode AND attend_leaveCode = ls_leave_code AND attend_category = ls_category)"
     isselect    = "trn_leaves.*,mslv.id as msId"
     sbsobj      =  TrnLeave.select(isselect).joins(jons).where(iswhere).order("ls_fromdate ASC")
     
     if sbsobj.length >0
          sbsobj.each do |newrecord|
                   fromdated  =  newrecord.ls_fromdate
                   enddated   =  newrecord.ls_todate
                   # cursordate = fromdated
                    startdy     = 0
                    if fromdated !=nil && fromdated !='' && enddated !=nil && enddated !=''
                    (fromdated).upto(enddated).each do |newdate|   
                                            
                         frmdate     = newdate+startdy                         
                         newfrmdated = year_month_days_formatted(frmdate)                         
                         if newfrmdated >=year_month_days_formatted(stardate) &&  newfrmdated <=year_month_days_formatted(enddate)                            
                              paidleave += 1
                              startdy +=1
                         end
                         
                    end

               end
          end
     end
     return paidleave
  end


  private
  def unpaid_apply_leave(empcode,periods,months,years,days)
      compcodes  = session[:loggedUserCompCode]
      stardate   =  years.to_s+"-"+months.to_s+"-01"
      enddate    =  years.to_s+"-"+months.to_s+"-"+days.to_s

      iswhere    =  "ls_compcode ='#{compcodes}' AND ls_empcode ='#{empcode}'  AND ls_status='A' AND attend_paidleave='N'"
      iswhere    += " AND (( ls_fromdate BETWEEN '#{stardate}' AND '#{enddate}') OR (ls_todate BETWEEN '#{stardate}' AND '#{enddate}') )"
     paidleave   = 0
     jons        = " LEFT JOIN mst_leaves mslv ON(ls_compcode = attend_compcode AND attend_leaveCode = ls_leave_code)"
     isselect    = "trn_leaves.*,mslv.id as msId"
     sbsobj      =  TrnLeave.select(isselect).joins(jons).where(iswhere)
     if sbsobj.length >0
          sbsobj.each do |newrecord|
                   fromdated  =  newrecord.ls_fromdate
                   enddated   =  newrecord.ls_todate
                   # cursordate = fromdated
                    startdy     = 0
                    if fromdated !=nil && fromdated !='' && enddated !=nil && enddated !=''
                    (fromdated).upto(enddated).each do |newdate|                       
                         frmdate     = newdate+startdy                         
                         newfrmdated = year_month_days_formatted(frmdate)                         
                         if newfrmdated >=stardate &&  newfrmdated <=enddate
                              paidleave +=1
                         end
                          
                    end

               end
          end
     end
     return paidleave
  end




   private
   def get_electrics_consumption_detail(sewacode,years,months)
     compcodes  = session[:loggedUserCompCode]
     electobj   = TrnElectricConsumption.where("ec_compcode =? AND ec_sewdarcode =? AND ec_readingyear=? AND ec_readingmonth =?",compcodes,sewacode,years,months).first
     return electobj
   end

   private
   def started_finacial_dated(reqdate)
     fndate     = ""
      month    = Date.parse(reqdate).strftime("%m")
      years1   = Date.parse(reqdate).strftime("%Y")
      if( month.to_i >=4 )
          ndate  = years1.to_s+"-04-01"
          edate  = (years1.to_i+1).to_s+"-03-31"

      else
          ndate  = (years1.to_i-1).to_s+"-04-01"
          edate  =  years1.to_s+"-03-31"
      end
      fndate     = ndate.to_s+"/"+edate.to_s
      return fndate
   end

  

   private
   def generate_start_financial_years(years)
      nyears   = years
      month    = Time.now.to_date.strftime("%m")
      if( month.to_i >= 1 && month.to_i <= 3 )
        years  = nyears.to_date.strftime("%Y")
      else
        years  = Time.now.to_date.strftime("%Y")
      end
      ndate  = years.to_s
      return ndate
   end

   private
   def genearate_last_financial_years(years)
      nyears   = years
      month    = Time.now.to_date.strftime("%m")
      if( month.to_i >= 1 && month.to_i <= 3 )
        years    = Time.now.to_date.strftime("%Y")
      else
        years    = nyears.to_date.strftime("%Y")
      end

      ndate    = years.to_s
      return ndate
   end

   private
   def get_finacial_years(reqdate)
     fndate     = ""
      month    = reqdate.strftime("%m")
      years1   = reqdate.strftime("%Y")
      if( month.to_i >=4 )
          ndate  = years1.to_s
          edate  = (years1.to_i+1)

      else
          ndate  = (years1.to_i-1)
          edate  =  years1.to_s
      end
      fndate     = ndate.to_s+"-"+edate.to_s
      return fndate
   end

   private
   def get_common_unversity_firstrecord(id)       
       iswhere       = "un_compcode ='#{@compCodes}' AND id = '#{id}'" #AND FIND_IN_SET('#{qualification.to_s.strip}',un_qltype) >0
       unobj         =  MstUniversity.where(iswhere).first      
       return unobj       
   end
   def get_hours_calculation(hrs,minute)
        newminute     =  hrs.to_i*60
        totalminuts   =  newminute.to_f+minute.to_f 
        newhrs        =  totalminuts.to_f/60
        splithours    =  newhrs.to_s.split(".")
        newcminuts    =  splithours[0].to_f*60
        finalminuts   =  totalminuts.to_f-newcminuts.to_f
        newtotaltime  =  splithours[0].to_s+"."+finalminuts.to_s
        newtotaltime  =  currency_formatted(newtotaltime)
        newtotaltime  =  newtotaltime.to_s.gsub(".",":")
        return newtotaltime
   end
   #####ATTENDANCE FUNCTIONS ##############
   private
def calc_time_mydiff(start_time, end_time)
      time = 0
      start_time = start_time != nil && start_time !=''  ? start_time : 0
      end_time   = end_time !=nil && end_time !='' ? end_time : 0
      if end_time.to_s !='0' && start_time.to_s !='0'
        difference = (end_time.to_time - start_time.to_time)
        seconds    =  difference % 60
        difference = (difference - seconds) / 60
        minutes    =  difference % 60
        difference = (difference - minutes) / 60
        hours      =  difference % 24
        hours      = hours.to_i
        minutes    = minutes.to_i
         # seconds = seconds_diff
         if minutes.to_i<10
           minutes = "0"+minutes.to_s
         end
        time = hours.to_s+":"+minutes.to_s
      end
  return time;
end
private
def calc_hours_diff(start_time)
      time = 0
      starttime = start_time != nil && start_time !=''  ? start_time.to_s.split(":") : 0
      hours = starttime[1]
       # seconds = seconds_diff
      time = hours

  return time;
end
private
 def get_calculated_hours_minute(times,type)
      fhrstime = 0
      if times != nil && times != ''
            vtms     = times.to_s.strip.split(":")
            nhrs     = vtms[0]
            nmnt     = vtms[1]
            if type == 'H'
               fhrstime =nhrs
            elsif type == 'M'
              fhrstime = nmnt
            end
      end
      return fhrstime
 end
 private
 def find_actual_hours_minuts(thrs,tmns)
     if tmns.to_f >59
       newmints = "%.2f" % (tmns.to_f/60)
    else
     newmints  = "."+tmns.to_s
    end
    if newmints.to_f <10
      newmints = "0"+newmints.to_s
     end
    newthrs    = "%.2f" % ( thrs.to_f+newmints.to_f).to_f
    cheknewhrs = newthrs ? newthrs.to_s.split(".") : 0
     if cheknewhrs && cheknewhrs[1].to_f >59
       newmints = "%.2f" % (cheknewhrs[1].to_f/60)
       if newmints.to_f <10
         newmints = "0"+newmints.to_s
        end
       newthrs    = "%.2f" % ( cheknewhrs[0].to_f+newmints.to_f).to_f
     end
    newthrs    = newthrs.gsub('.',':').to_s
    return newthrs
 end

 def get_days_name(months)
     monthsstr = ''
     if  months.to_s == "sun"
          monthsstr = "sunday"
     elsif  months.to_s == "mon"
          monthsstr = "monday"
     elsif  months.to_s == "tue"
           monthsstr  = "tuesday"     
     elsif  months.to_s == "wed"
          monthsstr = "wednesday"
     elsif  months.to_s == "thu"
          monthsstr = "thursday"
     elsif  months.to_s == "fri"
          monthsstr = "friday"
     elsif  months.to_s == "sat"
          monthsstr = "saturday"    
     end
     return monthsstr
   end
 ### END ATTENDANCE FUNCTION ###########
 private
 def generate_common_numbers(len)    
     nwmbers = ""
     nwmbers = rand(999999).to_s.center(6, rand(len).to_s).to_i
     return nwmbers
 end

 private
 def process_delete_left_employee(compcodes,months,years)
     leftdate    = years.to_s+"-"+months.to_s+"-01"
     jons        = "JOIN mst_sewadars swd ON(sw_compcode = pm_compcode AND sw_sewcode = pm_sewacode)"
     iswhere     = "pm_compcode='#{compcodes}' AND sw_leavingdate<>'0000-00-00' AND DATE(sw_leavingdate)<DATE('#{leftdate}') AND pm_payyear='#{years}' AND pm_paymonth='#{months}'"
     mthsobj     = TrnPayMonthly.joins(jons).where(iswhere)
     if mthsobj.length >0
         mthsobj.destroy_all
     end
     
 end

 private
 def get_request_type_listed(sewacode,months,years,requestno)
     compcodes   = session[:loggedUserCompCode]
     requesttype = ""
      iswhere    = "pma_compcode='#{compcodes}' AND pma_sewacode='#{sewacode}' AND pma_month ='#{months}' AND pma_year='#{years}'"
      isselect   = "(CASE  WHEN pma_type='Loan' then 'Advance upto 60k'
                    WHEN pma_type='Advance' then 'MA Advance' ELSE pma_type END) as trnstype,pma_requestno "
      sewobj     = TrnProcessMonthlyAdvance.select(isselect).where(iswhere).first

      if requestno !=nil && requestno !=''
              redates = ""
               reqdataob   = get_selected_advance_listing(sewacode,requestno)
               if reqdataob
                    redates   = reqdataob.al_requestdate  
                    reqtype   = reqdataob.al_requesttype 
                    if reqtype.to_s == 'Loan'
                         trnstype = "Advance upto 60k"
                    elsif reqtype.to_s == 'Advance'
                         trnstype = "MA Advance"    
                    else
                         trnstype = reqtype         
                    end
               end
               requesttype = trnstype.to_s+" ("+formatted_date(redates).to_s+" & "+requestno.to_s+")"
      else

          iswhere    = "pma_compcode='#{compcodes}' AND pma_sewacode='#{sewacode}' AND pma_month ='#{months}' AND pma_year='#{years}'"
          isselect   = "(CASE  WHEN pma_type='Loan' then 'Advance upto 60k'
                        WHEN pma_type='Advance' then 'MA Advance' ELSE pma_type END) as trnstype,pma_requestno "
          sewobj     = TrnProcessMonthlyAdvance.select(isselect).where(iswhere)

          if sewobj.length >0
               sewobj.each do |ndbs|
                    redates     = ""
                    requestno   = ""
                    reqdataob   = get_selected_advance_listing(sewacode,ndbs.pma_requestno)
                    if reqdataob
                         redates    = reqdataob.al_requestdate  
                         requestno  = reqdataob.al_requestno 
                         if reqtype.to_s == 'Loan'
                              trnstype = "Advance upto 60k"
                         elsif reqtype.to_s == 'Advance'
                              trnstype = "MA Advance"    
                         else
                              trnstype = reqtype         
                         end


                    end
                    requesttype += ndbs.trnstype.to_s+" ("+formatted_date(redates).to_s+" & "+ndbs.pma_requestno.to_s+"),"
                   
               end
               if requesttype !=nil && requesttype !=''
                    requesttype = requesttype.to_s.chop    
               end
          end
     end
     return requesttype
 end

 private
 def get_selected_sangam_range(compcodes,ntamts,years)
     iswhere = "bs_compcode='#{compcodes}' AND bs_years='#{years}' AND '#{ntamts}' BETWEEN bs_fromvalue AND bs_uptovalue"
     hrsobj = MstBakshishScale.where(iswhere).first
     return hrsobj

 end
 
 private
 def process_entire_execute(fromdated,uptodated)
     sql_connection = ActiveRecord::Base.connection
     delsql    = "DELETE FROM trn_temp_geo_locations WHERE `gc_date`>='#{fromdated}' AND `gc_date`<='#{uptodated}'"
     resultant = ActiveRecord::Base.connection.execute(delsql)
     myquery   = "INSERT INTO trn_temp_geo_locations SELECT * FROM `trn_geo_locations` WHERE `gc_date`>='#{fromdated}' AND `gc_date`<='#{uptodated}'"
     sql_connection.execute(myquery)
    
 end
 
end
