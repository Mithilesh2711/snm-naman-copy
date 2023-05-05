class LeavesController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_leavemaster_detail,:get_leave_taken,:global_sewadar_kyc_information
  helper_method :get_all_department_detail,:get_link_image,:get_mysewdar_list_details,:get_sewdar_designation_detail,:format_oblig_date
  helper_method :get_global_users,:get_member_listed
  def index
    @compCodes         = session[:loggedUserCompCode]
    @MstLeave          = MstLeave.where("attend_compcode=?",@compCodes).group("attend_leaveCode").order("attend_leaveCode ASC")
    @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
    @HrMonths          = nil
    @Hryears           = nil
    @month_numbers     = 0
    if @HeadHrp
          month_numbers =  @HeadHrp.hph_months
          myyears       =  @HeadHrp.hph_years
          month_begins  =  Date.new(myyears, month_numbers)
          begdates      =  Date.parse(month_begins.to_s)
          @nbegindates  =  begdates.strftime('%Y-%m-%d')
          month_endings =  month_begins.end_of_month
          endingdates   =  Date.parse(month_endings.to_s)
          @enddates     =  endingdates.strftime('%Y-%m-%d')
    end
    mydeprtcode    =  ""
    @newsewdarList =  nil
          if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
            if session[:sec_sewdar_code] !=nil
                sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
                if sewobjs
                  @mydepartcode = mydeprtcode = sewobjs.sw_depcode
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
          @sewDepart        =   Department.select("compCode,departDescription,departCode").where("compCode = ? AND subdepartment = '' AND departCode = ?",@compCodes, @mydepartcode ).order("departDescription ASC")
          @newsewdarList    =   MstSewadar.where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")

      elsif session[:requestuser_loggedintp]  && ( session[:requestuser_loggedintp] == 'ec' || session[:requestuser_loggedintp] == 'cod' )
            if @mydepartcode !=nil && @mydepartcode !=''
              @sewDepart      =   Department.select("compCode,departDescription,departCode").where("compCode = '#{@compCodes}' AND subdepartment ='' AND departCode IN(#{@mydepartcode})").order("departDescription ASC")
            end
            
            @newsewdarList  =   MstSewadar.where("sw_compcode = ? AND sw_depcode = ?",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")
      else
          @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compCodes).order("departDescription ASC")  
      end

    @ApplyLeaves = get_apply_leaves
  end

private
def get_apply_leaves
  @compCodes     =   session[:loggedUserCompCode]  
  sewacode       = session[:sec_sewdar_code]
  if params[:page].to_i >0
     pages = params[:page]
  else
     pages = 1
  end

  if params[:requestserver] !=nil && params[:requestserver] != ''
    session[:request_sewadar_name] = nil
    session[:request_leave_code] = nil
    session[:request_leave_type] = nil
    session[:request_search_fromdated] = nil
    session[:request_search_uptodated] = nil
    session[:request_voucher_department] = nil
  end
  
  search_sewadar     =   params[:search_sewadar]!=nil && params[:search_sewadar]!=nil ? params[:search_sewadar].to_s.strip : session[:request_sewadar_name]
  leave_code         =   params[:leave_code]!=nil && params[:leave_code]!=nil ? params[:leave_code] : session[:request_leave_code]
  leave_type         =   params[:leave_type]!=nil && params[:leave_type]!=nil ? params[:leave_type] : session[:request_leave_type]
  search_fromdated   =   params[:search_fromdated]!=nil && params[:search_fromdated]!=nil ? year_month_days_formatted(params[:search_fromdated]) : session[:request_search_fromdated]
  search_uptodated   =   params[:search_uptodated]!=nil && params[:search_uptodated]!=nil ? year_month_days_formatted(params[:search_uptodated]) : session[:request_search_uptodated]
  voucher_department =   params[:voucher_department]!=nil && params[:voucher_department]!=nil ? params[:voucher_department].to_s.strip : session[:request_voucher_department]


  # if search_fromdated == '' || search_fromdated == nil
  #   search_fromdated = @nbegindates
  # end
  # if search_uptodated == '' || search_uptodated == nil
  #   search_uptodated = @enddates
  # end
  jons    = nil
  
  if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
    iswhere = "ls_empcode ='#{@compCodes}' AND ls_empcode ='#{sewacode}'"  
  else
    iswhere = "ls_compcode ='#{@compCodes}'"
  end
  if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
    session[:request_voucher_department] = @mydepartcode
    @voucher_department                  = @mydepartcode
     iswhere     += " AND ls_depcode ='#{@mydepartcode}' AND ls_depcode<>''"
elsif session[:requestuser_loggedintp] && ( session[:requestuser_loggedintp].to_s == 'ec' || session[:requestuser_loggedintp].to_s == 'cod' )
  if @mydepartcode.to_s.length == '1'
      session[:request_voucher_department] = @mydepartcode
      @voucher_department                = @mydepartcode
      iswhere     += " AND ls_depcode ='#{@mydepartcode}' AND ls_depcode<>''" 
    else
      session[:request_voucher_department] = voucher_department
      @voucher_department                = voucher_department
      iswhere     += " AND ls_depcode ='#{voucher_department}' AND ls_depcode<>''" 
    
    end
else
    if voucher_department !=nil && voucher_department !=''
        session[:request_voucher_department] = voucher_department
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
     leavobj = TrnLeave.select("trn_leaves.*,msd.id as swdId").joins(jons).where(iswhere).paginate(:page =>pages,:per_page => 10).order("ls_empcode ASC")
  else
     leavobj = TrnLeave.where(iswhere).paginate(:page =>pages,:per_page => 10).order("ls_fromdate DESC")
  end

   return leavobj
end
end
