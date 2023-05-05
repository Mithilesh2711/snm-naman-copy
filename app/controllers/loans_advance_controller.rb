## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for main controller
### FOR REST API ######
class LoansAdvanceController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search,:loans_advance_list]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_mysewdar_list_details,:format_oblig_date,:global_sewadar_kyc_information
    helper_method :get_sewa_all_department,:get_sewa_all_rolesresp,:get_all_department_detail,:get_sewdar_designation_detail,:get_global_users
    helper_method :get_office_information
    def index
      @compCodes         = session[:loggedUserCompCode]
      @AllGuarnt         = nil
      mygurantors        = []
      mygurantorsx = MstSewadar.select("sw_sewcode,sw_sewadar_name,sw_joiningdate").where("sw_compcode = ? AND sw_catcode IN ('SDP')",@compCodes).order("sw_sewadar_name ASC")
        if mygurantorsx.length >0
          mygurantorsx.each do |newgsrt|                
                    newdateds  = newgsrt.sw_joiningdate
                    totalsewa  = get_dob_calculate(year_month_days_formatted(newdateds))
                    myadvobjx  = get_oustanding_balance(newgsrt.sw_sewcode)
                    gstatus    = get_check_guarantor(newgsrt.sw_sewcode)
                    if myadvobjx
                       outsatndamt  = myadvobjx.totaloustanding
                    end
                    if totalsewa.to_f >=5 && outsatndamt.to_f <=0 && gstatus.to_i<=0
                       mygurantors.push newgsrt
                    end
                
            end
        end
      @AllGuarnt = mygurantors
      @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
      @mydepartcode      = ''
      mydeprtcode        = ""
      @LoanRequest       = nil
      @reqcategory       = nil
      if session[:sec_sewdar_code] != nil
          sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
          if sewobjs
              @mydepartcode = sewobjs.sw_depcode
              mydeprtcode   = sewobjs.sw_depcode
          end
      end
      @GuarantDepart         = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment ='' ",@compCodes).order("departDescription ASC")
     if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
         @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment ='' AND departCode = ? ",@compCodes,mydeprtcode).order("departDescription ASC")
        if session[:requestuser_loggedintp].to_s == 'swd'
           @Allsewobj       = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")
        else
           @Allsewobj       = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_depcode = ?",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")
        end

     else
         @markedAllowed    = true
         @markedFieldAlw   = true
         @sewDepart        = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compCodes).order("departDescription ASC")
         @Allsewobj        = [] #MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode =?",@compCodes).order("sw_sewadar_name ASC")
     end
     if params[:id] !=nil && params[:id] != ''
       docs = params[:id].to_s.split("_")
       if docs[1].to_s != 'prt'
              @LoanRequest = TrnAdvanceLoan.where("al_compcode =? AND id = ?",@compCodes,params[:id].to_i).first
              if @LoanRequest
                    @Allsewobj  = get_common_list_by_department(@LoanRequest.al_depcode,@LoanRequest.al_requesttype)
                    empobjs     = get_mysewdar_list_details(@LoanRequest.al_sewadarcode)
                    if empobjs
                        @reqcategory  = empobjs.sw_catcode
                    end
              end

        end     
        if docs[1].to_s == 'prt'
                 hodobj         = get_first_my_sewadar("SHM00006")
                 newhodsobj     = get_first_my_sewadar("SHM00004")
                 hodhumane      = ""
                 if newhodsobj
                  hodhumane = newhodsobj.lds_name
                 end
                if docs[2].to_s == 'ma'
                  @excelPrint   =  nil
                  $dataitems    =  print_advance_ma_advance() 
                  cnames        =  "advance_ma_advance_#{Date.today}.csv"
                  send_data @excelPrint.to_advance_ma_advance, :filename=>cnames
                  return
                elsif docs[2].to_s == 'ex' ## EX GRATIA SANCTION LETTER
                    reqno         = docs[3]
                    sewacode       = docs[4]
                    rooturl        = "#{root_url}"
                    @compDetail    = MstCompany.where(["cmp_companycode = ?", @compCodes]).first
                    exgobj         = print_common_advance(reqno,sewacode)
                      respond_to do |format|
                          format.html
                          format.pdf do
                            pdf = ExgratiasanctionPdf.new(exgobj,@compDetail,session,rooturl,hodobj,hodhumane)
                            send_data pdf.render,:filename => "1_prt_ex_exgratia_report.pdf", :type => "application/pdf", :disposition => "inline"
                          end
                      end
                    elsif docs[2].to_s == 'mas' ### MA ADVANCE LETTER
                      reqno         = docs[3]
                      sewacode       = docs[4]
                      rooturl        = "#{root_url}"
                      @compDetail    = MstCompany.where(["cmp_companycode = ?", @compCodes]).first
                      exgobj         = print_common_advance(reqno,sewacode)
                        respond_to do |format|
                            format.html
                            format.pdf do
                              pdf = MaadvanceletterPdf.new(exgobj,@compDetail,session,rooturl,hodobj,hodhumane)
                              send_data pdf.render,:filename => "1_prt_ma_advance_report.pdf", :type => "application/pdf", :disposition => "inline"
                            end
                        end
                      elsif docs[2].to_s == 'wh'  ### WHEAT ADVANCE LETTER
                        reqno         = docs[3]
                        sewacode       = docs[4]
                        rooturl        = "#{root_url}"
                        @compDetail    = MstCompany.where(["cmp_companycode = ?", @compCodes]).first
                        exgobj         = print_common_advance(reqno,sewacode)
                          respond_to do |format|
                              format.html
                              format.pdf do
                                pdf = WheatadvanceletterPdf.new(exgobj,@compDetail,session,rooturl,hodobj,hodhumane)
                                send_data pdf.render,:filename => "1_prt_wheat_advance_report.pdf", :type => "application/pdf", :disposition => "inline"
                              end
                          end
                        elsif docs[2].to_s == 'adv'  ### WHEAT ADVANCE LETTER
                          reqno         = docs[3]
                          sewacode       = docs[4]
                          rooturl        = "#{root_url}"
                          @compDetail    = MstCompany.where(["cmp_companycode = ?", @compCodes]).first
                          exgobj         = print_common_advance(reqno,sewacode)
                            respond_to do |format|
                                format.html
                                format.pdf do
                                  pdf = AdvanceletterPdf.new(exgobj,@compDetail,session,rooturl,hodobj,hodhumane)
                                  send_data pdf.render,:filename => "1_prt_advance_report.pdf", :type => "application/pdf", :disposition => "inline"
                                end
                            end      
                    end        
        end
     end

  end

  #### ADVANCE & MA ADVANCE CANCEL DATA ###########
	def cancel
		@compcodes = session[:loggedUserCompCode]
		if params[:id].to_i >0
			 @Listobj =  TrnAdvanceLoan.where("al_compcode =? AND id = ?",@compcodes,params[:id]).first
			 if @Listobj
					 @Listobj.update(:al_approvestatus=>'C')
					 flash[:error] =  "Data cancelled successfully."
					 isFlags       =   true
					 session[:isErrorhandled] = nil
			 end
		end
		redirect_to "#{root_url}loans_advance/loans_advance_list"
	end

 def loans_advance_list
      @compcodes     = session[:loggedUserCompCode]
      @mydepartcode = nil
      mydeprtcode    = ""
      printcontroll = "1_prt_ma_davance_detail"
      @printpath    =  loans_advance_path(printcontroll,:format=>"pdf")
      if session[:sec_sewdar_code]
          sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
          if sewobjs
            @mydepartcode = sewobjs.sw_depcode
            mydeprtcode   = sewobjs.sw_depcode
          end
      end
      if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
      @sewDepart       = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment ='' AND departCode = ? ",@compcodes,mydeprtcode).order("departDescription ASC")
      else
      @sewDepart       = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compcodes).order("departDescription ASC")
      end   
      @sewadarCategory   = MstSewadarCategory.where("sc_compcode =? AND sc_catcode NOT IN('DWD','VIV')",@compcodes).order("sc_position ASC") 
      @LoanRequest       = get_sewadar_loan_request
 end

 def create
   @compCodes = session[:loggedUserCompCode]
   isFlags    = true
    ApplicationRecord.transaction do
    begin
        if params[:al_depcode] == nil || params[:al_depcode] == ''
           flash[:error] =  "Department is required."
           isFlags = false
        elsif params[:al_sewadarcode] == nil || params[:al_sewadarcode] == ''
           flash[:error] =  "Sewadar code is required."
           isFlags = false
       elsif params[:sewdarname] == nil || params[:sewdarname] == ''
           flash[:error] =  "Sewadar name is required."
           isFlags = false
        elsif   params[:al_requestdate] == nil || params[:al_requestdate] == ''
           flash[:error] =  "Request date is required."
           isFlags = false
         elsif   params[:al_requesttype] == nil || params[:al_requesttype] == ''
           flash[:error] =  "Request type is required."
           isFlags = false
        else
          category       = params[:checkcategory]
          currfile       = params[:currfilefour]           
           mid            = params[:mid]
           requestno     = params[:al_requestno]
           reqdated      = year_month_days_formatted(params[:al_requestdate])
           sewdarcode    = params[:al_sewadarcode] 
           requesttye    = params[:al_requesttype]
           loanamounts    = params[:al_loanamount]
           advamt        = params[:al_advanceamt]
           loanamount    = loanamounts.to_f+advamt.to_f
           installment   = params[:al_installpermonth]
           outsatndamt   = 0  
           if requesttye.to_s != 'Advance' && requesttye.to_s != 'Ex-gratia'
              if installment.to_f<=0
                  flash[:error] =  "Installment should be greater than zero."
                  isFlags       = false
                  session[:isErrorhandled] = 1
                   redirect_to "#{root_url}"+"loans_advance"
                   return;
              end
           end
          if params[:al_requesttype].to_s != 'Special Advance' ## IF HR ADVANCE NOT PROCESS

            if requesttye.to_s == 'Advance' 
                advobjx        = get_maadvance_oustanding_balance(params[:al_sewadarcode],requesttye.to_s.strip)
                if advobjx
                  outsatndamt  = advobjx.totaloustanding
                end
           else
                advobjx        = get_oustanding_balance(params[:al_sewadarcode])
                if advobjx
                  outsatndamt  = advobjx.totaloustanding
                end
           end
           
           mymas         = 0
           percentage    = 50
           allowma       = 0
           totalsewa     = 0
           mabasicdivide = 0
           totamstsex    = loanamounts.to_f+advamt.to_f
           chektakenamt  = outsatndamt.to_f+totamstsex.to_f
           

           officeobj     = get_office_information(params[:al_sewadarcode] )
           if officeobj
               mymas         = officeobj.so_basic
               newamts       = (mymas.to_f*percentage.to_f).to_f/100
               allowma       = currency_formatted(newamts) 
               mabasicdivide = mymas.to_f/2 
               if mabasicdivide.to_f >10000
                  mabasicdivide = 10000
               end
               mabasicdivide = currency_formatted(mabasicdivide)          

           end
           ### MA ADVANCE ############
           diffchkamt         =  mymas.to_f-chektakenamt.to_f
           uptosixtyklimit    =  mymas.to_f*3 ### upto 60k or three month MA
          
           ########
           newsewobj       = get_mysewdar_list_details(sewdarcode)
           if newsewobj
                dobs       = newsewobj.sw_date_of_birth
                newdated   = Date.parse(dobs.to_s)+62.years               
                newdateds  = newsewobj.sw_joiningdate  
                yearsobj   = get_dob_calculate(year_month_days_formatted(newdateds)) 
                if yearsobj !=nil && yearsobj!='' 
                    yearsobjx  = yearsobj.to_s.split(",")
                    totalsewa  = yearsobjx[0].to_i
                end
                
           end
           
           #### ABOVE SIXTY K APPLICABLE RULE
           netchekexgratiataken = 0
           if requesttye.to_s == 'Ex-gratia'
              totaltakenexg       =  final_check_total_exgratia(params[:al_sewadarcode])
              netchekexgratiataken = totaltakenexg.to_f+totamstsex.to_f
           end
            
            
           ###### CHECK ALLOWED ABOVE SIXTY #####
           if params[:al_requesttype].to_s == 'Loan' || params[:al_requesttype].to_s == 'Advance Above 60k'
              if category !=nil && category !=''  && category.to_s.upcase == 'VIT'
                    if currfile == nil || currfile == ''
                        if ( params[:al_guarantorattach] == nil ||  params[:al_guarantorattach] == ''  )
                          flash[:error] =  "Guarantor is required."
                          isFlags       = false
                        end
                      end    
              elsif category !=nil && category !=''  && category.to_s.upcase == 'SDP'
                #  if totalsewa.to_i<5
                #     if currfile == nil || currfile == ''
                #         if ( params[:al_guarantorattach] == nil ||  params[:al_guarantorattach] == ''  )
                #           flash[:error] =  "Guarantor is required."
                #           isFlags       = false
                #         end
                #       end   
                #   end   
             end
          end 
           ###### AND #############
           abosixtylimit      =  ((mymas.to_f*90)/100).to_f*totalsewa.to_f
           abosixtylimit      =  currency_formatted(abosixtylimit)
            ### Check ex-gratia rule ########
            if requesttye.to_s == 'Ex-gratia'
                ## checktotal 
                # if isFlags
                     
                #       if mid.to_i >0
                #         exwhere   = "al_compcode ='#{@compCodes}' AND al_sewadarcode ='#{sewdarcode}' AND al_requestno<>'#{requestno}'"
                #         exwhere   += " AND UPPER(al_requesttype) = UPPER('#{requesttye}') AND al_approvestatus IN('A','N')"
                #       else
                #         exwhere   = "al_compcode ='#{@compCodes}' AND al_sewadarcode ='#{sewdarcode}'"
                #         exwhere   += " AND UPPER(al_requesttype) = UPPER('#{requesttye}') AND al_approvestatus IN('A','N')"
                #       end              

                #       exobjts    = TrnAdvanceLoan.where(exwhere)
                #       if exobjts.length >0
                #             isFlags       =  false  
                #             flash[:error] =  "You have already applied for Ex-gratia."           
                #       end
                # end
                 if params[:myexemptionsewa].to_s !='Y' ## IF BY PASS EXEMPTION OF YEAR
                      if isFlags    
                            if( totalsewa.to_f <20 ) 
                                isFlags       =  false  
                                flash[:error] =  "You are not eligible for Ex-gratia due to minimum sewa required 20 years ." 
                            end
                      end 
                  end   
                ## ACCOMODATION TAKEN #######
                  if isFlags
                      if params[:myexemptionexgratia].to_s!= 'Y' ## IF BY PASS EXEMPTION OF ACCOMODATION
                            sewobjs = get_mysewdar_list_details(sewdarcode)
                            if sewobjs
                              accomodation = sewobjs.sw_isaccommodation
                              if accomodation.to_s == 'Y'
                                isFlags       =  false  
                                flash[:error] =  "You are not eligible for Ex-gratia due to accomodation taken."  
                              end

                            end
                      end
                  end   
                if isFlags
                   if netchekexgratiataken.to_f>350000 ###
                      isFlags       =  false  
                      flash[:error] =  "Could not be apply more than Ex-gratia limit";  
                   elsif netchekexgratiataken.to_f>abosixtylimit.to_f ### or 90% of MA into total sewa
                        isFlags       =  false  
                        die
                        flash[:error] =  "Could not be apply more than Ex-gratia limit";  
                    end    
                end
                 
                  
                  
             end
             
            ### End check ex-gratia rule ########

            if mid.to_i >0

              if requesttye.to_s == 'Advance'  ### MA ADVANCE can apply one time in month

                      
                newheres       = "al_compcode='#{@compCodes}' AND al_sewadarcode='#{sewdarcode}' AND YEAR(al_requestdate)=YEAR('#{reqdated}') AND MONTH(al_requestdate) =MONTH('#{reqdated}')"
                newheres       += " AND al_requesttype='#{requesttye}' AND al_approvestatus IN('A','N') AND al_requestno<>'#{requestno}'"
                chekthismonth  = TrnAdvanceLoan.where(newheres)
                if chekthismonth.length >0
                      isFlags       = false  
                      flash[:error] =  "MA Advance applied is exceeding the limit."         
                end
                if isFlags
                    if diffchkamt.to_f<5000
                      isFlags       =  false  
                      flash[:error] =  "Your are not eligible for apply MA Advance."
                    end
                end  
                 if isFlags
                    if advamt.to_f >10000                      
                      isFlags       =  false  
                      flash[:error] =  "Could not apply more than 10000."
                    elsif advamt.to_f >mabasicdivide.to_f 
                      isFlags       =  false  
                      flash[:error] =  "Could not apply more than 50% of MA"                    
                    end

                 end



            end
            if requesttye.to_s == 'Loan' || requesttye.to_s =='Advance Above 60k' 
                if outsatndamt.to_f >0
                  isFlags       =  false  
                  flash[:error] =  "Could not be apply more than one Advance"  
                end
            end
            if isFlags
              ####### RULE FOR UPTO 60K AND ABOVE 60K ONLY APLLY ONE WHILE BALANCE IS NOT EQUAL TO ZERO
               
              if requesttye.to_s == 'Loan' || requesttye.to_s =='Advance Above 60k'  ### MA ADVANCE can apply one time in month
                  newheres       = "al_compcode='#{@compCodes}' AND al_sewadarcode='#{sewdarcode}' AND al_requestno<>'#{requestno}'"
                  newheres       += " AND al_requesttype='#{requesttye}' AND al_approvestatus IN('A','N') AND al_balances>0"
                  chekthismonth  = TrnAdvanceLoan.where(newheres)
                  if chekthismonth.length >0
                        isFlags       =  false  
                        flash[:error] =  "Advance applied is exceeding the limit" #"You are not eligible for apply advance."           
                  end
              end

            end
            
            
              ####### end process ###############
              ### Check advance allowed
              if isFlags
                if requesttye.to_s == 'Loan' ## ADVANCE UPTO 60K
                    if isFlags    
                        if( totalsewa.to_f <=1 ) 
                            isFlags       =  false  
                            flash[:error] =  "Minimum sewa required #{totalsewa} year." 
                        end
                    end 
                  # if isFlags
                  #     if requesttye.to_s.downcase != 'loan' 
                  #       if installment.to_f<3000
                  #         isFlags       =  false  
                  #         flash[:error] =  "Advance upto 60k the installment amount should be >=3000"  
                  #       end
                  #     end     
                  # end
                 
                  if isFlags
                        if loanamount.to_f >60000                      
                          isFlags       =  false  
                          flash[:error] =  "Could not apply more than 60000."
                        elsif loanamount.to_f >uptosixtyklimit.to_f 
                          isFlags       = false  
                          flash[:error] =  "Could not be apply more than three month MA."
                        end

                    end
                   if isFlags
                      chekinstallment = loanamount.to_f/installment.to_f
                      if chekinstallment.to_i>20 ####
                        isFlags       =  false  
                        flash[:error] =  "No. of insatllment should not be greater than 20. "  
                      end
                   end

                end 

              end 
              ### END CHECK advance allowed 

               ### Check advance above 60k
                if isFlags
                    if requesttye.to_s == 'Advance Above 60k'
                      if isFlags    
                          if( totalsewa.to_f <=3 ) 
                              isFlags       =  false  
                              flash[:error] =  "Minimum sewa required 3 years." 
                          end
                      end 
                        if isFlags
                            if loanamount.to_f<=60000  
                                isFlags       =  false  
                                flash[:error] =  "Advance Above 60k should be greater than 60k."  
                            elsif loanamount.to_f >150000   
                                isFlags       =  false  
                                flash[:error] =  "Advance Above 60k should not be greater than 1.5 Lakh."  
                            end

                        end  
                        if isFlags
                            if loanamount.to_f >abosixtylimit.to_f 
                              isFlags       =  false  
                              flash[:error] =  "You are not eligible for apply this advance amount." 
                            end
                          
                        end
                        #  if isFlags
                        #     if requesttye.to_s != 'Advance Above 60k'
                        #         if installment.to_f<5000
                        #           isFlags       =  false  
                        #           flash[:error] =  "Advance Above 60k the installment amount should be >=5000"  
                        #         end
                        #     end   
                        # end
                        if isFlags
                            chekinstallment = loanamount.to_f/installment.to_f
                            if chekinstallment.to_i>30
                              isFlags       =  false  
                              flash[:error] =  "No. of insatllment should not be greater than 30. "  
                            end
                        end

                    end 
                end    
                
            ### END CHECK advance above 60k  

             #### WHEAT ADVANCE ##############
                    if isFlags
                        if requesttye.to_s == 'Wheat Advance'
                              if isFlags                             
                                newheres       = "al_compcode='#{@compCodes}' AND al_sewadarcode='#{sewdarcode}' AND al_requestno<>'#{requestno}' AND YEAR(al_requestdate)=YEAR('#{reqdated}')"
                                newheres       += " AND al_requesttype='#{requesttye}' AND al_approvestatus IN('A','N')"
                                chekthismonth  = TrnAdvanceLoan.where(newheres)
                                if chekthismonth.length >0
                                      isFlags       =  false  
                                      flash[:error] =  "Wheat Advance applied is exceeding the limit" #"You are not eligible for apply advance."           
                                end
                                  
                  
                              end

                            if isFlags
                                  if totamstsex.to_f >2000 
                                      isFlags       =  false  
                                      flash[:error] =  "Wheat Advance could not be apply more than 2000."                                   
                                  end

                            end 
                            if isFlags
                                chekinstallment = totamstsex.to_f/installment.to_f
                                if chekinstallment.to_i>4
                                    isFlags       =  false  
                                    flash[:error] =  "No. of insatllment should not be greater than 4. "  
                                end
                            end                      

                        end 
                    end  
             #####SPECIAL ADVANCE ###############
             if isFlags
                  if requesttye.to_s == 'Special Advance'
                      if totamstsex.to_f >50000 
                        isFlags       =  false  
                        flash[:error] =  "Special Advance could not be apply more than 50000."                                   
                      end
                  end

             end


             ######### END WHEAT ADVANCE ############


                ### MA ADVANCE ###########
                if isFlags
                      if requesttye.to_s == 'Advance'
                          if isFlags
                              kwheres       = "al_compcode='#{@compCodes}' AND al_sewadarcode='#{sewdarcode}' AND YEAR(al_requestdate)=YEAR('#{reqdated}')"
                              kwheres       += " AND al_requesttype='#{requesttye}' AND al_approvestatus IN('A','N') AND al_requestno<>'#{requestno}'"
                              kyearstaken   = TrnAdvanceLoan.where(kwheres)
                              if kyearstaken.length >6
                                  isFlags        =  false  
                                  flash[:error]  =  "Could not be apply more than 6 times."  
                              end
                          end
                    end

                  end   
                ### END MA ADVANCE CASE ##########

                 ###########EDIT MODE ############
                  if isFlags
                     stateupobj  = TrnAdvanceLoan.where("al_compcode =? AND id = ?",@compCodes,mid).first
                      if stateupobj
                           stateupobj.update(loan_params)                           
                           flash[:error] =  "Data updated successfully."
                            isFlags = true
                      end
                  end
            else


               if requesttye.to_s == 'Loan' || requesttye.to_s =='Advance Above 60k' 
                  if outsatndamt.to_f >0
                    isFlags       =  false  
                    flash[:error] =  "Could not be apply more than one Advance"  
                  end
               end

                   if requesttye.to_s == 'Advance'  ### MA ADVANCE can apply one time in month

                      
                        newheres       = "al_compcode='#{@compCodes}' AND al_sewadarcode='#{sewdarcode}' AND YEAR(al_requestdate)=YEAR('#{reqdated}') AND MONTH(al_requestdate) =MONTH('#{reqdated}')"
                        newheres       += " AND al_requesttype='#{requesttye}' AND al_approvestatus IN('A','N')"
                        chekthismonth  = TrnAdvanceLoan.where(newheres)
                        if chekthismonth.length >0
                              isFlags       = false  
                              flash[:error] =  "MA Advance applied is exceeding the limit"         
                        end
                        if isFlags
                            if diffchkamt.to_f<5000
                              isFlags       =  false  
                              flash[:error] =  "Your are not eligible for apply MA Advance."
                            end
                        end 
                         if isFlags
                           if advamt.to_f >10000                      
                              isFlags       =  false  
                              flash[:error] =  "Could not apply more than 10000."
                            elsif advamt.to_f >mabasicdivide.to_f 
                              isFlags       = false  
                              flash[:error] =  "Could not apply more than 50% of MA."
                            end

                        end
                    end
                    if isFlags
                      ####### RULE FOR UPTO 60K AND ABOVE 60K ONLY APLLY ONE WHILE BALANCE IS NOT EQUAL TO ZERO
                      if requesttye.to_s == 'Loan' || requesttye.to_s =='Advance Above 60k'  ### MA ADVANCE can apply one time in month
                          newheres       = "al_compcode='#{@compCodes}' AND al_sewadarcode='#{sewdarcode}' "
                          newheres       += " AND al_requesttype='#{requesttye}' AND al_approvestatus IN('A','N') AND al_balances>0"
                          chekthismonth  = TrnAdvanceLoan.where(newheres)
                          if chekthismonth.length >0
                                isFlags       =  false  
                                flash[:error] =  "Advance applied is exceeding the limit"           
                          end
                      end

                    end
                      ####### end process ###############
                      ### Check advance allowed
                        if isFlags
                          if requesttye.to_s == 'Loan' ## ADVANCE UPTO 60K
                              if isFlags    
                                  if( totalsewa.to_f <1 ) 
                                      isFlags       =  false  
                                      flash[:error] =  "Minimum sewa required 1 year." #+totalsewa.to_s
                                  end
                              end 
                            # if isFlags
                            #     if installment.to_f<3000
                            #       isFlags       =  false  
                            #       flash[:error] =  "Advance upto 60k the installment amount should be >=3000"  
                            #     end
                            # end
                           
                            if isFlags
                                  if loanamount.to_f >60000                      
                                    isFlags       =  false  
                                    flash[:error] =  "Could not apply more than 60000."
                                  elsif loanamount.to_f >uptosixtyklimit.to_f 
                                    isFlags       = false  
                                    flash[:error] =  "Could not apply more than three month MA."
                                  end
      
                              end
                             if isFlags
                                chekinstallment = loanamount.to_f/installment.to_f
                                if chekinstallment.to_i>20
                                  isFlags       =  false  
                                  flash[:error] =  "No. of insatllment could not be greater than 20. "  
                                end
                             end
      
                          end 
    
                        end   
                      ### END CHECK advance allowed 

                       ### Check advance above 60k
                if isFlags
                  if requesttye.to_s == 'Advance Above 60k'
                    if isFlags    
                        if( totalsewa.to_f <=3 ) 
                            isFlags       =  false  
                            flash[:error] =  "Minimum sewa required 3 years." 
                        end
                    end 
                      if isFlags
                          if loanamount.to_f<=60000  
                              isFlags       =  false  
                              flash[:error] =  "Advance Above 60k should be greater than 60k."  
                          elsif loanamount.to_f >150000   
                              isFlags       =  false  
                              flash[:error] =  "Advance Above 60k should not be greater than 1.5 Lakh."  
                          end

                      end  
                      if isFlags
                        if loanamount.to_f >abosixtylimit.to_f 
                          isFlags       =  false  
                          flash[:error] =  "You are not eligible for apply this advance amount." 
                        end
                      
                    end
                      #  if isFlags
                      #       if installment.to_f<5000
                      #         isFlags       =  false  
                      #         flash[:error] =  "Advance Above 60k the installment amount should be >=5000"  
                      #       end
                      # end
                      if isFlags
                          chekinstallment = loanamount.to_f/installment.to_f
                          if chekinstallment.to_i>30
                            isFlags       =  false  
                            flash[:error] =  "No. of insatllment should not be greater than 30. "  
                          end
                      end

                  end 
              end  
                        #### WHEAT ADVANCE ##############
                    if isFlags
                      if requesttye.to_s == 'Wheat Advance'
                            if isFlags                             
                              newheres       = "al_compcode='#{@compCodes}' AND al_sewadarcode='#{sewdarcode}' AND al_requestno<>'#{requestno}' AND YEAR(al_requestdate)=YEAR('#{reqdated}')"
                              newheres       += " AND al_requesttype='#{requesttye}' AND al_approvestatus IN('A','N')"
                              chekthismonth  = TrnAdvanceLoan.where(newheres)
                              if chekthismonth.length >0
                                    isFlags       =  false  
                                    flash[:error] =  "Wheat Advance applied is exceeding the limit" #"You are not eligible for apply advance."           
                              end
                                
                
                            end

                          if isFlags
                                if totamstsex.to_f >2000 
                                    isFlags       =  false  
                                    flash[:error] =  "Wheat Advance could not be apply more than 2000."                                   
                                end

                          end 
                          if isFlags
                              chekinstallment = totamstsex.to_f/installment.to_f
                              if chekinstallment.to_i>4
                                  isFlags       =  false  
                                  flash[:error] =  "No. of insatllment should not be greater than 4. "  
                              end
                          end                      

                      end 
                  end  
           #####SPECIAL ADVANCE ###############
           if isFlags
                if requesttye.to_s == 'Special Advance'
                    if totamstsex.to_f >50000 
                      isFlags       =  false  
                      flash[:error] =  "Special Advance could not be apply more than 50000."                                   
                    end
                end

           end


           ######### END WHEAT ADVANCE ############



                        ### MA ADVANCE ###########
                        if isFlags
                              if requesttye.to_s == 'Advance'
                                  if isFlags
                                      kwheres       = "al_compcode='#{@compCodes}' AND al_sewadarcode='#{sewdarcode}' AND YEAR(al_requestdate)=YEAR('#{reqdated}')"
                                      kwheres       += " AND al_requesttype='#{requesttye}' AND al_approvestatus IN('A','N')"
                                      kyearstaken   = TrnAdvanceLoan.where(kwheres)
                                      if kyearstaken.length >6
                                          isFlags        =  false  
                                          flash[:error]  =  "Could not be apply more than 6 times."  
                                      end
                                  end
                            end

                          end   
                        ### END MA ADVANCE CASE ##########
                       if isFlags
                            stsobj = TrnAdvanceLoan.new(loan_params)
                            if stsobj.save                              
                               flash[:error] =  "Data saved successfully."
                               isFlags = true
                            end
                       end
            end
          else ### FORCE TO HR ADVANCE PROCESS
            ######################HR ADVANCE PROCESSS #################
            if mid.to_i >0
                      if isFlags
                            stateupobj  = TrnAdvanceLoan.where("al_compcode =? AND id = ?",@compCodes,mid).first
                            if stateupobj
                                  stateupobj.update(loan_params)                           
                                  flash[:error] =  "Data updated successfully."
                                  isFlags = true
                            end
                      end
            else

                  
                  if isFlags
                        stsobj = TrnAdvanceLoan.new(loan_params)
                        if stsobj.save                              
                          flash[:error] =  "Data saved successfully."
                          isFlags = true
                        end
                  end


            end
            ##################### END HR ADVANCE PROCESS #######################            
           end
        end
          rescue Exception => exc
          flash[:error] =   "#{exc.message}"
          session[:isErrorhandled] = 1
          raise ActiveRecord::Rollback
          isFlags = false
      end
    end
     if !isFlags
       #  session[:request_params] = params
         session[:isErrorhandled] = 1
         isFlags = false
     else
         session[:request_params] = nil
         session[:isErrorhandled] = nil
         session.delete(:request_params)
     end
     if isFlags
       redirect_to "#{root_url}"+"loans_advance/loans_advance_list"
     else
       redirect_to "#{root_url}"+"loans_advance"
     end
 end
 
 def ajax_process
    @compCodes       = session[:loggedUserCompCode]
    if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
		get_sewdar_listing_by_department();
		return
    elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'SWCD'
		get_sewdarselected();
		return
    elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'LOANREQT'
		 process_update_loanrequestno();
		return
    elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'GTC'
		 get_ticket_listed();
		return
    elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'ATC'
		 process_assign_tickets();
		return
    elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'LASTRDN'
		 get_last_reading();
		 return
    elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'ECTCALC'
		 process_reading_amounts();
		 return
   elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'LINKUSER'
		 process_user_secured_parameter();
		 return
    elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'DEPEND'
       get_family_dependent_list();
      return
    elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'BRANCHADD'
       get_branch_address_list();
     return
    elsif params[:identity] !=nil  && params[:identity] !='' && params[:identity] == 'SNDOTP'
         send_otp_credential_data()
      return    
    end

     
 end

 private
 def loan_params
    @isCode     = 0
    @Startx     = '0000'
    @recCodes   = TrnAdvanceLoan.where(["al_compcode =? AND al_requestno >0 ",@compCodes]).order('al_requestno DESC').first
    if @recCodes
    @isCode    = @recCodes.al_requestno.to_i
    end

    @sumXOfCode    = @isCode.to_i + 1
    if  @sumXOfCode.to_s.length < 2
    @sumXOfCode = p @Startx.to_s + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length < 3
    @sumXOfCode = p "000" + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length < 4
    @sumXOfCode = p "00" + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length < 5
    @sumXOfCode = p "0" + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length >=5
    @sumXOfCode =  @sumXOfCode.to_i
    end
    if params[:mid].to_i >0
      params[:al_requestno] = params[:al_requestno]
    else
      params[:al_requestno] = @sumXOfCode

    end
    
   
    rqdated  = 0
    if params[:al_requestdate] !=nil && params[:al_requestdate] !=''
      rqdated = year_month_days_formatted(params[:al_requestdate])
    end

  dirf           = "advance/a1"
  dirs           = "advance/a2"
  dirths         = "advance/a3"
  dirfors        = "advance/a4"  
  currfilefirst  = params[:currfilefirst] 
	currfilesecond = params[:currfilesecond] 
	currfilethird  = params[:currfilethird]
  currfilefour   = params[:currfilefour] 
	imagefirst     = ""
	imagesecond    = ""
	imagethird     = ""
  imagefours     = ""
	if params[:ama_attachfirst] !=nil && params[:ama_attachfirst] !=''
		imagefirst = process_files(params[:ama_attachfirst],currfilefirst,dirf)

	end
	if imagefirst == nil || imagefirst == ''
		if currfilefirst !=nil && currfilefirst !='' 
			imagefirst = currfilefirst
		end
    end

	if params[:ama_attachsecond] !=nil && params[:ama_attachsecond] !=''
		imagesecond = process_files(params[:ama_attachsecond],currfilefirst,dirs)

	end
	if imagesecond == nil || imagesecond == ''
		if currfilesecond !=nil && currfilesecond !='' 
			imagesecond = currfilesecond
		end
    end
	if params[:ama_attachthird] !=nil && params[:ama_attachthird] !=''
		imagethird = process_files(params[:ama_attachthird],currfilefirst,dirths)

	end
	if imagethird == nil || imagethird == ''
        if currfilethird !=nil && currfilethird !='' 
          imagethird = currfilethird
        end
   end

   if params[:al_guarantorattach] !=nil && params[:al_guarantorattach] !=''
		imagefours = process_files(params[:al_guarantorattach],currfilefour,dirfors)

	end
	if imagefours == nil || imagefours == ''
        if currfilefour !=nil && currfilefour !='' 
          imagefours = currfilefour
        end
   end
   
    params[:al_attachfirst]       = imagefirst
    params[:al_attchsec]          = imagesecond
    params[:al_attachthird]       = imagethird
    params[:al_guarantorattach]   = imagefours
    params[:al_atttitlefirst]     = params[:ama_titlefirst] !=nil && params[:ama_titlefirst] !='' ? params[:ama_titlefirst] : ''
    params[:al_attachtilesec]     = params[:ama_tiitlesec] !=nil && params[:ama_tiitlesec] !='' ? params[:ama_tiitlesec] : ''
    params[:al_attachtitlethird]  = params[:ama_titlethird] !=nil && params[:ama_titlethird] !='' ? params[:ama_titlethird] : ''
    params[:al_guarantortitle]    = params[:al_guarantortitle] !=nil && params[:al_guarantortitle] !='' ? params[:al_guarantortitle] : ''

    params[:al_compcode]          = session[:loggedUserCompCode]
    params[:al_loanamount]        = params[:al_loanamount] !=nil && params[:al_loanamount] !='' ? params[:al_loanamount] : 0
    params[:al_advanceamt]        = params[:al_advanceamt]  !=nil && params[:al_advanceamt]  !='' ? params[:al_advanceamt]  : 0
    loansamunt = 0
    if params[:al_loanamount] !=nil && params[:al_loanamount] !='' && params[:al_loanamount].to_f >0
         loansamunt = params[:al_loanamount]        
    end
    if params[:al_advanceamt] !=nil && params[:al_advanceamt] !='' && params[:al_advanceamt].to_f >0
      loansamunt = params[:al_advanceamt]    
   end
    params[:al_loanamount]        = 0
    params[:al_advanceamt]        = loansamunt
    params[:al_installpermonth]   = params[:al_installpermonth] !=nil && params[:al_installpermonth] !='' ? params[:al_installpermonth] : 0
    params[:al_requestdate]       = rqdated
    params[:al_balances]          = loansamunt
    params[:al_purpose]           = params[:al_purpose] != nil && params[:al_purpose]!='' ? params[:al_purpose] : params[:other_purpose]
    params[:al_guarantordept]     = params[:al_guarantordept] != nil && params[:al_guarantordept]!='' ? params[:al_guarantordept] : ''
    params[:al_guarantorname]     = params[:al_guarantorname] != nil && params[:al_guarantorname]!='' ? params[:al_guarantorname] : ''
    
    params[:al_exmptotalsewa]      = params[:myexemptionsewa] != nil && params[:myexemptionsewa]!='' ? params[:myexemptionsewa] : 'N'
    params[:al_exmpreamrk]         = params[:exemptionremark] != nil && params[:exemptionremark]!='' ? params[:exemptionremark] : ''
    params[:al_exmpaccomodation]   = params[:myexemptionexgratia] != nil && params[:myexemptionexgratia]!='' ? params[:myexemptionexgratia] : 'N'
     
    params.permit(:al_compcode,:al_exmptotalsewa,:al_exmpreamrk,:al_exmpaccomodation,:al_guarantordept,:al_guarantorname,:al_guarantorattach,:al_guarantortitle,:al_attachfirst,:al_attchsec,:al_attachthird,:al_atttitlefirst,:al_attachtilesec,:al_attachtitlethird,:al_purpose,:al_requestno,:al_balances,:al_depcode,:al_sewadarcode,:al_requestdate,:al_requesttype,:al_advanceamt,:al_loanamount,:al_installpermonth,:al_remark)
 end

 private
 def process_sewdar_cb(compcode,sewdarcode,amounts,loanamt)
    amounts = amounts !=nil && amounts !='' ? amounts : 0
    loanamt  = loanamt !=nil && loanamt !='' ? loanamt : 0
    iswhere = "sw_compcode ='#{compcode}' AND sw_sewcode ='#{sewdarcode}'"
    sewobj  =  MstSewadar.where(iswhere).first
    if sewobj
        tamounts  = sewobj.sw_outstandingamt
        newamts   = tamounts.to_f+amounts.to_f
        loanamts  = sewobj.sw_outstandingamt
        newlonamt = loanamts.to_f+loanamt.to_f
        sewobj.update(:sw_outstandingamt=>newamts,:sw_loanamount=>newlonamt)
    end
 end

 private
 def reverse_process_sewdar_cb(compcode,sewdarcode,amounts,loanamt)
    amounts = amounts !=nil && amounts !='' ? amounts : 0
    loanamt  = loanamt !=nil && loanamt !='' ? loanamt : 0
    iswhere = "sw_compcode ='#{compcode}' AND sw_sewcode ='#{sewdarcode}'"
    sewobj  =  MstSewadar.where(iswhere).first
    if sewobj
        tamounts  = sewobj.sw_outstandingamt
        newamts   = tamounts.to_f-amounts.to_f
        loanamts  = sewobj.sw_outstandingamt
        newlonamt = loanamts.to_f-loanamt.to_f
        sewobj.update(:sw_outstandingamt=>newamts,:sw_loanamount=>newlonamt)
    end
 end
 
 private
 def process_reading_amounts
     isflags      = false
	 message      = ""
	 elecamount   = 0
	
	 netconsunt   = params[:totalunit] != nil && params[:totalunit] != '' ? params[:totalunit] : 0
	 hrsobj       = get_hr_parameters_head(@compCodes)
	 totalamts    = 0
	   if hrsobj
	
            consumlimit   = hrsobj.hph_consumption
            #months       = hrsobj.hph_months
            #years        = hrsobj.hph_years
            #monthdays    = get_total_days_of_month(months,years)
			#newmonthstr  = get_month_listed_data(months)			
			previousval   = 0
      balanceunit  = netconsunt
		   unitobj = get_hr_unit_rate(@compCodes,netconsunt)
		   if unitobj.length >0
			 unitobj.each do |newclc|
					consratesfirst  = newclc.hpr_rate1
					consrateseccond = newclc.hpr_rate2
					if netconsunt.to_f >consumlimit.to_f ### ( 400) fixed from hr parameter
						consrates = consrateseccond
					else
					   consrates = consratesfirst
					end	
					rangefrom     = newclc.hpr_rangefrom
					rangeupto     = newclc.hpr_rangeto

         
          if netconsunt.to_f >=rangeupto.to_f
            diffunits     = rangeupto.to_f-previousval.to_f
             if rangefrom.to_f == 0
               balanceunit   = balanceunit.to_f-(rangeupto.to_f).to_f
             else
               balanceunit   = balanceunit.to_f-(rangeupto.to_f-previousval.to_f).to_f
             end
            
          else
            diffunits     = balanceunit.to_f #-previousval.to_f
          end
					
					elecamount    = consrates.to_f*diffunits.to_f
					totalamts     += elecamount.to_f
					previousval   = rangeupto.to_f
			   end	  
			
			end
					isflags    = true
					message    = "Success"
		end
		
      respond_to do |format|
        format.json { render :json => { 'data'=>currency_formatted(totalamts),'balanceunit'=>balanceunit,"message"=>message,:status=>isflags} }
      end	
 
 end
 
 private
 def get_last_reading
    lastreadin   = 0
	message      = ""
	sflags       = false 
    departcode   = ""
    departname   = ""
    sewcode      = params[:sewcode]
    mymonth      = params[:hrmonths]
    myyears      = params[:hryears]
	stateupobj     = TrnElectricConsumption.select("ec_lastreading,ec_currentreading").where("ec_compcode = ? AND ec_sewdarcode = ? AND ec_lastreading >0",@compCodes,sewcode).order("ec_readingdate DESC").first
	if stateupobj
		lastreadin = stateupobj.ec_currentreading
		isflags   = true
		message   = "Success"
	end
  myexist       = false
  swmonthsobj   = TrnElectricConsumption.select("ec_lastreading").where("ec_compcode = ? AND ec_sewdarcode = ? AND ec_readingyear = ? AND ec_readingmonth = ?",@compCodes,sewcode,myyears,mymonth).order("ec_readingdate DESC")
	 if swmonthsobj.length >0
      myexist = true
   end
   if sewcode != nil && sewcode != ''
			 sewobj = get_global_sewadar_listed(sewcode)
			 if sewobj
				  departcode = sewobj.sw_depcode
				  depobj     = get_department_detail(departcode)
				  if depobj
				    departname = depobj.departDescription
				  end
			 end
	  end
	  respond_to do |format|
        format.json { render :json => { 'data'=>lastreadin,'departcode'=>departcode,'departname'=>departname,"message"=>message,:status=>isflags,'myexist'=>myexist} }
      end
	
 end

 private
 def get_sewdar_listing_by_department
    isflags   = false
    sedarname = []
    depcode   = params[:depcode].to_s.strip
    loantype  = params[:loantype].to_s.strip
    guarantor = params[:Guarantor]
    @HeadHrp  = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first    
    @monthsx  = ""
    @yearsx   = ""
    if  @HeadHrp
        @monthsx = @HeadHrp.hph_months
        @yearsx  = @HeadHrp.hph_years
    end


    iswhere = "sw_compcode ='#{@compCodes}' AND sw_depcode ='#{depcode}' AND ( sw_leavingdate='0000-00-00' OR ( MONTH(sw_leavingdate)='#{@monthsx}' AND YEAR(sw_leavingdate)='#{@yearsx}') )"
    if guarantor.to_s == 'Y'
        iswhere += " AND sw_catcode IN('SDP')"
    else    
      if loantype.to_s == 'Loan'  ### advnace up 60k
          iswhere += " AND sw_catcode NOT IN('SDR','VIH','VIV') " 
      elsif loantype.to_s == 'Advance' ### MA advance
          iswhere += " AND sw_catcode <>'VIV'"
      elsif loantype.to_s == 'Advance Above 60k' ### advance above 60k
          iswhere += " AND sw_catcode NOT IN('SDR','VIH','VIV')"  
      elsif loantype.to_s == 'Ex-gratia' ### Ex-gratia
          iswhere += " AND sw_catcode ='SDP'"
      elsif loantype.to_s == 'Special Advance' ### Special Advance
          iswhere += " AND sw_catcode IN('SDP','VIT')"  
      elsif loantype.to_s == 'Wheat Advance' ### Wheat Advance
          iswhere += " AND sw_catcode IN('SDP','VIT')"                
      elsif loantype.to_s == 'MAPED' ### Marriage/education
          iswhere += " AND sw_catcode IN('SDP','VIT')"
      elsif loantype.to_s == 'ATDNC'
          iswhere += " AND sw_catcode <>'VIV'"
      end
   end
    if params[:processreq].to_s == 'Y' 
       if loantype !='' && loantype !=nil
            sewobj  =  MstSewadar.select("sw_sewcode,sw_joiningdate,sw_sewadar_name,sw_catgeory,sw_catcode").where(iswhere).order("sw_sewadar_name ASC")
            if sewobj.length >0
              isflags = true
              sedarname = get_newsewdar_list(depcode,loantype)
            end
       end     
    else
      sewobj  =  MstSewadar.select("sw_sewcode,sw_joiningdate,sw_sewadar_name,sw_catgeory,sw_catcode").where(iswhere).order("sw_sewadar_name ASC")
      if sewobj.length >0
        isflags = true
        sedarname = get_newsewdar_list(depcode,loantype)
      end

    end
    #######CHE GUARRRR=======
         mygrnsts = []
         if guarantor.to_s == 'Y'
              if sewobj && sewobj.length >0
                  sewobj.each do |newgsrt|                
                            newdateds  = newgsrt.sw_joiningdate
                            totalsewa  = get_dob_calculate(year_month_days_formatted(newdateds))
                            myadvobjx  = get_oustanding_balance(newgsrt.sw_sewcode)
                            gstatus    = get_check_guarantor(newgsrt.sw_sewcode)
                            if myadvobjx
                              outsatndamt  = myadvobjx.totaloustanding
                            end
                            if totalsewa.to_f >=5 && outsatndamt.to_f <=0 && gstatus.to_i<=0
                              mygrnsts.push newgsrt
                            end
                        
                    end
                    sewobj = mygrnsts
              end
        end   
    ### END GUARANTOR ###
     respond_to do |format|
        format.json { render :json => { 'data'=>sewobj,'sedarname'=>sedarname,"message"=>'',:status=>isflags} }
      end
 end
 private
 def get_newsewdar_list(depcode,loantype)
    iswhere = "sw_compcode ='#{@compCodes}' AND sw_depcode ='#{depcode}' AND sw_leavingdate='0000-00-00'"
    if loantype.to_s == 'Loan'  ### advnace up 60k
      iswhere += " AND sw_catcode NOT IN('SDR','VIH','VIV') " 
  elsif loantype.to_s == 'Advance' ### MA advance
      iswhere += " AND sw_catcode <>'VIV'"
  elsif loantype.to_s == 'Advance Above 60k' ### advance above 60k
      iswhere += " AND sw_catcode NOT IN('SDR','VIH','VIV')"  
  elsif loantype.to_s == 'Ex-gratia' ### Ex-gratia
      iswhere += " AND sw_catcode ='SDP'"
  elsif loantype.to_s == 'Special Advance' ### Special Advance
      iswhere += " AND sw_catcode IN('SDP','VIT')"  
   elsif loantype.to_s == 'Wheat Advance' ### Wheat Advance
      iswhere += " AND sw_catcode IN('SDP','VIT')"               
   end
    sewobj  =  MstSewadar.select("sw_sewcode,sw_sewadar_name").where(iswhere).order("sw_sewadar_name ASC")
    return sewobj
 end


 private
 def get_sewdarselected
    isflags    = false
    sewcode    = params[:sewcode]
    monthlydav = params[:monthly_advance]
	  sewdarpan  = "";
    arritem    = []
    iswhere    = "sw_compcode ='#{@compCodes}' AND sw_sewcode ='#{sewcode}'"
    sewobj     =  MstSewadar.select("sw_sewcode,sw_oldsewdarcode,'' as totalsewa,sw_status,sw_catcode,sw_catgeory,sw_outstandingamt,sw_depcode,'' as department,sw_sewadar_name,DATE_FORMAT(sw_joiningdate,'%d-%b-%Y') as joiningdate,'' as supanndate,'' as totalsupann,'' as dateregliz,'' as sewduration,'' as outstatnding,'' as totalemi").where(iswhere).first
    if sewobj
       isflags = true
       if sewobj
                newsea =   sewobj
                 newsea.sewduration     = totalswawas = get_total_sewa_calculation(newsea.joiningdate)
                 newsea.totalsewa       = totalswawas.to_f >0 ? totalswawas.to_i : 0
                  officeobj             =  get_office_information(sewcode)
                  if officeobj
                    newsea.totalsupann  =  get_total_sewa_calculation(officeobj.so_superannuationdate,'','S').to_s.delete("-")
                    newsea.supanndate   =  formatted_date(officeobj.so_superannuationdate)
                    newsea.dateregliz   =  formatted_date(officeobj.so_regularizationdate)
                  end
                  
                #  if newsea.sw_status == 'Y'
                #       newsea.outstatnding =  newsea.sw_outstandingamt
                #  end
                instalobj  =  get_oustanding_balance(sewcode)
                if instalobj
                    newsea.outstatnding  =  instalobj.totaloustanding
                    newsea.totalemi      =  instalobj.totalemi
                end
                
               deptobj = get_all_department_detail( newsea.sw_depcode)
                if deptobj
                  newsea.department  = deptobj.departDescription
                end
           arritem.push newsea
       end
	     panobj =  get_sewadar_kyc_information(@compCodes,sewcode)
		 if panobj
			sewdarpan = panobj.sk_panno
		 end
    end
    
    monthslay     = ''
    if monthlydav == 'advance'
        monthslay  =  get_monthly_processed_salary_detail(sewcode)
        if monthslay != nil && monthslay.length  >0          
             ### execute parameters 
        else
         
             monthslay = get_singled_monthly_advance_detail(sewcode)
        end
     end
        @HeadHrp     = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
        @HrMonths    = nil
        @Hryears     = nil
        if @HeadHrp
            @HrMonths  = @HeadHrp.hph_months
            @Hryears   = @HeadHrp.hph_years
        end
          advamounts   = 0
          adinstallamt = 0         
          advamounts   = repaid_new_balances(sewcode,@HrMonths,@Hryears)           

        respond_to do |format|
          format.json { render :json => { 'data'=>arritem,'sewdarpin':sewdarpan,'monthslay'=>monthslay,'adinstallamt'=>adinstallamt,'advamounts'=>advamounts,"message"=>'',:status=>isflags} }
        end
 end

 private
 def get_advance_listed_data(compcode,sewacode,months)
  isselect  = "al_advanceamt,al_loanamount,al_installpermonth"
  iswhere   = "al_compcode='#{compcode}' AND al_sewadarcode ='#{sewacode}' AND MONTH(al_requestdate)='#{months}'"
  loansobj  = TrnAdvanceLoan.select(isselect).where(iswhere).first
 end

 private
   def get_total_sewa_calculation(joiningdated,leavs="",others="")
       newdate = ''
       if joiningdated != nil && joiningdated != ''
              newdate = get_dob_calculate(year_month_days_formatted(joiningdated),leavs,others)
       end
       return newdate
   end

   private
   def get_sewadar_loan_request
    if params[:requestserver] !=nil && params[:requestserver] != ''
        session[:sewa_sewadar_departments]  = nil
        session[:sewa_sewadar_category]     = nil
        session[:sewa_sewadar_status]       = nil
        session[:sewa_sewdar_requesttype]   = nil
        session[:sewa_search_fromdated]     = nil
        session[:sewa_search_uptodated]     = nil
        session[:sewa_sewadar_codetype]     = nil
    end
       sewadar_departments = params[:sewadar_departments] != nil && params[:sewadar_departments] !='' ? params[:sewadar_departments] : ''
       sewadar_codetype    = params[:sewadar_codetype] != nil && params[:sewadar_codetype] !='' ? params[:sewadar_codetype] : ''
       sewadar_string      = params[:sewadar_string] != nil && params[:sewadar_string] !='' ? params[:sewadar_string] : ''           

       sewadar_category    = params[:sewadar_category] != nil && params[:sewadar_category] !='' ? params[:sewadar_category] : '' 
       sewadar_status      = params[:sewadar_status] != nil && params[:sewadar_status] !='' ? params[:sewadar_status] : '' 
       sewdar_requesttype  = params[:sewdar_requesttype] != nil && params[:sewdar_requesttype] !='' ? params[:sewdar_requesttype] : '' 
       search_fromdated    = params[:search_fromdated] != nil && params[:search_fromdated] !='' ? params[:search_fromdated] : '' 
       search_uptodated    = params[:search_uptodated] != nil && params[:search_uptodated] !='' ? params[:search_uptodated] : '' 

       iswhere   = "al_compcode ='#{@compcodes}'"
       if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
          iswhere   += " AND al_sewadarcode ='#{session[:sec_sewdar_code]}'"
          iswhere   += " AND sw_depcode ='#{@mydepartcode}'"
          session[:sewa_sewadar_departments] = @mydepartcode
          @sewadar_departments = @mydepartcode
           myflagsjs = true
       elsif session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'stf'
                iswhere   += " AND sw_depcode ='#{@mydepartcode}'"
                @sewadar_departments = @mydepartcode
                session[:sewa_sewadar_departments] = @mydepartcode
                 myflagsjs        = true
       else
             #if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s != 'hr'
                if sewadar_departments !=nil && sewadar_departments !=''
                    iswhere   += " AND sw_depcode ='#{sewadar_departments}'"
                    @sewadar_departments = @mydepartcode
                    session[:sewa_sewadar_departments] = sewadar_departments
                    myflagsjs        = true
              #  end
            end
       end

       if sewadar_category !=nil && sewadar_category !=''
            iswhere   += " AND sw_catcode ='#{sewadar_category}'"         
            session[:sewa_sewadar_category] =sewadar_category
            @sewadar_category = sewadar_category
            myflagsjs = true
       end

       if sewadar_status !=nil && sewadar_status !=''
          if sewadar_status =='P'
          iswhere   += " AND ( al_approvestatus ='N' OR al_approvestatus='' ) AND al_hod_status<>'A'" 
          elsif sewadar_status =='F'
          iswhere   += " AND ( al_approvestatus NOT IN('A','C','R','H') AND al_hod_status='A' )"    
          else
          iswhere   += " AND al_approvestatus ='#{sewadar_status}'"   
          end              
          session[:sewa_sewadar_status] = sewadar_status
          @sewadar_status = sewadar_status       
       end
       if sewdar_requesttype !=nil && sewdar_requesttype !=''
          iswhere   += " AND al_requesttype ='#{sewdar_requesttype}'"         
          session[:sewa_sewdar_requesttype] =sewdar_requesttype
          @sewdar_requesttype = sewdar_requesttype      
       end
       if search_fromdated !=nil && search_fromdated !=''
          iswhere   += " AND al_requestdate >='#{year_month_days_formatted(search_fromdated)}'"         
          session[:sewa_search_fromdated] =search_fromdated
          @search_fromdated = search_fromdated      
       end     

       if search_uptodated !=nil && search_uptodated !=''
          iswhere   += " AND al_requestdate <='#{year_month_days_formatted(search_uptodated)}'"         
          session[:sewa_search_uptodated] =search_uptodated
          @search_uptodated = search_uptodated      
        end

       if sewadar_codetype !=nil && sewadar_codetype !=''
           
             if sewadar_string !=nil && sewadar_string != ''
                  @sewadar_string                 = sewadar_string
                  session[:sewa_sewadar_codetype] = sewadar_string
                  myflagsjs        = true
                  if sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='mycode'
                     iswhere += " AND sw_sewcode LIKE '%#{sewadar_string.to_s.strip}%' "
                  elsif sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='myemail'
                     iswhere += " AND sw_email LIKE '%#{sewadar_string.to_s.strip}%' "
                  elsif sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='mymobile'
                     iswhere += " AND sw_mobile LIKE '%#{sewadar_string.to_s.strip}%'  "
                  elsif sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='myname'
                     iswhere += " AND sw_sewadar_name LIKE '%#{sewadar_string.to_s.strip}%'  "
                  elsif sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='myrefcode'
                     iswhere += " AND sw_oldsewdarcode LIKE '%#{sewadar_string.to_s.strip}%' "
                  end

            end
            @sewadar_codetype               = sewadar_codetype
            session[:sewa_sewadar_codetype] = sewadar_codetype
       end
       if myflagsjs
           jons      = "LEFT JOIN mst_sewadars swa ON(sw_compcode = al_compcode AND sw_sewcode = al_sewadarcode)"
           isselect  = "trn_advance_loans.*,swa.id as swaId"
           loansobj  = TrnAdvanceLoan.select(isselect).joins(jons).where(iswhere).order("al_requestno DESC")
       else
           loansobj  = TrnAdvanceLoan.where(iswhere).order("al_requestno DESC")
       end
       
       return loansobj
   end

