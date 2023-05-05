class CalculateSalaryController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:search,:ledger_list,:ajax_process]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted
  helper_method :format_oblig_date,:get_accomodation_type,:get_month_listed_data
  def index
    @compcodes         = session[:loggedUserCompCode]
    @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compcodes).order("departDescription ASC")
    @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compcodes).order("sc_position ASC")
    @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compcodes).first
    @HrMonths          = nil
    @Hryears           = nil
    if @HeadHrp
      @HrMonths = @HeadHrp.hph_months
      @Hryears  = @HeadHrp.hph_years
    end
  end
  def create
    
  end
  def ajax_process
         @compcodes       = session[:loggedUserCompCode]
         if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
            process_salary_caluclation();
            return         
         end
  end

  private
  def get_advance_balances(sewacode,month,year)
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

   ####REVERESE SAME MONTH DEDUCTION #########
   private
   def get_reverse_loan_advance(sewacode,month,year)
     compcodes = session[:loggedUserCompCode]
     total     = 0
     iswhere   = "pma_compcode='#{compcodes}' AND pma_sewacode='#{sewacode}' AND pma_month='#{month}' AND pma_year='#{year}'"
     isselect  = "pma_installment,pma_sewacode,pma_requestno"
     sewobj    = TrnProcessMonthlyAdvance.select(isselect).where(iswhere).group("pma_requestno")
     if sewobj.length >0
          sewobj.each do |newadvance|
            reverse_closing_balance_advance(compcodes,newadvance.pma_sewacode,newadvance.pma_requestno,newadvance.pma_installment)
          end
      end
       return total
   end

   private
   def reverse_closing_balance_advance(compcodes,sewacode,reqnumber,amount)
    iswhere    = "al_compcode ='#{compcodes}' AND al_sewadarcode ='#{sewacode}' AND al_requesttype<>'Ex-gratia' AND al_requestno ='#{reqnumber}'"  
    advobj     = TrnAdvanceLoan.where(iswhere).first
     if advobj
          newbalnces =   advobj.al_balances.to_f+amount.to_f    
          advobj.update(:al_balances=>newbalnces)
     end

   end


   ######## END REVERSE DEDUCTION LISTED ##########

  private
  def get_advance_salary_advance(sewacode,months,years)
    monthdays   = get_total_days_of_month(months,years)
    newreqdate  = years.to_s+"-"+months.to_s+"-"+monthdays.to_s
    if months.to_i >0
      newmonths   = months.to_i-1
      if months.to_i == 1
         bakyear     = years.to_i-1
        startdated   = bakyear.to_s+"-"+newmonths.to_s+"-26"
      else
         startdated  = years.to_s+"-"+newmonths.to_s+"-26"
      end      
         endated     = years.to_s+"-"+months.to_s+"-25"
    end
    

    compcodes   = session[:loggedUserCompCode]
    iswhere     = "al_compcode ='#{compcodes}' AND ( al_openingdata ='Y' OR al_broucherno<>'' ) AND al_sewadarcode ='#{sewacode}' AND al_balances>0 AND al_requesttype<>'Ex-gratia' AND DATE(al_requestdate)<=DATE('#{endated}')"  
    isselect    = "al_requestdate,al_requesttype,al_sewadarcode,al_balances,al_requesttype,al_requestno,(al_advanceamt+al_loanamount) as totalamount,al_installpermonth" 
     advobj     = TrnAdvanceLoan.select(isselect).where(iswhere).order("al_sewadarcode asc")
      if advobj.length >0
            advobj.each do |newlst|
                totalamount = 0
                if newlst.al_installpermonth.to_f >0
                      if newlst.al_installpermonth.to_f >newlst.al_balances.to_f                  
                          totalamount = newlst.al_balances.to_f
                      else
                          totalamount = newlst.al_installpermonth.to_f
                      end
                else
                    #if type ma davence and reequest date>= start daetr and rquest date < = end date then
                    if newlst.al_requesttype.to_s.downcase =='advance' ### MA ADAVNCE ONLY
                          if year_month_days_formatted(newlst.al_requestdate) >=year_month_days_formatted(startdated) && year_month_days_formatted(newlst.al_requestdate) <=year_month_days_formatted(endated)
                            totalamount = newlst.totalamount.to_f
                          end
                    else
                          totalamount = newlst.totalamount.to_f
                    end
                     
               end
                # if newlst.al_requesttype.to_s.downcase =='loan' || newlst.al_requesttype.to_s =='Advance Above 60k' ### MA ADAVANCE UPTO 60 K
                #     if newlst.al_installpermonth.to_f >newlst.al_balances.to_f
                #        totalamount = newlst.al_balances.to_f
                #     else
                #        totalamount = newlst.al_installpermonth.to_f
                #     end
                   
                # else
                #    totalamount = newlst.totalamount                  
                # end             
                process_save_monhly_data(compcodes,newlst.al_sewadarcode,newlst.al_requesttype,newlst.al_requestno,months,years,totalamount)
            end
      end

  end

  private
  def process_save_monhly_data(compcode,sewacode,type,requestno,months,years,installment)
    iswhere   = "pma_compcode ='#{compcode}' AND pma_sewacode ='#{sewacode}' AND pma_month ='#{months}' AND pma_requestno='#{requestno}' AND pma_year = YEAR(NOW())"
     delsobj = TrnProcessMonthlyAdvance.where(iswhere).first
     if delsobj
        delsobj.destroy
     end
    sewobj = TrnProcessMonthlyAdvance.new(:pma_compcode=>compcode,:pma_sewacode=>sewacode,:pma_requestno=>requestno,:pma_month=>months,:pma_year=>years,:pma_type=>type,:pma_installment=>installment)
    sewobj.save
  end

  private
  def process_salary_caluclation
       departcode    = params[:departcode] !=nil && params[:departcode] !='' ? params[:departcode] : ''
       sewacode      = params[:sewacode] !=nil && params[:sewacode] !='' ? params[:sewacode] : ''
       sewacategory  = params[:sewacategory] !=nil && params[:sewacategory] !='' ? params[:sewacategory] : ''
       allowparams   = params[:allowparams] !=nil && params[:allowparams] !='' ? params[:allowparams] : ''
        isflags      = false
        message      = ""
        numberdays   = 0
        newmonth     = ""
        newyears     = ""
        hrsobj       = get_hr_parameters_head(@compcodes)
        if hrsobj
           numberdays = get_total_days_of_month(hrsobj.hph_months,0) ### total days in month
           newmonth     = hrsobj.hph_months
           newyears     = hrsobj.hph_years
        end
        monthenddate   = newyears.to_s+"-"+newmonth.to_s+"-"+numberdays.to_s
        monthstartdate = newyears.to_s+"-"+newmonth.to_s+"-01"
       ApplicationRecord.transaction do
        begin
           iswhere = "sw_compcode ='#{@compcodes}' AND UPPER(sw_catcode)<>'VIV' AND sw_joiningdate<>'0000-00-00' AND DATE(sw_joiningdate)<'#{monthenddate}' AND ( DATE(sw_leavingdate) >'#{monthstartdate}' OR sw_leavingdate ='0000-00-00')"
           if departcode !=nil && departcode !=''
             iswhere += " AND sw_depcode ='#{departcode}'"
           end
           if sewacode !=nil && sewacode !=''
             iswhere += " AND sw_sewcode ='#{sewacode}'"
           end
           if sewacategory !=nil && sewacategory !=''
             iswhere += " AND sw_catgeory ='#{sewacategory}'"
           end
            sewobj =  MstSewadar.where(iswhere).order("sw_sewcode")
            if sewobj.length >0
                sewobj.each do |processalary|
                  bannames    = ''
                  bankaccount = ''
                  bankobjs    = get_banking_detail_kyc_bankdetail(processalary.sw_sewcode)
                  if bankobjs
                      bannames    = bankobjs.skb_bank
                      bankaccount = bankobjs.skb_accountno
                  end
                  calculate_slary_part(@compcodes,processalary.sw_sewcode,processalary.sw_outstandingamt,processalary.sw_loanamount,numberdays,processalary.sw_isaccommodation,processalary.sw_accomodationtype,processalary.sw_accomodexemption,processalary.sw_joiningdate,processalary.sw_leavingdate,allowparams,processalary.sw_depcode,processalary.sw_catcode,processalary.sw_desigcode,bannames,bankaccount)
                end
                if newmonth !=nil && newmonth !='' && newyears !=nil && newyears !=''
                   process_delete_left_employee(@compcodes,newmonth,newyears)
                end
                
                isflags = true
                message ="Salary calculation completed successfully."
            else
                message ="No record(s) found for process salary calculation."
            end
            rescue Exception => exc
                message        = "#{exc.message}"
                isflags        = false
                raise ActiveRecord::Rollback
            end
       end
       respond_to do |format|
        format.json { render :json => { 'data'=>'', "message"=>message,:status=>isflags} }
       end
  end

  private
  def calculate_slary_part(compcode,sewacode,advanceamt,loaamount,numberdays,isaccomodation,accmodationid,accomoexempted,joiningdate,leavingdate,allowparams,department,category,desigcode,bankname,bankaccount)
        #processalary.sw_depcode,processalary.sw_catcode,processalary.sw_desigcode,bannames,bankaccount
        paiddays    = 0
        basicma     = 0
        months      = ""
        years       = 0
        actualma    = 0
        healthyn    = ""
        licgrpyn    = ""
        netconsunt  = 0
        consumlimit = 0
        elecamount  = 0
        consrates   = 0
        allotmentno  = ""
        accomodatval = 0
        accomtype    = 0
        licmandalamt = 0
        licsewamount = 0
        helthslab    = 0
        healthslbamt    = 0
        healthmandpay   = 0
        healthmansewpay = 0
        taxdeductlmt    = 0
        taxpercents     = 0
        taxcalamounts   = 0
        totalallownce   = 0
        arrearmonths    = 0
        arrearyears     = 0
        prevarears      = 0
        slabsecond      = 0
        slabfirst       = 0
        slabthird       = 0
        myyears         = 0
        mymonths        = ''
        applaccomodrate = 0
       
        officeobj       = get_office_list_detail(compcode,sewacode)
        if officeobj
              basicma   = officeobj.so_basic
              healthyn  = officeobj.so_healthinsurance
              licgrpyn  = officeobj.so_licgroup
              helthslab = officeobj.so_healthslab
              
        end
        hrsobj      = get_hr_parameters_head(compcode)
        if hrsobj
            consumlimit      = hrsobj.hph_consumption
            months           = hrsobj.hph_months
            years            = hrsobj.hph_years
            slabfirst        = hrsobj.hph_suminsured
            slabsecond       = hrsobj.hph_policyslabtwo_sumins
            slabthird        = hrsobj.hph_policythree_sumins
            taxdeductlmt     = hrsobj.hph_deductedlimited
            taxpercents      = hrsobj.hph_incometaxpercent
            applaccomodrate  = hrsobj.hph_aplicablema
            myyears          = years
            mymonths         = months
           if licgrpyn.to_s == 'Y'
              licmandalamt = hrsobj.hph_mandalpay
              licsewamount = hrsobj.hph_sewapay
           end
            if healthyn.to_s == 'Y'
                if slabfirst.to_i == helthslab.to_i
                    healthslbamt     =  slabfirst
                    healthmandpay    =  hrsobj.hph_policymandalpay
                    healthmansewpay  =  hrsobj.hph_policysewapay
                    healthdpedentpay =  hrsobj.hph_dependent
                    healthparentpay  =  hrsobj.hph_parent

                elsif slabsecond.to_i == helthslab.to_i
                    healthslbamt     =  slabsecond
                    healthmandpay    =  hrsobj.hph_policytwo_mandalpay
                    healthmansewpay  =  hrsobj.hph_policytwo_sewapay
                    healthdpedentpay =  hrsobj.hph_dependentsec
                    healthparentpay  =  hrsobj.hph_parenetsec
                elsif slabthird.to_i == helthslab.to_i
                    healthslbamt     =  slabthird
                    healthmandpay    =  hrsobj.hph_policythree_mandalpay
                    healthmansewpay  =  hrsobj.hph_policythree_sewpay
                    healthdpedentpay =  hrsobj.hph_dependentthird
                    healthparentpay  =  hrsobj.hph_parenthird
                end
           end
        end

        
        ########CALCULATE HEALTH ACCORDING HR PARAMETERS###########
          totaldepend   = get_family_helathcalculation(sewacode,'D')
          totalspouse   = get_family_helathcalculation(sewacode,'S')
          totalparent   = get_family_helathcalculation(sewacode,'P') 

          totalspouseval    = (totalspouse.to_i+1).to_f*healthmansewpay.to_f
          totaldependentval = totaldepend.to_f*healthdpedentpay.to_f
          totalparentvalue  = totalparent.to_f*healthparentpay.to_f
          totalsumofvalue   = totalspouseval.to_f+totaldependentval.to_f+totalparentvalue.to_f
          totalmandanvalue  = totalsumofvalue.to_f*2
          healthmansewpay   = currency_formatted(totalsumofvalue)
          healthmandpay     = currency_formatted(totalmandanvalue)
          
        ########### END CALCULATE HEALTH ACCORDING HR PARAMETERS########

        pdlsobj         = get_sewadar_monthly_list(compcode,sewacode,myyears,mymonths)
