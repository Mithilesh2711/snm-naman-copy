class LeaveDetailsController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_emp_attached_file,:get_employee_types,:get_leavemaster_detail
  helper_method :get_all_department_detail,:get_link_image,:format_oblig_date,:get_mysewdar_list_details,:get_first_my_sewadar
  helper_method :get_sewa_all_department,:get_sewa_all_rolesresp,:user_detail,:get_all_opening_balance,:get_opening_balance,:get_leavemaster_bycategory
  
  def index
    @compCodes        =  session[:loggedUserCompCode]
    @sewadarCategory  =  MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
    @sewcoded         =  nil
    @newsewdarList    =  nil
    @ListDist         =  nil
    @LeavePermit      =  nil
    @lockEdited       =  true
    mydeprtcode       =  ""
    category          =  ""
    @LeaveCategory    =  ""
    neywsr            =  Date.today.strftime("%Y")
    @SessFromDate     =  "2022-01-01"
    @SessEnddate      =  neywsr.to_s+"-12-31"
    @nbegindate       =  2021
    if session[:sec_sewdar_code]
          sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
          if sewobjs          
              mydeprtcode   = sewobjs.sw_depcode
              category      = sewobjs.sw_catcode
              @mydepartcode = mydeprtcode
          end
     end
     if session[:sec_x_dashboard] && session[:sec_x_dashboard].to_s == 'swd'
         @sewcoded      =   session[:sec_sewdar_code]
     end   
    if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf' 
        @sewDepart      = Department.where("compCode = ? AND subdepartment = '' AND departCode = ? ",@compCodes,mydeprtcode).order("departDescription ASC")
        @markedXAllowed = false
    else		  
        @sewDepart     = Department.where("compCode = ? AND subdepartment ='' ",@compCodes).order("departDescription ASC")		   		  
    end
    search_sewadar     =   params[:al_sewadarcode]!=nil && params[:al_sewadarcode]!=nil ? params[:al_sewadarcode].to_s.strip : session[:alrequest_sewadar_name]
    voucher_department =   params[:ls_depcode]!=nil && params[:ls_depcode]!=nil ? params[:ls_depcode] : session[:alvoucher_department]
 
  if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
      @markedXAllowed  =   false
      @newsewdarList   =   MstSewadar.where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")
  elsif session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'stf'
      @markedXAllowed  =   false
      @newsewdarList   =   MstSewadar.where("sw_compcode = ? AND sw_depcode = ?",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")
  else
      if voucher_department !=nil && voucher_department !=''
         @newsewdarList   =   MstSewadar.where("sw_compcode = ? AND sw_depcode = ?",@compCodes,voucher_department).order("sw_sewadar_name ASC")
      end
    end    
    
    @obalances   = 0
    @leaveLedger = nil
     if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
            @ApplyLeaves = taken_sewdar_leave_balances            
            @leaveLedger = print_sewdar_leave_balances()
      else

        if params[:requestserver] !=nil && params[:requestserver] != ''
            @ApplyLeaves = taken_sewdar_leave_balances           
            @leaveLedger = print_sewdar_leave_balances()
        end
      end
  end

  

def print_sewdar_leave_balances
      compcode   =  session[:loggedUserCompCode]  
      if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
        sewcode    =  session[:sec_sewdar_code]
    else
        sewcode    =  params[:al_sewadarcode]!=nil && params[:al_sewadarcode]!=nil ? params[:al_sewadarcode].to_s.strip : '' 
    end
    myyears         = params[:selected_years] !='' && params[:selected_years]!=nil ? params[:selected_years]  : ''  
    @selected_years = myyears
    itemsarra    =  []
 
   crediobj   = get_credited_leave_listed(compcode,sewcode,'','','',myyears)
   if crediobj.length >0
       crediobj.each do |newbls|
           itemsarra.push newbls
       end
   end
  availobj   =  get_user_availed_listings(compcode,sewcode,'','','',myyears)
  if availobj.length >0
      availobj.each do |newobx|
          itemsarra.push newobx
      end
  end
  codobj = get_co_od_request(compcode,sewcode,'','','',myyears)
  if codobj.length >0
      codobj.each do |newobx|
          itemsarra.push newobx
      end
  end
  newarrays = []
  if itemsarra.length >0
      TrnTempLeaveSummary.all.destroy_all
      itemsarra.each do |newbts|
          merge_leave_types(compcode,newbts.leavecode,newbts.tleave,newbts.mytpe)
      end
      isselect  = "tls_leavetype as leavecode,SUM(tls_credit) as credits,SUM(tls_debit) as debits"
      newarrays = TrnTempLeaveSummary.select(isselect).all.group("tls_leavetype")
  end

  return newarrays

end


private
def merge_leave_types(compcode,leavetype,tkens,type)
  credit = 0
  debits = 0
  if type == 'dbt'
    debits = tkens
  else
    credit = tkens
  end
    tlsobj = TrnTempLeaveSummary.new(:tls_compcode=>compcode,:tls_leavetype=>leavetype,:tls_credit=>credit,:tls_debit=>debits)
    if tlsobj.save
###
    end
end


private
def get_user_availed_listings(compcode,sewacode,fromdated,uptodated,leavecode,years="")
   
     iswherex   = "ls_compcode ='#{compcode}' AND ls_status NOT IN('C','R','D')"
     if years !=nil && years !=''
           iswherex  += " AND YEAR(ls_fromdate) ='#{years}' AND YEAR(ls_todate)='#{years}'" 
           #iswherex  += " AND  (CASE WHEN ls_leave_code='SL' THEN MONTH(ls_fromdate)=MONTH(NOW()) ELSE id >0 END)"              
     else
          iswherex  += " AND ls_fromdate >='#{@SessFromDate}' "
          iswherex  += " AND ls_todate <='#{@SessEnddate}'"
     end   
     iswherex  += " AND ls_empcode = '#{sewacode}'"        
     isselect  = "ls_nodays as tleave,ls_fromdate,ls_todate,ls_leave_code as leavecode,ls_empcode  as sewacode,'dbt' as mytpe,MONTH(ls_fromdate) as months,MONTH(NOW()) as curmonths"
     leaveobj  = TrnLeave.select(isselect).where(iswherex) #.group("ls_leave_code")
     if leaveobj.length >0
            leaveobj.each do |newdbs|
                 if newdbs.months.to_i != newdbs.curmonths.to_i && newdbs.leavecode == 'SL'
                    newdbs.tleave = 0    
                 end  
            end
     end
     return leaveobj
     
   end


def get_credited_leave_listed(compcode,sewacode,fromdated,uptodated,leavecode,years="")
 
      iswhere = "cl_compcode ='#{compcode}'"
      if leavecode !=nil && leavecode !='' && leavecode !='All'
          iswhere  += " AND cl_leavecode ='#{leavecode}'"
      end
      if years !=nil && years!=''
        iswhere  += " AND YEAR(cl_creditdate) ='#{years}'"
         
      else
          if fromdated !=nil && fromdated !='' 
              iswhere  += " AND cl_creditdate >='#{fromdated}'"
          end 
          if uptodated !=nil && uptodated !='' 
              iswhere  += " AND cl_creditdate <='#{uptodated}'"
          end         
      end

      iswhere  += " AND cl_sewacode ='#{sewacode}'"
      arritems = []
      isselect  = "cl_creditdays as tleave,cl_leavecode as leavecode,cl_sewacode  as sewacode,'cdt' as mytpe"
      lvsobj  = TrnCreditLeave.select(isselect).where(iswhere).order("cl_leavecode ASC")#.group("cl_leavecode")
      if lvsobj.length >0
          lvsobj.each do |newd|
              arritems.push newd 

          end
      end
      return arritems
end

private
def get_opening_balance(years,sewcode,leavecode="")
    compcode   =  session[:loggedUserCompCode] 
    availleave =  get_avail_leave_ob(compcode,sewcode,'','',leavecode,years)
    creditedlv =  get_credited_leave_ob(compcode,sewcode,'','',leavecode,years)
    reqcod     =  get_cood_leave_ob(compcode,sewcode,'','',leavecode,years)
    totals     =  (creditedlv.to_f+reqcod.to_f).to_f-availleave.to_f
    return totals
end

private
def get_all_opening_balance(leavecode="")
  compcode   =  session[:loggedUserCompCode] 
  if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
     sewcode    =  session[:sec_sewdar_code]
  else
     sewcode    =  params[:al_sewadarcode]!=nil && params[:al_sewadarcode]!=nil ? params[:al_sewadarcode].to_s.strip : '' 
  end
  
  # availleave =  get_avail_leave_ob(compcode,sewcode,'','','')
  # creditedlv =  get_credited_leave_ob(compcode,sewcode,'','','')
  
  mywhere    =  " lb_compcode ='#{compcode}' AND lb_empcode ='#{sewcode}'"  
  if leavecode != nil && leavecode != ''
      mywhere  += " AND lb_leavecode ='#{leavecode}'"
  end 
  newobs     = 0       
   oblsobj   = TrnLeaveBalance.select("SUM(lb_openbal) as tleavs").where(mywhere).first
   if oblsobj
       newobs = oblsobj.tleavs
   end
   fobalance  = newobs #(newobs.to_f+creditedlv.to_f).to_f-availleave.to_f
   return fobalance

end

def get_avail_leave_ob(compcode,sewacode,fromdated,uptodated,leavecode,years="")
  tcounts = 0
  iswhere   = "ls_compcode ='#{compcode}' AND ls_status ='A'"
  iswhere  += " AND ls_empcode = '#{sewacode}'"  
  if leavecode !=nil && leavecode !='' && leavecode !='All'
      iswhere  += " AND ls_leave_code ='#{leavecode}'"
  end
  if years !=nil && years!=''
        iswhere  += " AND YEAR(ls_fromdate) <'#{years}'"
  else
        if fromdated !=nil && fromdated !='' 
            iswhere  += " AND ls_fromdate <'#{fromdated}'"
        else
            iswhere  += " AND ls_fromdate >='#{@SessFromDate}' AND ls_fromdate <='#{@SessEnddate}'"
              
        end 
  end    
  
       
  isselect  = "SUM(ls_nodays) as tleaves"
  leaveobj  = TrnLeave.select(isselect).where(iswhere).first
  if leaveobj
      tcounts = leaveobj.tleaves
  end
  return tcounts
end
def get_credited_leave_ob(compcode,sewacode,fromdated,uptodated,leavecode,years="")
  
    tcounts = 0
      iswhere = "cl_compcode ='#{compcode}'"
      if leavecode !=nil && leavecode !='' && leavecode !='All'
          iswhere  += " AND cl_leavecode ='#{leavecode}'"
      end
      if years !=nil && years!=''
           iswhere  += " AND YEAR(cl_creditdate) <'#{years}'"
      else
          if fromdated !=nil && fromdated !='' 
              iswhere  += " AND cl_creditdate <'#{fromdated}'"
          else
            iswhere  += " AND cl_creditdate <'#{@SessFromDate}'" 
          end 
      end    
      iswhere  += " AND cl_sewacode ='#{sewacode}'"
      isselect  = "SUM(cl_creditdays) as tleave"
      lvsobj  = TrnCreditLeave.select(isselect).where(iswhere).first
      if lvsobj
          tcounts = lvsobj.tleave
      end
      return tcounts
end

private
def get_co_od_request(compcode,sewacode,fromdated,uptodated,leavecode,years="")
     iswherex   = "ls_compcode ='#{compcode}' AND ls_status='A' "     ##NOT IN('C','R','D')
     if years !=nil && years !=''
        iswherex  += " AND YEAR(ls_fromdate) ='#{years}' "
     else 
        # iswherex  += " AND ls_fromdate >='#{@SessFromDate}' "
        # iswherex  += " AND ls_todate <='#{@SessEnddate}'"  
     end     
     iswherex  += " AND ls_empcode = '#{sewacode}'"        
     isselect  = "ls_nodays as tleave,ls_fromdate,ls_todate,ls_leave_code as leavecode,ls_empcode  as sewacode,'cdt' as mytpe"  
     odrqobj = TrnRequestCoOd.select(isselect).where(iswherex)
end
def get_cood_leave_ob(compcode,sewacode,fromdated,uptodated,leavecode,years="")
  tcounts = 0
  iswhere   = "ls_compcode ='#{compcode}' AND ls_status='A'" #AND ls_status NOT IN('C','R','D')
  if leavecode !=nil && leavecode !='' && leavecode !='All'
      iswhere  += " AND ls_leave_code ='#{leavecode}'"
  end
  if years !=nil && years!=''
       iswhere  += " AND YEAR(ls_fromdate) <'#{years}'"
  else
    #   if fromdated !=nil && fromdated !='' 
    #       iswhere  += " AND ls_fromdate <'#{fromdated}'"
    #   else
    #      iswhere  += " AND ls_fromdate >='#{@SessFromDate}' AND ls_fromdate <='#{@SessEnddate}'"        
    #   end   
  end   
  iswhere  += " AND ls_empcode = '#{sewacode}'"       
  isselect  = "SUM(ls_nodays) as tleaves"
  leaveobj  = TrnRequestCoOd.select(isselect).where(iswhere).first
  if leaveobj
      tcounts = leaveobj.tleaves
  end
  return tcounts
end
private
def taken_sewdar_leave_balances
  @compCodes     =   session[:loggedUserCompCode]  
  sewacode       =   session[:sec_sewdar_code]
  
  if params[:server_request] !=nil && params[:server_request] != ''
      session[:dlrequest_sewadar_name]     = nil    
      session[:dlvoucher_department]       = nil
  end
  search_sewadar     =   params[:al_sewadarcode]!=nil && params[:al_sewadarcode]!=nil ? params[:al_sewadarcode].to_s.strip : session[:alrequest_sewadar_name]
  voucher_department =   params[:ls_depcode]!=nil && params[:ls_depcode]!=nil ? params[:ls_depcode] : session[:alvoucher_department]
  myyears            =   params[:selected_years] !='' && params[:selected_years]!=nil ? params[:selected_years]  : ''  
  jons               =   nil
  if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
      iswhere = "ls_compcode ='#{@compCodes}' AND ls_empcode ='#{sewacode}' AND ls_status NOT IN('C','R','D')"  
 else
      iswhere = "ls_compcode  ='#{@compCodes}' AND ls_status NOT IN('C','R','D')"
 end
 if myyears !=nil && myyears!=''
      iswhere  += " AND YEAR(ls_fromdate) ='#{myyears}' AND YEAR(ls_todate) ='#{myyears}' "
 else
      iswhere  += " AND ls_fromdate >='#{@SessFromDate}' "
      iswhere  += " AND ls_todate <='#{@SessEnddate}'"
 end
 
# iswhere  += " AND ls_fromdate >='#{@SessFromDate}' "
# iswhere  += " AND ls_todate <='#{@SessEnddate}'"

 if session[:requestuser_loggedintp] && session[:requestuser_loggedintp] =='stf' || session[:requestuser_loggedintp] =='swd'	  
   #iswhere += " AND ls_depcode ='#{@mydepartcode}'"
   @voucher_department              = @mydepartcode
   session[:lvoucher_department]    = @mydepartcode
else
    if voucher_department != nil && voucher_department != ''
    #iswhere += " AND ls_depcode='#{voucher_department}'"
    @voucher_department              = voucher_department
    session[:lvoucher_department]    = voucher_department
   end
end
  if search_sewadar !=nil && search_sewadar !=''
       iswhere += " AND ( ls_empcode LIKE '%#{search_sewadar}%' OR sw_sewadar_name LIKE '%#{search_sewadar}%' )"
       jons    =  " JOIN mst_sewadars msd ON(sw_compcode = ls_compcode AND ls_empcode = sw_sewcode)"
       session[:request_sewadar_name] = search_sewadar
       @search_sewadar                  = search_sewadar
  end
 
  if jons
     leavobj = TrnLeave.select("trn_leaves.*,msd.id as swdId").joins(jons).where(iswhere).order("ls_fromdate DESC") #.paginate(:page =>pages,:per_page => 10)
  else
     leavobj = TrnLeave.where(iswhere).order("ls_fromdate DESC") #.order("ls_empcode ASC")
  end

   return leavobj
end

end