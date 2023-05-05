class ManageSerialNumbersController < ApplicationController
   before_action :require_login
   before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  def index
     @compcodes      =  session[:loggedUserCompCode]
     @mstSeriesList  =  MstSerialNumber.where("sn_compcode =?",@compcodes).order("sn_type ASC")
  end
  
  def create
      @compcodes = session[:loggedUserCompCode]
      isFlags    = true
      begin
          if params[:sn_type]!='' && params[:sn_type]!=nil
                 i = 0
                params[:sn_type].each do |tnd|
                    if params[:sn_type][i]!=nil && params[:sn_type][i]!=''
                      sn_type = params[:sn_type][i]
                    else
                      sn_type = ''
                    end
                    if params[:sn_series_sample][i]!=nil && params[:sn_series_sample][i]!=''
                      sn_series_sample = params[:sn_series_sample][i]
                    else
                       sn_series_sample = ''
                    end
                    if params[:sn_prefix][i]!=nil && params[:sn_prefix][i]!=''
                       sn_prefix = params[:sn_prefix][i]
                    else
                       sn_prefix = ''
                    end
                    if params[:sn_length][i]!=nil && params[:sn_length][i]!=''
                       sn_length = params[:sn_length][i]
                    else
                       sn_length = ''
                    end
                    process_save(@compcodes,sn_type,sn_prefix,sn_length,sn_series_sample)
                     i +=1
                end
          end
       rescue Exception => exc
          flash[:error]            =  "#{exc.message}"
          session[:isErrorhandled] = 1
          isFlags                 = false
      end
      redirect_to "#{root_url}manage_serial_numbers"
  end
  
  def show

  end
  def destroy
    
  end
  private
  def process_save(sn_compcode,sn_type,sn_prefix,sn_length,sn_series_sample)
     svschkuobj =  MstSerialNumber.where("sn_compcode =? AND sn_type = ?",sn_compcode,sn_type).first
      if svschkuobj
          svschkuobj.update(:sn_type=>sn_type,:sn_prefix=>sn_prefix,:sn_length=>sn_length,:sn_series_sample=>sn_series_sample)
      else
        svsobj = MstSerialNumber.new(:sn_compcode=>sn_compcode,:sn_type=>sn_type,:sn_prefix=>sn_prefix,:sn_length=>sn_length,:sn_series_sample=>sn_series_sample)
        svsobj.save
      end
  end
end
