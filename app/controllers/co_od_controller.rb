class CoOdController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_leavemaster_detail
  helper_method :get_all_department_detail,:get_link_image,:get_mysewdar_list_details,:get_sewdar_designation_detail,:format_oblig_date
  helper_method :get_first_my_sewadar,:get_all_department_detail
  def index
    @compCodes         = session[:loggedUserCompCode]
    @MstLeave          = MstLeave.where("attend_compcode=? AND attend_leavereqst='Y' AND attend_leaveCode IN('CO')",@compCodes).group("attend_leaveCode").order("attend_leaveCode ASC")
    @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
    @HrMonths          = nil
    @Hryears           = nil
    @month_numbers     = 0
    if @HeadHrp
          month_numbers =  Time.now.month #@HeadHrp.hph_months
          myyears       =  Time.now.year #@HeadHrp.hph_years
          month_begins  =  Date.new(myyears, month_numbers)
          begdates      =  Date.parse(month_begins.to_s)
          @nbegindates  =  begdates.strftime('%Y-%m-%d')
          month_endings =  month_begins.end_of_month
          endingdates   =  Date.parse(month_endings.to_s)
          @enddates     =  endingdates.strftime('%Y-%m-%d')
    end
    @mydepartcode      = ''
    mydeprtcode        = ""
     if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
            if session[:sec_sewdar_code] != nil
               sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
               if sewobjs
                     @mydepartcode = sewobjs.sw_depcode
                     mydeprtcode   = sewobjs.sw_depcode
               end
            end  
      elsif session[:requestuser_loggedintp]  && ( session[:requestuser_loggedintp] == 'ec' || session[:requestuser_loggedintp] == 'cod' )
         hodobjs = get_hod_listed_sewadar(session[:sec_ecmem_code])
         if hodobjs       
               ecodes     = hodobjs.lds_membno  
               fdepart    = ""          
               deprtobj = get_all_coordinate_department(ecodes)
                 if deprtobj.length >0
                     deprtobj.each do |newdpts|
                       fdepart += "'"+newdpts.departCode.to_s+"',"
                     end
                 end    
                 if fdepart !=nil && fdepart !=''
                     fdepart = fdepart.to_s.chop
                 end
                   @mydepartcode = mydeprtcode = fdepart             
              
         end
     end

    if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
         @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment ='' AND departCode = ? ",@compCodes,mydeprtcode).order("departDescription ASC")
         if session[:requestuser_loggedintp].to_s == 'swd'
            @newsewdarList  = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")
         else
            @newsewdarList  = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_depcode = ?",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")
         end
      elsif session[:requestuser_loggedintp]  && ( session[:requestuser_loggedintp] == 'ec' || session[:requestuser_loggedintp] == 'cod' )
         if @mydepartcode !=nil && @mydepartcode !=''
           @sewDepart      =   Department.select("compCode,departDescription,departCode").where("compCode = '#{@compCodes}' AND subdepartment ='' AND departCode IN(#{@mydepartcode})").order("departDescription ASC")
         end         
         @newsewdarList  =   MstSewadar.where("sw_compcode = ? AND sw_depcode = ?",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")       
      else
            @sewDepart     =   Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment=''",@compCodes).order("departDescription ASC")
      end
      @ApplyLeaves          = get_apply_leaves
  end


  def co_od_new_refresh
    session[:request_params]           = nil
    session[:sales_search]             = nil
    session[:salessearchId]            = nil
    session[:req_prints]               = nil
    session[:request_sewadar_search]   = nil
    session[:req_myusedept]            = nil
    session[:req_myuseaccord]          = nil
    session[:req_myusestring]          = nil
    session[:request_params]           = nil
    session[:request_ls_empcode]       = nil
    session[:request_ls_leave_code]    = nil
    session[:request_ls_fromdate]      = nil
    session[:request_ls_todate]        = nil
    session[:request_ls_leavereson]    = nil
    session[:request_ls_days]          = nil
    session[:request_ls_remainleave]   = nil
    session[:request_sewadar_name]     = nil
    session[:request_leave_code]       = nil
    session[:request_leave_type]       = nil
    session[:request_search_fromdated] = nil
    session[:request_search_uptodated] = nil
    session.delete(:request_params)
   redirect_to "#{root_url}"+"co_od"
end

  private
def get_apply_leaves
  @compCodes     =   session[:loggedUserCompCode]  
  if params[:page].to_i >0
     pages = params[:page]
  else
     pages = 1
  end

  if params[:server_request] !=nil && params[:server_request] != ''
      session[:request_sewadar_name]        = nil
      session[:request_leave_code]          = nil
      session[:request_leave_type]          = nil
      session[:request_search_fromdated]    = nil
      session[:request_search_uptodated]    = nil
      session[:request_voucher_xdepartment] = nil
  end
  search_sewadar     =   params[:search_sewadar]!=nil && params[:search_sewadar]!=nil ? params[:search_sewadar].to_s.strip : session[:request_sewadar_name]
  leave_code         =   params[:leave_code]!=nil && params[:leave_code]!=nil ? params[:leave_code] : session[:request_leave_code]
  leave_type         =   params[:leave_type]!=nil && params[:leave_type]!=nil ? params[:leave_type] : session[:request_leave_type]
  search_fromdated   =   params[:search_fromdated]!=nil && params[:search_fromdated]!=nil ? year_month_days_formatted(params[:search_fromdated]) : session[:request_search_fromdated]
  search_uptodated   =   params[:search_uptodated]!=nil && params[:search_uptodated]!=nil ? year_month_days_formatted(params[:search_uptodated]) : session[:request_search_uptodated]
  voucher_department =   params[:voucher_department]!=nil && params[:voucher_department]!=nil ? params[:voucher_department].to_s.strip : session[:request_voucher_xdepartment]
  
  if search_fromdated == '' || search_fromdated == nil
    search_fromdated = @nbegindates
  end
  if search_uptodated == '' || search_uptodated == nil
    search_uptodated = @enddates
  end
  jons    = nil
  
  if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
   iswhere = "ls_empcode ='#{@compCodes}' AND ls_empcode ='#{sewacode}'"  
 else
   iswhere = "ls_compcode ='#{@compCodes}'"
 end
 if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
   session[:request_voucher_xdepartment] = @mydepartcode
    @voucher_department                  = @mydepartcode
    iswhere     += " AND ls_depcode ='#{@mydepartcode}' AND ls_depcode<>''"
elsif session[:requestuser_loggedintp] && ( session[:requestuser_loggedintp].to_s == 'ec' || session[:requestuser_loggedintp].to_s == 'cod' )
      if @mydepartcode.to_s.length == '1'
      session[:request_voucher_xdepartment] = @mydepartcode
      @voucher_department                = @mydepartcode
      iswhere     += " AND ls_depcode ='#{@mydepartcode}' AND ls_depcode<>''" 
      else
      session[:request_voucher_xdepartment] = voucher_department
      @voucher_department                = voucher_department
      iswhere     += " AND ls_depcode ='#{voucher_department}' AND ls_depcode<>''" 
      
      end
else
      if voucher_department !=nil && voucher_department !=''
         session[:request_voucher_xdepartment] = voucher_department
         @voucher_department                = voucher_department
         iswhere     += " AND ls_depcode ='#{voucher_department}' AND ls_depcode<>''"    
      end
end


  if search_sewadar !=nil && search_sewadar !=''
       iswhere += " AND ( ls_empcode LIKE '%#{search_sewadar}%' OR sw_sewadar_name LIKE '%#{search_sewadar}%' )"
       jons    =  " JOIN mst_sewadars msd ON(sw_compcode = ls_compcode AND ls_empcode = sw_sewcode)"
       session[:request_sewadar_name] = search_sewadar
       @search_sewadar                  = search_sewadar
  end
  if leave_code !=nil && leave_code  !=''
    iswhere += " AND ls_leave_code ='#{leave_code}'"
    session[:request_leave_code] = leave_code
    @leave_code = leave_code
  end
  if leave_type !=nil && leave_type  !=''
      iswhere += " AND ls_status ='#{leave_type}'"
      session[:request_leave_type] = leave_type
      @leave_type = leave_type
  else
     iswhere += " AND ls_status ='P'"
  end
  if search_fromdated !=nil && search_fromdated  !=''
      iswhere += " AND ls_fromdate >='#{search_fromdated}'"
      session[:request_search_fromdated] = search_fromdated
      @search_fromdated = search_fromdated
  end
  if search_uptodated !=nil && search_uptodated  !=''
      iswhere += " AND ls_todate <='#{search_uptodated}'"
      session[:request_search_uptodated] = search_uptodated
      @search_uptodated                  = search_uptodated
  end
  if jons
     leavobj = TrnRequestCoOd.select("trn_request_co_ods.*,msd.id as swdId").joins(jons).where(iswhere).paginate(:page =>pages,:per_page => 10).order("ls_empcode ASC")
  else
     leavobj = TrnRequestCoOd.where(iswhere).paginate(:page =>pages,:per_page => 10).order("ls_empcode ASC")
  end

   return leavobj
end
end
