class MonthlyImportController < ApplicationController
   before_action :require_login
   before_action :allowed_security
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
   helper_method :get_zone_district_listed,:get_zone_name_detail,:get_sewa_all_department,:get_month_listed_data
   def index
    @compCodes       = session[:loggedUserCompCode]
    @myMonth         = Date.today.strftime("%B")
    @myYear          = Date.today.strftime("%Y")
    @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
    @HrMonths          = nil
    @Hryears           = nil
    if @HeadHrp
      @HrMonths = @HeadHrp.hph_months
      @Hryears  = @HeadHrp.hph_years
    end
    @sewadarCategory = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
    @sewSubDepart    = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment=''",@compCodes).order("departDescription ASC")
     if params[:request_server] !=nil &&params[:request_server] !=''
          @listsewobj = get_sewadar_listed
          send_data @listsewobj.to_generate_sewadar_list, :filename=> "sewadar-list-#{Date.today}.csv"
          return
     end
   end

   def create
      @compcodes  = session[:loggedUserCompCode]
      $compcodes  = @compcodes
      $chkFlags   = true
      isFlags     = true
  begin
   if params[:file]!=nil && params[:file]!=''
         $isimport = 'monthly'
       # ActiveRecord::Base.connection.execute("TRUNCATE trn_pay_monthlies")
        if  TrnPayMonthly.import(params[:file])
            if $chkFlags
              flash[:error]  = "Data imported successfully New "+($xcount.to_s.length.to_i >0  ? $xcount.to_s : '0' ).to_s
            end
            isFlags                       = true
            session[:isErrorhandled]      = nil
            session[:upload_file_process] = nil
        end
   end  
    rescue Exception => exc
        flash[:error] =   "#{exc.message}"
        session[:isErrorhandled] = 1
    end

     if !isFlags
            session[:isErrorhandled] = 1
     else
           session[:postedpamams] = nil
           session[:isErrorhandled] = nil
     end
      redirect_to "#{root_url}"+"monthly_import"
   end

   private
   def get_sewadar_listed
         sewadar_categories  = params[:sewadar_categories]
         sewadar_departments = params[:sewadar_departments]
         iswhere = "sw_compcode ='#{@compCodes}'"
        if sewadar_categories !=nil && sewadar_categories !=''
          iswhere += " AND sw_catgeory LIKE '%#{sewadar_categories}%'"
          
        end
        if sewadar_departments !=nil && sewadar_departments !=''
          iswhere += " AND sw_depcode LIKE '%#{sewadar_departments}%'"
          
        end
         listobj =  MstSewadar.select("sw_compcode,sw_sewcode,sw_sewadar_name,'' as myear,'' as mymonth,'' as Present,'' as  EL,'' as  CL,'' as  WO").where(iswhere).order("sw_sewcode ASC")
         return listobj
   end
   
end