######## CALCULATE DAILY WAGES #############
      monthsdays  = 0
      myweekoff   = 0
      myholidays  = 0
      periods     = 0
      paiddays    = 0
      wrokingdays = 0
      paileaves   = 0
      unpaidleave = 0  
      
      ###########MONTH DAYS DATA ##########
      mypm_monthday   = 0
      mypm_wo         = 0
      mypm_hl         = 0
      mypm_paidleave  = 0
      mypm_workingday = 0
      mypm_paydays    = 0
      mypm_absent     = 0
      my_pm_unpaidleave = 0 
      pm_isposted       = ""
      if pdlsobj 
        mypm_monthday     = pdlsobj.pm_monthday
        mypm_wo           = pdlsobj.pm_wo
        mypm_hl           = pdlsobj.pm_hl
        mypm_paidleave    = pdlsobj.pm_paidleave
        mypm_workingday   = pdlsobj.pm_workingday
        mypm_paydays      = pdlsobj.pm_paydays
        mypm_absent       = pdlsobj.pm_absent
        pm_isposted       = pdlsobj.pm_isposted
        my_pm_unpaidleave = pdlsobj.pm_unpaidleave
      end
      ##### END MONTH DAYS #########
     # mymonths    = get_number_month_data(mymonths)
     monthsdays  = get_total_days_of_month(mymonths,myyears) 
     
    
      ###########CALCULATE JOING DAYS & LEAVING DAYS DIFFERENCE IN CURRENT MONTH
      joiningdates = joiningdate !=nil && joiningdate !='' ? joiningdate.to_s.split("-") : ''
      leavingdates = leavingdate !=nil && leavingdate !=''  ? leavingdate.to_s.split("-") : ''
      #myyears      = years
      #mymonths     = months
      if joiningdates && joiningdates[1].to_i == mymonths.to_i && joiningdates[0].to_i == myyears.to_i        
          jndays = joiningdates[2] ? (joiningdates[2].to_i-1).to_i : 0 
          #die("#{jndays}")
      end
      if leavingdates && leavingdates[1].to_i == mymonths.to_i && leavingdates[0].to_i == myyears.to_i
          slvdays  = leavingdates[2] ? leavingdates[2]  : 0 
          lvdays   = monthsdays.to_i-slvdays.to_i
          leftdate = slvdays
      else
           leftdate =   monthsdays
      end
      myweekoff      = week_of_month(leftdate,myyears,mymonths)
      myholidays     = get_no_of_holidays(mymonths,myyears,leavingdate)
      
      ########## END PROCESS ##############

      paileaves              = get_apply_leave(sewacode,periods,mymonths,myyears,monthsdays)
      unpaidleave            = unpaid_apply_leave(sewacode,periods,mymonths,myyears,monthsdays)
      
      if mypm_workingday.to_f <=0
        wrokingdays            = monthsdays.to_f-(myweekoff.to_f+myholidays.to_f+paileaves.to_f+jndays.to_f+lvdays.to_f).to_f
      else
        wrokingdays            = mypm_workingday
      end       
      paiddays               = (paileaves.to_f+wrokingdays.to_f+myweekoff.to_f+myholidays.to_f).to_f#-(jndays.to_f+lvdays.to_f).to_f 
       ### Calculate absent days ###
       myabsent  = monthsdays.to_f-(paiddays.to_f+unpaidleave.to_f+jndays.to_f+lvdays.to_f).to_f
       ### CKECK POSTING DATA
       if pm_isposted.to_s == 'Y'
            myweekoff     = mypm_wo
            myholidays    = mypm_hl
            paiddays      = mypm_paydays
            myabsent      = mypm_absent
            wrokingdays   = mypm_workingday
            paileaves     = mypm_paidleave
            unpaidleave   = my_pm_unpaidleave
            numberdays    = mypm_monthday
            monthsdays    = mypm_monthday
       end
       if myabsent.to_i >30 ##3 change if absent month is greater than 30
          myabsent = 30
       end
       ### END POSTING DATA ########
            ## end absent calculate######
