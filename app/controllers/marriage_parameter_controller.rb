## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for allotment an address to SEWADATRA
### FOR REST API ######
class MarriageParameterController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted
    def index
     @compcodes     = session[:loggedUserCompCode]
     @ListMarriage  = MstMarriageParameter.where("mp_compcode =? ",@compcodes).first
  end
  def ajax_process
    
  end
  def create
         @compcodes = session[:loggedUserCompCode]
        isFlags     = true
        ApplicationRecord.transaction do
          begin
              if params[:mp_totalsewaself] == nil || params[:mp_totalsewaself] == ''
                     flash[:error] =  "Total sewa self is required"
                     isFlags       =  false
               elsif params[:mp_totalsewaengage] == nil || params[:mp_totalsewaengage] == ''
                     flash[:error] =  "Total sewa engage is required"
                     isFlags       =  false
              elsif params[:mp_totalsewaengage] == nil || params[:mp_totalsewaengage] == ''
                     flash[:error] =  "For male is required"
                     isFlags       =  false
              elsif params[:mp_totalsewaengage] == nil || params[:mp_totalsewaengage] == ''
                     flash[:error] =  "For female is required"
                     isFlags       =  false
              else

                  cheqobj    = MstMarriageParameter.where("mp_compcode = ?",@compcodes)
                  if cheqobj.length >0
                              if isFlags
                                   stateupobj  = MstMarriageParameter.where("mp_compcode = ?",@compcodes).first
                                    if stateupobj
                                         stateupobj.update(marriage_params)
                                          flash[:error] = "Data updated successfully."
                                          isFlags       = true
                                    end
                              end
                    else

                             if isFlags
                                  stsobj = MstMarriageParameter.new(marriage_params)
                                  if stsobj.save
                                     flash[:error] =  "Data saved successfully."
                                     isFlags = true
                                  end

                             end
                  end
              end
                rescue Exception => exc
                  flash[:error]            = "#{exc.message}"
                  session[:isErrorhandled] = 1
                  isFlags                  = false
                  raise ActiveRecord::Rollback
            end
    end
     if !isFlags
         session[:isErrorhandled] = 1
         isFlags = false
     else
         session[:request_params] = nil
         session[:isErrorhandled] = nil
         session.delete(:request_params)
     end
      redirect_to "#{root_url}"+"marriage_parameter"
  end
  private
  def marriage_params
      params[:mp_compcode]           = @compcodes
      params[:mp_totalsewaself]      = params[:mp_totalsewaself] !=nil && params[:mp_totalsewaself] !='' ? params[:mp_totalsewaself] : 0
      params[:mp_totalsewaengage]    = params[:mp_totalsewaengage] !=nil && params[:mp_totalsewaengage] !='' ? params[:mp_totalsewaengage] : 0
      params[:mp_totalsewaformale]   = params[:mp_totalsewaformale] !=nil && params[:mp_totalsewaformale] !='' ? params[:mp_totalsewaformale] : 0
      params[:mp_totalsewafemale]    = params[:mp_totalsewafemale] !=nil && params[:mp_totalsewafemale] !='' ? params[:mp_totalsewafemale] : 0      
      params.permit(:mp_compcode,:mp_totalsewaself,:mp_totalsewaengage,:mp_totalsewaformale,:mp_totalsewafemale)
  end
end
