class LeaveCreditProcessController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted
  def index
        @compCodes         = session[:loggedUserCompCode]
        @nbegindate        = 2021
        @mydepartcode      = ''
        @HeadHrp           =  MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
        #process_update_co_request()
        #  process_leave_credit()
        #  return
  end

  def ajax_process

  end

  def create
    @compcodes   = session[:loggedUserCompCode]
    newmonth     = params[:hph_months] !=nil && params[:hph_months] !='' ? params[:hph_months] : ''
    newyears     = params[:hph_years] !=nil && params[:hph_years] !='' ? params[:hph_years] : ''
    xyears       = 0
    xmonths      = 0
    xnewdays     = 0
    clcounts     = 0
    elcounts     = 0
    arrcl        = []
    arrel        = []
    currentyears = Date.today.strftime("%Y")
    isFlags      = true
    mycounts     = 0
    if newyears.to_i<=0
        flash[:error] =  "Year is required."
        isFlags       =  false
    elsif newmonth.to_i <=0
        flash[:error] =  "Month is required."
        isFlags       =  false
    else

        #  process_credit_taken_balances()
        #  return
        
        numberdays =  get_total_days_of_month(newmonth,newyears)
        if newmonth.to_s.length<10
            newmonth = "0"+newmonth.to_s
        end
        allowflags = true
        levsobj    = MstCreditLeave.where("cls_compcode = ?",@compcodes).first
        processyears = currentyears
        if levsobj
            processyears = levsobj.cls_year
            if newyears.to_i<processyears.to_i && processyears.to_i >0
               
                allowflags     =  false 
                flash[:error] =  "Could not be processed..., It seems process already done."
                 isFlags       =  false
                 session[:isErrorhandled] = 1    
                 redirect_to "#{root_url}leave_credit_process"
                 return 
            elsif processyears.to_i == newyears.to_i && levsobj.cls_month.to_i == newmonth.to_i
               
               #flash[:error] =  "Could not be processed due to already done respected month and year."
               allowflags     =  false   
               flash[:error] =  "Could not be processed..., It seems process already done."+levsobj.cls_month.to_s
               isFlags       =  false  
               session[:isErrorhandled] = 1  
               redirect_to "#{root_url}leave_credit_process"
                 return           
            end
            
        end
          if isFlags  

                process_update_dated(newyears,newmonth)
                monthenddate   = newyears.to_s+"-"+newmonth.to_s+"-"+numberdays.to_s
                monthstartdate = newyears.to_s+"-"+newmonth.to_s+"-01"

                ###AND sw_sewcode='SD000294'
                iswhere        = "sw_compcode ='#{@compcodes}'  AND UPPER(sw_catcode)<>'VIV' AND sw_joiningdate<>'0000-00-00' AND DATE(sw_joiningdate)<'#{monthenddate}' AND ( DATE(sw_leavingdate) >'#{monthstartdate}' OR sw_leavingdate ='0000-00-00' ) " # AND sw_sewcode='SD000343' AND sw_sewcode='SD000480' #AND sw_sewcode='SD000284'
                sewobj         =  MstSewadar.where(iswhere).order("sw_sewcode")
                if sewobj.length >0
              
                    ### FOR CL ONLY ######
                            if allowflags
                               
                                sewobj.each do |newemp|
                                  
                                          levmstobj = get_leavemaster_bycategory(newemp.sw_catcode,'CL')
                                           if levmstobj
                                            ########CHECK YEARS FOR CL################
                                                clobj = called_between_days(newemp.sw_joiningdate,Date.today,0) 
                                                if clobj !=nil && clobj !=''
                                                    xmyparams = clobj.to_s.split("-")  
                                                    xyears    =  xmyparams[0]   
                                                    xmonths   =  xmyparams[1]
                                                    xnewdays  =  xmyparams[2] 
                                                end
                                            ######## END CHECK YEAR FOR CL############

                                                creditrule = levmstobj.attend_creditrule
                                                allowdays  = levmstobj.attend_accumulationleave 
                                                carrfwd    = levmstobj.attend_balanceforprevious
                                                totalsewa  = levmstobj.attend_totalsewarequired
                                                #######CHECK COMPLETING ONE YEARS OR SIX MONTH BY LEAVE RULES
                                                    if xyears.to_i == totalsewa.to_i 
                                                        arrcl.push newemp.sw_catcode 
                                                    end
                                                ###### END COMPLETING ONE YEARS OR SIX MONTH BY LEAVE RULES

                                                if  levmstobj.attend_leaveCode.to_s == 'CL' && xyears.to_i >= totalsewa.to_i  
                                                  
                                                        if creditrule == 'Y' ## FOR YEARLY
                                                           if newmonth.to_i == 12 &&  processyears.to_i >= newyears.to_i  
                                                                creditdate = (newyears.to_i+1).to_s+"-01-01"                                            
                                                                vmycounts   = process_cl_credits(newemp.sw_sewcode,levmstobj.attend_leaveCode,levmstobj.attend_creditruledays,creditdate)
                                                                mycounts +=vmycounts.to_i    
                                                                clcounts += 1                                                                                                                        
                                                                process_update_leave(newemp.sw_sewcode,levmstobj.attend_leaveCode,levmstobj.attend_creditruledays,allowdays,carrfwd,newemp.sw_catcode,newemp.sw_depcode,newmonth,newyears)
                                                           end
                                                        end   
                                                end   
                                            
                                          
                                            end    
                                    end
                            end         
                              
                    
                    ## BREk lopp for CL

                    ######### EL PROCESS #########
                    if allowflags
                            sewobj.each do |newemp|
                                    nelvsobj = get_leavemaster_bycategory(newemp.sw_catcode,'EL')
                                    if nelvsobj
                                            ########CHECK YEARS FOR EL################
                                            clobj = called_between_days(newemp.sw_joiningdate,Date.today,0) 
                                            if clobj !=nil && clobj !=''
                                                xmyparams = clobj.to_s.split("-")  
                                                xyears    =  xmyparams[0]   
                                                xmonths   =  xmyparams[1]
                                                xnewdays  =  xmyparams[2] 
                                            end
                                        ######## END CHECK YEAR FOR EL############    
                                            creditrule = nelvsobj.attend_creditrule                                    
                                            allowdays  = nelvsobj.attend_accumulationleave 
                                            carrfwd    = nelvsobj.attend_balanceforprevious
                                            totalsewa  = nelvsobj.attend_totalsewarequired
                                             #######CHECK COMPLETING ONE YEARS OR SIX MONTH BY LEAVE RULES
                                             if xyears.to_i == totalsewa.to_i 
                                                arrel.push newemp.sw_catcode 
                                            end
                                            ###### END COMPLETING ONE YEARS OR SIX MONTH BY LEAVE RULES


                                            if  nelvsobj.attend_leaveCode.to_s == 'EL' && xyears.to_i >= totalsewa.to_i

                                                if creditrule == 'Y' || creditrule == 'H'  ## FOR YEARLY & HALF YEARLY

                                                    if newmonth.to_i >= 12 &&  processyears.to_i >= newyears.to_i 
                                                            totaleaves   = get_total_counts(newemp.sw_sewcode,newmonth,newyears) #FOR LWM
                                                            if newemp.sw_catcode == 'SDP'
                                                                totaleaves = totaleaves.to_f >0 ? totaleaves.to_f/18 : 0
                                                            else
                                                                totaleaves = totaleaves.to_f >0 ? totaleaves.to_f/24 : 0    
                                                            end
                                                              totaleaves   = totaleaves.to_f.round(0)
                                                              ###CREDIT DAYS FOR TEMPRORY AND ASSOCIAT A
                                                              mycreditdays =  nelvsobj.attend_creditruledays                                                             
                                                              ###################END HERE #############

                                                            lewleaves    =  mycreditdays.to_f-totaleaves.to_f #nelvsobj.attend_creditruledays.to_f
                                                            creditdate   = (newyears.to_i+1).to_s+"-01-01" 
                                                            
                                                            vmycounts   = process_cl_credits(newemp.sw_sewcode,nelvsobj.attend_leaveCode,lewleaves,creditdate)
                                                            process_update_leave(newemp.sw_sewcode,nelvsobj.attend_leaveCode,lewleaves,allowdays,carrfwd,newemp.sw_catcode,newemp.sw_depcode,newmonth,newyears)
                                                            mycounts +=vmycounts.to_i
                                                            elcounts += 1
                                                    elsif newmonth.to_i == 6 &&  processyears.to_i >= newyears.to_i 
                                                            totaleaves   = get_total_counts(newemp.sw_sewcode,newmonth,newyears) #FOR LWM
                                                            if newemp.sw_catcode == 'SDP'
                                                                totaleaves = totaleaves.to_f >0 ? totaleaves.to_f/18 : 0
                                                            else
                                                                totaleaves = totaleaves.to_f >0 ? totaleaves.to_f/24 : 0    
                                                            end
                                                            ###CREDIT DAYS FOR TEMPRORY AND ASSOCIAT A
                                                             mycreditdays = nelvsobj.attend_creditruledays                                                            
                                                             ###################END HERE #############
                                                            totaleaves   = totaleaves.to_f.round(0)
                                                            lewleaves    = mycreditdays.to_f-totaleaves.to_f
                                                            creditdate   = newyears.to_s+"-07-01"                                                             
                                                            vmycounts    = process_cl_credits(newemp.sw_sewcode,nelvsobj.attend_leaveCode,lewleaves,creditdate)
                                                            process_update_leave(newemp.sw_sewcode,nelvsobj.attend_leaveCode,lewleaves,allowdays,carrfwd,newemp.sw_catcode,newemp.sw_depcode,newmonth,newyears)
                                                            mycounts +=vmycounts.to_i 
                                                            elcounts += 1   
                                                        end
                                                
                                                end
                                            end    
                                    end
                            end 
                    end   


                    ###### END EL PROCESS ###########

                     ####### SHORT LEAVE(SL) PROCESS ########
                     if newmonth.to_i >0 && newyears.to_i >0 && processyears.to_i >= newyears.to_i
                    
                        sewobj.each do |newemp|
                        
                                nelvsobj = get_leavemaster_bycategory(newemp.sw_catcode,'SL')
                                if nelvsobj
                               
                                    creditrule = nelvsobj.attend_creditrule                                    
                                    allowdays  = nelvsobj.attend_accumulationleave 
                                    carrfwd    = nelvsobj.attend_balanceforprevious
                                    vmycounts  = process_update_leave(newemp.sw_sewcode,'SL',nelvsobj.attend_creditruledays,allowdays,carrfwd,newemp.sw_catcode,newemp.sw_depcode,newmonth,newyears)
                                    mycounts   +=vmycounts.to_i   
                                end
                        end
                    end
                    #### END SHORT LEAVE PROCESS ########    
                    ########## UPDATE LEAVE BALANCES ###########
                   
                       if( clcounts.to_i >0 || elcounts.to_i >0 )                                         
                            sewobj.each do |newemp| ### PROCESS FOR FINAL BALANCES
                                if clcounts.to_i >=0
                                   process_update_final_balances(newemp.sw_sewcode,'CL',newmonth,newyears)
                                end
                                if elcounts.to_i >0
                                    process_update_final_balances(newemp.sw_sewcode,'EL',newmonth,newyears)
                                end                                
                                #process_update_final_balances(newemp.sw_sewcode,'SL',newmonth,newyears)
                            end

                       end

                    ########## LEAVE UPDATE BALANCES#########

                    
                     


                end
            end  
    end

    if mycounts.to_i >0
        flash[:error] =  "Leave credited Successfully."
        isFlags       =  true    
    else
        flash[:error] =  "Could not be processed..."
        isFlags       =  false        
    end
     if !isFlags
           session[:isErrorhandled] = 1    
      else
            session[:isErrorhandled] = nil
            session[:postedpamams]   = nil
            isFlags = true
      end
      redirect_to "#{root_url}leave_credit_process"
