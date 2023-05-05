class LeaveController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_emp_attached_file,:get_employee_types,:get_leavemaster_detail
  helper_method :get_all_department_detail,:get_link_image,:format_oblig_date,:get_mysewdar_list_details,:get_first_my_sewadar
  helper_method :get_sewa_all_department,:get_sewa_all_rolesresp,:user_detail,:get_sewdar_designation_detail,:get_merge_leave_status
  
  def index
    @authorizedId  =   session[:autherizedUserId]
    @compCodes     =   session[:loggedUserCompCode]
    @empDetail     =   MstSewadar.where("sw_compcode =?",@compCodes).order("sw_sewadar_name ASC")#Personal.where("emp_compcode=?",@compCodes)
    @MstLeave      =   MstLeave.where("attend_compcode=?",@compCodes).group("attend_leaveCode").order("attend_leaveCode ASC")
    @HrMonths          = nil
    @Hryears           = nil
    @month_numbers     = 0
    if @HeadHrp
          month_numbers =  @HeadHrp.hph_months
          myyears       =  @HeadHrp.hph_years
          month_begins  =  Date.new(myyears, month_numbers)
          begdates      =  Date.parse(month_begins.to_s)
          @nbegindates  =  begdates.strftime('%Y-%m-%d')
          month_endings =  month_begins.end_of_month
          endingdates   =  Date.parse(month_endings.to_s)
          @enddates     =  endingdates.strftime('%Y-%m-%d')
    end
   
    mydeprtcode    =   ""
    @newsewdarList =  nil
    if session[:sec_sewdar_code]
         sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
         if sewobjs
            mydeprtcode   = sewobjs.sw_depcode
            @mydepartcode = sewobjs.sw_depcode
         end
     end
     if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf' 
       @sewDepart  = Department.where("compCode = ? AND subdepartment = '' AND departCode = ? ",@compCodes,mydeprtcode).order("departDescription ASC")
      if session[:requestuser_loggedintp].to_s == 'swd' 
          @newsewdarList =   MstSewadar.where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")
      else
          @newsewdarList =   MstSewadar.where("sw_compcode = ? AND sw_depcode = ?",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")
      end  
   else		  
       @sewDepart     = Department.where("compCode = ? AND subdepartment ='' ",@compCodes).order("departDescription ASC")		   		  
   end
     
      
    @lastTrns      =   get_last_transact_no

    if params[:save_detail]!=nil && params[:save_detail]!='' && params[:save_detail]=='Y'
        save_leave_detail
        return
    elsif params[:all_leaves]!=nil && params[:all_leaves]!='' && params[:all_leaves]=='Y'
        get_all_leave_detail
        return
    elsif params[:all_leaves]!=nil && params[:all_leaves]!='' && params[:all_leaves]=='DFR'
        get_dated_diff()
        return
    elsif params[:is_delete]!=nil && params[:is_delete]!='' && params[:is_delete]=='Y'
        get_all_leave_delete
        return
    end
    @ApplyLeaves = get_apply_leaves_listing
    
  end
def cancel
  @compCodes     =   session[:loggedUserCompCode]
  if params[:id].to_i >0
      leaveobj  =   TrnLeave.where("ls_compcode = ? AND id = ?",@compCodes,params[:id]).first
      if leaveobj
         #leaveobj.update(:ls_status=>'C')
         if leaveobj.ls_status == 'P'
            leaveobj.update(:ls_status=>'C')
            flash[:error] =  "Data has been cancelled successfully."
            leave_reverse(@compCodes,leaveobj.ls_empcode,leaveobj.ls_leave_code,0,leaveobj.ls_nodays)
          elsif leaveobj.ls_status == 'A'
            leaveobj.update(:ls_status=>'R')
            flash[:error] =  "Data has been sent for cancellation."
          elsif leaveobj.ls_status == 'R'
            leaveobj.update(:ls_status=>'C')
            flash[:error] =  "Data has been cancelled successfully."
            leave_reverse(@compCodes,leaveobj.ls_empcode,leaveobj.ls_leave_code,0,leaveobj.ls_nodays)
          end
         
          session[:isErrorhandled]  = nil
      end
  end
   redirect_to "#{root_url}"+"leave"
end
def request_approve
  @compCodes     =   session[:loggedUserCompCode]
  if params[:id].to_i >0
          leaveobj  =   TrnLeave.where("ls_compcode = ? AND id = ?",@compCodes,params[:id]).first
          if leaveobj.ls_status == 'P'
            leaveobj.update(:ls_status=>'A',:ls_approved_by=>session[:autherizedUserType])
            flash[:error] =  "Data has been approved successfully."
          elsif leaveobj.ls_status == 'R'
            leaveobj.update(:ls_status=>'A')
            flash[:error] =  "Data has been approved successfully."          
          end
          session[:isErrorhandled]  = nil
  end
  redirect_to "#{root_url}"+"leave"
end

def apply_leave
    @compCodes        =  session[:loggedUserCompCode]
    @sewadarCategory  =  MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
    @sewcoded         =  nil
    @newsewdarList    =  nil
    @ListDist         =  nil
    @LeavePermit      =  nil
    @lockEdited       =  true
    mydeprtcode       =  ""
    category          =  ""
    @LeaveCategory    = ''
    @myReferenceCode = nil
    if session[:sec_sewdar_code]
         sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
         if sewobjs          
            mydeprtcode   = sewobjs.sw_depcode
            category      = sewobjs.sw_catcode
            if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
                @myReferenceCode = sewobjs.sw_oldsewdarcode
            end
         end
     end
     if session[:sec_x_dashboard] && session[:sec_x_dashboard].to_s == 'swd'
         @sewcoded      =   session[:sec_sewdar_code]
     end
    
    if params[:id].to_i >0
         @lockEdited     =   false
         @ListDist       =   TrnLeave.where("ls_compcode = ? AND id = ?",@compCodes,params[:id]).first
         if @ListDist
            @MstLeave    =   get_saved_leave_type(@ListDist.ls_category,@ListDist.ls_empcode) #MstLeave.where("attend_compcode = ? AND attend_category = ?",@compCodes,@ListDist.ls_category).order("attend_leaveCode ASC")
            lvsobj       =   get_leavemaster_detail(@ListDist.ls_leave_code)
            if lvsobj
                @LeavePermit   = lvsobj.attend_halfpermisable
            end
               mysewobjsx = get_global_sewadar_listed(@ListDist.ls_empcode)
               if mysewobjsx
                  @myReferenceCode = mysewobjsx.sw_oldsewdarcode
               end
               
          end
           if session[:autherizedUserType] && session[:autherizedUserType].to_s == 'adm'
               @newsewdarList =   MstSewadar.where("sw_compcode = ? ",@compCodes).order("sw_sewadar_name ASC")
           end
           
    else
           if session[:autherizedUserType] && session[:autherizedUserType].to_s != 'adm'
            #   category     =   category != nil && category !='' ? category.to_s.delete("-") : ''
            #   category     =   category.to_s.delete("-")
              newcats      =   category
             # @MstLeave    =   get_saved_leave_type(newcats.to_s.upcase,session[:sec_sewdar_code])
              @LeaveCategory = newcats
              
             
           end
    end
    if session[:sec_x_dashboard] && session[:sec_x_dashboard].to_s == 'swd'

    end
#    if session[:autherizedUserType] && session[:autherizedUserType].to_s != 'adm' 
#        @sewDepart     =   Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment='' AND departCode = ? ",@compCodes,mydeprtcode).order("departDescription ASC")
#        if session[:sec_x_dashboard] && session[:sec_x_dashboard].to_s == 'swd'
#          @newsewdarList =   MstSewadar.where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")
#        else
#          @newsewdarList =   MstSewadar.where("sw_compcode = ? AND sw_depcode = ?",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")
#        end

#   else
#        @sewDepart     =   Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment=''",@compCodes).order("departDescription ASC")
#    end

if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf' 
   @sewDepart  = Department.where("compCode = ? AND subdepartment = '' AND departCode = ? ",@compCodes,mydeprtcode).order("departDescription ASC")
  @markedXAllowed = false
else		  
   @sewDepart     = Department.where("compCode = ? AND subdepartment ='' ",@compCodes).order("departDescription ASC")		   		  
end

if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
   @markedXAllowed  =   false
   @newsewdarList   =   MstSewadar.where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")
   if @newsewdarList.length >0
       @MstLeave  =   get_saved_leave_type(@newsewdarList[0].sw_catcode,session[:sec_sewdar_code])
       @LeaveCategory = @newsewdarList[0].sw_catcode
   end   
elsif session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'stf'
    @markedXAllowed  =   false
   @newsewdarList   =   MstSewadar.where("sw_compcode = ? AND sw_depcode = ?",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")
end




end

def ajax_process
  if params[:identity] !=nil && params[:identity] != '' && params[:identity] == 'Y'
       get_dated_diff()
       return
  elsif params[:identity] !=nil && params[:identity] != '' && params[:identity] == 'REMAINLEAVE'
       get_remain_balance_leave()
       return
  elsif params[:identity] !=nil && params[:identity] != '' && params[:identity] == 'CHANGESTATUS'
       process_updatedbalance()
     return
  elsif params[:identity] !=nil && params[:identity] != '' && params[:identity] == 'LEAVECATGEOY'
       process_leave_type()
     return
  elsif params[:identity] !=nil && params[:identity] != '' && params[:identity] == 'LEAVERULE'
       check_leave_rules()
     return
   elsif params[:identity] !=nil && params[:identity] != '' && params[:identity] == 'RMNLEAVEBAL'
      get_leave_remain_balance()
     return
   end

  




end

  def create
  @compcodes  = session[:loggedUserCompCode]
  isFlags     = true
  mid         = params[:mid]
  begin
  if params[:ls_empcode]=='' || params[:ls_empcode]==nil
       flash[:error] =  "Sewadar code is required"
       isFlags       =  false
   elsif params[:ls_leave_code]=='' || params[:ls_leave_code]==nil
       flash[:error] =  "Leave type is required"
       isFlags       =  false
    elsif params[:ls_fromdate]=='' || params[:ls_fromdate]==nil
       flash[:error] =  "From date is required"
       isFlags       =  false
   elsif params[:ls_todate] == '' || params[:ls_todate] == nil
       flash[:error] =  "Upto date is required"
       isFlags       =  false
   
   else    
      
        ######## CHECK APPLY BETWEEN DATED ###########
            fromdate   = params[:ls_fromdate]
            uptodated  = params[:ls_todate]
            ls_empcode = params[:ls_empcode]
            if mid.to_i >0
               mylswhere = "ls_compcode ='#{@compcodes}' AND ls_empcode ='#{ls_empcode}'  AND ls_status NOT IN('C','R','D') AND id <>'#{mid}' AND UPPER(ls_leavereson)<>UPPER('Forfeit')"
            else
               mylswhere = "ls_compcode ='#{@compcodes}' AND ls_empcode ='#{ls_empcode}' AND ls_status NOT IN('C','R','D') AND UPPER(ls_leavereson)<>UPPER('Forfeit')"
            end
            mylswhere += "  AND (( ls_fromdate >='#{year_month_days_formatted(fromdate)}' AND ls_fromdate<='#{year_month_days_formatted(uptodated)}')"
            mylswhere += "  OR ( ls_todate >='#{year_month_days_formatted(fromdate)}' AND ls_todate<='#{year_month_days_formatted(uptodated)}' ))"
            leavaobj  = TrnLeave.where(mylswhere)
            if leavaobj.length >0
                  flash[:error] =  "You have already applied between these days."
                  isFlags       = false
            end

        ########## END APPLY DATED #############
         ###### ALLOW SHORT LEAVE A MONTH ###########
         if isFlags
            if params[:ls_leave_code]== 'SL'
               monthsyersdt = year_month_days_formatted(params[:ls_fromdate])
               chkshortobj  = TrnLeave.where("ls_compcode = ? AND ls_leave_code = ? AND DATE(ls_fromdate)='#{monthsyersdt}' AND ls_empcode ='#{ls_empcode}' AND ls_status NOT IN('C','R','D') AND UPPER(ls_leavereson)<>UPPER('Forfeit')",@compcodes,params[:ls_leave_code])
               if chkshortobj.length >0
                  flash[:error] =  "You could not apply more than one short leave in a day."
                  isFlags       =  false
               end
               if isFlags
                  chkshortxobj  = TrnLeave.where("ls_compcode = ? AND ls_leave_code = ? AND MONTH(ls_fromdate) = MONTH('#{monthsyersdt}') AND ls_empcode ='#{ls_empcode}' AND ls_status NOT IN('C','R','D') AND UPPER(ls_leavereson)<>UPPER('Forfeit')",@compcodes,params[:ls_leave_code])
                  if chkshortxobj && chkshortxobj.length >2
                  flash[:error] =  "You could not apply more than 2 short leave in a month."
                  isFlags       =  false
                  end

               end
            end  
        end
           ########### END SHORT LEAVE ###################
         if mid.to_i >0
            if isFlags
               uptleave = TrnLeave.where("ls_compcode = ? AND id = ?",@compcodes,mid).first
               if uptleave
                    uptleave.update(trn_params)
                    leave_reverse(@compcodes,params[:ls_empcode],params[:ls_leave_code],0,params[:ls_days])
                    leave_add(@compcodes,params[:ls_empcode],params[:ls_leave_code],0,params[:ls_days])
                    flash[:error] =  "Data updated successfully."
                    isFlags       =   true
                end
             end
         else
            
             if isFlags
                 savleave = TrnLeave.new(trn_params)
                  if savleave.save
                      leave_add(@compcodes,params[:ls_empcode],params[:ls_leave_code],0,params[:ls_days])
                      flash[:error] =  "Data saved successfully."
                      isFlags       =   true
                  end
              end

         end

   end
   rescue Exception => exc
      flash[:error] =   "#{exc.message}"
      session[:isErrorhandled] = 1
      isFlags = false
   end
     if !isFlags
          session[:request_ls_empcode]      = params[:ls_empcode]
          session[:request_ls_leave_code]   = params[:ls_leave_code]
          session[:request_ls_fromdate]     = params[:ls_fromdate]
          session[:request_ls_todate]       = params[:ls_todate]
          session[:request_ls_leavereson]   = params[:ls_leavereson]
          session[:request_ls_days]         = params[:ls_days]
          session[:request_ls_remainleave]  = params[:ls_remainleave]
          session[:isErrorhandled] = 1
     else
          session[:request_params]          = nil
          session[:request_ls_empcode]      = nil
          session[:request_ls_leave_code]   = nil
          session[:request_ls_fromdate]     = nil
          session[:request_ls_todate]       = nil
          session[:request_ls_leavereson]   = nil
          session[:request_ls_days]         = nil
          session[:request_ls_remainleave]  = nil
          session.delete(:request_params)
          session[:isErrorhandled]          = nil
     end
      if !isFlags
         redirect_to "#{root_url}"+"leave/apply_leave"
      else
         redirect_to "#{root_url}"+"leave"
      end
    
  end

def show
  @authorizedId  =   session[:autherizedUserId]
  @compCodes     =   session[:loggedUserCompCode]
  @leaveReport   =   print_all_leave_detail()
  @compdetail    =   Company.where("compCode=?",@compCodes).first
  if @leaveReport.length >0
    respond_to do |format|
     format.html
      format.pdf do
        pdf = TrnleavePdf.new(@leaveReport,@compdetail)
        send_data pdf.render,:filename => "1_"+@compCodes.to_s+"_leave_transaction"+"_"+"#{Time.now}", :type => "application/pdf", :disposition => "inline"
      end
   end
 end
end


def leave_new_refresh
    session[:request_params]          = nil
    session[:sales_search]            = nil
    session[:salessearchId]           = nil
    session[:req_prints]              = nil
    session[:request_sewadar_search]  = nil
    session[:req_myusedept]           = nil
    session[:req_myuseaccord]         = nil
    session[:req_myusestring]         = nil
    session[:request_params]          = nil
    session[:request_ls_empcode]      = nil
    session[:request_ls_leave_code]   = nil
    session[:request_ls_fromdate]     = nil
    session[:request_ls_todate]       = nil
    session[:request_ls_leavereson]   = nil
    session[:request_ls_days]         = nil
    session[:request_ls_remainleave]  = nil
    session.delete(:request_params)
   redirect_to "#{root_url}"+"leave"
end



  private
  def get_all_leave_delete
    dlitems = params[:dlId] ? params[:dlId] : ''
    message = ''
    isFlags  = false
    if dlitems!=''
        vids = dlitems.split(",")
        vids.each do |ids|
          delete_all_reacord(ids,@compCodes)
        end
         message = 'Data deleted successfully'
         isFlags = true
    end
    respond_to do |format|
      format.json { render :json => { 'data'=>'', "message"=>message,:status=>isFlags } }
     end
  end

  private
  def delete_all_reacord(id,compCodes)
     if id.to_i >0
         @isOblDel =  TrnLeave.where("ls_compcode=? AND id=?",compCodes,id).first
         if @isOblDel
            @isOblDel.destroy
         end
     end
 end
  
  private
  def save_leave_detail
      message = ""
      @isleavedata = nil
      isFlags      = true;
      empcode      = params[:empCode] ? params[:empCode] : ''
      lvcode       = params[:lvcode] ? params[:lvcode] : ''
      transtype    = params[:trnstype] ? params[:trnstype] : ''
      slectyear    = params[:slectyear] ? params[:slectyear] : ''
      fromyear     = params[:Bo] ? params[:Bo] : ''
      toyear       = params[:todate] ? params[:todate] : ''
      ndays        = 0
      runworking   = ''
      @runObj      = MstLeave.select('attend_runworking as runwork').where("attend_compcode=? AND attend_leaveCode=?",@compCodes,lvcode).first
      if @runObj
         if @runObj.runwork!=nil && @runObj.runwork!=''
           runworking = @runObj.runwork           
         end
      end
      params[:leaveype]  = runworking
      if fromyear!=nil && fromyear!=''
        strsdate  = Date.parse(fromyear.to_s)
        vlyear    = strsdate.strftime('%Y')
        if slectyear!=nil && slectyear!='' && vlyear!=slectyear
          isFlags = false
          message ="From date between selected year of employee"
        end
      end

     if toyear!=nil && toyear!=''
        strdate   = Date.parse(toyear.to_s)
        tnyear    = strdate.strftime('%Y')
        if slectyear!=nil && slectyear!='' && tnyear!=slectyear
          isFlags = false
          message ="To date between selected year of employee";
        end
      end
 if isFlags
    if lvcode!=nil && lvcode!=''
       @isTrnObj =  TrnLeave.where("ls_compcode=? AND ls_empcode=? AND ls_leave_code=?",@compCodes,empcode,lvcode).first
        if @isTrnObj
              ndays  = @isTrnObj.ls_days
              lsdays = params[:lc] ? params[:lc] : ''
              ncdays = 0
              if transtype!=nil && lvcode!='' && transtype.delete(' ').upcase =='E'
                 ncdays = ndays.to_f-lsdays.to_f
              elsif transtype!=nil && transtype!='' && transtype.delete(' ').upcase =='A'
                 ncdays = ndays.to_f-lsdays.to_f
              else
                 ncdays = ndays.to_f+lsdays.to_f
              end
              params[:lc] = ncdays
              @isTrnObj.update(trn_params)
              message ="Data saved successfully"
              isFlags = true
        else
              lsdays = params[:lc] ? params[:lc] : ''
              if transtype!=nil && transtype!='' && transtype.delete(' ').upcase =='E'
                 ncdays = ndays.to_f-lsdays.to_f
              elsif transtype!=nil && transtype!='' && transtype.delete(' ').upcase =='A'
                 ncdays = ndays.to_f-lsdays.to_f
              else
                 ncdays = ndays.to_f+lsdays.to_f
              end
              params[:lc] = ncdays
              @trnSaveObj = TrnLeave.new(trn_params)
              if @trnSaveObj.save
                message = "Data saved successfully"
                isFlags = true
              end
        end
         @isleavedata = TrnLeave.select("sum(ls_days) as leavedays,ls_empcode,ls_transtype,ls_fromdate,ls_todate,ls_leave_code,ls_days,ls_leave_typerw,ls_half_option").where("ls_compcode=? AND ls_empcode=?",@compCodes,empcode).group('ls_leave_code')
    end
 else
   @isleavedata = nil
 end
      respond_to do |format|
      format.json { render :json => { 'data'=>@isleavedata, "message"=>message,:status=>isFlags } }
     end
  end

  private
  def get_dated_diff
     @compcodes  = session[:loggedUserCompCode]
      frdated    = params[:frmdate]!=nil && params[:frmdate]!='' ? year_month_days_formatted(params[:frmdate]) : ''
      updated    = params[:uptodate]!=nil && params[:uptodate]!='' ? year_month_days_formatted(params[:uptodate]) : ''
      leavecd    = params[:leavecode]!=nil && params[:leavecode]!='' ? params[:leavecode] : ''
      categery   = params[:categery]!=nil && params[:categery]!='' ? params[:categery] : ''
      

      ndates   = ''
      message  = ''
      status   = 1
      wk       = 0
      hld      = 0
      wks      = 0
      hlds     = 0
      isflags  = true
      if isflags
            if frdated !=nil && frdated !=''
                  nwhere   = "compCode ='#{@compcodes}' AND dateYear ='#{frdated}'"
                  chkhld  =  Holiday.where(nwhere)
                  if chkhld.length >0
                     hld = 1
                  end
                  weekdayf = Date.parse(frdated)             
                  if weekdayf.strftime('%A') == 'Sunday'
                     wk =1
                  end              
                  # if hld.to_i == 1 || wk.to_i == 1
                  #   message = " From date should not be Holiday or Weekly Off."
                  #   isflags = false
                  #   status = 5
                  # end

            end
      end      
      if isflags
          if updated !=nil && updated !=''
                nwhere   = "compCode ='#{@compcodes}' AND  dateYear ='#{updated}'"
                 chkhld  =  Holiday.where(nwhere)
                 if chkhld.length >0
                    hlds = 1
                 end
                  weekdays = Date.parse(updated)
                  if weekdays.strftime('%A') == 'Sunday'
                     wks +=1
                  end
               #    if hlds.to_i == 1 || wks.to_i == 1
               #      message = " Upto date should not be Holiday or Weekly Off."
               #      isflags = false
               #      status = 6
               #   end
               ## COMMNET BY UMESH ON TOLD BY : AMIT
            end
      end
      if isflags
            if leavecd !=nil && leavecd !='' && leavecd == 'ML'
              trnlsvsob  = MstLeave.select('attend_leavetakenrow as tkenleve').where("attend_compcode=? AND attend_leaveCode=? AND attend_category = ?",@compcodes,leavecd,categery).first
              if trnlsvsob
                 updateds = Date.parse(frdated)+trnlsvsob.tkenleve.to_i-1
                 updated = year_month_days_formatted(updateds)
              end

            end
            if frdated!=nil && frdated!='' && updated!=nil && updated!=''
                 if frdated >updated
                   message = " UpTo date should be greater than from date."
                   status  = 2
                 else
                    ndates = (updated.to_date - frdated.to_date).to_i#/(60*60*24)
                    ndates = ndates.to_i+1

                    status  = 3
                 end
            end
      end
       respond_to do |format|
          format.json { render :json => { 'data'=>ndates, "message"=>message,:status=>status,'updated'=>format_oblig_date(updated)} }
       end
  end

  private
  def get_all_leave_detail
    empcode = params[:empCode] ? params[:empCode] : ''
    nyear   = params[:paidyear] ? params[:paidyear] : ''
    @isleave  = nil
    isFlags   = false
    message   = ''
    @rtpath   = ''
    if empcode!=nil && empcode!='' && nyear!=nil && nyear!=''
        @isleave = TrnLeave.select("trn_leaves.*,DATE_FORMAT(ls_fromdate,'%d-%b-%Y') as frmdate,DATE_FORMAT(ls_todate,'%d-%b-%Y') as upsdate").where("ls_compcode=? AND ls_empcode=? AND ls_leave_year=?",@compCodes,empcode,nyear)
        if @isleave.length >0
          isFlags   = true
          message   = "Success"
          session[:employee_printcode] = empcode.to_s
          session[:employee_printyear] = nyear.to_s
          @printControll  =  "1_"+@compCodes.to_s+"_leav_transaction"+"_"+"#{Time.now}"
          @rtpath          =  leave_path(@printControll,:format=>"pdf")
        else
          message = "No Leave Record(s) Found"
        end
    end
      nsleavs =  leave_details_primary(empcode,nyear)
      respond_to do |format|
       format.json { render :json => { 'data'=>@isleave, "message"=>message,:status=>isFlags,'nsleavs'=>nsleavs,'printpath'=>@rtpath } }
      end
  end

  private
  def print_all_leave_detail
    empcode    = session[:employee_printcode] ? session[:employee_printcode] : ''
    nyear      = session[:employee_printyear] ? session[:employee_printyear] : ''
    @retleave  = nil
    arr        = []
    if empcode!=nil && empcode!='' && nyear!=nil && nyear!=''
        @retleave = TrnLeave.select("id,ls_empcode,ls_compcode,ls_compcode as lemployee,ls_transtype,ls_fromdate,ls_todate,ls_leave_code,ls_days,ls_leave_typerw,ls_half_option").where("ls_compcode=? AND ls_empcode=? AND YEAR(ls_fromdate)=?",@compCodes,empcode,nyear)
        if @retleave.length >0
          @retleave.each do |leavs|
            if leavs.ls_empcode!=nil && leavs.ls_empcode!=''
              empnames =   employee_details_primary(leavs.ls_compcode,leavs.ls_empcode)
              leavs.lemployee = empnames.upcase
            end
            if leavs.ls_transtype!=nil && leavs.ls_transtype!='' && leavs.ls_transtype=='O'
              leavs.ls_transtype = 'OPENED ON'
            elsif leavs.ls_transtype!=nil && leavs.ls_transtype!='' && leavs.ls_transtype=='A'
              leavs.ls_transtype = 'AVAILED ON'
            elsif leavs.ls_transtype!=nil && leavs.ls_transtype!='' && leavs.ls_transtype=='E'
              leavs.ls_transtype = 'ENCHASHED ON'
           elsif leavs.ls_transtype!=nil && leavs.ls_transtype!='' && leavs.ls_transtype=='C'
              leavs.ls_transtype = 'CREDITED ON'
            end
            arr.push leavs
          end
          return arr
        end
    end
    return arr
  end

private
def leave_details_primary(empcode,years)
   isleave = TrnLeaveBalance.where("lb_compcode = ? AND lb_empcode = ? ",@compCodes,empcode) #$AND lb_year = ? 
   return isleave
end
private
def employee_details_primary(compcode,empcode)
   arname = ''
   @isempObj = Personal.select('emp_name').where("emp_compcode=? AND emp_code=?",compcode,empcode).first
   if @isempObj
      if @isempObj.emp_name!='' && @isempObj.emp_name!=nil
          arname = @isempObj.emp_name
      end
   end
   return arname
end
  private
  def trn_params
      strdate = 0
      uptodate = 0
      if params[:ls_fromdate]!=nil && params[:ls_fromdate]!=''
        strdate  = year_month_days_formatted(params[:ls_fromdate].to_s)
      end
      
     if params[:ls_todate]!=nil && params[:ls_todate]!=''
        uptodate     = year_month_days_formatted(params[:ls_todate].to_s)        
      end
      
      params[:ls_number]       = ''
      params[:ls_todate]       = uptodate
      params[:ls_fromdate]     = strdate
      params[:ls_compcode]     = session[:loggedUserCompCode]
      params[:ls_empcode]      = params[:ls_empcode]!=nil && params[:ls_empcode]!= '' ? params[:ls_empcode] : ''      
      params[:ls_leave_code]   = params[:ls_leave_code]!=nil && params[:ls_leave_code]!= '' ? params[:ls_leave_code] : ''
      params[:ls_nodays]       = params[:ls_days].to_f >0 ? params[:ls_days] : 0
      params[:ls_remainleave]  = params[:ls_remainleave]!=nil && params[:ls_remainleave]!='' ? params[:ls_remainleave] : 0
      params[:ls_leavereson]   = params[:ls_leavereson]!=nil && params[:ls_leavereson]!='' ? params[:ls_leavereson] : ''
      params[:ls_depcode]      = params[:ls_depcode] !=nil && params[:ls_depcode] !='' ? params[:ls_depcode] : ''
      params[:ls_avail]        = params[:firsthalfsec] !=nil && params[:firsthalfsec] !='' ? params[:firsthalfsec] : ''
      params[:ls_period]       = params[:firstperiodsec] !=nil && params[:firstperiodsec] !='' ? params[:firstperiodsec] : ''
      params[:ls_category]     = params[:ls_category] !=nil &&  params[:ls_category] !='' ?  params[:ls_category] : ''
      
      params.permit(:ls_compcode,:ls_category,:ls_avail,:ls_period,:ls_number,:ls_empcode,:ls_fromdate,:ls_todate,:ls_leave_code,:ls_nodays,:ls_remainleave,:ls_leavereson,:ls_depcode)
  end

  private
def get_last_transact_no
  @isCode     = 0
  @Startx     = '0000'
  @recCodes   = TrnLeave.where(["ls_compcode = ? AND ls_number >0", @compcodes]).order('ls_number DESC').first
   if @recCodes
      @isCode    = @recCodes.ls_number.to_i
   end
    @sumXOfCode    = @isCode.to_i + 1
    if @sumXOfCode.to_s.length   < 2
      @sumXOfCode = p "0000" + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length < 3
      @sumXOfCode = p "000" + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length < 4
      @sumXOfCode = p "00" + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length < 5
      @sumXOfCode = p "0" + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length >=5
      @sumXOfCode =  @sumXOfCode.to_i
    end
    return @sumXOfCode
end

private
def leave_reverse(compcode,empcode,leavecode,years,leavbal)
    leavobj = TrnLeaveBalance.where("lb_compcode = ? AND lb_empcode = ? AND lb_leavecode = ?",compcode,empcode,leavecode).first
    if leavobj
         newleave   = leavobj.lb_closingbal
         finalleave = newleave.to_f+leavbal.to_f
         leavobj.update(:lb_closingbal=>finalleave)
     end
  
end

private
def leave_add(compcode,empcode,leavecode,years,leavbal)
    leavobj = TrnLeaveBalance.where("lb_compcode = ? AND lb_empcode = ? AND lb_leavecode = ?",compcode,empcode,leavecode).first
    if leavobj
      newleave   = leavobj.lb_closingbal
      finalleave = newleave.to_f-leavbal.to_f
      leavobj.update(:lb_closingbal=>finalleave)
    else
         finalleave = leavbal
         lvobj = TrnLeaveBalance.new(:lb_compcode=>compcode,:lb_closingbal=>leavbal,:lb_empcode=>empcode,:lb_leavecode=>leavecode,:lb_year=>years)
         if lvobj.save
           ####
         end
    end
  
end


private
def save_update_opebal
     compcodes = session[:loggedUserCompCode]
     empcode  = params[:employeeCode]
     years    = params[:attend_paidyear]
     if params[:leavecodes]!=nil && params[:leavecodes]!=''
           m = 0
           params[:leavecodes].each do |fil|
                if params[:leavecodes][m]!=nil && params[:leavecodes][m]!=''
                     leavecode     =  params[:leavecodes][m]
                     leavbal       =  params[:leavebalance][m]
                     if leavecode!=nil && leavecode!='' 
                       save_process_attendance(compcodes,empcode,leavecode,years,leavbal)
                     end                     
                 end
                 m +=1                 
           end
      end
end

private
def save_process_attendance(compcode,empcode,leavecode,years,leavbal)
   leavobj = TrnLeaveBalance.where("lb_compcode = ? AND lb_empcode = ? AND lb_leavecode = ? ",compcode,empcode,leavecode).first
   if leavobj
      leavobj.update(:lb_openbal=>leavbal)
   else
    lvobj = TrnLeaveBalance.new(:lb_compcode=>compcode,:lb_openbal=>leavbal,:lb_empcode=>empcode,:lb_leavecode=>leavecode,:lb_year=>years)
    if lvobj.save
      ####
    end
   end
end



private
def get_leave_remain_balance
     compcodes  = session[:loggedUserCompCode]
     sewdarcode = params[:sewadarcode]
     leavecode  = params[:leavecode]
     categery   = params[:category]
     status     = false
     remainbal  = 0
    leaveobj    = TrnLeaveBalance.where("lb_compcode = ? AND lb_empcode = ? AND lb_leavecode = ?",compcodes,sewdarcode,leavecode).first
    
    if leaveobj
      status = true
       remainbal = leaveobj.lb_closingbal
    end
    stobjs      = MstLeave.select("attend_leavetakenrow").where("attend_compcode=? AND attend_leaveCode = ? AND attend_category = ?",compcodes,leavecode,categery).first
      rlnumdays   = 0
    if stobjs
       rlnumdays = stobjs.attend_leavetakenrow
    end

    respond_to do |format|
      format.json { render :json => { 'data'=>remainbal,:rlnumdays=>rlnumdays,:status=>status} }
    end
end

private
def get_remain_balance_leave
     compcodes  = session[:loggedUserCompCode]
     sewdarcode = params[:sewadarcode]
     leavecode  = params[:leavecode]
     categery   = params[:categery]
     status     = false
    leaveobj    = TrnLeaveBalance.where("lb_compcode = ? AND lb_empcode = ? AND lb_leavecode = ?",compcodes,sewdarcode,leavecode).first
    stobjs      = MstLeave.select("attend_leavetakenrow").where("attend_compcode=? AND attend_leaveCode = ? AND attend_category = ?",compcodes,leavecode,categery).first
    rlnumdays   = 0
    if stobjs
       rlnumdays = stobjs.attend_leavetakenrow
    end

    if leaveobj
      status = true
    end
    respond_to do |format|
      format.json { render :json => { 'data'=>leaveobj,:status=>status,:rlnumdays=>rlnumdays} }
    end
end

private
def process_updatedbalance
     compcodes    = session[:loggedUserCompCode]
     leaveid      = params[:leaveid]
     leavestatus  = params[:leavestatus]
     status     = false
     
    if session[:autherizedUserType] && session[:autherizedUserType].to_s == 'adm' || session[:sec_ecmem_code].to_i >0
      approvedby = session[:logedUserId]
    else
      approvedby = session[:sec_sewdar_code]
    end
    leaveobj    = TrnLeave.where("ls_compcode = ? AND id= ?",compcodes,leaveid).first
    if leaveobj
       if leavestatus.to_s == 'D'
         leave_reverse(compcodes,leaveobj.ls_empcode,leaveobj.ls_leave_code,0,leaveobj.ls_nodays)
       end
       if leavestatus.to_s == 'AC'
           leaveobj.update(:ls_requestcancel=>'Y',:ls_approved_by=>approvedby)
       else
         leaveobj.update(:ls_status=>leavestatus,:ls_approved_by=>approvedby)
       end
      
      status = true
      message ="Data updated successfully."
    else
       message ="No record(s) found for update."
    end
    respond_to do |format|
      format.json { render :json => { 'data'=>leaveobj,:status=>status,'message'=>message} }
    end

end

private
def process_leave_type
     compcodes    = session[:loggedUserCompCode]
     catgeory     = params[:catgeory]
     sewcodes     = params[:sewcodes]
     userid       = session[:logedUserId]
     loggedtyp    = session[:requestuser_loggedintp]
     sewobj       = get_mysewdar_list_details(sewcodes)
    if sewobj
          gnders  = sewobj.sw_gender
          married = sewobj.sw_maritalstatus
          if loggedtyp.to_s == 'hr'
             iswhere = "attend_compcode ='#{compcodes}' AND attend_category ='#{catgeory}' "
          else
             iswhere = "attend_compcode ='#{compcodes}' AND attend_category ='#{catgeory}' AND UPPER(attend_leaveCode)<>'SPL' "
          end         
           #AND UPPER(attend_leaveCode)<>'OD'
          if gnders == 'M'
            iswhere += " AND attend_leaveavailby IN('M','B')"
           elsif gnders == 'F'
             iswhere += " AND attend_leaveavailby IN('F','B')"
          else
             iswhere += " AND attend_leaveavailby IN('B')"
           end
           userobj      = user_detail(userid)
           hr = nil
           sew = nil
           stf  = nil
           if userobj
              listmodule = userobj.listmodule.to_s.split(",")
               if listmodule && listmodule.include?('HR')
                  hr = 'HR'
               end
               if listmodule && listmodule.include?('SSS')
                  sew = 'SSS'
               end
               if listmodule && listmodule.include?('STF')
                  sew = 'STF'
               end
            end
             if hr
               iswhere += " AND FIND_IN_SET('HR', attend_whocanapply) >0 "
            end
            if loggedtyp.to_s != 'hr'

               if sew
                  iswhere += " AND FIND_IN_SET('SSS', attend_whocanapply) >0 "
               end
               if stf
                  iswhere += " AND  FIND_IN_SET('STF', attend_whocanapply) >0"
               end
            end   
#            if hr || sew || stf
#               iswhere += " AND ( FIND_IN_SET('HR', attend_whocanapply) >0 OR  FIND_IN_SET('SSS', attend_whocanapply) >0 OR FIND_IN_SET('STF', attend_whocanapply) >0)"
#            end
#            if sew
#               iswhere += " AND FIND_IN_SET('SSS', attend_whocanapply) >0"
#            end
#            if stf
#               iswhere += " AND FIND_IN_SET('STF', attend_whocanapply) >0"
#            end
            arrleave  = []
            leaveobj  = MstLeave.where(iswhere).order("attend_leavetype ASC")
            if leaveobj.length >0
                status  = true
                message = "Success"
                leaveobj.each do |newlvs|
                    if gnders =='F'
                          if married == 'Y'
                              arrleave.push newlvs
                          else
                                if newlvs.attend_leaveCode !='ML'
                                   arrleave.push newlvs
                                end
                          end
                    else
                          if newlvs.attend_leaveCode !='ML'
                             arrleave.push newlvs
                          end
                    end
                end
            end
    end
    
    respond_to do |format|
      format.json { render :json => { 'data'=>arrleave,:status=>status,'message'=>message} }
    end

end
private
def check_leave_rules
  compcodes    = session[:loggedUserCompCode]
  userid       = session[:logedUserId]
  catgeory     = params[:catgeory]
  leavecod     = params[:leavecode]
  ls_empcode   = params[:ls_empcode]
  numberdys    = params[:numberdys]
  fromdate     = params[:fromdate]
  uptodated    = params[:uptodated]
  mid          = params[:mid]
  message      = ""
  status       = true
  isflags      = true
  tsewyear     = 0
  halfday      = ''
  leavgos     = 0
  findtdays   = 0
  tdays    = 0


  leaveobj     = MstLeave.where("attend_compcode=? AND attend_category = ? AND attend_leaveCode =?",compcodes,catgeory,leavecod).first
   if leaveobj
        # aplyleaveallow = leaveobj.attend_whocanapply.to_s.split(",")
         crediterule    = leaveobj.attend_creditrule
         creditdays     = leaveobj.attend_monthlyleave
         mergeleave     = leaveobj.attend_mergeleave
         weekhld        = leaveobj.attend_sundayleave
         tsewyear       = leaveobj.attend_totalsewarequired
         halfday        = leaveobj.attend_halfpermisable
         leavgos        = leaveobj.attend_leavetakenrow
         tdays          = creditdays
         applwho        = leaveobj.attend_periodapply
         takenmonly     = numberdys
        
         
#         if  isflags
#             apl_f  = aplyleaveallow[0]
#             apl_s  = aplyleaveallow[1]
#             pal_th = aplyleaveallow[1]
#            if listmodule
#                if( apl_f && listmodule.include?(apl_f) )
#                     alcount = 1
#                elsif( apl_s && listmodule.include?(apl_s) )
#                     alcount = 1
#                elsif( pal_th && listmodule.include?(pal_th))
#                     alcount = 1
#                end
#            end
#            if alcount <=0
#                 message     = "You are not allowed for apply leave."
#                 isflags = false
#            end
#         end
         # if  isflags
         #      if crediterule == 'M' && takenmonly.to_f > creditdays.to_f
         #           message     = "You can not apply for #{takenmonly} days in Month."
         #           isflags = false
         #     elsif crediterule == 'Q' && numberdys.to_f > creditdays.to_f
         #          message     = "You can not apply for #{creditdays} days in Quarterly."
         #          isflags = false
         #     elsif crediterule == 'H' && numberdys.to_f > creditdays.to_f
         #          message     = "You can not apply for #{creditdays} days in Half Yearly."
         #          isflags = false
         #     elsif crediterule == 'Y' && numberdys.to_f > creditdays.to_f
         #          message     = "You can not apply for #{creditdays} days in Yearly."
         #          isflags = false
         #      end
         # end
         ### check merge leave ## AND ls_status<>'C' and ls_category='#{catgeory}'   #
         #if leavecod.to_s !='LWM'
               if  isflags
                        ###AND ls_leave_code='#{leavecod}'
                  if mid.to_i >0
                     mylswhere = "ls_compcode ='#{compcodes}' AND ls_empcode ='#{ls_empcode}'  AND ls_status NOT IN('C','R','D') AND id <>'#{mid}' AND UPPER(ls_leavereson)<>UPPER('Forfeit')"
                  else
                     mylswhere = "ls_compcode ='#{compcodes}' AND ls_empcode ='#{ls_empcode}' AND ls_status NOT IN('C','R','D') AND UPPER(ls_leavereson)<>UPPER('Forfeit')"
                  end
                  mylswhere += "  AND (( ls_fromdate >='#{year_month_days_formatted(fromdate)}' AND ls_fromdate<='#{year_month_days_formatted(uptodated)}')"
                  mylswhere += "  OR ( ls_todate >='#{year_month_days_formatted(fromdate)}' AND ls_todate<='#{year_month_days_formatted(uptodated)}' ))"
                  leavaobj  = TrnLeave.where(mylswhere)
                  if leavaobj.length >0
                        message     = "You have already applied between these days."
                        isflags = false
                  end
              end
        # end
        # if leavecod.to_s !='LWM'     
         if  isflags
              if mergeleave == 'N'
                    #### FROM DATE MERGE LEAVE VALIDATION
                    i          = 1
                    nshld      = 0
                    nefrmdates = ''
                    nefrmdate  = Date.parse(year_month_days_formatted(fromdate));
                     while i <=30
                             if  i == 1
                               nefrmdates = nefrmdate-1                            
                             end
                             
                             nwhere = "compCode ='#{compcodes}' AND dateYear='#{year_month_days_formatted(nefrmdates)}'"
                             chkhld =  Holiday.select("id").where(nwhere)                             
                          if nefrmdates.strftime("%A") == 'Sunday'
                             nefrmdates = nefrmdates-1                            
                          elsif chkhld.length >0
                            nefrmdates = nefrmdates-1
                          else

                              chwhere   = "ls_compcode ='#{compcodes}' AND ls_category ='#{catgeory}'  AND ls_todate ='#{year_month_days_formatted(nefrmdates)}' AND ls_empcode ='#{ls_empcode}' AND ls_status NOT IN('C','R','D') AND UPPER(ls_leavereson)<>UPPER('Forfeit')"
                              leaveobj  = TrnLeave.where(chwhere)
                              if leaveobj.length >0
                                  if leaveobj[0].ls_leave_code != leavecod   
                                     mergstatus = get_merge_leave_status(leaveobj[0].ls_category,leaveobj[0].ls_leave_code)
                                     if mergstatus  
                                      
                                       ### merge allowed or not
                                       break;
                                     else
                                          message    = "You are not allowed to merge leave with leave code #{leavecod}."
                                          isflags    = false
                                          break;
                                     end
                                  end
                                
                              else
                                  break;
                              end
                             nefrmdates = nefrmdates-1
                          end
                           
                          i = i+1
                     end
                      ### END FROM DATE LEAVE MERGE VALIDATION
                     
                      ### START UPTO LEAVE VALIDATION
                    j          = 1
                    nshld      = 0
                    neuptodates = ''
                    neuptodate  = Date.parse(year_month_days_formatted(uptodated));
                     while j <=30
                             if  j == 1
                               neuptodates = neuptodate+1
                             end

                             nwheres = "compCode ='#{compcodes}' AND dateYear='#{year_month_days_formatted(neuptodates)}'"
                             chkhlds =  Holiday.select("id").where(nwheres)
                          if neuptodates.strftime("%A") == 'Sunday'
                             neuptodates = neuptodates+1
                          elsif chkhlds.length >0
                            neuptodates = neuptodates+1
                          else
                              chwheres   = "ls_compcode ='#{compcodes}' AND ls_category ='#{catgeory}'  AND ls_fromdate ='#{year_month_days_formatted(neuptodates)}' AND ls_empcode ='#{ls_empcode}' AND ls_status NOT IN('C','R','D') AND UPPER(ls_leavereson)<>UPPER('Forfeit')"
                              leaveobjs  = TrnLeave.where(chwheres)
                              if leaveobjs.length >0
                                  if leaveobjs[0].ls_leave_code != leavecod
                                       mergstatus = get_merge_leave_status(leaveobjs[0].ls_category,leaveobjs[0].ls_leave_code)
                                       if mergstatus  
                                          
                                       ### merge allowed or not
                                       break;
                                       else
                                          message    = "You are not allowed to merge leave with leave code #{leavecod}."
                                          isflags    = false
                                          break;
                                       end
                                  end

                              else
                                  break;
                              end
                             neuptodates = neuptodates+1
                          end
                          j = j+1
                     end
                      ### START UPTO LEAVE VALIDATION


              end
         end
      #end
           if weekhld == 'N'
                 nshld   = 0
                 weekhl  = 0
                 nwhere  = "compCode ='#{compcodes}' AND ( dateYear >='#{year_month_days_formatted(fromdate)}' AND dateYear <='#{year_month_days_formatted(uptodated)}' )"
                 chkhld  =  Holiday.where(nwhere)
                 if chkhld.length >0
                    nshld = chkhld.length
                    
                 end
                   if fromdate !=nil && fromdate !='' && uptodated !=nil && uptodated !=''
                     fromdatesx      = Date.parse(fromdate)
                     uptodatedsx     = Date.parse(uptodated)
                     datesbyweekday = (fromdatesx..uptodatedsx).group_by(&:wday)
                      if datesbyweekday[0]!=nil && datesbyweekday[0]!= ''
                         weekhl = datesbyweekday[0].length
                      end
                        
                   end
                   totdays   = nshld.to_f+weekhl.to_f
                   findtdays = numberdys.to_f-totdays.to_f

           end

   end
   if isflags
      if applwho == 'today'
          if fromdate && year_month_days_formatted(fromdate) !=year_month_days_formatted(Date.today)
               message    = "You can apply today only ."
               isflags    = false
          end
      elsif applwho == 'further'
             furthdate   = Date.today+90;
             furtherdate = Date.today+1;
             newdys      = (furthdate-furtherdate).to_i
             if fromdate && year_month_days_formatted(fromdate).to_date >Date.today && newdys <90
                 ### execute message
             else
                  message    = "You apply date between  #{formatted_date(furtherdate)} and #{formatted_date(furthdate)} ."
                  isflags    = false
             end
      end
   end
   
   if isflags
        sewobj =  get_mysewdar_list_details(ls_empcode)
        if sewobj
            joiningdate =  sewobj.sw_joiningdate
             if joiningdate != nil && joiningdate !=''
                  totalsewa = get_sewa_calated_yers(joiningdate)
                  if tsewyear.to_i >0 
                     if totalsewa.to_i < tsewyear.to_i 
                        message    = "Your total sewa should be not applicable."
                        isflags    = false
                     end
                  end
             end

        end
   end
   
  if isflags
       if  numberdys.to_f >leavgos.to_f && leavgos.to_f >0
          message    = "Number of days should not be greater than #{leavgos}."
          isflags    = false
       end
  end

  if findtdays.to_i <=0
    dtf = Date.parse(fromdate);
    dts =  Date.parse(uptodated);
    ndt =  (dts-dtf).to_i+1
    findtdays = ndt
  end
  ### allow check date for sewadar and support staff could not apply for back date
   #if session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
      chkdated     = "2022-11-26" 
      frdated      =  year_month_days_formatted(params[:fromdate])
      updated      =  year_month_days_formatted(params[:uptodated])
      newcheckdated = year_month_days_formatted(chkdated)
         if frdated.to_date<chkdated.to_date || updated.to_date<newcheckdated.to_date
                  message    = "Back date leave not allowed"
                  isflags    = false
         end
         # if leavecod !='OD'
         #       curryears   = Date.today.strftime("%Y") 
         #       myeyars     = ""
         #       myuptoyear  = ""
         #       cflags      = false
         #      
         #    if( frdated !=nil && frdated !='' )
         #       myeyars  = Date.parse(frdated.to_s).strftime("%Y")
         #    end
         #    if( updated !=nil && updated !='' )
         #       myuptoyear  = Date.parse(updated.to_s).strftime("%Y")
         #    end
         #    if myeyars.to_i >0 && myeyars.to_i<curryears.to_i 
         #       cflags = true
         #    end
         #    if myuptoyear.to_i >0 && myuptoyear.to_i<curryears.to_i 
         #       cflags = true
         #    end
         #    if cflags         
         #          message    = "Back year leave not allowed"
         #          isflags    = false
               
         #    end
         # end 

 #  end
  ##  PROCESS ####
   respond_to do |format|
      format.json { render :json => { 'data'=>weekhl,:status=>isflags,'message'=>message,'halfday'=>halfday,'totdays'=>findtdays} }
    end

end
private
def get_saved_leave_type(catgeory,sewcodes)
     compcodes    = session[:loggedUserCompCode]     
     userid       = session[:logedUserId]
     sewobj       = get_mysewdar_list_details(sewcodes)
    if sewobj
          gnders  = sewobj.sw_gender
          married = sewobj.sw_maritalstatus
          iswhere = "attend_compcode ='#{compcodes}' AND attend_category ='#{catgeory}' " #AND UPPER(attend_leaveCode)<>'OD'
          if gnders == 'M'
            iswhere += " AND attend_leaveavailby IN('M','B')"
           elsif gnders == 'F'
             iswhere += " AND attend_leaveavailby IN('F','B')"
          else
             iswhere += " AND attend_leaveavailby IN('B')"
           end
           userobj      = user_detail(userid)
           hr = nil
           sew = nil
           stf  = nil
           if userobj
              listmodule = userobj.listmodule.to_s.split(",")
               if listmodule && listmodule.include?('HR')
                  hr = 'HR'
               end
               if listmodule && listmodule.include?('SSS')
                  sew = 'SSS'
               end
               if listmodule && listmodule.include?('STF')
                  sew = 'STF'
               end
            end
            if hr 
               iswhere += " AND FIND_IN_SET('HR', attend_whocanapply) >0 "
            end
            if sew
               iswhere += " AND FIND_IN_SET('SSS', attend_whocanapply) >0 "
            end
            if stf
               iswhere += " AND  FIND_IN_SET('STF', attend_whocanapply) >0"
            end
            arrleave  = []
            leaveobj  = MstLeave.where(iswhere).order("attend_leavetype ASC")
            if leaveobj.length >0
               
                leaveobj.each do |newlvs|
                    if gnders =='F'
                          if married == 'Y'
                              arrleave.push newlvs
                          else
                                if newlvs.attend_leaveCode !='ML'
                                   arrleave.push newlvs
                                end
                          end
                    else
                          if newlvs.attend_leaveCode !='ML'
                             arrleave.push newlvs
                          end
                    end
                end
            end
    end

    return arrleave

end



private
def get_apply_leaves_listing
  @compCodes     =   session[:loggedUserCompCode]  
  sewacode       =   session[:sec_sewdar_code]
  if params[:requestserver] !=nil && params[:requestserver] != ''
   session[:lrequest_sewadar_name]     = nil
   session[:lrequest_leave_code]       = nil
   session[:lrequest_leave_type]       = nil
   session[:lrequest_search_fromdated] = nil
   session[:lrequest_search_uptodated] = nil
   session[:lvoucher_department]       = nil
 end
  if params[:page].to_i >0
     pages = params[:page]
  else
     pages = 1
  end

 
  search_sewadar     =   params[:search_sewadar]!=nil && params[:search_sewadar]!=nil ? params[:search_sewadar].to_s.strip : session[:lrequest_sewadar_name]
  leave_code         =   params[:leave_code]!=nil && params[:leave_code]!=nil ? params[:leave_code] : session[:lrequest_leave_code]
  leave_type         =   params[:leave_type]!=nil && params[:leave_type]!=nil ? params[:leave_type] : session[:lrequest_leave_type]
  search_fromdated   =   params[:search_fromdated]!=nil && params[:search_fromdated]!=nil ? year_month_days_formatted(params[:search_fromdated]) : session[:lrequest_search_fromdated]
  search_uptodated   =   params[:search_uptodated]!=nil && params[:search_uptodated]!=nil ? year_month_days_formatted(params[:search_uptodated]) : session[:lrequest_search_uptodated]
  voucher_department =   params[:voucher_department]!=nil && params[:voucher_department]!=nil ? params[:voucher_department] : session[:lvoucher_department]
  if search_fromdated == '' || search_fromdated == nil
    search_fromdated = @nbegindates
  end
  if search_uptodated == '' || search_uptodated == nil
    search_uptodated = @enddates
  end
  jons    = nil
  if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
   iswhere = "ls_compcode ='#{@compCodes}' AND ls_empcode ='#{sewacode}'"  
 else
   iswhere = "ls_compcode ='#{@compCodes}'"
 end
 if session[:requestuser_loggedintp] && session[:requestuser_loggedintp] =='stf' || session[:requestuser_loggedintp] =='swd'	  
   iswhere += " AND ls_depcode ='#{@mydepartcode}'"
   @voucher_department              = @mydepartcode
   session[:lvoucher_department]    = @mydepartcode
else
    if voucher_department != nil && voucher_department != ''
    iswhere += " AND ls_depcode='#{voucher_department}'"
    @voucher_department              = voucher_department
    session[:lvoucher_department]    = voucher_department
   end
end
  if search_sewadar !=nil && search_sewadar !=''
  
       iswhere += " AND ( ls_empcode LIKE '%#{search_sewadar}%' OR sw_sewadar_name LIKE '%#{search_sewadar}%' )"
       jons    =  " JOIN mst_sewadars msd ON(sw_compcode = ls_compcode AND ls_empcode = sw_sewcode)"
       session[:lrequest_sewadar_name] = search_sewadar.to_s.strip
       @search_sewadar                  = search_sewadar.to_s.strip
  end
  if leave_code !=nil && leave_code  !=''
    iswhere += " AND ls_leave_code ='#{leave_code}'"
    session[:lrequest_leave_code] = leave_code
    @leave_code = leave_code
  end
  if leave_type !=nil && leave_type  !='' 
      if  leave_type  == 'all'
         session[:lrequest_leave_type] = leave_type
         @leave_type = leave_type
      else
         iswhere += " AND ls_status ='#{leave_type}'"
         session[:lrequest_leave_type] = leave_type
         @leave_type = leave_type
      end
  else
      session[:lrequest_leave_type] = leave_type
      @leave_type = leave_type
     iswhere += " AND ls_status ='P'"
  end
  if search_fromdated !=nil && search_fromdated  !=''
      iswhere += " AND ls_fromdate >='#{search_fromdated}'"
      session[:lrequest_search_fromdated] = search_fromdated
      @search_fromdated = search_fromdated
  end
  if search_uptodated !=nil && search_uptodated  !=''
      iswhere += " AND ls_todate <='#{search_uptodated}'"
      session[:lrequest_search_uptodated] = search_uptodated
      @search_uptodated                  = search_uptodated
  end
  if jons
     leavobj = TrnLeave.select("trn_leaves.*,msd.id as swdId").joins(jons).where(iswhere).paginate(:page =>pages,:per_page => 10).order("ls_empcode ASC")
  else
     leavobj = TrnLeave.where(iswhere).paginate(:page =>pages,:per_page => 10).order("ls_empcode ASC")
  end

   return leavobj
end

end