######## END CALCULATE WAGES ##################
        
        
        if pdlsobj            
             arrearmonths    = pdlsobj.pm_areaprvmonths
             arrearyears     = pdlsobj.pm_areaprvyears
        end        
                
        monthdays   = monthsdays #get_total_days_of_month(mymonths,myyears)
        newmonthstr = get_month_listed_data(mymonths)
        ##atualma    = (basicma.to_f/monthdays.to_f).to_f*abs.to_f  ### ABSENT+LWM 
        newabsentval = (basicma.to_f/monthdays.to_f).to_f
        newabsentval = newabsentval.to_f.round(2)
        actualma     = basicma.to_f-(newabsentval*myabsent.to_f).to_f     
        elctobj      = get_electric_consumption(compcode,sewacode,myyears,newmonthstr)

        # isaccomodation,accmodationid,accomoexempted
        if isaccomodation.to_s == 'Y' 
          
                if accomoexempted.to_s != 'Y'
                 
                    if accmodationid.to_i >0
                      
                          acchrprmobj = get_accomodation_parmvalues(compcode,accmodationid)
                          if acchrprmobj
                          
                              range1 = acchrprmobj.hpa_value
                              range2 = acchrprmobj.hpa_rates
                              if basicma.to_f >applaccomodrate.to_f
                                accomodatval = range2
                              else
                                accomodatval = range1
                              end
                              
                              
                          end
                    end

                else
                   accomodatval = 0
                end
          else
                accomodatval = 0
          end

        # alomobj    = get_allotment_detail(compcode,sewacode)
        # if alomobj
        #   allotmentno  = alomobj.aa_alotmentno
        #   accoaddress  = alomobj.aa_address
        #   if accoaddress.to_i >0
        #      accoobs = get_accomodation_addresslisted(accoaddress)
        #       if accoobs
        #         accomtype = accoobs.ad_accomodtype
        #       end
        #   end
        #       if accomtype.to_i >0
        #           acchrprmobj = get_accomodation_parmvalues(compcode,accomtype)
        #           if acchrprmobj
        #               accomodatval = acchrprmobj.hpa_value
        #           end
        #       end
        # end
        ###### CALCULATE ARREAR ###
          sonlsobjs = get_previous_arear_month(compcode,sewacode,arrearmonths,arrearyears)
          if sonlsobjs
             areardays    = sonlsobjs.pm_areardays
             armonthdays  = sonlsobjs.pm_monthday
             if areardays.to_i >0
                  prevarears   = (basicma.to_f/armonthdays.to_f).to_f*areardays.to_f
             end

          end
        ### END ARREAR ######
        if elctobj
            netconsunt  = elctobj.ec_totalunit
            previousval = 0
            elecamount1 = 0
            totalamts   = 0
            unitobj     = get_electrics_consumption_detail(sewacode,myyears,newmonthstr)
            if unitobj
              elecamount = unitobj.ec_totalamount

			  #  unitobj.each do |newclc|
				# 	consratesfirst  = newclc.hpr_rate1
				# 	consrateseccond = newclc.hpr_rate2
				# 	if netconsunt.to_f >consumlimit.to_f
				# 		consrates = consrateseccond
				# 	else
				# 	    consrates = consratesfirst
				# 	end	
				# 	rangefrom      = newclc.hpr_rangefrom
				# 	rangeupto      = newclc.hpr_rangeto	
				# 	diffunits      = rangeupto.to_f-previousval.to_f
				# 	elecamount1    = consrates.to_f*diffunits.to_f
				# 	totalamts      += elecamount1.to_f
				# 	previousval     = rangeupto.to_f
			  #  end	  
				#  elecamount = totalamts
			end		
			
				
				# unitobj    = get_hr_unit_rate(compcode,netconsunt)
				# if unitobj
				#        consratesfirst  = unitobj.hpr_rate1
				#        consrateseccond = unitobj.hpr_rate2
				#        if netconsunt.to_f >consumlimit.to_f
				#            consrates = consrateseccond
				#        else
				#           consrates = consratesfirst
				#        end
				#       elecamount = netconsunt.to_f*consrates.to_f
				# end
        end

        ### TAX CALCULATION ####        
        # if actualma.to_f >taxdeductlmt.to_f
        #   taxcalamounts = (actualma.to_f*taxpercents.to_f)/100
        # end
        taxcalamounts = 0 #currency_formatted(taxcalamounts)
        ## END TAX CALCUALTION ##
        ### CALCULATE DEDUCTION #####

        ### CHECK ALREADY DEDCUTED WHILE AGAIN PROCESS SALARY ###
          get_reverse_loan_advance(sewacode,mymonths,myyears)      
        ############CALCULATE & SALARY ADAVNCE LOADING #########        
          get_advance_salary_advance(sewacode,mymonths,myyears)  
          totaladvance  =   get_advance_balances(sewacode,mymonths,myyears)
          process_deduction_balance(sewacode,mymonths,myyears)
        ############ END CALCULATE& SALARY ADVANCE #############
        advanceamts  = totaladvance !=nil && totaladvance != '' ? totaladvance : 0
        elecamount   = elecamount.to_f.round
        loaamount    = 0
        totaldeduct = advanceamts.to_f+loaamount.to_f+elecamount.to_f+accomodatval.to_f+licsewamount.to_f+healthmansewpay.to_f #+taxcalamounts.to_f
        netpaymount = (actualma.to_f+totalallownce.to_f).to_f-totaldeduct.to_f
          # if paiddays.to_i <=0
          #   actualma = 0
          #   basicma = 0
          #   myabsent = 30
          # end
        ### DEDUCTION LIIMIT##3
        
        process_update_salary(compcode,sewacode,paiddays,actualma,basicma,advanceamts,loaamount,netconsunt,elecamount,accomtype,allotmentno,accomodatval,licmandalamt,licsewamount,healthslbamt,healthmandpay,healthmansewpay,taxpercents,taxcalamounts,totalallownce,totaldeduct,netpaymount,myabsent,numberdays,prevarears,myyears,mymonths,myholidays,wrokingdays,paileaves,myweekoff,unpaidleave,totalspouseval,totaldependentval,totalparentvalue,department,category,desigcode,bankname,bankaccount)
  end
 
  private
  def process_update_salary(compcode,sewacode,paiddays,actualma,basicma,advanceamt,loaamount,electunit,electamount,accomtype,allotmentno,accomodatval,licmandalamt,licsewamount,healthslbamt,healthmandpay,healthmansewpay,taxpercents,taxcalamounts,totalallownce,totaldeduct,netpaymount,myabsent,numberdays,prevarears,myyears,mymonths,myholidays,wrokingdays,paileaves,myweekoff,unpaidleave,totalspouseval,totaldependentval,totalparentvalue,department,category,desigcode,bankname,bankaccount)
    if mymonths.to_i >=4 
      genfinalyear = myyears.to_s+"-"+(myyears.to_i+1).to_s
    else
      genfinalyear = (myyears.to_i-1).to_s+"-"+myyears.to_s
    end  
    
    
       mobjs  = TrnPayMonthly.where("pm_compcode = ? AND pm_sewacode = ? AND pm_paymonth =? AND pm_payyear =? AND pm_financialyear =?",compcode,sewacode,mymonths,myyears,genfinalyear).first
       if mobjs
        newtotaldeduct =  mobjs.pm_totaltds.to_f+totaldeduct.to_f+mobjs.pm_dedfirst.to_f+mobjs.pm_dedsecond.to_f
        netamounts     =  (netpaymount.to_f+mobjs.pm_allowancefirst.to_f+mobjs.pm_allowancesecond.to_f+mobjs.pm_fixarear.to_f).to_f-(mobjs.pm_dedfirst.to_f+mobjs.pm_dedsecond.to_f+mobjs.pm_totaltds.to_f).to_f
        netpaymount    =  netamounts.to_f.round(2)
        mobjs.update(:pm_hl=>myholidays,:pm_workingday=>wrokingdays,:pm_paidleave=>paileaves,:pm_wo=>myweekoff,:pm_paymonth=>mymonths,:pm_payyear=>myyears,:pm_paydays=>paiddays,:pm_basic=>actualma,:pm_actbasic=>basicma,:pm_ded_repaidadvance=>advanceamt,:pm_ded_repaidloan=>loaamount,:pm_ded_electricunit=>electunit,:pm_ded_electricamount=>electamount ,:pm_dedaccomodatype=>accomtype,:pm_dedaccomodationno=>allotmentno,:pm_dedaccomodatamount=>accomodatval,:pm_licemployer=>licmandalamt,:pm_ded_licemployee=>licsewamount,:pm_ded_healthslab=>healthslbamt,:pm_ded_healthmandalpay=>healthmandpay,:pm_ded_healthsewdarpay=>healthmansewpay,:pm_ded_incometaxpercent=>taxpercents,:pm_incometaxamount=>taxcalamounts,:pm_totalallowance=>totalallownce,:pm_totaldeduction=>newtotaldeduct,:pm_netpay=>netpaymount,:pm_absent=>myabsent,:pm_monthday=>numberdays,:pm_arear=>prevarears,:pm_financialyear=>genfinalyear,:pm_unpaidleave=>unpaidleave,:pm_sewadar_n_spouse=>totalspouseval,:pm_healthdependent=>totaldependentval,:pm_healthparent=>totalparentvalue,:pm_department=>department,:pm_category=>category,:pm_descode=>desigcode,:pm_bankname=>bankname,:pm_bankaccountno=>bankaccount)
       else
           netpaymount      =  netpaymount.to_f.round(2)
            #newtotaldeduct =  mobjs.pm_totaltds.to_f+totaldeduct.to_f+mobjs.pm_dedfirst.to_f+mobjs.pm_dedsecond.to_f
            strobjs        = TrnPayMonthly.new(:pm_compcode=>compcode,:pm_hl=>myholidays,:pm_workingday=>wrokingdays,:pm_paidleave=>paileaves,:pm_wo=>myweekoff,:pm_sewacode=>sewacode,:pm_paymonth=>mymonths,:pm_payyear=>myyears,:pm_paydays=>paiddays,:pm_basic=>actualma,:pm_actbasic=>basicma,:pm_ded_repaidadvance=>advanceamt,:pm_ded_repaidloan=>loaamount,:pm_ded_electricunit=>electunit,:pm_ded_electricamount=>electamount ,:pm_dedaccomodatype=>accomtype,:pm_dedaccomodationno=>allotmentno,:pm_dedaccomodatamount=>accomodatval,:pm_licemployer=>licmandalamt,:pm_ded_licemployee=>licsewamount,:pm_ded_healthslab=>healthslbamt,:pm_ded_healthmandalpay=>healthmandpay,:pm_ded_healthsewdarpay=>healthmansewpay,:pm_ded_incometaxpercent=>taxpercents,:pm_incometaxamount=>taxcalamounts,:pm_totalallowance=>totalallownce,:pm_totaldeduction=>totaldeduct,:pm_netpay=>netpaymount,:pm_absent=>myabsent,:pm_monthday=>numberdays,:pm_arear=>prevarears,:pm_financialyear=>genfinalyear,:pm_unpaidleave=>unpaidleave,:pm_sewadar_n_spouse=>totalspouseval,:pm_healthdependent=>totaldependentval,:pm_healthparent=>totalparentvalue,:pm_department=>department,:pm_category=>category,:pm_descode=>desigcode,:pm_bankname=>bankname,:pm_bankaccountno=>bankaccount)
            strobjs.save
          end
  end
  
end