end


########CHECK PROCESS OF LEVAE #############
 ######FOR CL
def process_cl_credits(sewacode,leavecode,creditdays,creditdate)
    @compcodes   = session[:loggedUserCompCode]
    mycounts     = 0
    iswhere      = "cl_compcode ='#{@compcodes}' AND cl_creditdate='#{creditdate}' AND cl_leavecode='#{leavecode}' AND cl_sewacode='#{sewacode}'"
    checkexist   = TrnCreditLeave.where(iswhere)
    if checkexist.length >0
        ### NO UPDATE IS REQUIRED
        mycounts +=1; 
    else
        lvsobj       = TrnCreditLeave.new(:cl_compcode=>@compcodes,:cl_leavecode=>leavecode,:cl_sewacode=>sewacode,:cl_creditdays=>creditdays,:cl_creditdate=>creditdate)
        if lvsobj.save        
            mycounts +=1;    
        end
    end
    return mycounts
end
def process_update_dated(years,months)
    @compcodes   = session[:loggedUserCompCode]
    levsobj      = MstCreditLeave.where("cls_compcode = ?",@compcodes).first ####,years,months
    if levsobj
         levsobj.update(:cls_year=>years,:cls_month=>months)
    else
        lvsobj = MstCreditLeave.new(:cls_compcode=>@compcodes,:cls_year=>years,:cls_month=>months)
        if lvsobj.save
            ### execute message if required
        end
    end

