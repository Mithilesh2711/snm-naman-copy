class AdvanceReportController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_sewdar_designation_detail,:get_all_department_detail
  helper_method :set_dct,:set_ent,:get_personal_information,:get_office_information,:get_roles_information,:format_oblig_date,:get_university_deegre_listed
  helper_method :get_sewa_all_department,:get_sewa_all_qualification,:get_sewa_all_rolesresp,:get_sewa_all_designation,:get_first_my_sewadar,:get_mysewdar_list_details
def index
   @compCodes         = session[:loggedUserCompCode]
   @mydepartcode      = ''
  
  @nbegindate        = 2021
 
  @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
  @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
  
  @printPath         =  "advance_report/1_advance_common_report.pdf"
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
        @voucherdata  =  print_sewadar_advance
        if types == 'AD'
            respond_to do |format|
                format.html
                format.pdf do
                   pdf = AdvancedetailPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                   send_data pdf.render,:filename => "1_advance_detail_report.pdf", :type => "application/pdf", :disposition => "inline"
                end
             end

       elsif  types == 'FHR'
            respond_to do |format|
                format.html
                format.pdf do
                   pdf = ForwardhrdetailPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                   send_data pdf.render,:filename => "1_forward_hr_detail_report.pdf", :type => "application/pdf", :disposition => "inline"
                  end
                end
       elsif  types == 'PR'
            respond_to do |format|
                format.html
                format.pdf do
                   pdf = PendingadvancedetailPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                   send_data pdf.render,:filename => "1_pending_requests_report.pdf", :type => "application/pdf", :disposition => "inline"
                  end
                end
       elsif  types == 'SA'
            respond_to do |format|
                format.html
                format.pdf do
                   pdf = SanctionedadvancedetailPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                   send_data pdf.render,:filename => "1_sanctioned_advances_report.pdf", :type => "application/pdf", :disposition => "inline"
                  end
                end
        elsif  types == 'OAA'
            respond_to do |format|
                format.html
                format.pdf do
                   pdf = OutstandingadvanceamountdetailPdf.new(@voucherdata,@compDetail,rooturl,@username,@inchargename)
                   send_data pdf.render,:filename => "1_outstanding_advance_report.pdf", :type => "application/pdf", :disposition => "inline"
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
  @printPath         =  "advance_report/1_deduction_common_report.pdf"
  @ListDesignation   = Designation.where("compcode = ?",@compCodes).order("ds_description ASC")

  if session[:autherizedUserType] && session[:autherizedUserType].to_s != 'adm'
   @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =? AND sw_depcode = ?",@compCodes,@mydepartcode)
  else
    @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =?",@compCodes)
 end

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
  # session[:my_sl_years]        = nil
  # session[:my_sl_months]       = nil
  session[:my_sl_depart]         = nil
  session[:my_sl_category]       = nil
  session[:my_sl_refrence]       = nil
  session[:my_sl_searchstr]      = nil
  session[:my_sl_type]           = nil
  session[:print_excel_type]     = nil
  session[:sewdar_requesttype]   = nil
  session[:search_fromdated]     = nil
  session[:search_uptodated]     = nil
 
  # # years       = params[:years]
  # # months      = params[:months] !=nil && params[:months] != '' ? params[:months] : ''
  
  sedep       = params[:sedep]
  sewcatg     = params[:sewcatg]
  refecoename = params[:refecoename]
  sewsearches = params[:sewsearches]
  sltype      = params[:sltype]
  requesttype = params[:sewdar_requesttype]
  fromdated   = year_month_days_formatted(params[:fromdated])
  uptodated   = year_month_days_formatted(params[:uptodated])
  # mybanks     = false
  # if params[:printtype] !=''  && params[:printtype] != nil
  #   session[:print_excel_type] = params[:printtype]
  # end

  # if months.to_i >=4 
  #    genfinalyear = years.to_s+"-"+(years.to_i+1).to_s
  # else
  #    genfinalyear = (years.to_i-1).to_s+"-"+years.to_s
  # end 
  iswhere = "al_compcode ='#{@compcodes}'"#AND pm_financialyear='#{genfinalyear}'
  

  # if years !=nil && years !=''
  #   iswhere += " AND pm_payyear ='#{years}'"
  #   session[:my_sl_years] = years
  # end
  # if months !=nil && months !=''
  #   iswhere += " AND pm_paymonth ='#{months}'"
  #   session[:my_sl_months] = months
  # end
  if sedep !=nil && sedep !=''
    iswhere += " AND al_depcode ='#{sedep}'"
     session[:my_sl_depart] = sedep
  end
  if sewcatg !=nil && sewcatg !=''
    iswhere += " AND sw_catgeory ='#{sewcatg}'"
    session[:my_sl_category] = sewcatg
  end
  if requesttype !=nil && requesttype !=''
    iswhere += " AND al_requesttype ='#{requesttype}'"
    session[:sewdar_requesttype] = requesttype
  end
  if fromdated !=nil && fromdated !=''
    iswhere += " AND al_requestdate >='#{fromdated}'"
    session[:search_fromdated] = fromdated
  end
  if uptodated !=nil && uptodated !=''
    iswhere += " AND al_requestdate <='#{uptodated}'"
    session[:search_uptodated] = uptodated
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
  
  if sltype !=nil && sltype !='' && sltype =='AD'
    session[:my_sl_type]  = sltype
    iswhere += " AND al_approvestatus <>'C'"
