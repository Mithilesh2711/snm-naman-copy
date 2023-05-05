## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for create users
### FOR REST API ######
class CreateUserController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search,:create_user,:user_list]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_user_access_option
    helper_method :set_dct,:set_ent,:get_sewdar_listed_detail,:get_all_department_detail,:get_mysewdar_list_details
 def index
    @compCodes   = session[:loggedUserCompCode]
    @ListDepart  = Department.where("compCode = ? AND subdepartment =''",@compCodes).order("departDescription ASC")
    @ListModule  = MstListModule.where("lm_compcode = ? AND lm_status='Y'",@compCodes).order("lm_modules ASC")
    @ListForms   = TrnUserAccess.where("id >0").group("form_type").order("form_type ASC")
    @useFormList = TrnUserAccess.where("id>0").order("menu_name ASC")
    @ZoneList    = MstZone.where("zn_compcode = ?",@compCodes).order("zn_name ASC")

    @ListUsers    = nil
    @sewdarListed = nil
    @BranchList   = nil
    @EcCodMemmber = nil
    if params[:id].to_i >0
        @ListUsers    = User.where("usercompcode = ? AND id = ?",@compCodes,params[:id]).first
        if @ListUsers && @ListUsers.usertype == 'brc'
                @sewdarListed = MstSewadar.where("sw_compcode =? AND sw_branchtype = 'Branch'",@compCodes).order("sw_sewadar_name ASC")
        else
              objsewd       = get_sewdar_listed_detail(@ListUsers.sewadarcode)
              if objsewd
                 @sewdarListed = MstSewadar.where("sw_compcode =? AND sw_depcode = ?",@compCodes, objsewd.sw_depcode).order("sw_sewadar_name ASC")
              end
        end
        if @ListUsers
              @BranchList      = MstBranch.where("bch_compcode = ? AND bch_zonecode = ?",@compCodes,@ListUsers.zonecode).order("bch_branchname ASC")
        end
        if @ListUsers && @ListUsers.approvalby == 'ec' || @ListUsers.approvalby == 'cod'
                if @ListUsers.approvalby == 'ec'
                  ectype = 'EC'
                elsif @ListUsers.approvalby == 'cod'
                  ectype = 'Cordinators'
                end
            @EcCodMemmber = MstLedger.where("lds_compcode =? AND lds_type=?",@compCodes,ectype).order("lds_name ASC")
        end
         
        
    end

 end

 def create
 @compCodes   = session[:loggedUserCompCode]
 isFlags      = true
  begin

  if params[:username] == '' || params[:username] == nil
        flash[:error] =  "User name is required."
        isFlags      =  false
   elsif params[:usertype] == '' || params[:usertype] == nil
        flash[:error] =  "User type is required."
        isFlags      =   false
   elsif params[:listmodule].to_s.length <=0
        flash[:error] =  "List module is required."
        isFlags       =  false

  else
       currentusername = params[:currentusername].to_s.strip
       username        = params[:username].to_s.strip
       mid             = params[:mid]
        
         if mid.to_i >0
                if currentusername.to_s.delete(' ').downcase != username.to_s.delete('').downcase
                    userobj = User.where("usercompcode = ? AND username = ?",@compCodes,username)
                   if userobj.length >0
                        flash[:error] = "Your entered username is already taken, Please try to another."
                        isFlags       = false
                   end
                end
                if isFlags
                       userupobj  = User.where("usercompcode = ? AND id = ?",@compCodes,mid).first
                        if userupobj
                            userupobj.update(user_params)
                            flash[:error] = "Data updated successfully."
                            isFlags       = true
                        end
                end
                     
           else                   
                    userobj = User.where("usercompcode = ? AND username = ?",@compCodes,username)
                   if userobj.length >0
                        flash[:error] = "Your entered username is already taken, Please try to another."
                        isFlags       = false
                   end

                     if isFlags
                        usersobj = User.new(user_params)
                        if usersobj.save
                          flash[:error] =  "Data saved successfully."
                          isFlags = true
                       end
                    end
        end
  end

   if !isFlags
       session[:isErrorhandled]    = 1
       session[:req_username]      = params[:username]
       session[:req_sewadarcode]   = params[:sewadarcode]
       session[:req_usertype]      = params[:usertype]
       
   else
      session[:req_username]      = nil
      session[:req_sewadarcode]   = nil
      session[:req_usertype]      = nil
      session[:isrequestparam] = nil
      session.delete(:isrequestparam)
      session[:isErrorhandled] = nil
      session.delete(:isErrorhandled)
   end

  rescue Exception => exc
      flash[:error]            = "#{exc.message}"
      session[:isErrorhandled] = 1
  end
   if !isFlags
      redirect_to "#{root_url}"+"create_user"
   else
      redirect_to "#{root_url}"+"create_user/user_list"
   end
   

 end
 def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         @ListUser =  User.where("usercompcode =? AND id = ?",@compcodes,params[:id]).first
         if @ListUser
              @ListUser.destroy
              flash[:error] =  "Data deleted successfully."
              isFlags       = true
              session[:isErrorhandled] = 1
         end
    end
    redirect_to "#{root_url}create_user/user_list"
 end
 def user_list
    @compCodes    = session[:loggedUserCompCode]
     @ListDepart  = Department.where("compCode = ? AND subdepartment =''",@compCodes).order("departDescription ASC")
     iswhere       = "usercompcode ='#{@compCodes}' AND  username <>'' "
     if params[:requestserver] !=nil && params[:requestserver] !=''
       session[:req_search_department] = nil
       session[:req_search_username] = nil
     end
     search_department = params[:search_department] !=nil && params[:search_department] !='' ? params[:search_department] : session[:req_search_department]
     search_username   = params[:search_username] !=nil && params[:search_username] !='' ? params[:search_username] : session[:req_search_username]
     jons = ""
     if search_department !=nil && search_department !=''
       iswhere       += " AND sw_depcode = '#{search_department}'"
       jons          = " JOIN mst_sewadars swd ON( sw_compcode = usercompcode AND sw_sewcode = sewadarcode )"
       session[:req_search_department] = search_department
       @search_department = search_department
     end
     if search_username !=nil && search_username !=''
        iswhere       += " AND username LIKE '%#{search_username}%'"
        session[:req_search_username] = search_username
        @search_username = search_username
     end
     if jons !=nil && jons !=''
       @AllUsers    = User.select("swd.id as swdId,users.*").joins(jons).where(iswhere).order("users.created_at DESC")
     else
       @AllUsers    = User.where(iswhere).order("users.created_at DESC")
     end
     