end

########## END PROCESS LEAVE ############
def get_total_counts(sewacode,months,years)
    @compcodes     = session[:loggedUserCompCode]
    totaleaves     = 0
    fromcdated     = ""
    uptodate       = ""
    if months.to_i == 6            
         fromcdated = years.to_s+"-01-01"
         uptodate   = years.to_s+"-06-30"
    elsif months.to_i == 12         
         fromcdated = years.to_s+"-07-01"
         uptodate   = years.to_s+"-12-31"
    end

    iswhere   = "ls_compcode ='#{@compcodes}' AND ls_empcode ='#{sewacode}' AND ls_status NOT IN('C','R','D') AND ls_leave_code ='LWM'"
    iswhere   += " AND ls_fromdate >='#{year_month_days_formatted(fromcdated)}' AND ls_todate<='#{year_month_days_formatted(uptodate)}'"
    isselect  = "SUM(ls_nodays) as totalleave"
    leavaobj  = TrnLeave.select(isselect).where(iswhere).first
    if leavaobj
         totaleaves = leavaobj.totalleave
    end
    return totaleaves
end

def process_update_final_balances(sewacode,leavecode,months,years)
    @compcodes  = session[:loggedUserCompCode]
    totoalob    = get_opening_blances(sewacode,leavecode)
    credittotal = get_credits_leave_counts(sewacode,leavecode,months,years)
    takentotal  = get_taken_leave_counts(sewacode,leavecode,months,years)
    difftotels  = (totoalob.to_f+credittotal.to_f).to_f-takentotal.to_f
    iswhere     = "lb_compcode ='#{@compcodes}' AND lb_empcode ='#{sewacode}' AND lb_leavecode ='#{leavecode}'"
    leavsobj    = TrnLeaveBalance.where(iswhere).first
    if leavsobj
        leavsobj.update(:lb_closingbal=>difftotels)
    end 

