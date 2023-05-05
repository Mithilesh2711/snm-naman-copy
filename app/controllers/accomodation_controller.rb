class AccomodationController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:search,:ledger_list,:ajax_process]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted
  helper_method :format_oblig_date,:get_accomodation_type

  def index
     @compcodes   = session[:loggedUserCompCode]
     @HeadListed  = get_list_of_accomodation 
  end
  def manage_accomodation
    @compcodes       = session[:loggedUserCompCode]
    @hraccmtype      = MstAccomodationType.where("at_compcode =?",@compcodes).order("at_description ASC")
    @sewadarState    = MstState.where("sts_compcode =?",@compcodes).order("sts_description ASC")
    @HeadAccomo      = nil
    @sewadarpsDist   = nil
    if params[:id].to_i >0
      @HeadAccomo  = MstAccomodationDetail.where("ad_compcode =? AND id = ?",@compcodes,params[:id]).first
        if @HeadAccomo
          @sewadarpsDist   = MstDistrict.where("dts_compcode =? AND dts_statecode =?",@compcodes,@HeadAccomo.ad_state).order("dts_description ASC")
        end
      
    end
    
  end

  def create
    @compcodes = session[:loggedUserCompCode]
    isFlags    = true
    begin
        if params[:ad_accomodtype] == nil || params[:ad_accomodtype] == ''
           flash[:error] =  "Accomodation type is required."
           isFlags = false
        elsif params[:ad_address] == nil || params[:ad_address] == ''
           flash[:error] =  "Address is required."
           isFlags = false
      
        else
            mid          = params[:mid]
            curaccomo    = params[:ad_accomodtype]
            prevaccomo   = params[:prevaccomod]
           

            if mid.to_i >0
                  if curaccomo.to_i != prevaccomo.to_i

                       chekaccomtype = MstAccomodationDetail.where("ad_compcode =? AND ad_accomodtype = ? ",@compcodes,curaccomo)
                       if chekaccomtype.length >0
                            #flash[:error] =  "Accomodation type is already taken."
                            #isFlags       =  false
                       end
                  end
                  if isFlags
                     stateupobj  = MstAccomodationDetail.where("ad_compcode =? AND id = ?",@compcodes,mid).first
                      if stateupobj
                           stateupobj.update(accomo_params)
                           flash[:error] =  "Data updated successfully."
                           isFlags = true
                      end
                  end
            else
                      chekaccomtype = MstAccomodationDetail.where("ad_compcode =? AND ad_accomodtype = ? ",@compcodes,curaccomo)
                       if chekaccomtype.length >0
                           # flash[:error] =  "Accomodation type is already taken."
                           # isFlags       =  false
                       end
                       if isFlags
                            stsobj = MstAccomodationDetail.new(accomo_params)
                            if stsobj.save
                               flash[:error] =  "Data saved successfully."
                               isFlags = true
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
         #session[:request_params] = params
         session[:isErrorhandled] = 1
         isFlags = false
     else
         session[:request_params] = nil
         session[:isErrorhandled] = nil
         session.delete(:request_params)
     end
     if isFlags
       redirect_to "#{root_url}"+"accomodation"
     else
       redirect_to "#{root_url}"+"accomodation/manage_accomodation"
     end
  end

  def destroy
     @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         @Listccod =  MstAccomodationDetail.where("ad_compcode =? AND id = ?",@compcodes,params[:id]).first
         if @Listccod
              @Listccod.destroy
              flash[:error] =  "Data deleted successfully."
              isFlags       = true
              session[:isErrorhandled] = nil
         end
    end
    redirect_to "#{root_url}accomodation"
  end

  private
  def accomo_params
     params[:ad_compcode]     = session[:loggedUserCompCode]
     params[:ad_belongs]      = params[:ad_belongs]  !=nil && params[:ad_belongs]  !='' ? params[:ad_belongs]  : ''
     params[:ad_accomodtype]  = params[:ad_accomodtype]  !=nil && params[:ad_accomodtype]  !='' ? params[:ad_accomodtype]  : 0
     params.permit(:ad_compcode,:ad_accomodtype,:ad_belongs,:ad_address,:ad_noofrooms,:ad_state,:ad_district,:ad_city,:ad_typeofkitechen,:ad_typeofwashroom,:ad_pincode)
  end

  private
  def get_list_of_accomodation
     if params[:page].to_i >0
    pages = params[:page]
  else
     pages = 1
  end
     iswhere      = "ad_compcode ='#{@compcodes}'"
     listaccmtype = MstAccomodationDetail.where(iswhere).paginate(:page =>pages,:per_page => 10).order("id DESC")
     return listaccmtype
  end

end
