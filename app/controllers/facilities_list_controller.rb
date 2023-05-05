class FacilitiesListController < ApplicationController
    
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_sewdar_designation_detail,:get_all_department_detail
    helper_method :set_dct,:set_ent,:get_personal_information,:get_office_information,:get_roles_information,:format_oblig_date,:get_university_deegre_listed
    helper_method :get_sewa_all_department,:get_sewa_all_qualification,:get_sewa_all_rolesresp,:get_sewa_all_designation,:get_first_my_sewadar
  def index
     @compCodes         = session[:loggedUserCompCode]
     @mydepartcode      = ''
    
    
    @nbegindate        = 2021
   
    @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
    @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
    
    @printPath         =  "facilities_list/1_deduction_common_report.pdf"
    @ListDesignation   = Designation.where("compcode = ?",@compCodes).order("ds_description ASC")
  
    if session[:autherizedUserType] && session[:autherizedUserType].to_s != 'adm'
     @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =? AND sw_depcode = ?",@compCodes,@mydepartcode)
    else
      @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =?",@compCodes)
   end
     
  end
  ### SEWADAR REPORT ANALYSIS ###

  def show
     @compcodes     = session[:loggedUserCompCode]
     @compDetail    = MstCompany.where(["cmp_companycode = ?", @compcodes]).first
      rooturl       = "#{root_url}"
      if params[:id] != nil && params[:id] != ''
        docsid  = params[:id].to_s.split("_")
  
        if  docsid[2] == 'common'
                  types         = session[:my_sl_type]
                  @voucherdata  =  print_sewadar_salary
                  if types == 'LIC'
                      respond_to do |format|
                          format.html
                          format.pdf do
                             pdf = MonthlyliclistPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                             send_data pdf.render,:filename => "1_salary_lic_report.pdf", :type => "application/pdf", :disposition => "inline"
                          end
                       end
  
                 elsif  types == 'BUILD'
                      respond_to do |format|
                          format.html
                          format.pdf do
                             pdf = MonthlybuildinglistPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                             send_data pdf.render,:filename => "1_salary_accomodation_report.pdf", :type => "application/pdf", :disposition => "inline"
                            end
                          end
                 elsif  types == 'ELEC'
                      respond_to do |format|
                          format.html
                          format.pdf do
                             pdf = MonthlyelectriclistPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                             send_data pdf.render,:filename => "1_salary_electric_report.pdf", :type => "application/pdf", :disposition => "inline"
                            end
                          end
                 elsif  types == 'ADVL'
                      respond_to do |format|
                          format.html
                          format.pdf do
                             pdf = MonthlyadvancelistPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                             send_data pdf.render,:filename => "1_salary_advance_loan_report.pdf", :type => "application/pdf", :disposition => "inline"
                            end
                          end
                  elsif  types == 'HEAL'
                      respond_to do |format|
                          format.html
                          format.pdf do
                             pdf = MonthlyhealthlistPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                             send_data pdf.render,:filename => "1_salary_health_report.pdf", :type => "application/pdf", :disposition => "inline"
                            end
                          end
                  elsif  types == 'MA'
                          respond_to do |format|
                              format.html
                              format.pdf do
                                 pdf = MonthlymaviewPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                                 send_data pdf.render,:filename => "1_ma_report.pdf", :type => "application/pdf", :disposition => "inline"
                                end
                              end
                  end
                  
                  
                 
        end
  end
  
  end
  
  
 
  
  def monthly_deduction
    @compCodes         = session[:loggedUserCompCode]
    @nbegindate        = 2021
    @mydepartcode      = ''
    @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
    @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
    @familylisted      = total_sewadar_kyc_family(@compCodes)
    @printPath         =  "facilities_list/1_deduction_common_report.pdf"
    @ListDesignation   = Designation.where("compcode = ?",@compCodes).order("ds_description ASC")
  
    if session[:autherizedUserType] && session[:autherizedUserType].to_s != 'adm'
     @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =? AND sw_depcode = ?",@compCodes,@mydepartcode)
    else
      @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =?",@compCodes)
   end
  
  end
  
 
  
  def new_sewadar_user
    session[:request_processlogid] = nil
    redirect_to "#{root_url}sewadar_information/add_sewadar"
  end
  def create
    
  end
  
  def sewadar_info_grid
    
  end
  
  def ajax_process
    @compcodes  = session[:loggedUserCompCode]
    if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
      get_sewadar_info();
      return
    elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'DAILYRPT'
      get_attendance_performance();
      return
    end
  
  
  
  
  
  
  end
  
  private
  def get_sewadar_info
    session[:my_sl_years]      = nil
    session[:my_sl_months]     = nil
    session[:my_sl_depart]     = nil
    session[:my_sl_category]   = nil
    session[:my_sl_refrence]   = nil
    session[:my_sl_searchstr]  = nil
    session[:my_sl_type]       = nil
    session[:print_excel_type] = nil
    session[:my_bankname]      = nil
    session[:my_bankname]      = nil
    years       = params[:years]
    months      = params[:months] !=nil && params[:months] != '' ? params[:months] : ''
    
    sedep       = params[:sedep]
    sewcatg     = params[:sewcatg]
    refecoename = params[:refecoename]
    sewsearches = params[:sewsearches]
    sltype      = params[:sltype]
    bankname    = params[:bankname]
    mybanks     = false
    if params[:printtype] !=''  && params[:printtype] != nil
      session[:print_excel_type] = params[:printtype]
    end
  
    if months.to_i >=4 
       genfinalyear = years.to_s+"-"+(years.to_i+1).to_s
    else
       genfinalyear = (years.to_i-1).to_s+"-"+years.to_s
    end 
    iswhere = "sw_compcode ='#{@compcodes}' "#AND pm_financialyear='#{genfinalyear}'
    
  
    # if years !=nil && years !=''
    #   iswhere += " AND pm_payyear ='#{years}'"
    #   session[:my_sl_years] = years
    # end
    # if months !=nil && months !=''
    #   iswhere += " AND pm_paymonth ='#{months}'"
    #   session[:my_sl_months] = months
    # end
    if sedep !=nil && sedep !=''
      iswhere += " AND sw_depcode ='#{sedep}'"
       session[:my_sl_depart] = sedep
    end
    if sewcatg !=nil && sewcatg !=''
      iswhere += " AND sw_catgeory ='#{sewcatg}'"
      session[:my_sl_category] = sewcatg
    end
    
    if refecoename !=nil && refecoename !=''
        session[:my_sl_refrence] = refecoename
        if sewsearches !=nil && sewsearches !=''
          session[:my_sl_searchstr] = sewsearches
  
              if refecoename == 'mycode'
               iswhere += " AND sw_sewcode ='#{sewsearches}'"
             elsif refecoename == 'myrefcode'
               iswhere += " AND sw_oldsewdarcode ='#{sewsearches}'"
             elsif refecoename == 'myname'
               iswhere += " AND sw_sewadar_name LIKE '%#{sewsearches}%'"
             elsif refecoename == 'mymobile'
               iswhere += " AND sw_mobile ='#{sewsearches}'"
             elsif refecoename == 'myemail'
               iswhere += " AND sw_email ='#{sewsearches}'"
             end
        end
    end
    
    if sltype !=nil && sltype !='' && sltype =='LIC'
         session[:my_sl_type]  = sltype
         iswhere += " AND so_licgroup ='Y'"
    elsif sltype !=nil && sltype !='' && sltype =='BUILD'
         session[:my_sl_type]  = sltype
         iswhere += " AND sw_isaccommodation='Y'"
    elsif sltype !=nil && sltype !='' && sltype =='ELEC'
         session[:my_sl_type]  = sltype
         iswhere += " AND sw_iselectricconsump='Y'"
   
    elsif sltype !=nil && sltype !='' && sltype =='HEAL'
         session[:my_sl_type]  = sltype
         iswhere += " AND so_healthinsurance='Y'"   
    elsif sltype !=nil && sltype !='' && sltype =='MA'
      session[:my_sl_type]  = sltype
      iswhere += " AND AND so_basic>0"   
         
    end
    
    isflags   = false
    message   = ""
    jons      = " LEFT JOIN mst_sewadar_office_infos office ON( sw_compcode = so_compcode AND sw_sewcode = so_sewcode)"
    isselect  =  "mst_sewadars.id as sewid,office.id as officeId" 
    pmsobj    = MstSewadar.select(isselect).joins(jons).where(iswhere).order("sw_sewcode ASC")
    if pmsobj.length >0
      isflags = true
      message ="Success"
    end
    respond_to do |format|
      format.json { render :json => { 'data'=>'', "message"=>message,:status=>isflags} }
    end
  end
  
  
  private
  def print_sewadar_salary
    years       = session[:my_sl_years]
    months      = session[:my_sl_months]
    sedep       = session[:my_sl_depart]
    sewcatg     = session[:my_sl_category]
    refecoename = session[:my_sl_refrence]
    sewsearches = session[:my_sl_searchstr]
    sltype      = session[:my_sl_type]
    bankname   =  session[:my_bankname]
    
    iswhere = "sw_compcode ='#{@compcodes}' "
    # if years !=nil && years !=''
    #   iswhere += " AND pm_payyear ='#{years}'"
    # end
   
    # if months !=nil && months !=''
    #   iswhere += " AND pm_paymonth ='#{months}'"
    # end
   # sedep= "DPT0008"
    if sedep !=nil && sedep !=''
      iswhere += " AND sw_depcode ='#{sedep}'"
    end
    if sewcatg !=nil && sewcatg !=''
      iswhere += " AND TRIM(sw_catgeory) =TRIM('#{sewcatg}')"
    end
    
  
   
  
    if refecoename !=nil && refecoename !=''
      if sewsearches !=nil && sewsearches !=''
          if refecoename == 'mycode'
           iswhere += " AND sw_sewcode ='#{sewsearches}'"
         elsif refecoename == 'myrefcode'
           iswhere += " AND sw_oldsewdarcode ='#{sewsearches}'"
         elsif refecoename == 'myname'
           iswhere += " AND sw_sewadar_name LIKE '%#{sewsearches}%'"
         elsif refecoename == 'mymobile'
           iswhere += " AND sw_mobile ='#{sewsearches}'"
         elsif refecoename == 'myemail'
           iswhere += " AND sw_email ='#{sewsearches}'"
         end
      end
    end
    if sltype !=nil && sltype !='' && sltype =='LIC'
        session[:my_sl_type]  = sltype
        iswhere += " AND so_licgroup ='Y'"
   elsif sltype !=nil && sltype !='' && sltype =='BUILD'
        session[:my_sl_type]  = sltype
        iswhere += " AND sw_isaccommodation='Y'"
   elsif sltype !=nil && sltype !='' && sltype =='ELEC'
        session[:my_sl_type]  = sltype
        iswhere += " AND sw_iselectricconsump='Y'"
  
   elsif sltype !=nil && sltype !='' && sltype =='HEAL'
        session[:my_sl_type]  = sltype
        iswhere += " AND so_healthinsurance='Y'"   
      elsif sltype !=nil && sltype !='' && sltype =='HEAL'
        session[:my_sl_type]  = sltype
        iswhere += " AND so_basic>0" 
  
        
   end
    arrpms    = []
    
    isselect  =  "mst_sewadars.*,mst_sewadars.id as sewid,office.id as officeId,''as departname,so_licgroup,so_healthinsurance,so_healthslab,'' as accomodationname,so_basic" 
    jons      = " LEFT JOIN mst_sewadar_office_infos office ON( sw_compcode = so_compcode AND sw_sewcode = so_sewcode)"
    pmsobj    = MstSewadar.select(isselect).joins(jons).where(iswhere).order("sw_sewcode ASC")
    arraitem   = []
    if pmsobj.length >0
      pmsobj.each do |newrqst|
      requehead = get_department_detail(newrqst.sw_depcode)
      if requehead
        newrqst.departname  =  requehead.departDescription
       
      end
      requehead =  get_accomodation_types(newrqst.sw_accomodationtype)
      if requehead
        newrqst.accomodationname  =  requehead.at_description
       
      end
      arraitem.push newrqst
    end
  end 
    return pmsobj
    
  end
  
  
  


  
  private
  def get_department_counts(departcode)
    
         compcode  =  session[:loggedUserCompCode]
         mycounts  = 0
         sewdarobj =  MstSewadar.select("COUNT(sw_depcode) as totaldepartment").where("sw_compcode =? AND sw_depcode =?",compcode,departcode).first
         if sewdarobj
            mycounts = sewdarobj.totaldepartment
         end
         return mycounts
  end
  
  private
  def get_sewdara_inofrmation_first(sewcode)
         compcode  = session[:loggedUserCompCode]
         sewdarobj =  MstSewadar.select("sw_depcode").where("sw_compcode =? AND sw_sewcode =?",compcode,sewcode).first
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
  def get_total_strength(deprtment,loc,types)
      counts     = 0
      compcodes  =  session[:loggedUserCompCode]
      if types.to_s == 'ARS'
        sewdobj    =  MstSewadar.where("sw_compcode = ? AND sw_location = ? AND sw_leavingdate='0000-00-00'",compcodes,loc)
      else
        sewdobj    =  MstSewadar.where("sw_compcode = ? AND sw_depcode = ? AND sw_leavingdate='0000-00-00'",compcodes,deprtment)
      end
      
      if sewdobj.length >0
         counts = sewdobj.length
      end
      return counts
  end
  private
  def get_department_detail(dscode)
      compcode =  session[:loggedUserCompCode]
      disobj   =  Department.where("compCode= ? AND departCode = ? AND subdepartment=''",compcode,dscode).first
      return disobj
  end
  private
  def get_accomodation_types(id)
     compcodes  = session[:loggedUserCompCode]
     acoobjs    = MstAccomodationType.where("at_compcode =? AND id =?",compcodes,id).first
     return acoobjs
  end
end