end

def get_opening_blances(sewacode,leavecode)
    @compcodes  = session[:loggedUserCompCode]
    totalob     = 0
    iswhere     = "lb_compcode ='#{@compcodes}' AND lb_empcode ='#{sewacode}' AND lb_leavecode ='#{leavecode}'"
    leavsobj    = TrnLeaveBalance.select("lb_openbal").where(iswhere).first
    if leavsobj
        totalob = leavsobj.lb_openbal
    end
    return totalob
end

def process_maiantinance_balances(sewacode,leavecode,months,years,processtrue)
    @compcodes  = session[:loggedUserCompCode]
    totoalob    = get_opening_blances(sewacode,leavecode)
    credittotal = get_credits_leave_counts(sewacode,leavecode,months,years,processtrue)
    takentotal  = get_taken_leave_counts(sewacode,leavecode,months,years,processtrue)
    difftotels  = ( totoalob.to_f+credittotal.to_f).to_f-takentotal.to_f
    iswhere     = "lb_compcode ='#{@compcodes}' AND lb_empcode ='#{sewacode}' AND lb_leavecode ='#{leavecode}'"
    leavsobj    = TrnLeaveBalance.where(iswhere).first
    if leavsobj
        leavsobj.update(:lb_closingbal=>difftotels)
    end 

