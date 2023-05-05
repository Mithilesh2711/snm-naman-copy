class SummaryReportsController < ApplicationController

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
    
    @printPath         =  "summary_reports/1_summary_common_report.pdf"
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
          @voucherdata  =  print_sewadar_summary
          if types == 'MW'
              respond_to do |format|
                  format.html
                  format.pdf do
                     pdf = SummarymonthwisePdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                     send_data pdf.render,:filename => "1_month_wise_report.pdf", :type => "application/pdf", :disposition => "inline"
                  end
               end
  
         elsif  types == 'DW'
              respond_to do |format|
                  format.html
                  format.pdf do
                     pdf = SummarydepartmentwisePdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                     send_data pdf.render,:filename => "1_department_wise_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                  end
         elsif  types == 'MIW'
              respond_to do |format|
                  format.html
                  format.pdf do
                     pdf = SummarymiwisePdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                     send_data pdf.render,:filename => "1_mi_wise_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                  end
         elsif  types == 'CW'
              respond_to do |format|
                  format.html
                  format.pdf do
                     pdf = SummarycategorywisePdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                     send_data pdf.render,:filename => "1_category_wise_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                  end
          elsif  types == 'ER'
              respond_to do |format|
                  format.html
                  format.pdf do
                     pdf = SummaryexceptionreportPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                     send_data pdf.render,:filename => "1_exception_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                  end
          
          end
     
  end
  end
  
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
    
    years       = params[:years]
    months      = params[:months] !=nil && params[:months] != '' ? params[:months] : ''
    sedep       = params[:sedep]
    sewcatg     = params[:sewcatg]
    refecoename = params[:refecoename]
    sewsearches = params[:sewsearches]
    sltype      = params[:sltype]
    
    iswhere = "al_compcode ='#{@compcodes}' "#AND pm_financialyear='#{genfinalyear}'
  
    if years !=nil && years !=''
      iswhere += " AND YEAR(al_requestdate) ='#{years}'"
      session[:my_sl_years] = years
    end
    if months !=nil && months !=''
      iswhere += " AND MONTH(al_requestdate) ='#{months}'"
      session[:my_sl_months] = months
    end
    if sedep !=nil && sedep !=''
      iswhere += " AND al_depcode ='#{sedep}'"
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
             iswhere += " AND al_sewadarcode ='#{sewsearches}'"
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
  if sltype !=nil && sltype !='' && sltype =='MW'
    session[:my_sl_type]  = sltype
   # iswhere += " AND al_balances >0"
elsif sltype !=nil && sltype !='' && sltype =='DW'
    session[:my_sl_type]  = sltype
   # iswhere += " AND al_balances >0"
elsif sltype !=nil && sltype !='' && sltype =='MIW'
     session[:my_sl_type]  = sltype
     iswhere += " AND al_approvedby >0"

elsif sltype !=nil && sltype !='' && sltype =='CW'
    session[:my_sl_type]  = sltype
    iswhere += " AND  sw_catcode <>''"   
  elsif sltype !=nil && sltype !='' && sltype =='ER'
    session[:my_sl_type]  = sltype
    iswhere += " AND al_balances >0" 
  
