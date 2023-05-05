class SamagamBakshisController < ApplicationController
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
      @HeadHrp           = MstBakshishScale.where("bs_compcode = ?",@compcodes).order("bs_ashdate ASC").first
      @HrMonths          = nil
      @Hryears           = nil
        printpath        = "1_bakshis_register_report"
        @PrintDeptPath   = "samagam_bakshis/1_department_bakshis_summary_report.pdf"
        @PrintBnkPath    = "samagam_bakshis/1_bank_register_report.pdf"
        @PrintPath       = "samagam_bakshis/1_bakshis_register_report.pdf" #samagam_bakshis_path(printpath,:format=>"pdf")
      if @HeadHrp
        @HrMonths = @HeadHrp.bs_ashdate.strftime("%b")
        @Hryears  = @HeadHrp.bs_ashdate.strftime("%Y")
      end
    end
    
    def show
        @compcodes     = session[:loggedUserCompCode]
        @compDetail    = MstCompany.where(["cmp_companycode = ?", @compcodes]).first
        @chobj         = TrnBakshishTransaction.where(["bt_compcode = ?", @compcodes]).first
        month_numbers =  Time.now.month
        month_begins  =  Date.new(Date.today.year, month_numbers)
        begdates      =  Date.parse(month_begins.to_s)
        @nbegindates  =  Date.today.strftime('%d-%b-%Y') #begdates.strftime('%d-%b-%Y')
        month_endings =  month_begins.end_of_month
        endingdates   =  Date.parse(month_endings.to_s)
        @enddates     =  Date.today.strftime('%d-%b-%Y') #endingdates.strftime('%d-%b-%Y')
        @attendance   =  ''
        @processdetail = nil
        
       
         rooturl       = "#{root_url}"
         if params[:id] != nil && params[:id] != ''
           docsid  = params[:id].to_s.split("_")
            if docsid[1] != 'department'
               dataitem   = print_samagam_bakshis
            end
           
             if  docsid[1] == 'bakshis'
             
                respond_to do |format|
                  format.html
                  format.pdf do
                    pdf = BakshisregisterPdf.new(dataitem,@compDetail,rooturl,@chobj,@username,session)
                    send_data pdf.render,:filename => "1_bakshis_register_report.pdf", :type => "application/pdf", :disposition => "inline"
                  end
              end
            
           
             
            elsif  docsid[1] == 'bank'
            
            
                      respond_to do |format|
                          format.html
                          format.pdf do
                            pdf = BakshisbankformatPdf.new(dataitem,@compDetail,rooturl,@chobj,@username,session)
                            send_data pdf.render,:filename => "1_bank_register_report.pdf", :type => "application/pdf", :disposition => "inline"
                          end
                      end 

             elsif  docsid[1] == 'department'
                       deprtdata =  print_departmentwise_bakshis
            
                      respond_to do |format|
                          format.html
                          format.pdf do
                            pdf = BakshisdepartmentsummaryPdf.new(deprtdata,@compDetail,rooturl,@chobj,@username,session)
                            send_data pdf.render,:filename => "1_bakshis_department_summary_report.pdf", :type => "application/pdf", :disposition => "inline"
                          end
                      end 
          
  
                    end          
                  end
     end





    def ajax_process
           @compcodes       = session[:loggedUserCompCode]
           if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
              process_bkashis_caluclation();
              return         
            elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'RPT'
              check_samagam_bakshis();
                return         
             end


           
    end
  

    def check_samagam_bakshis
      @HeadHrp           = MstBakshishScale.where("bs_compcode = ?",@compcodes).order("bs_ashdate ASC").first
      @Hryears  = ""
      isflags = false
      if @HeadHrp
        @HrMonths = @HeadHrp.bs_ashdate.strftime("%b")
        @Hryears  = @HeadHrp.bs_ashdate.strftime("%Y")
      end
      iswhere = "bt_compcode='#{@compcodes}' AND bt_year='#{@Hryears}'"    
      chobj   = TrnBakshishTransaction.where(iswhere)
      if chobj.length >0
        isflags = true
      end
       respond_to do |format|
        format.json { render :json => { 'data'=>'',:status=>isflags} }
       end

    end

    def print_samagam_bakshis
      @HeadHrp     = MstBakshishScale.where("bs_compcode = ?",@compcodes).order("bs_ashdate ASC").first
      @Hryears     = ""
      if @HeadHrp
        @HrMonths = @HeadHrp.bs_ashdate.strftime("%b")
        @Hryears  = @HeadHrp.bs_ashdate.strftime("%Y")
      end
       iswhere  = "bt_compcode='#{@compcodes}' AND bt_year='#{@Hryears}'"    
        chobj   = TrnBakshishTransaction.where(iswhere)
        return chobj;

    end

    def print_departmentwise_bakshis
      @HeadHrp     = MstBakshishScale.where("bs_compcode = ?",@compcodes).order("bs_ashdate ASC").first
      arritem     = []
      @Hryears     = ""
      if @HeadHrp
        @HrMonths = @HeadHrp.bs_ashdate.strftime("%b")
        @Hryears  = @HeadHrp.bs_ashdate.strftime("%Y")
      end
       iswhere  = "bt_compcode='#{@compcodes}' AND bt_year='#{@Hryears}'"   
       isselect = "SUM(bt_payamount) as totalsangashd,bt_department,bt_sewacode,bt_departname" 
       isselect +=",'' as totalpnb,'' as totalboi,'' as othersneft,SUM(bt_ma) as totalma"
        chobj   = TrnBakshishTransaction.select(isselect).where(iswhere).group("bt_department").order("bt_departname")
        if chobj.length >0
            chobj.each do |newslsp|
              newslsp.totalpnb   = process_department_banks(@compcodes,newslsp.bt_sewacode,newslsp.bt_department,@Hryears,'pnb')
              newslsp.totalboi   = process_department_banks(@compcodes,newslsp.bt_sewacode,newslsp.bt_department,@Hryears,'boi')
              newslsp.othersneft = process_department_banks(@compcodes,newslsp.bt_sewacode,newslsp.bt_department,@Hryears,'oth')
              arritem.push newslsp
            end

        end
          return arritem
    end

    def process_department_banks(compcode,sewacode,dpcode,years,type)
        totalamts = 0
        isflags   = 0
        if type == 'boi'
            iswhere = " bt_compcode='#{compcode}' AND bt_year='#{years}' AND bt_department='#{dpcode}' AND REPLACE(LOWER(bt_bankname),' ','')='bankofindia'"
            isflags = 1
        elsif type == 'pnb'
            iswhere = " bt_compcode='#{compcode}' AND bt_year='#{years}' AND bt_department='#{dpcode}' AND REPLACE(LOWER(bt_bankname),' ','')='punjabnationalbank' "
            isflags = 1
        else
            iswhere = " bt_compcode='#{compcode}' AND bt_year='#{years}' AND bt_department='#{dpcode}'  AND REPLACE(LOWER(bt_bankname),' ','') NOT IN('bankofindia','punjabnationalbank') "
            isflags = 1
        end
        if isflags.to_i >0
            chobj     = TrnBakshishTransaction.select("SUM(bt_payamount) as totalamt").where(iswhere).first
            if chobj
              totalamts = chobj.totalamt
            end
       end
        return totalamts
    end
   
  
    private
    def process_bkashis_caluclation
        
          isflags      = false
          message      = ""
          numberdays   = 0
          newmonth     = ""
          newyears     = ""
          monthenddate = ""
          acctno       = ""
          ifscode      = ""
          bankname     = ""
          designations = ""
          department   = ""
          hrsobj       = MstBakshishScale.where("bs_compcode = ?",@compcodes).order("bs_ashdate ASC").first
         
          if hrsobj            
            monthenddate = hrsobj.bs_ashdate    
            newyears     = hrsobj.bs_years  
            
                chobj   = TrnBakshishTransaction.where("bt_compcode=? AND bt_year=?",@compcodes,newyears)
                 if chobj.length >0
                    chobj.destroy_all
                 end
          end
          
         ApplicationRecord.transaction do
          begin
             iswhere = "sw_compcode ='#{@compcodes}' AND sw_catcode<>'VIV' AND sw_joiningdate<>'0000-00-00' AND DATE(sw_joiningdate)<'#{monthenddate}' AND ( DATE(sw_leavingdate) >'#{monthenddate}' OR sw_leavingdate ='0000-00-00')"
           
              sewobj =  MstSewadar.where(iswhere).order("sw_sewcode")
              if sewobj.length >0

                 

                  sewobj.each do |processalary|
                     spobj = get_office_information(@compcodes,processalary.sw_sewcode)
                     if spobj
                        mavalue =  spobj.so_basic                        
                     end
                     bankobj   = get_sewadar_kyc_bankdetail(@compcodes,processalary.sw_sewcode)
                     if bankobj
                        acctno     = bankobj.skb_accountno
                        ifscode    = bankobj.skb_ifccocde
                        bankname   = bankobj.skb_bank
                     end
                     sewadarname =  processalary.sw_sewadar_name                     
                     doj         =  processalary.sw_joiningdate                  
                     refcode     =  processalary.sw_oldsewdarcode  
                     
                     deptobj = get_department_detail(processalary.sw_depcode)
                     if deptobj
                        department = deptobj.departDescription
                     end
                     desigobj =   get_sewdar_designation_detail(processalary.sw_desigcode)
                     if desigobj
                      designations = desigobj.ds_description
                     end


                    calculate_bkashis_part(@compcodes,processalary.sw_sewcode,processalary.sw_joiningdate,processalary.sw_leavingdate,processalary.sw_depcode,processalary.sw_catcode,processalary.sw_desigcode,newyears,monthenddate,mavalue,sewadarname,acctno,ifscode,bankname,doj,refcode, department,designations)
                  end                 
                  isflags = true
                  message ="Bakshis calculation completed successfully."
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

  def calculate_bkashis_part(compcodes,sw_sewcode,sw_joiningdate,sw_leavingdate,sw_depcode,sw_catcode,sw_desigcode,years,dated,mavalue,sewadarname,acctno,ifscode,bankname,doj,refcode, department,designations)
      myconutsprocess = 0
      iswhere = "bt_compcode='#{compcodes}' AND bt_sewacode='#{sw_sewcode}' AND bt_year='#{years}'"    
      chobj   = TrnBakshishTransaction.where(iswhere).first
      ### check sangam bakshis issue parameter ###########
       datedcalcsewa = called_between_days(sw_joiningdate,dated,0); 
       baskshisamt = 0
      if datedcalcsewa != nil && datedcalcsewa != ''
            datedcalcsewas   =  datedcalcsewa.to_s.split("-")  
            myyears          =  datedcalcsewas[0]   
            mymonths         =  datedcalcsewas[1]
            mynewdays        =  datedcalcsewas[2] 
            rngobj           =  get_selected_sangam_range(compcodes,mavalue,years)
            if rngobj
                  bakshisamt   = rngobj.bs_paylimit
                  fmruled      = rngobj.bs_month_rule_first
                  smruled      = rngobj.bs_month_rule_sec
                  rgtation     = rngobj.bs_condition
                  percentfirst = rngobj.bs_sewpercent_first
                  percentsec   = rngobj.bs_sewpercent_second
                  cclaculate   = (mavalue.to_f*percentfirst.to_f).to_f/100 
                  cclaculate   = cclaculate.round(0)
                  if myyears.to_i >=1
                 
                     if rgtation == "GreaterThenOREqual"
                            if cclaculate.to_f <=bakshisamt.to_f 
                                baskshisamt = bakshisamt
                              elsif  cclaculate.to_f >=bakshisamt.to_f 
                                    baskshisamt = cclaculate
                              else
                                  baskshisamt = 0      
                              end
                        else
                            if cclaculate.to_f<=bakshisamt.to_f 
                              baskshisamt = cclaculate
                            elsif  cclaculate.to_f >=bakshisamt.to_f 
                                  baskshisamt = bakshisamt
                            else
                                baskshisamt = 0      
                            end
                        end

                  else
                          if mymonths.to_i >=6 && mymonths.to_i<12
                              if rgtation == "GreaterThenOREqual"
                                if cclaculate.to_f <=bakshisamt.to_f 
                                    baskshisamt = bakshisamt
                                elsif  cclaculate.to_f >=bakshisamt.to_f 
                                    baskshisamt = cclaculate
                                else
                                     baskshisamt = 0      
                                end
                          else
                                if cclaculate.to_f<=bakshisamt.to_f 
                                    baskshisamt = cclaculate
                                elsif  cclaculate.to_f >=bakshisamt.to_f 
                                      baskshisamt = bakshisamt
                                else
                                    baskshisamt = 0      
                                end
                          end
    
                                 if baskshisamt >=0 
                                    baskshisamt = (baskshisamt.to_f*percentsec.to_f)/100
                                else
                                      baskshisamt= 0
                                end
                            end

                  end
            end
      end
      
      
      ### end check sangam issue parameter ###########
      if chobj
        #### NO UPDATE REQUIRED.
      else
          svsobj =  TrnBakshishTransaction.new(:bt_compcode=>compcodes,:bt_sewacode=>sw_sewcode,:bt_department=>sw_depcode,:bt_designation=>sw_desigcode,:bt_category=>sw_catcode,:bt_payamount=>baskshisamt,:bt_date=>dated,:bt_year=>years,:bt_total_sewa=>datedcalcsewa,:bt_sewadarname=>sewadarname,:bt_accountno=>acctno,:bt_ifsccode=>ifscode,:bt_bankname=>bankname,:bt_datejoining=>doj,:bt_ma=>mavalue,:bt_refercode=>refcode,:bt_departname=>department,:bt_designname=>designations)
          if svsobj.save
              ####### SS
              myconutsprocess +=1
          end
      end
      return myconutsprocess
  end
  private
  def get_department_counts(departcode)
    
         compcode  =  session[:loggedUserCompCode]
         mycounts  = 0
         sewdarobj =  TrnBakshishTransaction.select("COUNT(bt_departname) as totaldepartment").where("bt_departname =? AND bt_departname =?",compcode,departcode).first
         if sewdarobj
            mycounts = sewdarobj.totaldepartment
         end
         return mycounts
  end
  private
  def get_office_information(compcode,empcode)
         sewdarobj =  MstSewadarOfficeInfo.where("so_compcode =? AND so_sewcode =?",compcode,empcode).first
         return sewdarobj
  end
  private
  def get_sewadar_kyc_bankdetail(compcode,sewcode)
       sewdarobj =  MstSewadarKycBank.where("skb_compcode =? AND sbk_sewcode =?",compcode,sewcode).first
       return sewdarobj
  end

  private
  def get_office_information(compcode,empcode)
         sewdarobj =  MstSewadarOfficeInfo.where("so_compcode =? AND so_sewcode =?",compcode,empcode).first
         return sewdarobj
  end
  private
  def get_sewadar_kyc_bankdetail(compcode,sewcode)
       sewdarobj =  MstSewadarKycBank.where("skb_compcode =? AND sbk_sewcode =?",compcode,sewcode).first
       return sewdarobj
  end

end