end

def get_taken_leave_counts(sewacode,leavecode,months,years,processupdates="")
    @compcodes     = session[:loggedUserCompCode]
    totaleaves     = 0
    if processupdates =='Y'
        fromcdated     = ""
        uptodate       = ""
        if months.to_i == 6            
            fromcdated = years.to_s+"-01-01"
            uptodate   = years.to_s+"-06-30"
        elsif months.to_i == 12         
            fromcdated = years.to_s+"-07-01"
            uptodate   = years.to_s+"-12-31"
        end
        iswhere    = "ls_compcode ='#{@compcodes}' AND ls_empcode ='#{sewacode}' AND UPPER(ls_status) NOT IN('C','R','D') AND ls_leave_code ='#{leavecode}'"
        iswhere   += " AND ls_todate<='#{year_month_days_formatted(uptodate)}'"
    else
        iswhere   = "ls_compcode ='#{@compcodes}' AND ls_empcode ='#{sewacode}' AND UPPER(ls_status) NOT IN('C','R','D') AND ls_leave_code ='#{leavecode}'"

    end
     isselect  = "SUM(ls_nodays) as totalleave"
    leavaobj  = TrnLeave.select(isselect).where(iswhere).first
    if leavaobj
         totaleaves = leavaobj.totalleave
    end
    return totaleaves
end

def get_credits_leave_counts(sewacode,leavecode,months,years,processupdates="")
    @compcodes     = session[:loggedUserCompCode]
    totaleaves     = 0
    if processupdates.to_s == 'Y'
       fromcdated     = ""
        uptodate       = ""
        if months.to_i == 6            
            fromcdated = years.to_s+"-01-01"
            uptodate   = years.to_s+"-06-30"
        elsif months.to_i == 12         
            fromcdated = years.to_s+"-07-01"
            uptodate   = years.to_s+"-12-31"
        end
       # uptodate   = "2023-01-01" #FOR ONLY CORRECTION BALANCES CB
        iswhere    = "cl_compcode ='#{@compcodes}' AND cl_creditdate<='#{year_month_days_formatted(uptodate)}' AND cl_sewacode ='#{sewacode}' AND cl_leavecode ='#{leavecode}'"
    else
        iswhere   = "cl_compcode ='#{@compcodes}' AND cl_sewacode ='#{sewacode}' AND cl_leavecode ='#{leavecode}'"
    end
    isselect  = "SUM(cl_creditdays) as totalleave"
    leavaobj  = TrnCreditLeave.select(isselect).where(iswhere).first
    if leavaobj
         totaleaves = leavaobj.totalleave
    end
    return totaleaves
end

