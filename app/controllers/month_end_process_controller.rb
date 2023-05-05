class MonthEndProcessController < ApplicationController
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
  def process_salary_caluclation
       departcode    = params[:departcode] !=nil && params[:departcode] !='' ? params[:departcode] : ''
       sewacode      = params[:sewacode] !=nil && params[:sewacode] !='' ? params[:sewacode] : ''
       sewacategory  = params[:sewacategory] !=nil && params[:sewacategory] !='' ? params[:sewacategory] : ''
        isflags      = false
        message      = ""
        numberdays   = 0
        hrsobj      = get_hr_parameters_head(@compcodes)
        if hrsobj
           numberdays = get_total_days_of_month(hrsobj.hph_months,0)
        end
       ApplicationRecord.transaction do
        begin
           iswhere = "sw_compcode ='#{@compcodes}' AND sw_joiningdate<>'0000-00-00' AND DAY(sw_joiningdate)<'#{numberdays}' AND ( DAY(sw_leavingdate) >'1' OR sw_leavingdate ='0000-00-00')"
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
                 calculate_slary_part(@compcodes,processalary.sw_sewcode,processalary.sw_outstandingamt,processalary.sw_loanamount,numberdays)
               end
               isflags = true
               message ="Salary calculation completed successfuly."
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
  def calculate_slary_part(compcode,sewacode,advanceamt,loaamount,numberdays)
        
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
        pdlsobj      = get_sewadar_monthly_list(compcode,sewacode)
        officeobj    = get_office_list_detail(compcode,sewacode)
        if officeobj
              basicma   = officeobj.so_basic
              healthyn  = officeobj.so_healthinsurance
              licgrpyn  = officeobj.so_licgroup
              helthslab = officeobj.so_healthslab
        end
        hrsobj      = get_hr_parameters_head(compcode)
        if hrsobj
            consumlimit  = hrsobj.hph_consumption
            months       = hrsobj.hph_months
            years        = hrsobj.hph_years
            slabfirst    = hrsobj.hph_suminsured
            slabsecond   = hrsobj.hph_policyslabtwo_sumins
            slabthird    = hrsobj.hph_policythree_sumins
            taxdeductlmt = hrsobj.hph_deductedlimited
            taxpercents  = hrsobj.hph_incometaxpercent
          
           if licgrpyn.to_s == 'Y'
              licmandalamt = hrsobj.hph_mandalpay
              licsewamount = hrsobj.hph_sewapay
           end
           if healthyn.to_s == 'Y'
              if slabfirst.to_i == helthslab.to_i
                  healthslbamt    = slabfirst
                  healthmandpay   = hrsobj.hph_policymandalpay
                  healthmansewpay = hrsobj.hph_policysewapay
              elsif slabsecond.to_i == helthslab.to_i
                  healthslbamt    = slabsecond
                  healthmandpay   = hrsobj.hph_policytwo_mandalpay
                  healthmansewpay = hrsobj.hph_policytwo_sewapay
              elsif slabthird.to_i == helthslab.to_i
                  healthslbamt    = slabthird
                  healthmandpay   = hrsobj.hph_policythree_mandalpay
                  healthmansewpay = hrsobj.hph_policythree_sewpay
              end
           end
        end
        
        if pdlsobj
             paiddays        = pdlsobj.pm_paidleave.to_f+pdlsobj.pm_workingday.to_f+pdlsobj.pm_wo.to_f+pdlsobj.pm_hl.to_f
             arrearmonths    = pdlsobj.pm_areaprvmonths
             arrearyears     = pdlsobj.pm_areaprvyears
        end
        ### Calculate absent days ###
         myabsent =  numberdays.to_f-paiddays.to_f

       ## end absent calculate######
        
        monthdays   = get_total_days_of_month(months,years)
        newmonthstr = get_month_listed_data(months)
        actualma   = (basicma.to_f/monthdays.to_f).to_f*paiddays.to_f
        elctobj    = get_electric_consumption(compcode,sewacode,years,newmonthstr)
        alomobj    = get_allotment_detail(compcode,sewacode)
        if alomobj
          allotmentno  = alomobj.aa_alotmentno
          accoaddress  = alomobj.aa_address
          if accoaddress.to_i >0
             accoobs = get_accomodation_addresslisted(accoaddress)
              if accoobs
                accomtype = accoobs.ad_accomodtype
              end
          end
              if accomtype.to_i >0
                  acchrprmobj = get_accomodation_parmvalues(compcode,accomtype)
                  if acchrprmobj
                      accomodatval = acchrprmobj.hpa_value
                  end
              end
        end
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
			if unitobj.length >0
			   unitobj.each do |newclc|
					consratesfirst  = newclc.hpr_rate1
					consrateseccond = newclc.hpr_rate2
					if netconsunt.to_f >consumlimit.to_f
						consrates = consrateseccond
					else
					    consrates = consratesfirst
					end	
					rangefrom      = newclc.hpr_rangefrom
					rangeupto      = newclc.hpr_rangeto	
					diffunits      = rangeupto.to_f-previousval.to_f
					elecamount1    = consrates.to_f*diffunits.to_f
					totalamts      += elecamount1.to_f
					previousval     = rangeupto.to_f
			   end	  
				 elecamount = totalamts
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
        if actualma.to_f >taxdeductlmt.to_f
          taxcalamounts = (actualma.to_f*taxpercents.to_f)/100
        end
        taxcalamounts = currency_formatted(taxcalamounts)
        ## END TAX CALCUALTION ##
        ### CALCULATE DEDUCTION #####
        totaldeduct = advanceamt.to_f+loaamount.to_f+elecamount.to_f+accomodatval.to_f+licsewamount.to_f+healthmansewpay.to_f+taxcalamounts.to_f
        netpaymount = (actualma.to_f+totalallownce.to_f).to_f-totaldeduct.to_f

        ### DEDUCTION LIIMIT##3
        process_update_salary(compcode,sewacode,paiddays,actualma,basicma,advanceamt,loaamount,netconsunt,elecamount,accomtype,allotmentno,accomodatval,licmandalamt,licsewamount,healthslbamt,healthmandpay,healthmansewpay,taxpercents,taxcalamounts,totalallownce,totaldeduct,netpaymount,myabsent,numberdays,prevarears)
  end
  private
  def process_update_salary(compcode,sewacode,paiddays,actualma,basicma,advanceamt,loaamount,electunit,electamount,accomtype,allotmentno,accomodatval,licmandalamt,licsewamount,healthslbamt,healthmandpay,healthmansewpay,taxpercents,taxcalamounts,totalallownce,totaldeduct,netpaymount,myabsent,numberdays,prevarears)
       mobjs  = TrnPayMonthly.where("pm_compcode = ? AND pm_sewacode = ?",compcode,sewacode).first
       if mobjs
           mobjs.update(:pm_paydays=>paiddays,:pm_basic=>actualma,:pm_actbasic=>basicma,:pm_ded_repaidadvance=>advanceamt,:pm_ded_repaidloan=>loaamount,:pm_ded_electricunit=>electunit,:pm_ded_electricamount=>electamount ,:pm_dedaccomodatype=>accomtype,:pm_dedaccomodationno=>allotmentno,:pm_dedaccomodatamount=>accomodatval,:pm_licemployer=>licmandalamt,:pm_ded_licemployee=>licsewamount,:pm_ded_healthslab=>healthslbamt,:pm_ded_healthmandalpay=>healthmandpay,:pm_ded_healthsewdarpay=>healthmansewpay,:pm_ded_incometaxpercent=>taxpercents,:pm_incometaxamount=>taxcalamounts,:pm_totalallowance=>totalallownce,:pm_totaldeduction=>totaldeduct,:pm_netpay=>netpaymount,:pm_absent=>myabsent,:pm_monthday=>numberdays,:pm_arear=>prevarears)
       end
  end
  
end
