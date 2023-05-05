## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for allotment an address to SEWADATRA
### FOR REST API ######
class EducationParameterController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted
    
  def index
     @compcodes     = session[:loggedUserCompCode]
     @ListEducation = MstEducationalParameter.where("ep_compcode =? ",@compcodes).first
  end

  def create
         @compcodes = session[:loggedUserCompCode]
        isFlags     = true
        ApplicationRecord.transaction do
          begin
              if params[:ep_aglimit] == nil || params[:ep_aglimit] == ''
                   flash[:error] =  "Age limit is required."
                   isFlags       =  false
              else
                 
                  cheqobj    = MstEducationalParameter.where("ep_compcode = ?",@compcodes)
                  if cheqobj.length >0

                        if isFlags
                             stateupobj  = MstEducationalParameter.where("ep_compcode = ?",@compcodes).first
                              if stateupobj
                                   stateupobj.update(education_params)
                                    flash[:error] = "Data updated successfully."
                                    isFlags       = true
                              end
                        end
                  else

                             if isFlags
                                  stsobj = MstEducationalParameter.new(education_params)
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
      redirect_to "#{root_url}"+"education_parameter"
  end
  private
  def education_params
      params[:ep_compcode]           = @compcodes
      params[:ep_aglimit]            = params[:ep_aglimit] !=nil && params[:ep_aglimit] !='' ? params[:ep_aglimit] : 0
      params[:ep_fromfirstto]        = params[:ep_fromfirstto] !=nil && params[:ep_fromfirstto] !='' ? params[:ep_fromfirstto] : 0
      params[:ep_uptofifth]          = params[:ep_uptofifth] !=nil && params[:ep_uptofifth] !='' ? params[:ep_uptofifth] : 0
      params[:ep_firstfifthamt]      = params[:ep_firstfifthamt] !=nil && params[:ep_firstfifthamt] !='' ? params[:ep_firstfifthamt] : 0
      params[:ep_fromsixto]          = params[:ep_fromsixto] !=nil && params[:ep_fromsixto] !='' ? params[:ep_fromsixto] : 0
      params[:ep_uptotwelth]         = params[:ep_uptotwelth] !=nil && params[:ep_uptotwelth] !='' ? params[:ep_uptotwelth] : 0
      params[:ep_sixtotwelthamt]     = params[:ep_sixtotwelthamt] !=nil && params[:ep_sixtotwelthamt] !='' ? params[:ep_sixtotwelthamt] : 0
      params[:ep_univfirstyearamt]   = params[:ep_univfirstyearamt] !=nil && params[:ep_univfirstyearamt] !='' ? params[:ep_univfirstyearamt] : 0
      params[:ep_univsecondyearamt]  = params[:ep_univsecondyearamt] !=nil && params[:ep_univsecondyearamt] !='' ? params[:ep_univsecondyearamt] : 0
      params[:ep_univthirdamt]       = params[:ep_univthirdamt] !=nil && params[:ep_univthirdamt] !='' ? params[:ep_univthirdamt] : 0
      params[:ep_postgraduateamt]    = params[:ep_postgraduateamt] !=nil && params[:ep_postgraduateamt] !='' ? params[:ep_postgraduateamt] : 0
      params[:ep_postgraduatesecamt] = params[:ep_postgraduatesecamt] !=nil && params[:ep_postgraduatesecamt] !='' ? params[:ep_postgraduatesecamt] : 0
      params[:ep_docterateamt]       = params[:ep_docterateamt] !=nil && params[:ep_docterateamt] !='' ? params[:ep_docterateamt] : 0
      params[:ep_doctoratesecamt]    = params[:ep_doctoratesecamt] !=nil && params[:ep_doctoratesecamt] !='' ? params[:ep_doctoratesecamt] : 0
      params.permit(:ep_compcode,:ep_aglimit,:ep_fromfirstto,:ep_uptofifth,:ep_uptofifth,:ep_firstfifthamt,:ep_fromsixto,:ep_uptotwelth,:ep_sixtotwelthamt,:ep_univfirstyearamt,:ep_univsecondyearamt,:ep_univthirdamt,:ep_postgraduateamt,:ep_postgraduatesecamt,:ep_docterateamt,:ep_doctoratesecamt)
  end
end
