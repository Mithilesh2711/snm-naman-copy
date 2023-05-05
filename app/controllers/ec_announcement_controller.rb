class EcAnnouncementController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_emp_attached_file,:get_employee_types,:get_leavemaster_detail
  helper_method :get_all_department_detail,:get_link_image,:format_oblig_date,:get_mysewdar_list_details,:get_first_my_sewadar
  helper_method :get_sewa_all_department,:get_sewa_all_rolesresp,:user_detail,:get_department_detail
  
  def index
    @authorizedId  =   session[:autherizedUserId]
    @compCodes     =   session[:loggedUserCompCode]
    @empDetail     =   MstSewadar.where("sw_compcode =?",@compCodes).order("sw_sewadar_name ASC")#Personal.where("emp_compcode=?",@compCodes)
    @MstLeave      =   MstLeave.where("attend_compcode=?",@compCodes).order("attend_leaveCode ASC")
    mydeprtcode    =   ""
    @newsewdarList =  nil
    @Hodname       =  nil
    if session[:sec_x_dashboard] && session[:sec_x_dashboard].to_s == 'cod' || session[:sec_x_dashboard].to_s == 'ec'
        anobs = get_member_listed(session[:sec_ecmem_code])
        if anobs
          @Hodname = anobs.lds_name
        end
    else
        @Hodname = session[:autherizedUserName]
    end
    if session[:sec_sewdar_code]
         sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
         if sewobjs
            mydeprtcode   = sewobjs.sw_depcode
            @mydepartcode = sewobjs.sw_depcode
         end
     end
     if session[:sec_x_dashboard] && session[:sec_x_dashboard].to_s == 'cod' || session[:sec_x_dashboard].to_s == 'ec'
       ecmembobj =  get_member_listed(session[:sec_ecmem_code])
       hodid  = ""
       if ecmembobj
            hodid = ecmembobj.lds_membno
       end
       @sewDepart     =   Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment='' AND departHod = ?",@compCodes,hodid).order("departDescription ASC")
      else
        @sewDepart     =   Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment=''",@compCodes).order("departDescription ASC")
      end
       
   
    @announcementListed = get_apply_announcment
    
  end

def  ec_announcement_refresh
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
      session[:request_sewadar_search] = nil
      session[:req_myusedept]   = nil
      session[:req_myuseaccord] = nil
      session[:req_myusestring] = nil
      redirect_to "#{root_url}ec_announcement"
end
def cancel
  @compCodes     =   session[:loggedUserCompCode]
  if params[:id].to_i >0
      leaveobj  =  TrnAnnouncement.where("ans_compcode = ? AND id = ?",@compCodes,params[:id]).first 
      if leaveobj.destroy
          session[:isErrorhandled]  = nil
          flash[:error] =  "Data deleted successfully."
      end
  end
   redirect_to "#{root_url}"+"ec_announcement"
end


def add_announcement
    @compCodes        =  session[:loggedUserCompCode]
    @sewadarCategory  =  MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
    @sewcoded         =  nil
    @newsewdarList    =  nil
    @ListDist         =  nil
    @LeavePermit      =  nil
    @lockEdited       =  true
    @sewDepart        =  nil
    mydeprtcode       =  ""
    category          =  ""
    @Hodname          =  nil
    if session[:sec_x_dashboard] && session[:sec_x_dashboard].to_s == 'cod' || session[:sec_x_dashboard].to_s == 'ec'
        anobs = get_member_listed(session[:sec_ecmem_code])
        if anobs
          @Hodname = anobs.lds_name
        end
    else
        @Hodname = session[:autherizedUserName]    
    end
    if session[:sec_sewdar_code]
         sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
         if sewobjs          
            mydeprtcode   = sewobjs.sw_depcode
            category      = sewobjs.sw_catgeory
         end
     end
     if session[:sec_x_dashboard] && session[:sec_x_dashboard].to_s == 'swd'
         @sewcoded      =   session[:sec_sewdar_code]
     end
    if params[:id].to_i >0
         @lockEdited     =   false
         @ListDist       =   TrnAnnouncement.where("ans_compcode = ? AND id = ?",@compCodes,params[:id]).first      
    end
    
     if session[:sec_x_dashboard] && session[:sec_x_dashboard].to_s == 'cod' || session[:sec_x_dashboard].to_s == 'ec'
       ecmembobj =  get_member_listed(session[:sec_ecmem_code])
       hodid  = ""
       if ecmembobj
            hodid = ecmembobj.lds_membno
       end
       @sewDepart     =   Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment='' AND departHod = ?",@compCodes,hodid).order("departDescription ASC")
     end
end

def ajax_process
  if params[:identity] !=nil && params[:identity] != '' && params[:identity] == 'Y'
       get_dated_diff()
       return
  elsif params[:identity] !=nil && params[:identity] != '' && params[:identity] == 'REMAINLEAVE'
       get_remain_balance_leave()
       return
 
  end