end
    
    isflags   = false
    message   = ""
    jons      = " LEFT JOIN mst_sewadars sewa ON( al_compcode = sw_compcode AND al_sewadarcode = sw_sewcode)"
    pmsobj    = TrnAdvanceLoan.joins(jons).where(iswhere).order("al_sewadarcode ASC")
    if pmsobj.length >0
      isflags = true
      message ="Success"
    end
    respond_to do |format|
      format.json { render :json => { 'data'=>'', "message"=>message,:status=>isflags} }
    end
  end
  
  
  private
  def print_sewadar_summary
    years       = session[:my_sl_years]
    months      = session[:my_sl_months]
    sedep       = session[:my_sl_depart]
    sewcatg     = session[:my_sl_category]
    refecoename = session[:my_sl_refrence]
    sewsearches = session[:my_sl_searchstr]
    sltype      = session[:my_sl_type]
   
    
    iswhere = "al_compcode='#{@compcodes}' "
    if years !=nil && years !=''
      iswhere += " AND YEAR(al_requestdate) ='#{years}'"
    end
    if months !=nil && months !=''
      iswhere += " AND MONTH(al_requestdate) ='#{months}'"
    end
    if sedep !=nil && sedep !=''
      iswhere += " AND al_depcode ='#{sedep}'"
    end
    if sewcatg !=nil && sewcatg !=''
      iswhere += " AND TRIM(sw_catgeory) =TRIM('#{sewcatg}')"
    end
   
  
    if refecoename !=nil && refecoename !=''
      if sewsearches !=nil && sewsearches !=''
          if refecoename == 'mycode'
           iswhere += " AND al_sewadarcode ='#{sewsearches}'"
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
    if sltype !=nil && sltype !='' && sltype =='MW'
        session[:my_sl_type]  = sltype
       # iswhere += " AND al_balances >0"
    elsif sltype !=nil && sltype !='' && sltype =='DW'
        session[:my_sl_type]  = sltype
       # iswhere += " AND al_balances >0"
    elsif sltype !=nil && sltype !='' && sltype =='MIW'
         session[:my_sl_type]  = sltype
         iswhere += " AND al_approvedby >0"
    
    elsif sltype !=nil && sltype !='' && sltype =='CW'
        session[:my_sl_type]  = sltype
        iswhere += " AND  sw_catcode <>''"   
      elsif sltype !=nil && sltype !='' && sltype =='ER'
        session[:my_sl_type]  = sltype
        iswhere += " AND al_balances >0" 
      
    end
    arrpms    = []

    jons      = " LEFT JOIN mst_sewadars sewa ON( al_compcode = sw_compcode AND al_sewadarcode = sw_sewcode)"
   isselect   = "trn_advance_loans.*,'' as sewaid,'' as sw_sewadar_name,'' as sw_father_name,'' as sw_joiningdate,'' as sw_date_of_birth,'' as sw_oldsewdarcode, '' as categoryname,'' as sw_catcode,''as departname"
   isselect  += ", '' as so_superannuationdate,''as sanctionamount,MONTH(al_requestdate) as months,YEAR(al_requestdate) as years"
   isselect  += ",''as totalrepaid ,''as memberincharge"
   isselect  += ",SUM(al_balances) as totaloutstanding,sum(al_installpermonth) as totalinstallment"
   pmsobj    = TrnAdvanceLoan.select(isselect).joins(jons).where(iswhere).order("al_sewadarcode ASC")
    if sltype !=nil && sltype !='' && sltype =='MW'
       pmsobj    = TrnAdvanceLoan.select(isselect).joins(jons).where(iswhere).group("MONTH(al_requestdate)").order("MONTH(al_requestdate) ASC")

    elsif  sltype !=nil && sltype !='' && sltype =='DW'
       pmsobj    = TrnAdvanceLoan.select(isselect).joins(jons).where(iswhere).group("al_depcode").order("al_depcode ASC")

    elsif  sltype !=nil && sltype !='' && sltype =='MIW'  
       pmsobj    = TrnAdvanceLoan.select(isselect).joins(jons).where(iswhere).group("al_approvedby").order("al_sewadarcode ASC")


    elsif  sltype !=nil && sltype !='' && sltype =='CW' 
       pmsobj    = TrnAdvanceLoan.select(isselect).joins(jons).where(iswhere).group("sw_catcode").order("al_sewadarcode ASC")

    elsif sltype !=nil && sltype !='' && sltype =='ER'  
      pmsobj    = TrnAdvanceLoan.select(isselect).joins(jons).where(iswhere).group("al_sewadarcode").order("al_sewadarcode ASC")

    end
    
    arraitem   = []
  if pmsobj.length >0
    pmsobj.each do |newrqst|            
      
      sewdarobjs = get_mysewdar_list_details(newrqst.al_sewadarcode)
      if sewdarobjs
        newrqst.sw_sewadar_name  = sewdarobjs.sw_sewadar_name
        newrqst.sw_father_name   = sewdarobjs.sw_father_name
        newrqst.sw_joiningdate   = sewdarobjs.sw_joiningdate
        newrqst.sw_date_of_birth = sewdarobjs.sw_date_of_birth
        newrqst.sw_oldsewdarcode = sewdarobjs.sw_oldsewdarcode
        newrqst.categoryname     = sewdarobjs.sw_catgeory
        newrqst.sw_catcode       = sewdarobjs.sw_catcode
      end
      officeobjs = get_office_information(newrqst.al_compcode,newrqst.al_sewadarcode)
      if officeobjs
        newrqst.so_superannuationdate  = officeobjs.so_superannuationdate
       
      end
      deprtcode = ""
      
      if  sltype !=nil && sltype !='' && sltype =='DW'
        deprtcode = newrqst.al_depcode
      end
      if sewsearches !=nil && sewsearches !=''
       
        sancobjs = get_sanction_detail(newrqst.al_compcode,newrqst.al_sewadarcode,newrqst.months,newrqst.years,deprtcode)
      else
       
        sancobjs = get_sanction_detail(newrqst.al_compcode,'',newrqst.months,newrqst.years,deprtcode)
      end
     
      if sancobjs
       
        newrqst.sanctionamount = sancobjs.sanctamount
    
      end
       membobj = user_detail(newrqst.al_approvedby)
       if membobj
        mebobj = get_member_listed(membobj.ecmember)
          if mebobj
            newrqst.memberincharge  = mebobj.lds_name
          end
       end
      requehead = get_department_detail(newrqst.al_depcode)
      if requehead
        newrqst.departname  =  requehead.departDescription
        
      end
      if sewsearches !=nil && sewsearches !=''
        payhead = get_total_deduction_month(newrqst.al_compcode,newrqst.al_sewadarcode,newrqst.months,newrqst.years,deprtcode)
      else
        payhead = get_total_deduction_month(newrqst.al_compcode,'',newrqst.months,newrqst.years,deprtcode)
      end
     
      if payhead
        newrqst.totalrepaid  =  payhead.totalpaid
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
  
  private
  def get_total_deduction_month(compcodes,sewacode,months,years,depat="")
      compcodes  = session[:loggedUserCompCode]
      iswhere     = "pm_compcode='#{compcodes}' AND pm_paymonth='#{months}' and pm_payyear='#{years}'"
      if sewacode !=nil && sewacode !=''
        iswhere     = "pm_sewacode='#{sewacode}'"
      end 
      if depat !=nil && depat !=''
       
        iswhere += " AND sw_depcode ='#{depat}'"
        jons      = " LEFT JOIN mst_sewadars sewa ON( pm_compcode = sw_compcode AND pm_sewacode = sw_sewcode)"
        mthsobj = TrnPayMonthly.select("(SUM(pm_ded_repaidadvance)+SUM(pm_ded_repaidloan)) as totalpaid").joins(jons).where(iswhere).first
      else
      
      mthsobj    = TrnPayMonthly.select("(SUM(pm_ded_repaidadvance)+SUM(pm_ded_repaidloan)) as totalpaid").where(iswhere).first
      end
      return mthsobj
  end
  private
def get_sanction_detail(compcodes,sewacode,months,years,depat="")
     compcodes  = session[:loggedUserCompCode]
     iswhere     = "vd_compcode='#{compcodes}' AND MONTH(vd_requestdate)='#{months}' AND YEAR(vd_requestdate)='#{years}'"
      if sewacode !=nil && sewacode !=''
        iswhere     = "vd_sewadarcode ='#{sewacode}'"
      end 
      if depat !=nil && depat !=''
        iswhere += " AND sw_depcode ='#{depat}'"
        jons      = " LEFT JOIN mst_sewadars sewa ON( vd_compcode = sw_compcode AND vd_sewadarcode = sw_sewcode)"
        loansobj = TrnVoucherDetail.select("SUM(vd_reqamount) as sanctamount").joins(jons).where(iswhere).first
      else
        loansobj = TrnVoucherDetail.select("SUM(vd_reqamount) as sanctamount").where(iswhere).first
      end
     
     return loansobj

end
end
