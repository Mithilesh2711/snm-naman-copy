## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for month end process
### FOR REST API ######
class MonthEndProcesssController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:search,:ledger_list,:ajax_process]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted
  helper_method :format_oblig_date,:get_accomodation_type,:get_month_listed_data
  def index
    @compcodes         = session[:loggedUserCompCode]
    @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compcodes).order("departDescription ASC")
    @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compcodes).order("sc_position ASC")
    @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compcodes).first
    @HrMonths          = nil
    @Hryears           = nil
    if @HeadHrp
        @HrMonths = @HeadHrp.hph_months
        @Hryears  = @HeadHrp.hph_years
    end
  end
  def create
    
  end
end
