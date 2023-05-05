class AllFormatsController < ApplicationController

    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_sewdar_designation_detail,:get_all_department_detail,:get_ho_location,:get_global_office_detail
    helper_method :set_dct,:set_ent,:get_personal_information,:get_office_information,:get_roles_information,:format_oblig_date,:get_university_deegre_listed,:get_my_selected_department_code
    helper_method :get_sewa_all_department,:get_sewa_all_qualification,:get_sewa_all_rolesresp,:get_sewa_all_designation,:get_first_my_sewadar,:get_subs_location
  def index
   @compCodes         = session[:loggedUserCompCode]
   @mydepartcode      = ''
   @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
   @printPath          = "all_formats/1_common_report.pdf"
   mydeprtcode        = ""
 if session[:sec_sewdar_code] != nil
       sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
       if sewobjs
           @mydepartcode = sewobjs.sw_depcode
           mydeprtcode   = sewobjs.sw_depcode
       end
  end
 if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
  
     @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment ='' AND departCode = ? ",@compCodes,mydeprtcode).order("departDescription ASC")
     if session[:requestuser_loggedintp].to_s == 'swd'
       @Allsewobj         = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")
     else
       @Allsewobj         = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_depcode = ?",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")
     end

 else
      @markedAllowed    = true
      @markedFieldAlw   = true
      @sewDepart        = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compCodes).order("departDescription ASC")
      @Allsewobj        = [] #MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode =?",@compCodes).order("sw_sewadar_name ASC")
 end
     
  end
  ### SEWADAR REPORT ANALYSIS ###
  def show
     @compcodes       = session[:loggedUserCompCode]
     @compDetail      = MstCompany.where(["cmp_companycode = ?", @compcodes]).first
     @seawdarsobj     = nil
     @sewadarpersonal = nil
     @empChecked      = nil
     @EmpKyc          = nil
     @EmpKycBank      = nil
     @EmpKycQulifc    = nil
     @EmpKycFamily    = nil
     @EmpWorkExp      = nil
     @EmpStatelist    = nil
     @EmpDistrict     = nil
     @Hodlisted       = nil
     @EmpDepartment   = nil
     
     if session[:req_sewdarcode] !=nil && session[:req_sewdarcode] !='' 
        get_all_formats_data();
     end
      rooturl       = "#{root_url}"
      if params[:id] != nil && params[:id] != ''
        docsid  = session[:reqtypes]
        if docsid == 'LIC'
            @voucherdata  =   print_common_list
            respond_to do |format|
                format.html
                format.pdf do
                   pdf = LicPdf.new(@voucherdata,@compDetail,rooturl,@sewadarpersonal,@empChecked,@EmpKyc,@EmpKycBank,@EmpKycQulifc,@EmpKycFamily,@EmpWorkExp,@EmpStatelist,@EmpDistrict,@Hodlisted,@EmpDepartment)
                   send_data pdf.render,:filename => "1_lic_report.pdf", :type => "application/pdf", :disposition => "inline"
                end
             end
        elsif  docsid == 'BUILD'
            @voucherdata  =  print_common_list
            respond_to do |format|
                format.html
                format.pdf do
                   pdf = BuildPdf.new(@voucherdata,@compDetail,rooturl,@sewadarpersonal,@empChecked,@EmpKyc,@EmpKycBank,@EmpKycQulifc,@EmpKycFamily,@EmpWorkExp,@EmpStatelist,@EmpDistrict,@Hodlisted,@EmpDepartment)
                   send_data pdf.render,:filename => "1_build_report.pdf", :type => "application/pdf", :disposition => "inline"
                end
             end
        elsif  docsid == 'ELEC'
              @voucherdata  =  print_common_list
              respond_to do |format|
                  format.html
                  format.pdf do
                     pdf = ElecPdf.new(@voucherdata,@compDetail,rooturl,@sewadarpersonal,@empChecked,@EmpKyc,@EmpKycBank,@EmpKycQulifc,@EmpKycFamily,@EmpWorkExp,@EmpStatelist,@EmpDistrict,@Hodlisted,@EmpDepartment)
                     send_data pdf.render,:filename => "1_elec_report.pdf", :type => "application/pdf", :disposition => "inline"
                  end
               end
              elsif  docsid == 'ADVL'
                @voucherdata  =  [] #print_sewadar_salary
                respond_to do |format|
                    format.html
                    format.pdf do
                       pdf = AdvlPdf.new(@seawdarsobj,@compDetail,rooturl,@sewadarpersonal,@empChecked,@EmpKyc,@EmpKycBank,@EmpKycQulifc,@EmpKycFamily,@EmpWorkExp,@EmpStatelist,@EmpDistrict,@Hodlisted,@EmpDepartment)
                       send_data pdf.render,:filename => "1_advl_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                 end     
              
                elsif  docsid == 'HEAL'
                  @voucherdata  =   print_common_list
                  respond_to do |format|
                      format.html
                      format.pdf do
                         pdf = HealPdf.new(@voucherdata,@compDetail,rooturl,@sewadarpersonal,@empChecked,@EmpKyc,@EmpKycBank,@EmpKycQulifc,@EmpKycFamily,@EmpWorkExp,@EmpStatelist,@EmpDistrict,@Hodlisted,@EmpDepartment)
                         send_data pdf.render,:filename => "1_heal_report.pdf", :type => "application/pdf", :disposition => "inline"
                      end
                   end 
                  elsif  docsid == 'RESP'
                    @voucherdata  =  []
                    respond_to do |format|
                        format.html
                        format.pdf do
                           pdf = RespPdf.new(@seawdarsobj,@compDetail,rooturl,@sewadarpersonal,@empChecked,@EmpKyc,@EmpKycBank,@EmpKycQulifc,@EmpKycFamily,@EmpWorkExp,@EmpStatelist,@EmpDistrict,@Hodlisted,@EmpDepartment)
                           send_data pdf.render,:filename => "1_resp_report.pdf", :type => "application/pdf", :disposition => "inline"
                        end
                     end    
                  elsif  docsid == 'RESPWITHOUT'
                     @voucherdata  =  []
                     respond_to do |format|
                         format.html
                         format.pdf do
                            pdf = RespwithoutPdf.new(@seawdarsobj,@compDetail,rooturl,@sewadarpersonal,@empChecked,@EmpKyc,@EmpKycBank,@EmpKycQulifc,@EmpKycFamily,@EmpWorkExp,@EmpStatelist,@EmpDistrict,@Hodlisted,@EmpDepartment)
                            send_data pdf.render,:filename => "1_resp1_report.pdf", :type => "application/pdf", :disposition => "inline"
                         end
                      end    
 
                    elsif  docsid == 'EWS'
                      @voucherdata  =  print_common_list
                      respond_to do |format|
                          format.html
                          format.pdf do
                             pdf = EwsPdf.new(@voucherdata,@compDetail,rooturl,@sewadarpersonal,@empChecked,@EmpKyc,@EmpKycBank,@EmpKycQulifc,@EmpKycFamily,@EmpWorkExp,@EmpStatelist,@EmpDistrict,@Hodlisted,@EmpDepartment)
                             send_data pdf.render,:filename => "1_ews_report.pdf", :type => "application/pdf", :disposition => "inline"
                          end
                       end  
                      elsif  docsid == 'AOCA'
                        @voucherdata  =  [] #print_sewadar_salary
                        respond_to do |format|
                            format.html
                            format.pdf do
                               pdf = AocaPdf.new(@seawdarsobj,@compDetail,rooturl,@sewadarpersonal,@empChecked,@EmpKyc,@EmpKycBank,@EmpKycQulifc,@EmpKycFamily,@EmpWorkExp,@EmpStatelist,@EmpDistrict,@Hodlisted,@EmpDepartment)
                               send_data pdf.render,:filename => "1_aoca_report.pdf", :type => "application/pdf", :disposition => "inline"
                            end
                         end    
                        elsif  docsid == 'AOCWA'
                          @voucherdata  =  [] #print_sewadar_salary
                          respond_to do |format|
                              format.html
                              format.pdf do
                                 pdf = AocwaPdf.new(@seawdarsobj,@compDetail,rooturl,@sewadarpersonal,@empChecked,@EmpKyc,@EmpKycBank,@EmpKycQulifc,@EmpKycFamily,@EmpWorkExp,@EmpStatelist,@EmpDistrict,@Hodlisted,@EmpDepartment)
                                 send_data pdf.render,:filename => "1_aocwa_report.pdf", :type => "application/pdf", :disposition => "inline"
                              end
                           end   
                          elsif  docsid == 'BLMW'
                            monhlydata  =  print_new_sewadar_salary
                            respond_to do |format|
                                format.html
                                format.pdf do
                                   pdf = BlmwPdf.new(@seawdarsobj,@compDetail,rooturl,@sewadarpersonal,@empChecked,@EmpKyc,@EmpKycBank,@EmpKycQulifc,@EmpKycFamily,@EmpWorkExp,@EmpStatelist,@EmpDistrict,@Hodlisted,@EmpDepartment,monhlydata)
                                   send_data pdf.render,:filename => "1_blmw_report.pdf", :type => "application/pdf", :disposition => "inline"
                                end
                             end 
                            elsif  docsid == 'ITR'
                              @voucherdata  =  print_common_list
                              respond_to do |format|
                                  format.html
                                  format.pdf do
                                     pdf = ItrPdf.new(@voucherdata,@compDetail,rooturl,@sewadarpersonal,@empChecked,@EmpKyc,@EmpKycBank,@EmpKycQulifc,@EmpKycFamily,@EmpWorkExp,@EmpStatelist,@EmpDistrict,@Hodlisted,@EmpDepartment,session)
                                     send_data pdf.render,:filename => "1_itr_report.pdf", :type => "application/pdf", :disposition => "inline"
                                  end
                               end                     
        elsif  docsid[2] == 'bdexcel'
             @ExcelList    = nil
             $voucherdata  =  excel_birth_of_sewadar
            if @ExcelList !=nil              
                send_data @ExcelList.to_get_birthday_listed, :filename=> "birthday_sewadar_listed-#{Date.today}.csv"
            end
       elsif  docsid[2] == 'excel'
            @ExcelList = nil
           $voucherdata  =  print_sewadar_salary
           if @ExcelList !=nil              
               send_data @ExcelList.process_excel_data, :filename=> "salary_register-#{Date.today}.csv"
           end    
        elsif  docsid[2] == 'common'
                  types         = session[:my_sl_type]
                  @voucherdata  =  print_sewadar_salary
                  if types == 'LIC'
                      respond_to do |format|
                          format.html
                          format.pdf do
                             pdf = MonthlylicPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                             send_data pdf.render,:filename => "1_salary_lic_report.pdf", :type => "application/pdf", :disposition => "inline"
                          end
                       end
  
                 elsif  types == 'BUILD'
                      respond_to do |format|
                          format.html
                          format.pdf do
                             pdf = MonthlybuildingPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                             send_data pdf.render,:filename => "1_salary_accomodation_report.pdf", :type => "application/pdf", :disposition => "inline"
                            end
                          end
                 elsif  types == 'ELEC'
                      respond_to do |format|
                          format.html
                          format.pdf do
                             pdf = MonthlyelectricPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                             send_data pdf.render,:filename => "1_salary_electric_report.pdf", :type => "application/pdf", :disposition => "inline"
                            end
                          end
                 elsif  types == 'ADVL'
                      respond_to do |format|
                          format.html
                          format.pdf do
                             pdf = MonthlyadvancePdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                             send_data pdf.render,:filename => "1_salary_advance_loan_report.pdf", :type => "application/pdf", :disposition => "inline"
                            end
                          end
                  elsif  types == 'HEAL'
                      respond_to do |format|
                          format.html
                          format.pdf do
                             pdf = MonthlyhealthPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                             send_data pdf.render,:filename => "1_salary_health_report.pdf", :type => "application/pdf", :disposition => "inline"
                            end
                          end
                  end
                  
                  
                  elsif  docsid[2] == 'personal'
                  types         = session[:my_sl_type]
                  @voucherdata  =  print_sewadar_salary
                  if types == 'BIO'
                      
                      respond_to do |format|
                          format.html
                          format.pdf do
                             pdf = BiodataPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                             send_data pdf.render,:filename => "1_personal_details_report.pdf", :type => "application/pdf", :disposition => "inline"
                          end
                       end
  
                 elsif  types == 'CHARACTER'
                      respond_to do |format|
                          format.html
                          format.pdf do
                             pdf = CharPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                             send_data pdf.render,:filename => "1_character_certificate_report.pdf", :type => "application/pdf", :disposition => "inline"
                            end
                          end
                 elsif  types == 'HINDICHARACTER'
                      respond_to do |format|
                          format.html
                          format.pdf do
                             pdf = CharhindiPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                             send_data pdf.render,:filename => "1_hindi_character_certificate_report.pdf", :type => "application/pdf", :disposition => "inline"
                            end
                          end
                      end
                elsif  docsid[2] == 'pdfcard'
                      mycattype = session[:req_sewp_cat] 
                      if mycattype == 'SW'                      
                        @voucherdata = print_card_of_sewadar()
                      else
                        @voucherdata = print_card_of_members()
                      end                  
  
                      respond_to do |format|
                          format.html
                          format.pdf do
                             pdf = CardlistPdf.new(@voucherdata,@compDetail,mycattype,rooturl,session)
                             send_data pdf.render,:filename => "1_sewadar_card_report.pdf", :type => "application/pdf", :disposition => "inline"
                            end
                          end                          
                      
                    elsif  docsid[2] == 'excelcard'
                          @ExcelList    = nil
                          mycattype = session[:req_sewp_cat] 
                          if mycattype == 'SW' 
                             listeddata    = print_card_of_sewadar()
                            $categiry_name = listeddata[0].sw_catgeory                    
                            $voucherdata   = listeddata
                            
                          else
                            $categiry_name = session[:swp_sewa_member]
                            $voucherdata = print_card_of_members()
                          end                
      
                          
                          
                          if @ExcelList !=nil              
                              send_data @ExcelList.to_get_sewacard_listed, :filename=> "sewadar_card_listed-#{Date.today}.csv"
                          end                         
                          
                    end
  end
  
  end
 
  
  def ajax_process
         @compcodes       = session[:loggedUserCompCode]
         if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
            session[:reqtypes] = params[:types]
            session[:req_sewdarcode] = params[:sewacode]
            session[:req_printsewacode] = params[:printsewacode]
            respond_to do |format|
              format.json { render :json => { 'data'=>'', "message"=>'',:status=>true} }
            end
           return
        end

  end

  private
  def get_all_formats_data
   @compCodes       = session[:loggedUserCompCode]
   if session[:req_sewdarcode] !=nil && session[:req_sewdarcode] !=''       
         @seawdarsobj     = MstSewadar.where("sw_compcode =? AND sw_sewcode = ?",@compCodes,session[:req_sewdarcode]).first  
         
         if @seawdarsobj
               @sewadarpersonal = get_personal_information(@compCodes,@seawdarsobj.sw_sewcode)
               @empChecked      = get_office_information(@compCodes,@seawdarsobj.sw_sewcode)
               @EmpKyc          = get_sewadar_kyc_information(@compCodes,@seawdarsobj.sw_sewcode)
               @EmpKycBank      = get_sewadar_kyc_bankdetail(@compCodes,@seawdarsobj.sw_sewcode)
               @EmpKycQulifc    = get_sewadar_kyc_qualification(@compCodes,@seawdarsobj.sw_sewcode)
               @EmpKycFamily    = get_sewadar_kyc_family(@compCodes,@seawdarsobj.sw_sewcode)
               @EmpWorkExp      = get_sewadar_work_experience(@compCodes,@seawdarsobj.sw_sewcode)
               @EmpDepartment   = get_all_department_detail('DPT0011')
               if @sewadarpersonal
                  @EmpStatelist    = get_state_detail(@sewadarpersonal.sp_pres_state)
                  @EmpDistrict     = get_district_detail(@sewadarpersonal.sp_pres_distcity)
               end
               if @EmpDepartment
                  @Hodlisted      = get_first_my_sewadar(@EmpDepartment.departHod)   
               end
               
         end
         

    end

  end



  private
  def print_new_sewadar_salary
    @compCodes  = session[:loggedUserCompCode]
    pmssewacode = session[:req_sewdarcode]    
    finayear = session[:requestyear] 
    iswhere   = "pm_compcode ='#{@compcodes}' AND pm_paymonth >=4 AND pm_sewacode='#{pmssewacode}'"    
    arrpms    = []
    jons      = " JOIN mst_sewadars sewa ON( sw_compcode = pm_compcode AND sw_sewcode = pm_sewacode)"
    isselect  = "trn_pay_monthlies.*,sewa.id as sewid,sw_sewadar_name,sw_father_name,sw_joiningdate,sw_oldsewdarcode"
    isselect  += ",'' as deprtment,'' as designation,'' as bankaccount,'' as bankname,'' as ifscode,'' as statename,sw_depcode,sw_desigcode"
    isselect  += ", '' as pmactbasic,'' as pmarear,'' as pmbasic,'' as pmdedlicemployee,'' as pmdedaccomodatamount ,'' as pmdedelectricamount,'' as pmdedrepaidadvance,'' as pmdedrepaidloan "
    isselect  += ", '' as pmdedhealthsewdarpay,'' as pmincometaxamount,'' as pmtotaldeduction,'' as pmnetpay"
    isselect  += ", '' as uptosixty,'' as abovesixty,'' as exgratia,'' as maadvance,'' as wheatadvance,'' as specialadvance"
    isselect  += ", sw_catgeory as categoryname,sw_catcode,'' as monthname "
    pmsobj = TrnPayMonthly.select(isselect).joins(jons).where(iswhere).order("pm_paymonth ASC,pm_payyear ASC")
    
    if pmsobj.length >0
        
          pmsobj.each do |newsalry|            
                      bankaccount  = ""
                      deprtment    = ""
                      bksobj       = get_sewadar_kyc_bankdetail(@compcodes,newsalry.pm_sewacode)
                      if bksobj
                          newsalry.bankaccount  = bankaccount = bksobj.skb_accountno
                          newsalry.bankname     = bksobj.skb_bank
                          newsalry.ifscode      = bksobj.skb_ifccocde                  
                      end
                      sdpobj = get_all_department_detail(newsalry.sw_depcode)
                      if sdpobj
                         newsalry.deprtment = deprtment = sdpobj.departDescription
                      end
                      desobj = get_sewdar_designation_detail(newsalry.sw_desigcode)
                      if desobj
                          newsalry.designation = desobj.ds_description
                      end
                      sewinfobj = get_personal_information(@compcodes,newsalry.pm_sewacode)
                      newsalry.monthname = get_month_listed_data(newsalry.pm_paymonth)
                      if sewinfobj
                          statecpde   = sewinfobj.sp_pres_state
                          if statecpde !=nil && statecpde !=''
                              stsnonj = get_state_detail(statecpde)
                              if stsnonj
                                newsalry.statename = stsnonj.sts_description
                              end
                          end
                      end
                      arrpms.push  newsalry 
                      
             end
    end
    return arrpms
    
  end

