class DashboardController < ApplicationController
   before_action :require_login
   before_action :allowed_security
  def index
     if session[:autherizedUserType] && session[:autherizedUserType].to_s == 'swd'
       redirect_to "#{root_url}sewadar_dashboard"
       return
     end
  end
end