end

  def create
  @compcodes  = session[:loggedUserCompCode]
  isFlags     = true
  mid         = params[:mid]
  begin
  if params[:ans_postedby]=='' || params[:ans_postedby]==nil
       flash[:error] =  "Posted by is required"
       isFlags       =  false
   elsif params[:ans_posteddashboard]=='' || params[:ans_posteddashboard]==nil
       flash[:error] =  "Posted dashboard is required"
       isFlags       =  false
    elsif params[:ans_postingdate]=='' || params[:ans_postingdate]==nil
       flash[:error] =  "Posting date is required"
       isFlags       =  false
   elsif params[:ans_postingtime] == '' || params[:ans_postingtime] == nil
       flash[:error] =  "Posting  time is required"
       isFlags       =  false
   elsif params[:ans_announcment] == '' || params[:ans_announcment] == nil
       flash[:error] =  "Announcement is required"
       isFlags       =  false
   elsif params[:ans_publishdate] == '' || params[:ans_publishdate] == nil
       flash[:error] =  "Publishing date is required"
       isFlags       =  false
   elsif params[:ans_publishtime] == '' || params[:ans_publishtime] == nil
       flash[:error] =  "Publishing time is required"
       isFlags       =  false
   else       

         if mid.to_i >0
               uptleave = TrnAnnouncement.where("ans_compcode = ? AND id = ?",@compcodes,mid).first
               if uptleave
                   uptleave.update(announcemnt_params)
                    #save_update_opebal
                    flash[:error] =  "Data updated successfully."
                    isFlags       = true
               end
         else
            
             if isFlags
                 savleave = TrnAnnouncement.new(announcemnt_params)
                  if savleave.save
                     # save_update_opebal
                      flash[:error] =  "Data saved successfully."
                      isFlags       = true
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
          session[:isErrorhandled]          = 1
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
         redirect_to "#{root_url}"+"ec_announcement/add_announcement"
      else
         redirect_to "#{root_url}"+"ec_announcement"
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
  def announcemnt_params
      strdate = 0
      uptodate = 0
      if params[:ans_postingdate]!=nil && params[:ans_postingdate]!=''
        strdate  = year_month_days_formatted(params[:ans_postingdate].to_s)
      end
      
     if params[:ans_publishdate] !=nil && params[:ans_publishdate] !=''
        uptodate     = year_month_days_formatted(params[:ans_publishdate].to_s)
      end      
     
      params[:ans_compcode]          = session[:loggedUserCompCode]
      params[:ans_postedby]          = params[:ans_postedby]!=nil && params[:ans_postedby]!= '' ? params[:ans_postedby] : ''
      params[:ans_posteddashboard]   = params[:ans_posteddashboard]!=nil && params[:ans_posteddashboard]!= '' ? params[:ans_posteddashboard] : ''
     
      params[:ans_postingdate]   = strdate
      params[:ans_postingtime]   = params[:ans_postingtime]!=nil && params[:ans_postingtime]!='' ? params[:ans_postingtime] : ''
      params[:ans_announcment]   = params[:ans_announcment] !=nil && params[:ans_announcment] !='' ? params[:ans_announcment] : ''
      params[:ans_publishdate]   = uptodate
      params[:ans_publishtime]   = params[:ans_publishtime] !=nil && params[:ans_publishtime] !='' ? params[:ans_publishtime] : ''
      params[:ans_status]        = params[:ans_status] !=nil &&  params[:ans_status] !='' ?  params[:ans_status] : 'N'      
      params.permit(:ans_compcode,:ans_postedby,:ans_posteddashboard,:ans_postingdate,:ans_postingtime,:ans_announcment,:ans_publishdate,:ans_publishtime,:ans_status)
  end
 


private
def get_apply_announcment
        @compCodes     =   session[:loggedUserCompCode]
        if params[:requestserver] !=nil && params[:requestserver] != ''
              session[:request_sewadar_search] = nil
              session[:req_myusedept]   = nil
              session[:req_myuseaccord] = nil
              session[:req_myusestring] = nil
        end
        if params[:page].to_i >0
         pages = params[:page]
        else
         pages = 1
        end

       sewadar_departments = params[:sewadar_departments] != nil && params[:sewadar_departments] !='' ? params[:sewadar_departments] : session[:req_myusedept]
       sewadar_codetype    = params[:sewadar_codetype] != nil && params[:sewadar_codetype] !='' ? params[:sewadar_codetype] : session[:req_myuseaccord]       

      iswhere = "ans_compcode ='#{@compCodes}'"
     if  sewadar_departments !=nil  && sewadar_departments != ''
       iswhere += " AND ans_posteddashboard ='#{sewadar_departments}'"
          @sewadar_departments    = params[:sewadar_departments]
          session[:req_myusedept] = params[:sewadar_departments]
     end
      if sewadar_codetype !=nil && sewadar_codetype !=''
           iswhere += " AND ans_status ='#{sewadar_codetype}'"
           session[:req_myuseaccord] = sewadar_codetype
           @sewadar_codetype         =  sewadar_codetype
      end
      
     leavobj = TrnAnnouncement.where(iswhere).paginate(:page =>pages,:per_page => 20).order("id DESC")
     return leavobj
end



end