##### ITR COLLECTION LIST
  private
  def print_common_list
    @compCodes  = session[:loggedUserCompCode]
    pmssewacode = session[:req_sewdarcode]     
      
     officeobj  = get_common_information(@compCodes,pmssewacode)
     arrpms = []
      if officeobj.length >0
            officeobj.each do |newitem|
                  sewobj = get_sewdara_inofrmation_first(newitem.so_sewcode)
                  if sewobj
                     newitem.sewadarname  = sewobj.sw_sewadar_name
                     newitem.sw_gender    = sewobj.sw_gender
                     newitem.sw_maritalstatus    = sewobj.sw_maritalstatus
                     newitem.sw_husbprefix    = sewobj.sw_husbprefix
                     newitem.sw_father_prefix    = sewobj.sw_father_prefix
                     newitem.sw_husbandname    = sewobj.sw_husbandname
                     newitem.sw_father_name    = sewobj.sw_father_name
                     newitem.sw_sewadar_prefix    = sewobj.sw_sewadar_prefix
                     newitem.sw_joiningdate    = sewobj.sw_joiningdate
                     newitem.accomodation       = sewobj.sw_isaccommodation
                  end
               arrpms.push  newitem 
            end        
               
               
      end
    
    return arrpms
    
  end

  private
  def get_sewdara_inofrmation_first(sewcode)
         compcode  = session[:loggedUserCompCode]
         sewdarobj =  MstSewadar.where("sw_compcode =? AND sw_sewcode =?",compcode,sewcode).first
         return sewdarobj
  end
  private
  def get_personal_information(compcode,empcode)
         sewdarobj =  MstSewadarPersonalInfo.where("sp_compcode =? AND sp_sewcode =?",compcode,empcode).first
         return sewdarobj
  end

  private
  def get_office_information(compcode,empcode)
         sewdarobj =  MstSewadarOfficeInfo.where("so_compcode =? AND so_sewcode =?",compcode,empcode).first
         return sewdarobj
  end

  private
  def get_common_information(compcode,empcode)
         isselect  = "mst_sewadar_office_infos.*,'' as sewadarname,so_sewcode as sw_sewcode,so_sewcode,'' as accomodation"
         isselect  +=",'' as sw_father_name,'' as sw_gender,'' as sw_maritalstatus,'' as sw_husbprefix,'' as sw_father_prefix,'' as sw_joiningdate,'' as sw_sewadar_prefix,'' as sw_sewadar_name,'' as sw_husbandname"
         sewdarobj =  MstSewadarOfficeInfo.select(isselect).where("so_compcode =? AND so_sewcode =?",compcode,empcode)
         return sewdarobj
  end

   private
  def get_roles_information(compcode,rspcode)
         sewdarobj =  MstResponsibility.where("rsp_compcode =? AND rsp_rspcode =?",compcode,rspcode).first
         return sewdarobj
  end

