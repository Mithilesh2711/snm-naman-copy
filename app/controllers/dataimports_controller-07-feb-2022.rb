class DataimportsController < ApplicationController
  before_action :require_login
 
  #skip_before_action :verify_authenticity_token, :only=> [:index]
  def index
    @compcodes  =  session[:loggedUserCompCode]
    @logedId    =  session[:autherizedUserId]
    @xLoc       =  session[:autherizedLoc]
  end
  
  def create
  @compcodes  = session[:loggedUserCompCode]
  $compcodes  = @compcodes
  isFlags     = true
 # begin
   if params[:file]!=nil && params[:file]!=''    
      $isimport ="zone"
      ############### IMPORT CUSTOMER & PRODUCT DATA ITEMS#############
      if $isimport == 'zone'
         # if  MstZone.import(params[:file])
          if  MstZone.process_zone_incharge(params[:file])
            flash[:error] =  "You have saved successfully "+(($xcount.to_s.length.to_i >0 ) ? $xcount.to_s : '0' )+" record(s)!"
            isFlags = true
            session[:isErrorhandled] = nil
          end
      end
     ############### END IMPORT CUSTOMER & PRODUCT DATA ITEMS#############
   end
 
 if !isFlags
  session[:postedpamams] = params
  session[:isErrorhandled] = 1
 else
   session[:postedpamams] = nil
   session[:isErrorhandled] = nil
 end
# rescue Exception => exc
#      flash[:error] =   "#{exc.message}"
#      session[:isErrorhandled] = 1
#  end
 redirect_to "#{root_url}"+"dataimports"
end

end