#### PRINT ADVANCE & MA ADVANCE #############
private
   def print_advance_ma_advance
       sewadar_departments = session[:sewa_sewadar_departments]
       sewadar_codetype    = session[:sewa_sewadar_codetype]
       sewadar_string      = session[:sewa_sewadar_string]
       compcodes           = session[:loggedUserCompCode]
       sewadar_category    = session[:sewa_sewadar_category]
       sewadar_status      = session[:sewa_sewadar_status]
       sewdar_requesttype  = session[:sewa_sewdar_requesttype]
       search_fromdated    = session[:sewa_search_fromdated]
       search_uptodated    = session[:sewa_search_uptodated]
       reqdated            = ""
       @HeadHrp            =  MstHrParameterHead.where("hph_compcode = ?",compcodes).first
       if @HeadHrp
           reqdated = @HeadHrp.hph_years.to_s+"-"+@HeadHrp.hph_months.to_s+"-01"
       end

       iswhere   = "al_compcode ='#{compcodes}'"
       if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
          iswhere   += " AND al_sewadarcode ='#{session[:sec_sewdar_code]}'"
          iswhere   += " AND sw_depcode ='#{@mydepartcode}'"
           myflagsjs = true
       elsif session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'stf'
                iswhere   += " AND sw_depcode ='#{@mydepartcode}'"             
                 myflagsjs        = true
       else
           #if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s != 'hr'
                if sewadar_departments !=nil && sewadar_departments !=''
                    iswhere   += " AND sw_depcode ='#{sewadar_departments}'"
                    
                    myflagsjs        = true
                end
           # end
       end
       if sewadar_category !=nil && sewadar_category !=''
        iswhere   += " AND sw_catcode ='#{sewadar_category}'"         
        session[:sewa_sewadar_category] =sewadar_category
        @sewadar_category = sewadar_category
        myflagsjs = true
   end

   if sewadar_status !=nil && sewadar_status !=''
      if sewadar_status =='P'
      iswhere   += " AND ( al_approvestatus ='N' OR al_approvestatus='' )" 
      elsif sewadar_status =='F'
      iswhere   += " AND ( al_approvestatus NOT IN('A','C','R','H') AND al_hod_status='A' )"    
      else
      iswhere   += " AND al_approvestatus ='#{sewadar_status}'"   
      end              
      session[:sewa_sewadar_status] = sewadar_status
      @sewadar_status = sewadar_status       
   end
   if sewdar_requesttype !=nil && sewdar_requesttype !=''
      iswhere   += " AND al_requesttype ='#{sewdar_requesttype}'"         
      session[:sewa_sewdar_requesttype] =sewdar_requesttype
      @sewdar_requesttype = sewdar_requesttype      
   end
   if search_fromdated !=nil && search_fromdated !=''
      iswhere   += " AND al_requestdate >='#{year_month_days_formatted(search_fromdated)}'"         
      session[:sewa_search_fromdated] =search_fromdated
      @search_fromdated = search_fromdated      
   end     

   if search_uptodated !=nil && search_uptodated !=''
      iswhere   += " AND al_requestdate <='#{year_month_days_formatted(search_uptodated)}'"         
      session[:sewa_search_uptodated] =search_uptodated
      @search_uptodated = search_uptodated      
    end
       if sewadar_codetype !=nil && sewadar_codetype !=''
           
             if sewadar_string !=nil && sewadar_string != ''
                  @sewadar_string  = sewadar_string
                  myflagsjs        = true
                  if sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='mycode'
                     iswhere += " AND sw_sewcode LIKE '%#{sewadar_string.to_s.strip}%' "
                  elsif sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='myemail'
                     iswhere += " AND sw_email LIKE '%#{sewadar_string.to_s.strip}%' "
                  elsif sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='mymobile'
                     iswhere += " AND sw_mobile LIKE '%#{sewadar_string.to_s.strip}%'  "
                  elsif sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='myname'
                     iswhere += " AND sw_sewadar_name LIKE '%#{sewadar_string.to_s.strip}%'  "
                  elsif sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='myrefcode'
                     iswhere += " AND sw_oldsewdarcode LIKE '%#{sewadar_string.to_s.strip}%' "
                  end

            end
            @sewadar_codetype = sewadar_codetype
       end
       isselect  = "trn_advance_loans.*,'' as sewdarname,'' as refercode,'' as designation,'' as joiningdate,'' as dobs,'' as genders,'' as approvedby "
       isselect  += ",'' as department,'' as selfadhar,'' as approvedby,DATE_FORMAT(al_requestdate,'%d-%b-%Y') as requestDated,'' as categoryname"
       isselect  += ",(al_advanceamt+al_loanamount) as totalamount, ( CASE WHEN al_requesttype='Advance' THEN 'MA Advance' WHEN al_requesttype='Loan' THEN 'Advance upto 60k' ELSE al_requesttype END) as requestype"
       isselect  += ", ( CASE WHEN al_approvestatus='A' THEN 'Approved' WHEN al_approvestatus='R' THEN 'Rejected' WHEN al_approvestatus='H' THEN 'Hold' WHEN al_approvestatus='C' THEN 'Cancelled' ELSE 'Pending' END  ) as reqstatus" 
       isselect  += ",'' as guarantorname,'' as leavingdated,'' as dos,'' as dor,'' as dateofjoing,'' as sanctionNo,'' as sanctionDate,al_balances as currentoutsatnding,'' as noinstallment,'' as lastinstallmentdate "
       if myflagsjs
           jons      = "LEFT JOIN mst_sewadars swa ON(sw_compcode = al_compcode AND sw_sewcode = al_sewadarcode)"
           isselect  += ",swa.id as swaId"
           loansobj  = TrnAdvanceLoan.select(isselect).joins(jons).where(iswhere).order("al_requestno DESC")
       else
           loansobj  = TrnAdvanceLoan.select(isselect).where(iswhere).order("al_requestno DESC")
       end
       arritem = []
       if loansobj.length >0
            @excelPrint = loansobj
            loansobj.each do |newadv|
              sewdobjs   = get_mysewdar_list_details(newadv.al_sewadarcode)
              if sewdobjs
                newadv.sewdarname   = sewdobjs.sw_sewadar_name
                newadv.refercode    = sewdobjs.sw_oldsewdarcode
                dsicode             = sewdobjs.sw_desigcode
                newadv.joiningdate  = formatted_date(sewdobjs.sw_joiningdate)
                newadv.dobs         = formatted_date(sewdobjs.sw_date_of_birth)
                newadv.genders      = sewdobjs.sw_gender
                newadv.categoryname = sewdobjs.sw_catgeory
                newadv.leavingdated = sewdobjs.sw_leavingdate
                
                sewdptobj           = get_all_department_detail(newadv.al_depcode)
                if sewdptobj
                  newadv.department = sewdptobj.departDescription
                end
                desobjs = get_sewdar_designation_detail(dsicode)
                if desobjs
                  newadv.designation = desobjs.ds_description
                end
              end
              gaurobj   = get_mysewdar_list_details(newadv.al_guarantorname)
              if gaurobj
                newadv.guarantorname = gaurobj.sw_sewadar_name
              end
              kycobj    =  global_sewadar_kyc_information(newadv.al_sewadarcode)  
              if kycobj
                  newadv.selfadhar = kycobj.sk_adharno
              end

              officeobj = get_office_information(newadv.al_sewadarcode)
              if officeobj       
                newadv.dos         = formatted_date(officeobj.so_superannuationdate)
                newadv.dor         = formatted_date(officeobj.so_regularizationdate)
                newadv.dateofjoing = formatted_date(officeobj.so_joiningdate)
              end

              seapprovedobj     = get_global_users(newadv.al_approvedby)
              if seapprovedobj
                    membercode  = seapprovedobj.ecmember
                    ldsobj      = get_member_listed(membercode)
                    if ldsobj
                      newadv.approvedby  = ldsobj.lds_name
                        #lds_profile = ldsobj.lds_profile
                    end
                    
              end
             
              #######GET CURRENT OUTSTANDING DETAIL #########
               totaladvance         = newadv.al_balances #newadv.totalamount
               installmentpermonth  = newadv.al_installpermonth
               noofinstallment      = ""
                if totaladvance.to_f >0 && installmentpermonth.to_f >0
                  noofinstallment            = totaladvance.to_f/installmentpermonth.to_f
                  newadv.noinstallment       = noofinstallment.to_i
                  instdated                  = Date.parse(reqdated.to_s)+noofinstallment.to_i.months 
                  newadv.lastinstallmentdate = formatted_date(instdated)
                end
                voucobj  = get_sanction_detail(newadv.al_broucherno)
                if voucobj
                    newadv.sanctionNo      = voucobj.vd_voucherno
                    newadv.sanctionDate    = formatted_date(voucobj.vd_voucherdate)
                  end              
              
              #########END CURRENT OUTSTANDING DETAIL ##########
              arritem.push newadv
            end
       end       
       return arritem
   end

   