private
  def get_sewadar_kyc_information(compcode,sewcode)
       sewdarobj =  MstSewadarKyc.where("sk_compcode =? AND sk_sewcode =?",compcode,sewcode).first
       return sewdarobj
  end
  private
  def get_sewadar_kyc_bankdetail(compcode,sewcode)
       sewdarobj =  MstSewadarKycBank.where("skb_compcode =? AND sbk_sewcode =?",compcode,sewcode).first
       return sewdarobj
  end

  private
  def get_sewadar_kyc_qualification(compcode,sewcode)
       sewdarobj =  MstSewadarKycQualification.where("skq_compcode =? AND skq_sewcode = ?",compcode,sewcode).order("skq_passingyear DESC")
       return sewdarobj
  end

  private
  def get_sewadar_kyc_family(compcode,sewcode)
       sewdarobj =  MstSewdarKycFamilyDetail.where("skf_compcode =? AND skf_sewcode =?",compcode,sewcode).order("skf_dependent ASC")
       return sewdarobj
  end

  private
  def get_sewadar_work_experience(compcode,sewcode)
       sewdarobj =  MstSewadarWorkExperience.where("swe_compcode =? AND swe_sewcode =?",compcode,sewcode).order("swe_employer ASC")
       return sewdarobj
  end

end