def process_update_leave(empcode,leavecode,numdays,allowdays,carrfwd,catcode,deptcode,months,years)
       @compcodes     = session[:loggedUserCompCode]
       mycounts       = 0
       iswhere        = "lb_compcode ='#{@compcodes}' AND lb_empcode ='#{empcode}' AND lb_leavecode ='#{leavecode}'"
        leavsobj = TrnLeaveBalance.where(iswhere).first
        if leavsobj
            newblances = leavsobj.lb_closingbal.to_f+numdays.to_f
            remainbal  = leavsobj.lb_closingbal
            obbalance  = get_opening_blances(empcode,leavecode) 
                if carrfwd.to_s == 'Y'
                    difftotels  = 0
                    credittotal = 0
                    if months.to_i == 12
                            credittotal = get_credits_leave_counts(empcode,leavecode,months,years,'Y')
                            takentotal  = get_taken_leave_counts(empcode,leavecode,months,years,'Y')
                            difftotels  = credittotal.to_f-takentotal.to_f                     
                            cheknewrefbal = obbalance.to_f+difftotels.to_f
                            if obbalance.to_f>allowdays.to_f && allowdays.to_f >0 
                                   if difftotels.to_f >0                                          
                                        newblances = (obbalance.to_f+numdays.to_f).to_f-difftotels.to_f
                                        leavsobj.update(:lb_closingbal=>newblances)
                                        process_update_forfeit(empcode,leavecode,catcode,deptcode,difftotels,months,years) 
                                   else
                                        leavsobj.update(:lb_closingbal=>newblances)                                     
                                   end
                                    mycounts +=1
                            else
                                    if cheknewrefbal.to_f >allowdays.to_f && allowdays.to_f >0 
                                        newblances = (cheknewrefbal.to_f+numdays.to_f).to_f-allowdays.to_f
                                        forefietval = cheknewrefbal.to_f-allowdays.to_f
                                        leavsobj.update(:lb_closingbal=>newblances)
                                        process_update_forfeit(empcode,leavecode,catcode,deptcode,forefietval,months,years) 
                                        mycounts +=1
                                    else
                                        leavsobj.update(:lb_closingbal=>newblances) 
                                        mycounts +=1
                                    end
                            end    
                    else
                           leavsobj.update(:lb_closingbal=>newblances)  
                           mycounts +=1
                    end
                    
                    # if newblances.to_f>allowdays.to_f && allowdays.to_f >0
                    #      ### no update is required 
                    # else
                        
                    # end

                else
                        leavsobj.update(:lb_closingbal=>newblances)                    
                        if remainbal.to_f >0
                            process_update_forfeit(empcode,leavecode,catcode,deptcode,remainbal,months,years) 
                            mycounts +=1
                        end
                end
        else
                svsobj  = TrnLeaveBalance.new(:lb_compcode=>@compcodes,:lb_empcode=>empcode,:lb_leavecode=>leavecode,:lb_openbal=>0,:lb_closingbal=>numdays,:lb_cfbalance=>0,:lb_year=>years) 
                if svsobj.save
                        ### execute message if required
                        mycounts +=1
                end
                 
            
        end
        return  mycounts
end
########PROCESS UPDATE FORFEIT ###########
def process_update_forfeit(empcode,leavecode,catcode,deptcode,blancedays,months,years)
    @compcodes     = session[:loggedUserCompCode]
    fromcdated     = 0
    uptodate       = 0
    if months.to_i == 6            
         fromcdated = years.to_s+"-06-30"
         uptodate   = years.to_s+"-06-30"
    elsif months.to_i == 12         
         fromcdated = years.to_s+"-12-31"
         uptodate   = years.to_s+"-12-31"
    end
    iswhere    = "ls_compcode='#{@compcodes}' AND ls_empcode='#{empcode}' AND ls_leave_code='#{leavecode}' AND ls_fromdate='#{fromcdated}' AND ls_todate='#{uptodate}'"
    checkitem  = TrnLeave.where(iswhere)
    if checkitem.length >0
        ### no update is required.
    else
        leavaobj   = TrnLeave.new(:ls_compcode=>@compcodes,:ls_nodays=>blancedays,:ls_empcode=>empcode,:ls_depcode=>deptcode,:ls_fromdate=>fromcdated,:ls_todate=>uptodate,:ls_leave_code=>leavecode,:ls_remainleave=>0,:ls_leavereson=>'Forfeit',:ls_number=>0,:ls_approved_by=>'',:ls_approve_date=>fromcdated,:ls_status=>'A',:ls_avail=>'',:ls_period=>'',:ls_category=>catcode)
        if leavaobj.save
            ## execute message if required
        end
   end
