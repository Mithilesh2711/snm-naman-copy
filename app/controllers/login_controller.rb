class LoginController < ApplicationController
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :set_dct,:set_ent,:formatted_date,:year_month_days_formatted  
	  def index
       # @ChkNumber = set_ent('8076372788')
    end
   

    ######## PROCESS TO LOGIN ################################
def create
     session[:membsh_true] = nil
     useurl =  "#{root_url}"+"login"
     if params[:userName] == ''
        flash[:error] = "Please enter user name"
        session[:isErrorhandled] = 1
        redirect_to useurl
     elsif params[:userPassword] == ''
      session[:isErrorhandled] = 1
        flash[:error] =  "Plase enter password"
        redirect_to useurl
     elsif params[:userName]!='' && params[:userPassword]!=''
            xpassword = Digest::MD5.hexdigest(params[:userPassword])
            @Item     = User.find_by_username_and_userpassword(params[:userName],xpassword)
            if @Item
                            if @Item.username.to_s == params[:userName] &&  @Item.userpassword.to_s == xpassword

                                    flash[:error]                 = nil
                                    session[:loggedUserCompCode]  = @Item.usercompcode.to_s
                                    session[:logedUserId]         = @Item.id
                                    session[:autherizedUserId]    = @Item.id
                                    session[:autherizedUserName]  = @Item.firstname.to_s
                                    session[:autherizedUserImage] = @Item.userimage.to_s
                                    session[:autherizedLoc]       = @Item.userlocation.to_s
                                    session[:autherizedUserLastNm]= @Item.lastname.to_s
                                    session[:autherizedUserType]  = @Item.usertype.to_s
                                    session[:autherizedXUserType]  = @Item.usertype.to_s
                                     session[:autherizedXUserSelectnm]  = @Item.username.to_s
                                    session[:SECURED_LOGIN_CHK]   = xpassword
                                    session[:sec_sewdar_code]     = @Item.sewadarcode.to_s
                                    userdashboard                 = @Item.userdashboard.to_s
                                    session[:sec_x_dashboard]     = userdashboard
                                    session[:sec_ecmem_code]      = @Item.ecmember.to_s
                                    session[:sec_stoff_depcode]   = @Item.suportstfdeparment.to_s
                                    session[:loggedusername]      = @Item.username
                                    session[:sec_deprtmentcode]   = @Item.sewdepart.to_s
                                    session[:sec_ec_approved]     = @Item.approvalby.to_s
                                    loginfirsttime                = @Item.loginfirsttime
                                    session[:isErrorhandled]     = nil
                                    session[:alrequest_sewadar_name]     = nil
                                    session[:alvoucher_department]       = nil
                                    if userdashboard.to_s.strip == 'swd'
                                       if @Item.approvalby.to_s == 'ec' 
                                             redirect_to "#{root_url}o_dashboard"
                                       else
                                          if loginfirsttime.to_s != 'Y' 
                                              redirect_to "#{root_url}change_password"
                                          else
                                         session[:request_absent_logged] ='Y'   
                                              redirect_to "#{root_url}s_dashboard"
                                          end
                                          
                                          
                                       end
                                      
                                    else
                                      redirect_to "#{root_url}o_dashboard"
                                    end
                                   
                            else
                              session[:isErrorhandled] = 1
                              flash[:error] =  "Incorrect user or password"
                               redirect_to useurl
                            end
            else
               session[:isErrorhandled] = 1
                flash[:error] =  "Invalid user detail"
                redirect_to useurl
            end
    end
     
end
def ajax_process
   @compCodes       = session[:loggedUserCompCode]
   if params[:identity] !=nil  && params[:identity] !='' && params[:identity] == 'SNDOTP'
        send_otp_credential_data()
     return    
   elsif params[:identity] !=nil  && params[:identity] !='' && params[:identity] == 'VFOTP'
      verify_otp_data()
   return    
 end

    