###########GET EXGRAITIA #################
#### PRINT ADVANCE & MA ADVANCE #############
private
   def print_common_advance(reqno,sewacode)
        compcodes = session[:loggedUserCompCode]
        iswhere   = "al_compcode ='#{compcodes}' AND al_sewadarcode='#{sewacode}' AND al_requestno ='#{reqno}'"
       
       isselect  = "trn_advance_loans.*,'' as sewdarname,'' as refercode,'' as designation,'' as joiningdate,'' as dobs,'' as genders,'' as approvedby "
       isselect  += ",al_installpermonth,'' as department,'' as selfadhar,'' as approvedby,DATE_FORMAT(al_requestdate,'%d-%b-%Y') as requestDated,'' as categoryname"
       isselect  += ",(al_advanceamt+al_loanamount) as totalamount, ( CASE WHEN al_requesttype='Advance' THEN 'MA Advance' WHEN al_requesttype='Loan' THEN 'Advance upto 60k' ELSE al_requesttype END) as requestype"
       isselect  += ", ( CASE WHEN al_approvestatus='A' THEN 'Approved' WHEN al_approvestatus='R' THEN 'Rejected' WHEN al_approvestatus='H' THEN 'Hold' WHEN al_approvestatus='C' THEN 'Cancelled' ELSE 'Pending' END  ) as reqstatus" 
       isselect  += ",al_broucherno as sanctionno,'' as leavingdated,'' as dos,'' as dor,'' as dateofjoing,'' as sw_sewcode,'' as sw_sewcode,'' as bankaccountno,'' as bankname,'' as branch,'' as ifsccode,MONTHNAME(al_requestdate) as mymonths,YEAR(al_requestdate) as myyears,'' as sewaprefix  "
       loansobj  = TrnAdvanceLoan.select(isselect).where(iswhere).order("al_requestno DESC")
       arritem = []
       if loansobj.length >0
            @excelPrint = loansobj
            loansobj.each do |newadv|
              sewdobjs   = get_mysewdar_list_details(newadv.al_sewadarcode)
              if sewdobjs
                newadv.sewdarname   = sewdobjs.sw_sewadar_name
                newadv.refercode    = sewdobjs.sw_oldsewdarcode
                newadv.sw_sewcode   = sewdobjs.sw_sewcode
                dsicode             = sewdobjs.sw_desigcode
                newadv.joiningdate  = formatted_date(sewdobjs.sw_joiningdate)
                newadv.dobs         = formatted_date(sewdobjs.sw_date_of_birth)
                newadv.genders      = sewdobjs.sw_gender
                newadv.categoryname = sewdobjs.sw_catgeory
                newadv.sewaprefix   = sewdobjs.sw_sewadar_prefix
                newadv.leavingdated = sewdobjs.sw_leavingdate
                
                sewdptobj           = get_all_department_detail(newadv.al_depcode)
                if sewdptobj
                  newadv.department = sewdptobj.departDescription
                end
                desobjs = get_sewdar_designation_detail(dsicode)
                if desobjs
                  newadv.designation = desobjs.ds_description
                end
              end
              kycobj    =  global_sewadar_kyc_information(newadv.al_sewadarcode)  
              if kycobj
                  newadv.selfadhar = kycobj.sk_adharno
              end

              officeobj = get_office_information(newadv.al_sewadarcode)
              if officeobj       
                newadv.dos         = formatted_date(officeobj.so_superannuationdate)
                newadv.dor         = formatted_date(officeobj.so_regularizationdate)
                newadv.dateofjoing = formatted_date(officeobj.so_joiningdate)
              end

              kycobj      = get_sewadar_kyc_bankdetail(compcodes,newadv.al_sewadarcode)
              if kycobj                
                  newadv.bankaccountno   = kycobj.skb_accountno
                  newadv.bankname        = kycobj.skb_bank
                  newadv.branch          = kycobj.skb_branch
                  newadv.ifsccode        = kycobj.skb_ifccocde
              end
              seapprovedobj     = get_global_users(newadv.al_approvedby)
              if seapprovedobj
                    membercode  = seapprovedobj.ecmember
                    ldsobj      = get_member_listed(membercode)
                    if ldsobj
                      newadv.approvedby  = ldsobj.lds_name
                        #lds_profile = ldsobj.lds_profile
                    end
                    
              end
              arritem.push newadv
            end
       end       
       return arritem
   end