end

def process_credit_taken_balances
    @compcodes     = session[:loggedUserCompCode]    
    newmonth       = params[:hph_months] !=nil && params[:hph_months] !='' ? params[:hph_months] : ''
    newyears       = params[:hph_years] !=nil && params[:hph_years] !='' ? params[:hph_years] : ''
    numberdays     = get_total_days_of_month(newmonth,newyears)
    monthenddate   = newyears.to_s+"-"+newmonth.to_s+"-"+numberdays.to_s
    monthstartdate = newyears.to_s+"-"+newmonth.to_s+"-01"
    
    iswhere        = "sw_compcode ='#{@compcodes}' AND UPPER(sw_catcode)<>'VIV' AND sw_joiningdate<>'0000-00-00' AND DATE(sw_joiningdate)<'#{monthenddate}' AND ( DATE(sw_leavingdate) >'#{monthstartdate}' OR sw_leavingdate ='0000-00-00' ) " #AND sw_sewcode='SD000480' #AND sw_sewcode='SD000284'
    sewobj         =  MstSewadar.where(iswhere).order("sw_sewcode")
    if sewobj.length >0
        sewobj.each do |newemp|
            process_maiantinance_balances(newemp.sw_sewcode,'CL',newmonth,newyears,'Y')
            process_maiantinance_balances(newemp.sw_sewcode,'EL',newmonth,newyears,'Y')
            process_maiantinance_balances(newemp.sw_sewcode,'SL',newmonth,newyears,'Y')

        end
    end 
    redirect_to "#{root_url}leave_credit_process"  
end

def process_update_co_request
    @compcodes     = session[:loggedUserCompCode]
    leaveobj  = TrnRequestCoOd.select("SUM(ls_nodays) as totaldays,ls_empcode").where("ls_compcode = ? AND UPPER(ls_status) NOT IN('C','R','D') AND UPPER(ls_leave_code)='CO'",@compcodes).group("ls_empcode")
    if leaveobj.length >0
        leaveobj.each do |newleavs|
            apllyreq = newleavs.totaldays
            takenlv  =  get_all_taken_leave(newleavs.ls_empcode)
            leavbal  = apllyreq.to_f-takenlv.to_f
            save_process_attendance(@compcodes,newleavs.ls_empcode,'CO',0,leavbal)
        end
    end
end

def get_all_taken_leave(empcode)
    @compcodes = session[:loggedUserCompCode]
    tleaves    = 0
    leavtkeobj =  TrnLeave.select("SUM(ls_nodays) as coleave").where("ls_compcode=? AND ls_empcode=? AND UPPER(ls_leave_code)='CO' AND UPPER(ls_status) NOT IN('C','R','D')",@compcodes,empcode).first
    if leavtkeobj
        tleaves = leavtkeobj.coleave
    end
    return tleaves
end
private
def save_process_attendance(compcode,empcode,leavecode,years,leavbal)
   leavobj = TrnLeaveBalance.where("lb_compcode = ? AND lb_empcode = ? AND lb_leavecode = ? ",compcode,empcode,leavecode).first
   if leavobj
         ###########NO REFLECTION#########
   else    
        lvobj = TrnLeaveBalance.new(:lb_compcode=>compcode,:lb_closingbal=>leavbal,:lb_empcode=>empcode,:lb_leavecode=>leavecode,:lb_year=>0)
        if lvobj.save
          ####
        end
   end
