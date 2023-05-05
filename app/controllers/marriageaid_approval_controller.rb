class MarriageaidApprovalController < ApplicationController
  before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_mysewdar_list_details,:get_all_department_detail
    helper_method :get_sewdar_designation_detail,:format_oblig_date,:get_dob_calculate,:get_family_relation_detail,:get_mysewdar_list_details
    helper_method :get_department_detail,:get_all_department_detail,:global_sewadar_kyc_information
  def index
    @compcodes  = session[:loggedUserCompCode]

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
            @sewDepart        =   Department.select("compCode,departDescription,departCode").where("compCode = ? AND subdepartment = '' AND departCode = ?",@compcodes, @mydepartcode ).order("departDescription ASC")
            @newsewdarList    =   MstSewadar.where("sw_compcode = ? AND sw_sewcode = ?",@compcodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")

      elsif session[:requestuser_loggedintp]  && ( session[:requestuser_loggedintp] == 'ec' || session[:requestuser_loggedintp] == 'cod' )
          if @mydepartcode !=nil && @mydepartcode !=''
              @sewDepart      =   Department.select("compCode,departDescription,departCode").where("compCode = '#{@compcodes}' AND subdepartment ='' AND departCode IN(#{@mydepartcode})").order("departDescription ASC")
          end 
          @newsewdarList     =   MstSewadar.where("sw_compcode = ? AND sw_depcode = ?",@compcodes,mydeprtcode).order("sw_sewadar_name ASC")
      else
            @sewDepart         =  Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compcodes).order("departDescription ASC")  
      end   
   
      @sewadarCategory   = MstSewadarCategory.where("sc_compcode =? AND sc_catcode NOT IN('DWD','VIV') ",@compcodes).order("sc_position ASC")    
      @MarriageListing   = get_marriage_listing()

  end

  def create

  end
  def show
  @compcodes = session[:loggedUserCompCode]
  Time.zone  = "Kolkata"
  loctime    = Time.zone.now.strftime('%I:%M%p')
   if params[:id].to_i >0
          mystatus =  params[:st].to_s.strip.upcase
          @Listobj =  TrnApplyMarriageAid.where("ama_compcode =? AND id = ?",@compcodes,params[:id]).first
          if @Listobj
                @Listobj.update(:ama_status=>mystatus,:ama_approvedated=>Date.today,:ama_localtime=>loctime,:ama_approvedby=>session[:autherizedUserId])
                flash[:error] =  "Data Updated successfully."
                isFlags       =  true
                session[:isErrorhandled] = nil
          end	
   end
   redirect_to "#{root_url}marriageaid_approval"
  end

  private
 def get_marriage_listing
	  compcode = session[:loggedUserCompCode]
    if params[:server_request] != nil && params[:server_request] != ''
        session[:areqs_voucher_department]    = nil
        session[:areqs_voucher_category]      = nil
        session[:areqs_sewadar_status]        = nil
        session[:areqs_sewadar_requesttype]   = nil
        session[:reqs_search_from_date]       = nil 
        session[:reqs_search_upto_date]       = nil
    end
    voucher_department  = params[:voucher_department] !=nil && params[:voucher_department] !='' ? params[:voucher_department] : session[:areqs_voucher_department]
    voucher_category    = params[:voucher_category] !=nil && params[:voucher_category] !='' ? params[:voucher_category] : session[:areqs_voucher_category]
    sewadar_status      = params[:sewadar_status] !=nil && params[:sewadar_status] !='' ? params[:sewadar_status] : session[:areqs_sewadar_status]
    sewadar_requesttype = params[:sewadar_requesttype] !=nil && params[:sewadar_requesttype] !='' ? params[:sewadar_requesttype] : session[:areqs_sewadar_requesttype]
    search_from_date    = params[:search_from_date] !=nil && params[:search_from_date] !='' ? params[:search_from_date] : session[:reqs_search_from_date]
    search_upto_date    = params[:search_upto_date] !=nil && params[:search_upto_date] !='' ? params[:search_upto_date] : session[:reqs_search_upto_date]


	  iswhere   = "ama_compcode ='#{compcode}'"
    if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
          session[:areqs_voucher_department]   = @mydepartcode
          @voucher_department                  = @mydepartcode
          iswhere     += " AND ama_departcode ='#{@mydepartcode}' AND ama_departcode<>''"
    elsif session[:requestuser_loggedintp] && ( session[:requestuser_loggedintp].to_s == 'ec' || session[:requestuser_loggedintp].to_s == 'cod' )
          # session[:areqs_voucher_department] = @mydepartcode
          # @voucher_department                = @mydepartcode
          # iswhere     += " AND ama_departcode ='#{@mydepartcode}' AND ama_departcode<>''" 
              session[:areqs_voucher_department]   = voucher_department
              @voucher_department                  = voucher_department
              iswhere     += " AND ama_departcode ='#{voucher_department}' AND ama_departcode<>''"        
    else
          if voucher_department !=nil && voucher_department !=''
              session[:areqs_voucher_department]   = voucher_department
              @voucher_department                  = voucher_department
              iswhere     += " AND ama_departcode ='#{voucher_department}' AND ama_departcode<>''"
          end
    end
    

    nflags = false
    jons   = ""
    if voucher_category != nil && voucher_category !='' 
      session[:areqs_voucher_category] = voucher_category
      @voucher_category  = voucher_category
      iswhere   += " AND sw_catgeory LIKE '%#{voucher_category}%'"
      jons      =  " LEFT JOIN  mst_sewadars swd on(ama_compcode = sw_compcode AND ama_sewadarcode = sw_sewcode)"
      nflags = true
    end
    if sewadar_status !=nil && sewadar_status !=''
        if sewadar_status == 'N' 
          iswhere   += " AND ( ama_status ='' OR ama_status ='N' )"
        else
          iswhere   += " AND ama_status ='#{sewadar_status}'"
        end
      
      @sewadar_status                = sewadar_status
      session[:areqs_sewadar_status] = sewadar_status
    end
    if sewadar_requesttype != nil && sewadar_requesttype !=''
        iswhere   += " AND ama_applyfor     ='#{sewadar_requesttype}'"
        @sewadar_requesttype                = sewadar_requesttype
        session[:areqs_sewadar_requesttype] = sewadar_requesttype
    end
    if search_from_date !=nil && search_from_date !=''
      session[:reqs_search_from_date]     = search_from_date
      @search_from_date                     = search_from_date
      iswhere     += " AND ama_approvedated >='#{year_month_days_formatted(search_from_date)}' "

    end
    if search_upto_date !=nil && search_upto_date !=''
        session[:reqs_search_upto_date]       = search_upto_date
        @search_upto_date                     = search_upto_date
        iswhere     += " AND ama_approvedated <='#{year_month_days_formatted(search_upto_date)}' "
    end
     if nflags
        isselect = "trn_apply_marriage_aids.*,swd.id as swedId"
        listmarrigeobj = TrnApplyMarriageAid.select(isselect).joins(jons).where(iswhere).order("ama_requestno DESC")
     else
       listmarrigeobj = TrnApplyMarriageAid.where(iswhere).order("ama_requestno DESC")
     end
	 
	 return listmarrigeobj

 end

  private
   def get_sewadar_loan_request
     iswhere = "al_compcode='#{@compcodes}'"
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
     search_from_date    = params[:search_from_date] !=nil && params[:search_from_date] !='' ? params[:search_from_date] : session[:reqs_search_from_date]
     search_upto_date    = params[:search_upto_date] !=nil && params[:search_upto_date] !='' ? params[:search_upto_date] : session[:reqs_search_upto_date]
  
     
     isfalgs = false
     
     if voucher_department !=nil && voucher_department !=''
         session[:reqs_voucher_department] = voucher_department
         @voucher_department              = voucher_department
          iswhere     += " AND al_depcode ='#{voucher_department}'"
     end
     if voucher_category !=nil && voucher_category !=''
         session[:reqs_voucher_category] = voucher_category
         @voucher_category = voucher_category
         isfalgs = true
         iswhere     += " AND sw_catgeory ='#{voucher_category}'"
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
         iswhere           += " AND al_approvestatus ='#{sewadar_reqtype}'"
     end
    
     if isfalgs
       jons    = "LEFT JOIN mst_sewadars sewb ON(sw_compcode = al_compcode AND sw_sewcode = al_sewadarcode)"
       loansobj = TrnAdvanceLoan.select("trn_advance_loans.*,sewb.id as sewID").joins(jons).where(iswhere).order("al_sewadarcode asc")
     else
        loansobj = TrnAdvanceLoan.where(iswhere).order("al_sewadarcode asc")
     end  
     
     return loansobj
   end
end