elsif sltype !=nil && sltype !='' && sltype =='FHR'
    session[:my_sl_type]  = sltype
    iswhere += " AND al_approvestatus ='F'"
elsif sltype !=nil && sltype !='' && sltype =='PR'
    session[:my_sl_type]  = sltype
    iswhere += " AND al_approvestatus='P'"

elsif sltype !=nil && sltype !='' && sltype =='SA'
    session[:my_sl_type]  = sltype
    iswhere += " AND al_approvestatus='A' AND al_broucherno<>''"   
  elsif sltype !=nil && sltype !='' && sltype =='OAA'
    session[:my_sl_type]  = sltype
    iswhere += " AND al_balances>0" 
  
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
def print_sewadar_advance
  # years       = session[:my_sl_years]
  # months      = session[:my_sl_months]
  sedep       = session[:my_sl_depart]
  sewcatg     = session[:my_sl_category]
  refecoename = session[:my_sl_refrence]
  sewsearches = session[:my_sl_searchstr]
  sltype      = session[:my_sl_type]
  requesttype = session[:sewdar_requesttype]
  fromdated   = session[:search_fromdated]
  uptodated   = session[:search_uptodated]
  # bankname   =  session[:my_bankname]
  reqdated     = ""
  @HeadHrp    =  MstHrParameterHead.where("hph_compcode = ?",@compcodes).first
  if @HeadHrp
      reqdated = @HeadHrp.hph_years.to_s+"-"+@HeadHrp.hph_months.to_s+"-01"
  end
  iswhere = "al_compcode ='#{@compcodes}' "

  if sedep !=nil && sedep !=''
    iswhere += " AND al_depcode ='#{sedep}'"
  end
  if sewcatg !=nil && sewcatg !=''
    iswhere += " AND TRIM(sw_catgeory) =TRIM('#{sewcatg}')"
  end
  if requesttype !=nil && requesttype !=''
    iswhere += " AND al_requesttype ='#{requesttype}'"
  end
  if fromdated !=nil && fromdated !=''
    iswhere += " AND al_requestdate >='#{fromdated}'"
  end
  if uptodated !=nil && uptodated !=''
    iswhere += " AND al_requestdate <='#{uptodated}'"
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
  if sltype !=nil && sltype !='' && sltype =='AD'
    session[:my_sl_type]  = sltype
    iswhere += " AND al_approvestatus <>'C'"
elsif sltype !=nil && sltype !='' && sltype =='FHR'
    session[:my_sl_type]  = sltype
    iswhere += " AND al_approvestatus ='F'"
elsif sltype !=nil && sltype !='' && sltype =='PR'
    session[:my_sl_type]  = sltype
    iswhere += " AND al_approvestatus='P'"

elsif sltype !=nil && sltype !='' && sltype =='SA'
    session[:my_sl_type]  = sltype
    iswhere += " AND al_approvestatus='A' AND al_broucherno<>''"   
  elsif sltype !=nil && sltype !='' && sltype =='OAA'
    session[:my_sl_type]  = sltype
    iswhere += " AND al_balances >0" 
  