end
####### END HERE ###########

##### LEAVE CORRECTION ###########
def process_leave_credit
    @compcodes     = session[:loggedUserCompCode]
    dated          = Date.today
    #AND sw_sewcode='SD000294' 
    iswhere        = "sw_compcode ='#{@compcodes}' AND UPPER(sw_catcode)<>'VIV' AND sw_joiningdate<>'0000-00-00' " # AND sw_sewcode='SD000343' AND sw_sewcode='SD000480' #AND sw_sewcode='SD000284'
    sewobj         =  MstSewadar.where(iswhere).order("sw_sewcode")   
    if sewobj.length >0
            sewobj.each do |newseadar|
                #nelvsobj = get_leavemaster_bycategory(newemp.sw_catcode,'EL') 
                process_leave_correction_balances(newseadar.sw_sewcode,'CL',dated)
                process_leave_correction_balances(newseadar.sw_sewcode,'EL',dated)
                # nelvsobj   = get_leavemaster_bycategory(newseadar.sw_catcode,'SL')
                # if nelvsobj
                #     process_leave_correction_balances(newseadar.sw_sewcode,'SL',dated,nelvsobj.attend_creditruledays)                    
                # end           
            end
    end
end


def get_taken_leave_correction(sewacode,leavecode,frmdated)
    @compcodes  = session[:loggedUserCompCode]
    totaleaves  = 0
    iswhere     =  "ls_compcode ='#{@compcodes}' AND ls_empcode ='#{sewacode}' AND UPPER(ls_status) NOT IN('C','R','D') AND ls_leave_code ='#{leavecode}'"
    iswhere     += " AND ls_todate<='#{year_month_days_formatted(frmdated)}'"
   # iswhere     += " AND YEAR(ls_todate)<='2022' AND YEAR(ls_fromdate)<='2022'" ### FOR 
    #iswhere      += " AND YEAR(ls_todate)='2023' AND YEAR(ls_fromdate)='2023' AND MONTH(ls_fromdate)=2" ### FOR 
    isselect    =  "SUM(ls_nodays) as totalleave"
    leavaobj    =  TrnLeave.select(isselect).where(iswhere).first
    if leavaobj
         totaleaves = leavaobj.totalleave
    end
    return totaleaves
end

def get_credits_leave_correction(sewacode,leavecode,frmdated)
    @compcodes  = session[:loggedUserCompCode]
    totaleaves  = 0
    iswhere     = "cl_compcode ='#{@compcodes}' AND cl_creditdate<='#{year_month_days_formatted(frmdated)}' AND cl_sewacode ='#{sewacode}' AND cl_leavecode ='#{leavecode}'"
    isselect    = "SUM(cl_creditdays) as totalleave"
    leavaobj    = TrnCreditLeave.select(isselect).where(iswhere).first
    if leavaobj
         totaleaves = leavaobj.totalleave
    end
    return totaleaves
end
def process_leave_correction_balances(sewacode,leavecode,dated,numdays=0)
    @compcodes  = session[:loggedUserCompCode]
    totoalob    = get_opening_blances(sewacode,leavecode)
    takentotal  = get_taken_leave_correction(sewacode,leavecode,dated)
    if( numdays.to_f >0 )
        credittotal = numdays
        difftotels  = ( credittotal.to_f).to_f#-takentotal.to_f
    else
        credittotal = get_credits_leave_correction(sewacode,leavecode,dated)
        difftotels  = ( totoalob.to_f+credittotal.to_f).to_f-takentotal.to_f
    end   
    
    iswhere     = "lb_compcode ='#{@compcodes}' AND lb_empcode ='#{sewacode}' AND lb_leavecode ='#{leavecode}'"
    leavsobj    = TrnLeaveBalance.where(iswhere).first
    if leavsobj
        leavsobj.update(:lb_closingbal=>difftotels)
    end 

end

###### LEAVE END ########## 


end
