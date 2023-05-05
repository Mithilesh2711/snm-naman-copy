class LoansApprovalController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_mysewdar_list_details,:get_all_department_detail,:get_global_university
    helper_method :get_sewdar_designation_detail,:format_oblig_date,:get_dob_calculate,:global_sewadar_kyc_information,:get_global_users
  
  def index
    @compcodes         = session[:loggedUserCompCode]
    @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compcodes).order("departDescription ASC")
    @sewadarCategory   = MstSewadarCategory.where("sc_compcode =? AND sc_catcode NOT IN('DWD','VIV')",@compcodes).order("sc_position ASC")

    
    @mydepartcode      = nil
    if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
         if session[:sec_sewdar_code] !=nil
             sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
             if sewobjs
                @mydepartcode = sewobjs.sw_depcode
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
       @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode = ? AND subdepartment = '' AND departCode = ?",@compcodes, @mydepartcode ).order("departDescription ASC")
   elsif session[:requestuser_loggedintp]  && ( session[:requestuser_loggedintp] == 'ec' || session[:requestuser_loggedintp] == 'cod' )
        if @mydepartcode !=nil && @mydepartcode !=''
            @sewDepart      =   Department.select("compCode,departDescription,departCode").where("compCode = '#{@compcodes}' AND subdepartment ='' AND departCode IN(#{@mydepartcode})").order("departDescription ASC")
        end
    else
        @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compcodes).order("departDescription ASC")  
   end
     @LoanListReqest    = get_sewadar_loan_request
     
  end

  def create

  end
  private
   def get_sewadar_loan_request
     
     if params[:server_request] !=nil && params[:server_request] !=''
        session[:reqs_voucher_department] = nil
        session[:reqs_voucher_category]   = nil
        session[:reqs_voucher_number]     = nil
        session[:reqs_sewadar_loantype]   = nil
        session[:reqs_show_voucher]       = nil
        session[:reqs_sewadar_reqtype]    = nil
     end
     voucher_department = params[:voucher_department] !=nil && params[:voucher_department] !='' ? params[:voucher_department] : session[:reqs_voucher_department]
     voucher_category   = params[:voucher_category] !=nil && params[:voucher_category] !='' ? params[:voucher_category] : session[:reqs_voucher_category]
     voucher_number     = params[:voucher_number] !=nil && params[:voucher_number] !='' ? params[:voucher_number] : session[:reqs_voucher_number]
     sewadar_loantype   = params[:sewadar_loantype] !=nil && params[:sewadar_loantype] !='' ? params[:sewadar_loantype] : session[:reqs_sewadar_loantype]
     sewadar_reqtype    = params[:sewadar_reqtype] !=nil && params[:sewadar_reqtype] !='' ? params[:sewadar_reqtype] : session[:reqs_sewadar_reqtype]
     isfalgs = false
     iswhere = "al_compcode ='#{@compcodes}'"   
     if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
             session[:reqs_voucher_department] = @mydepartcode
             @voucher_department              = @mydepartcode
              iswhere     += " AND al_depcode ='#{@mydepartcode}' AND al_depcode<>''"
     elsif session[:requestuser_loggedintp] && ( session[:requestuser_loggedintp].to_s == 'ec' || session[:requestuser_loggedintp].to_s == 'cod' )
            
             session[:reqs_voucher_department] = voucher_department
             @voucher_department              = voucher_department
             iswhere     += " AND al_depcode ='#{voucher_department}' AND al_depcode<>''"      
     else
           if voucher_department !=nil && voucher_department !=''
             session[:reqs_voucher_department] = voucher_department
             @voucher_department              = voucher_department
              iswhere     += " AND al_depcode ='#{voucher_department}' AND al_depcode<>''"
           end
     end
     
     if voucher_category !=nil && voucher_category !=''
         session[:reqs_voucher_category] = voucher_category
         @voucher_category = voucher_category
         isfalgs = true
         iswhere     += " AND sw_catcode ='#{voucher_category}'"
     end
     if voucher_number !=nil && voucher_number !=''
         session[:reqs_voucher_number] = voucher_number
         @voucher_number = voucher_number
         iswhere     += " AND al_broucherno ='#{voucher_number}'"
     end
     if sewadar_loantype !=nil && sewadar_loantype !=''
         session[:reqs_sewadar_loantype] = sewadar_loantype
         @sewadar_loantype  = sewadar_loantype
         iswhere           += " AND al_requesttype ='#{sewadar_loantype}'"
     end
     
     if sewadar_reqtype != nil && sewadar_reqtype != ''
          session[:reqs_sewadar_reqtype] = sewadar_reqtype
          @sewadar_reqtype               = sewadar_reqtype
          if sewadar_reqtype.to_s == 'F'
                iswhere           += " AND al_hod_status ='A' AND al_approvestatus='F'"
          else
                  if sewadar_reqtype == 'N'
                     iswhere  += " AND ( al_approvestatus ='N' OR al_approvestatus = '' )"
                  else
                     iswhere  += " AND al_approvestatus ='#{sewadar_reqtype}'"
                  end
      
            end            
      end
     if isfalgs
       jons    = "LEFT JOIN mst_sewadars sewb ON(sw_compcode = al_compcode AND sw_sewcode = al_sewadarcode)"
       loansobj = TrnAdvanceLoan.select("trn_advance_loans.*,sewb.id as sewID").joins(jons).where(iswhere).order("al_sewadarcode asc")
     else
        loansobj = TrnAdvanceLoan.where(iswhere).order("al_requestno desc")
     end  
     
     return loansobj
   end
end