end
############### END PROCESS LOGIN ##########################
#####SEND OTP & CHECK USER ##########
private
def send_otp_credential_data
  iscompcode    =  session[:loggedUserCompCode]
  userid        =  params[:userid]
  isflags       =  true
  message       =  ""
  otpnumber    = ''
  if userid == nil || userid == ''
      message = "User id is required."
      isflags = false
  else
      otpnumber =  generate_common_numbers(6)
      iswhere   =  "username='#{userid}'"
      objuser   =  User.where(iswhere).first
      name      =  ""
      mobdecode =  ""
      membobjs  =  nil

      if objuser
           memmberid   = objuser.ecmember
           iscompcode  = objuser.usercompcode
           objuser.update(:otpnumber=>otpnumber)                    
            persobj  = get_personal_information(iscompcode,userid)
            if persobj
              #### NOTHING TO DO
            else
              membobjs = get_memeber_information(iscompcode,memmberid)
            end
             persinfo = get_login_sewdar_single_list(iscompcode,userid)
            if persobj ### IF CASE SEWADAR ONLY
                 mobiles   = persobj.sp_mobileno
                 mobdecode = "******"+mobiles[6..10].to_s
    
                if persinfo
                  name     = persinfo.sw_sewadar_name
                end
                messages = "Rev. #{name} Ji, Dhan Nirankar Ji, Your password reset request has been received, please enter OTP :#{otpnumber} for Password reset.- Team NAMAN, Sant Nirankari Mandal"
                UserMailMailer.send_common_message(mobiles,messages,1307165650194726697).deliver
                message  = "An OTP has been sent to your registered mobile number #{mobdecode}."   
                # Rev. {#var#} Ji, Dhan Nirankar Ji, Your password reset request has been received, please enter OTP :#{otpnumber} for Password reset.- Team NAMAN, Sant Nirankari Mandal
                isflags = true 
            elsif membobjs ### IF CASE MEMBER ONLY
                mobiles   = membobjs.lds_mobile!=nil && membobjs.lds_mobile!='' ? set_dct(membobjs.lds_mobile) : ''
                mobdecode = "******"+mobiles[6..10].to_s  
                name      = membobjs.lds_name
                messages  = "Rev. #{name} Ji, Dhan Nirankar Ji, Your password reset request has been received, please enter OTP :#{otpnumber} for Password reset.- Team NAMAN, Sant Nirankari Mandal"
                UserMailMailer.send_common_message(mobiles,messages,1307165650194726697).deliver
                message  = "An OTP has been sent to your registered mobile number #{mobdecode}."   
                # Rev. {#var#} Ji, Dhan Nirankar Ji, Your password reset request has been received, please enter OTP :#{otpnumber} for Password reset.- Team NAMAN, Sant Nirankari Mandal
                isflags = true 
            else  
                message = "Contact number is not found."
                isflags = false 
            end 

      else
          message = "Invalid User Id"
          isflags = false 
      end
  end
  respond_to do |format|
    format.json { render :json => { :status=>isflags,'message'=>message,:data=>otpnumber } }
  end

end

######## VERIFY OTP NUMBER ############
private
def verify_otp_data
  iscompcode    =  session[:loggedUserCompCode]
  userid        =  params[:userid]
  optnumber     =  params[:otp_number]
  isflags       =  true
  message       =  ""
  if userid == nil || userid == ''
      message = "User id is required."
      isflags = false
  elsif optnumber == nil  || optnumber == ''  
      message = "Otp number should not blank."
      isflags = false 
  else      
      iswhere  = " username ='#{userid}' AND otpnumber ='#{optnumber}'"
      objuser  =  User.where(iswhere).first
      membobjs =  nil
      name = ''
      if objuser
          memmberid   = objuser.ecmember
          iscompcode  = objuser.usercompcode
          genpassword = generate_common_numbers(8)
          persobj     = get_personal_information(iscompcode,userid)
          if persobj
            #### NOTHING TO DO
          else
            membobjs = get_memeber_information(iscompcode,memmberid)
          end

          persinfo = get_login_sewdar_single_list(iscompcode,userid)
          if persobj ### IF CASE SEWADAR ONLY
              newpassword = Digest::MD5.hexdigest(genpassword.to_s)
              objuser.update(:userpassword=>newpassword)
              mobiles  = persobj.sp_mobileno
              if persinfo
                  name  = persinfo.sw_sewadar_name
              end
              messages = "Rev. #{name} Ji, Dhan Nirankar Ji, Your password has been changed successfully, New temporary password is #{genpassword}. Kindly change password on first login.- Team NAMAN, Sant Nirankari Mandal"
              #  messages = "Rev. 123 Ji, Dhan Nirankar Ji, Your password has been changed successfully, New temporary password is 123. Kindly change password on first login.- Team NAMAN, Sant Nirankari Mandal"
              UserMailMailer.send_common_message(mobiles,messages,1307165650210163611).deliver
              message = "Password reset successfully . You will receive password in SMS, Please check your registered mobile no."
              isflags = true           
          elsif membobjs ### IF CASE MEMBER ONLY
                newpassword = Digest::MD5.hexdigest(genpassword.to_s)
                objuser.update(:userpassword=>newpassword)
                mobiles  = membobjs.lds_mobile!=nil && membobjs.lds_mobile!='' ? set_dct(membobjs.lds_mobile) : ''
                name     = membobjs.lds_name
                messages = "Rev. #{name} Ji, Dhan Nirankar Ji, Your password has been changed successfully, New temporary password is #{genpassword}. Kindly change password on first login.- Team NAMAN, Sant Nirankari Mandal"
                #  messages = "Rev. 123 Ji, Dhan Nirankar Ji, Your password has been changed successfully, New temporary password is 123. Kindly change password on first login.- Team NAMAN, Sant Nirankari Mandal"
                UserMailMailer.send_common_message(mobiles,messages,1307165650210163611).deliver
                message = "Password reset successfully . You will receive password in SMS, Please check your registered mobile no."
                isflags = true  
          else  
              message = "Contact number not found."
              isflags = false 
          end
         
      else
          message = "Invalid OTP number you entered"
          isflags = false 
      end
  end
  respond_to do |format|
    format.json { render :json => { :status=>isflags,'message'=>message } }
  end

end
 private
  def get_personal_information(compcode,empcode)
         sewdarobj =  MstSewadarPersonalInfo.where("sp_sewcode =?",empcode).first
         return sewdarobj
  end
  private
  def get_memeber_information(compcode,membid)
         sewdarobj =  MstLedger.where("lds_compcode =?  AND id =?",compcode,membid).first
         return sewdarobj
  end

private
def get_login_sewdar_single_list(compcodes,sewcodes)
  
  sewdobj    = MstSewadar.where("sw_sewcode =?",sewcodes).first
  return sewdobj
end
end