############ ADVANCE && MA ADVANCE ############
private
def get_sewadar_kyc_bankdetail(compcode,sewcode)
     sewdarobj =  MstSewadarKycBank.where("skb_compcode =? AND sbk_sewcode =?",compcode,sewcode).first
     return sewdarobj
end
   private
   def process_update_loanrequestno
       loanreqid = params[:requestno]
       postatus  = params[:postatus]
       myremark  = params[:myremark]
       isflags   = false
       cdated    = Date.today
       iswhere   = "al_compcode ='#{@compCodes}' AND id = '#{loanreqid}'"
       loansobj  = TrnAdvanceLoan.where(iswhere).first
        if loansobj
              compcode     = @compCodes
              sewdarcode   = loansobj.al_sewadarcode
              adamounts    = loansobj.al_advanceamt
              loanamounts  = loansobj.al_loanamount
              if session[:sec_ec_approved] == 'ec' || session[:sec_ec_approved] == 'cod'                
                  if postatus.to_s.strip == 'F'
                      loansobj.update(:al_hod_status=>"A",:al_hoddated=>cdated,:al_approvestatus=>'F',:al_hod_remark=>myremark,:al_approvedby=>session[:logedUserId])
                  else
                      loansobj.update(:al_hod_status=>postatus,:al_hoddated=>cdated,:al_hod_remark=>myremark,:al_approvedby=>session[:logedUserId])
                  end         
              else
                   loansobj.update(:al_approvestatus=>postatus,:al_apprvdated=>cdated,:al_hrremark=>myremark)
              end
              if postatus.to_s.strip == 'A'
               #   process_sewdar_cb(compcode,sewdarcode,adamounts,loanamounts)
              end
              message = "Data updated successfully."
              isflags = true
        else
               message = "No record(s) found for update."
        end
        
       respond_to do |format|
        format.json { render :json => { 'data'=>'',"message"=>message,:status=>isflags} }
       end
       
   end

   private
   def get_ticket_listed
        ticketno  =  params[:ticketno]
        isflags   =  false
         message  = ""
         mydepartment = ""
        trnsobj   =  TrnRaiseTicket.select("trn_raise_tickets.*,DATE_FORMAT(rt_ticketdate,'%d-%b-%Y') as ticketdated").where("rt_compcode = ? AND rt_ticketno = ?",@compCodes,ticketno).first
        if trnsobj
            isflags   = true
            message   = "Success"
            deprstobj = get_department_detail(trnsobj.rt_raiseddep)
            if deprstobj
              mydepartment = deprstobj.departDescription
            end
            
        end
        respond_to do |format|
        format.json { render :json => { 'data'=>trnsobj,'raseddeprtment'=>mydepartment,"message"=>message,:status=>isflags} }
       end

   end

   private
   def process_assign_tickets
     usertypes   =  params[:usertypes]
     ticketno    =  params[:ticketno]
     tkdate      =  params[:tkdate]
     assgto      =  params[:assgto] !=nil && params[:assgto] !='' ? params[:assgto] : 'L1'
     levels      =  params[:levels]
     resolution  =  params[:resolution] !=nil && params[:resolution] !='' ? params[:resolution] : ''
     feedback    =  params[:feedback] !=nil && params[:feedback] !='' ? params[:feedback] : ''
     ratings     =  params[:ratings] !=nil && params[:ratings] !='' ? params[:ratings] : 0
     myststus    =  params[:myststus]
     Time.zone   =  "Kolkata"
     localtimes  =  Time.zone.now.strftime('%I:%M%p')
     cdated      =  formatted_date(Time.now.to_date)
     isflags = true
     if myststus == 'A'
         if assgto == nil || assgto == ''
           message = "Assigned to is required."
           isflags = false
         elsif levels == nil || levels == ''
           message = "Level is required."
           isflags = false
         end
     elsif myststus == 'S'
          if resolution == nil  || resolution == ''
            message = "Resolution is required."
            isflags = false
          end
     elsif myststus == 'R' || myststus == 'C'
         if feedback == nil || feedback == ''
            message = "Feedback is required."
            isflags = false
         end
         
     end
     if ticketno == nil  || ticketno == ''
          message = "Ticket number is required."
          isflags = false
     end
      if isflags
           trnsobj     =  TrnRaiseTicket.where("rt_compcode = ? AND rt_ticketno =?",@compCodes,ticketno).first
           if trnsobj
                  reslquery   = trnsobj.rt_resolveremark
                  feedquery   = trnsobj.rt_feeback
                  if myststus.to_s == 'A'
                     trnsobj.update(:rt_status=>'A',:rt_priorty=>levels,:rt_assignedsewacode=>assgto)
                  elsif myststus.to_s == 'S'
                      newrsql = cdated.to_s+" "+localtimes.to_s+" "+resolution.to_s+"<br/>"+reslquery.to_s
                     trnsobj.update(:rt_status=>'S',:rt_priorty=>levels,:rt_resolveremark=>newrsql)
                  elsif myststus.to_s == 'R'
                      newfeebk  = cdated.to_s+" "+localtimes.to_s+" "+feedback.to_s+"<br/>"+feedquery.to_s
                     trnsobj.update(:rt_status=>'R',:rt_priorty=>levels,:rt_feeback=>newfeebk)
                  elsif myststus.to_s =='C'
                      newfeebk  = cdated.to_s+" "+localtimes.to_s+" "+feedback.to_s+"<br/>"+feedquery.to_s
                     trnsobj.update(:rt_status=>'C',:rt_priorty=>levels,:rt_feeback=>newfeebk,:rt_rating=>ratings)
                  end
                 message = "Data updated successfully."
                isflags = true
           end
      end
          respond_to do |format|
        format.json { render :json => { 'data'=>'',"message"=>message,:status=>isflags} }
       end


   end
   
   private
  def get_sewadar_kyc_information(compcode,sewcode)
       sewdarobj =  MstSewadarKyc.where("sk_compcode =? AND sk_sewcode =?",compcode,sewcode).first
       return sewdarobj
  end
  
 private
 def process_user_secured_parameter
    isflags        = false
    processuser    = params[:processuser] != nil && params[:processuser] != '' ? params[:processuser] : ''
	if processuser != nil && processuser != '' 

    #######DSIBALE ALL SESSION #########
        session[:reqs_ticket_number]     = nil
        session[:tickets_department]     = nil
        session[:reqs_ticket_status]     = nil
        session[:reqs_ticket_from_date]  = nil
        session[:reqs_ticket_upto_dated] = nil
        session[:req_raised_department]  = nil

        session[:request_sewadar_name] = nil
        session[:request_leave_code] = nil
        session[:request_leave_type] = nil
        session[:request_search_fromdated] = nil
        session[:request_search_uptodated] = nil
        session[:request_voucher_department] = nil
        session[:eareqs_voucher_department] = nil
        session[:eareqs_voucher_category] = nil
        session[:eareqs_sewadar_status] = nil
        session[:eareqs_sewadar_requesttype] = nil

        session[:reqs_voucher_department] = nil
        session[:reqs_voucher_category]   = nil
        session[:reqs_voucher_number]     = nil
        session[:reqs_sewadar_loantype]   = nil
        session[:reqs_show_voucher]       = nil
        session[:reqs_sewadar_reqtype]    = nil
        session[:areqs_voucher_department]    = nil
        session[:areqs_voucher_category]      = nil
        session[:areqs_sewadar_status]        = nil
        session[:areqs_sewadar_requesttype]   = nil
    ######### END DSABLED SESSIONS ###########
		isflags = true
		session[:tickets_department] = nil
		session[:requestuser_loggedintp] = processuser
		session[:requser_loggeddpt]      = get_department_code(params[:processuser])
	end	
	respond_to do |format|
	format.json { render :json => { 'data'=>'',:status=>isflags} } 
   end
  
  end
  private
  def get_department_code(type)
     departcode  = ""
	 moduleocdeobj  = MstListModule.select("lm_departcode").where("lm_compcode = ? AND lm_status='Y' AND lm_modules = ?",@compCodes,type.to_s.upcase).first
	 if moduleocdeobj
		 departcode = moduleocdeobj.lm_departcode
	 end
	 return departcode
  end

  private
  def get_family_dependent_list()
    compcode   = session[:loggedUserCompCode]
    sewcode    = params[:sewacode]
    mariagetpe = params[:mariagetpe]
    if mariagetpe.to_s == 'Y'
     iswhere     = "skf_compcode='#{compcode}' AND skf_relation IN('Son','Daughter') AND skf_sewcode='#{sewcode}' AND skf_family_dependent='Y' AND skf_married_status<>'Y' AND skf_datebirth<>'0000-00-00' AND (DATE_FORMAT(FROM_DAYS(DATEDIFF(now(),skf_datebirth)), '%Y')+0)>=18"
    else
      iswhere    = "skf_compcode='#{compcode}' AND skf_relation IN('Son','Daughter') AND skf_sewcode='#{sewcode}' AND skf_family_dependent='Y' AND skf_married_status<>'Y' AND skf_datebirth<>'0000-00-00' AND (DATE_FORMAT(FROM_DAYS(DATEDIFF(now(),skf_datebirth)), '%Y')+0)<=25"
    end
     sewdarobj =  MstSewdarKycFamilyDetail.where(iswhere).order("skf_dependent ASC")
     isflags   = false 
     message   = ""
     if sewdarobj.length >0
         isflags = true
         message ="success"
     end
     respond_to do |format|
      format.json { render :json => { 'data'=>sewdarobj,"message"=>message,:status=>isflags} }
     end

  end

  private
  def get_branch_address_list()
    compcode   = session[:loggedUserCompCode]
    branchcode = params[:branchcode]
     sewdarobj =  MstBranch.where("bch_compcode = ? AND bch_branchcode = ?",compcode,branchcode).first
     isflags   = false 
     message   = ""
     if sewdarobj
         isflags = true
         message = "success"
     end
     respond_to do |format|
      format.json { render :json => { 'data'=>sewdarobj,"message"=>message,:status=>isflags} }
     end

  end
  private
  def get_office_information(empcode)
         compcode   = session[:loggedUserCompCode]
         sewdarobj  = MstSewadarOfficeInfo.where("so_compcode =? AND so_sewcode =?",compcode,empcode).first
         return sewdarobj
  end

 private
 def get_common_list_by_department(depcode,loantype)
    @HeadHrp  = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first    
    @monthsx  = ""
    @yearsx   = ""
    if  @HeadHrp
        @monthsx = @HeadHrp.hph_months
        @yearsx  = @HeadHrp.hph_years
    end
    iswhere = "sw_compcode ='#{@compCodes}' AND sw_depcode ='#{depcode}' AND ( sw_leavingdate='0000-00-00' OR MONTH(sw_leavingdate)='#{@monthsx}' AND YEAR(sw_leavingdate)='#{@yearsx}')"
    if loantype.to_s == 'Loan'  ### advnace up 60k
        iswhere += " AND sw_catcode NOT IN('SDR','VIH','VIV') " 
    elsif loantype.to_s == 'Advance' ### MA advance
        iswhere += " AND sw_catcode <>'VIV'"
    elsif loantype.to_s == 'Advance Above 60k' ### advance above 60k
        iswhere += " AND sw_catcode NOT IN('SDR','VIH','VIV')"  
    elsif loantype.to_s == 'Ex-gratia' ### Ex-gratia
        iswhere += " AND sw_catcode ='SDP'"
    elsif loantype.to_s == 'Special Advance' ### Special Advance
        iswhere += " AND sw_catcode IN('SDP','VIT')"  
     elsif loantype.to_s == 'Wheat Advance' ### Wheat Advance
        iswhere += " AND sw_catcode IN('SDP','VIT')"                
    elsif loantype.to_s == 'MAPED' ### Marriage/education
        iswhere += " AND sw_catcode IN('SDP','VIT')"
    end
    sewobj  =  MstSewadar.select("sw_sewcode,sw_sewadar_name,sw_catgeory,sw_catcode").where(iswhere).order("sw_sewadar_name ASC")
    return sewobj
 end


 

end