end
  arrpms    = []
  jons      = " LEFT JOIN mst_sewadars sewa ON( al_compcode = sw_compcode AND al_sewadarcode = sw_sewcode)"
  isselect  = "trn_advance_loans.*,'' as sewid,'' as sw_sewadar_name,'' as sw_father_name,'' as sw_joiningdate,'' as sw_date_of_birth,'' as sw_oldsewdarcode, '' as categoryname,'' as sw_catcode,''as departname"
  isselect  += ", '' as so_superannuationdate,'' as so_regularizationdate,'' as memberincharge,''as skb_ifccocde,''as skb_accountno,''as skb_bank,''as approvedby,''as sanctionno,''as sanctiondate,'' as leftinstallmentdate"
  
  if sltype !=nil && sltype !='' && sltype =='OAA'
   isselect  = "trn_advance_loans.*,'' as sewid,'' as sw_sewadar_name,'' as sw_father_name,'' as sw_joiningdate,'' as sw_date_of_birth,'' as sw_oldsewdarcode, '' as categoryname,'' as sw_catcode,''as departname"
  isselect  += ", '' as so_superannuationdate,'' as so_regularizationdate,'' as memberincharge,''as skb_ifccocde,''as skb_accountno,''as skb_bank,''as approvedby,''as sanctionno,''as sanctiondate,'' as leftinstallmentdate"
  isselect  += ",(SUM(al_advanceamt)+SUM(al_loanamount)) as advancetotal,sum(al_installpermonth) as totalinstallment,SUM(al_balances) as totaloutstanding"
   pmsobj    = TrnAdvanceLoan.select(isselect).joins(jons).where(iswhere).group("al_sewadarcode").order("al_sewadarcode ASC")
  else
    isselect  = "trn_advance_loans.*,'' as sewid,'' as sw_sewadar_name,'' as sw_father_name,'' as sw_joiningdate,'' as sw_date_of_birth,'' as sw_oldsewdarcode, '' as categoryname,'' as sw_catcode,''as departname"
    isselect  += ", '' as so_superannuationdate,'' as so_regularizationdate,'' as memberincharge,''as skb_ifccocde,''as skb_accountno,''as skb_bank,''as approvedby,''as sanctionno,''as sanctiondate,'' as leftinstallmentdate"
    pmsobj    = TrnAdvanceLoan.select(isselect).joins(jons).where(iswhere).order("al_sewadarcode ASC")
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
      
      totaladvance               = newrqst.al_balances #newadv.totalamount
      installmentpermonth        = newrqst.al_installpermonth
      if totaladvance.to_f >0 && installmentpermonth.to_f >0
          noofinstallment             = totaladvance.to_f/installmentpermonth.to_f
          instdated                   = Date.parse(reqdated.to_s)+noofinstallment.to_i.months 
          newrqst.leftinstallmentdate = formatted_date(instdated)
      end 
      officeobjs = get_office_information(newrqst.al_compcode,newrqst.al_sewadarcode)
      if officeobjs
        newrqst.so_superannuationdate  = officeobjs.so_superannuationdate
        newrqst.so_regularizationdate  = officeobjs.so_regularizationdate
       
      end
      bankkycobjs = get_banking_detail_kyc_bankdetail(newrqst.al_sewadarcode)
      if bankkycobjs
        newrqst.skb_bank       = bankkycobjs.skb_bank
        newrqst.skb_accountno  = bankkycobjs.skb_accountno
        newrqst.skb_ifccocde   = bankkycobjs.skb_ifccocde
       
      end
      sancobjs = get_sanction_detail(newrqst.al_sewadarcode)
      if sancobjs
        newrqst.sanctionno    = sancobjs.vd_voucherno
        newrqst.sanctiondate  = sancobjs.vd_voucherdate
    
      end
      seapprovedobj     = get_global_users(newrqst.al_approvedby)
      if seapprovedobj
            membercode  = seapprovedobj.ecmember
            ldsobj      = get_member_listed(membercode)
            if ldsobj
              newrqst.approvedby  = ldsobj.lds_name
               
            end
            
      end
    requehead = get_department_detail(newrqst.al_depcode)
    if requehead
      newrqst.departname  =  requehead.departDescription
      membovj = get_first_my_sewadar(requehead.departHod)
      if membovj
          newrqst.memberincharge  = membovj.lds_name
      end
     
    end
     

   
    arraitem.push newrqst
  end
end 
  return pmsobj
  
end






private
def get_banking_detail_kyc_bankdetail(sewcode)
     compcode  =  session[:loggedUserCompCode]
     sewdarobj =  MstSewadarKycBank.where("skb_compcode =? AND sbk_sewcode =?",compcode,sewcode).first
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
def get_sanction_detail(sewcode)
     compcodes  = session[:loggedUserCompCode]
     loansobj = TrnVoucherDetail.where("vd_compcode =? AND vd_sewadarcode =?",compcodes,sewcode).first
     return loansobj

end


end