end


private
def user_params
    compcode              = session[:loggedUserCompCode]
    params[:usercompcode] = compcode
    params[:userimage]    = ""
    mid                   = params[:mid]
    listmodule            = ''
    allowparameter        = ''
    params[:sewadarcode]  =  params[:sewadarcode] !=nil &&  params[:sewadarcode] !='' ?  params[:sewadarcode] : ''
    params[:username]     =  params[:username] !=nil &&  params[:username] !='' ?  params[:username] : ''
    userpassword          =  params[:userpassword] !=nil &&  params[:userpassword] !='' ?  params[:userpassword] : ''
    params[:usertype]     =  params[:usertype] !=nil &&  params[:usertype] !='' ?  params[:usertype] : ''
    params[:sewdepart]    =  params[:mydepartment] !=nil &&  params[:mydepartment] !='' ?  params[:mydepartment] : ''
    params[:zonecode]     =  params[:my_zones] !=nil &&  params[:my_zones] !='' ?  params[:my_zones] : ''
    params[:branchcode]   =  params[:my_branch] !=nil &&  params[:my_branch] !='' ?  params[:my_branch] : ''
    params[:userdashboard] =  params[:mydashboards] !=nil &&  params[:mydashboards] !='' ?  params[:mydashboards] : ''
  
    params[:ecmember]           =  params[:myecordination] !=nil &&  params[:myecordination] !='' ?  params[:myecordination] : 0
    params[:suportstfdeparment] =  params[:mysupportstaffdepartment] !=nil &&  params[:mysupportstaffdepartment] !='' ?  params[:mysupportstaffdepartment] : ''
  	params[:approvalby]         =  params[:approvalby]  !=nil && params[:approvalby]  !='' ? params[:approvalby]  : ''
    params[:managetype]         =  params[:maallowed]  !=nil && params[:maallowed]  !='' ? params[:maallowed]  : ''
    
  
    if params[:listmodule]!=nil && params[:listmodule]!=''
          params[:listmodule].each do |modulecode|
            listmodule += modulecode+","
          end
          if listmodule !=nil && listmodule !=''
            listmodule = listmodule.to_s.chop
          end
          params[:listmodule] = listmodule
     end 

  if params[:allowhrparameter]!=nil && params[:allowhrparameter]!=''
      params[:allowhrparameter].each do |hrparams|
        allowparameter += hrparams.to_s+","
      end
      if allowparameter !=nil && allowparameter !=''
        allowparameter = allowparameter.to_s.chop
      end
      
    end 
      params[:allowhrparameter] = allowparameter
      if userpassword !='' && userpassword !=nil
        xpassword = Digest::MD5.hexdigest(userpassword)
        params[:userpassword] = xpassword
      end
   
       if mid.to_i >0
            if xpassword !=nil && xpassword !=''
               params.permit(:usercompcode,:allowhrparameter,:managetype,:approvalby,:ecmember,:suportstfdeparment,:userdashboard,:zonecode,:branchcode,:sewdepart,:username,:userpassword,:usertype,:userimage,:sewadarcode,:listmodule)
            else
              params.permit(:usercompcode,:allowhrparameter,:managetype,:approvalby,:ecmember,:suportstfdeparment,:userdashboard,:zonecode,:branchcode,:sewdepart,:username,:usertype,:userimage,:sewadarcode,:listmodule)
            end

       else         
              params.permit(:usercompcode,:allowhrparameter,:managetype,:approvalby,:ecmember,:suportstfdeparment,:userdashboard,:zonecode,:branchcode,:sewdepart,:username,:userpassword,:usertype,:userimage,:sewadarcode,:listmodule)
       end

 end

private
def get_sewdar_listed_detail(sewcode)
   compcode  =  session[:loggedUserCompCode]
   sewobj      = MstSewadar.where("sw_compcode =? AND sw_sewcode = ?",compcode, sewcode).first
   return sewobj
end
def get_user_access_option(compcode,controllername,user)
 tnsbs =  TrnUserRight.where("ur_compcode = ?  AND ur_controller = ? AND ur_user = ?",compcode,controllername,user).first
  return tnsbs
end
end
