class EducationaidApprovalController < ApplicationController
    before_action :require_login
	before_action :allowed_security
	skip_before_action :verify_authenticity_token,:only=>[:index,:search,:ajax_process]
	include ErpModule::Common
	helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_class_series,:get_department_detail,:get_class_series
	helper_method :format_oblig_date,:get_family_relation_detail,:get_all_department_detail,:get_first_my_sewadar,:get_all_department_detail,:global_sewadar_kyc_information
    def index
        @authorizedId      = session[:autherizedUserId]
		    @compCodes         = session[:loggedUserCompCode]

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
      @sewadarCategory   = MstSewadarCategory.where("sc_compcode =? AND sc_catcode NOT IN('DWD','VIV')",@compCodes).order("sc_position ASC")
      if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
        @sewDepart        =   Department.select("compCode,departDescription,departCode").where("compCode = ? AND subdepartment = '' AND departCode = ?",@compCodes, @mydepartcode ).order("departDescription ASC")
        @newsewdarList    =   MstSewadar.where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")

      elsif session[:requestuser_loggedintp]  && ( session[:requestuser_loggedintp] == 'ec' || session[:requestuser_loggedintp] == 'cod' )
          if @mydepartcode !=nil && @mydepartcode !=''
              @sewDepart         =   Department.select("compCode,departDescription,departCode").where("compCode = '#{@compCodes}' AND subdepartment ='' AND departCode IN(#{@mydepartcode})").order("departDescription ASC")
          end
            @newsewdarList     =   MstSewadar.where("sw_compcode = ? AND sw_depcode = ?",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")
      else
            @sewDepart         =  Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compCodes).order("departDescription ASC")  
      end            
        
               
		    @MarriageListing   = get_educational_listing()

     end
     def create

     end
     def show
        @compcodes = session[:loggedUserCompCode]
        Time.zone  = "Kolkata"
        loctime    = Time.zone.now.strftime('%I:%M%p')
        if params[:id].to_i >0
               mystatus =  params[:st].to_s.strip.upcase
               @Listobj =  TrnApplyEducationAid.where("aea_compcode =? AND id = ?",@compcodes,params[:id]).first
               if @Listobj
                     @Listobj.update(:aea_status=>mystatus,:aea_approvedated=>Date.today,:aea_localtime=>loctime,:aea_approvedby=>session[:autherizedUserId])
                     flash[:error] =  "Data Updated successfully."
                     isFlags       =  true
                     session[:isErrorhandled] = nil
               end	
        end
        redirect_to "#{root_url}educationaid_approval"
       end
     private
 def get_educational_listing
    compcode = session[:loggedUserCompCode]
    if params[:server_request] !=nil && params[:server_request] != ''
      session[:eareqs_voucher_department] = nil
      session[:eareqs_voucher_category] = nil
      session[:eareqs_sewadar_status] = nil
      session[:eareqs_sewadar_requesttype] = nil
      session[:eareqs_search_from_date] = nil
      session[:eareqs_search_upto_date] = nil

    end
   voucher_department  = params[:voucher_department] !=nil && params[:voucher_department] !='' ? params[:voucher_department] : session[:eareqs_voucher_department]
   voucher_category    = params[:voucher_category] !=nil && params[:voucher_category] !='' ? params[:voucher_category] : session[:eareqs_voucher_category]
   sewadar_status      = params[:sewadar_status] !=nil && params[:sewadar_status] !='' ? params[:sewadar_status] : session[:eareqs_sewadar_status]
   sewadar_requesttype = params[:sewadar_requesttype] !=nil && params[:sewadar_requesttype] !='' ? params[:sewadar_requesttype] : session[:eareqs_sewadar_requesttype]
   search_from_date    = params[:search_from_date] !=nil && params[:search_from_date] !='' ? params[:search_from_date] : session[:eareqs_search_from_date]
   search_upto_date    = params[:search_upto_date] !=nil && params[:search_upto_date] !='' ? params[:search_upto_date] : session[:eareqs_search_upto_date]

	 iswhere   = "aea_compcode ='#{compcode}'"
   if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
    session[:eareqs_voucher_department]   = @mydepartcode
    @voucher_department                  = @mydepartcode
    iswhere     += " AND aea_departcode ='#{@mydepartcode}' AND aea_departcode<>''"
  elsif session[:requestuser_loggedintp] && ( session[:requestuser_loggedintp].to_s == 'ec' || session[:requestuser_loggedintp].to_s == 'cod' )
      if @mydepartcode.to_s.length == '1'
        session[:eareqs_voucher_department] = @mydepartcode
        @voucher_department                = @mydepartcode
        iswhere     += " AND aea_departcode ='#{@mydepartcode}' AND aea_departcode<>''" 
      else  
          session[:eareqs_voucher_department]   = voucher_department
          @voucher_department                  = voucher_department
          iswhere     += " AND aea_departcode ='#{voucher_department}' AND aea_departcode<>''"

      end
      
  else
      if voucher_department !=nil && voucher_department !=''
          session[:eareqs_voucher_department]   = voucher_department
          @voucher_department                  = voucher_department
          iswhere     += " AND aea_departcode ='#{voucher_department}' AND aea_departcode<>''"
      end
  end

    
    nflags = false
    jons   = ""
    if voucher_category != nil && voucher_category !='' 
      session[:eareqs_voucher_category] = voucher_category
      @voucher_category  = voucher_category
      iswhere   += " AND sw_catgeory LIKE '%#{voucher_category}%'"
      jons      =  " LEFT JOIN  mst_sewadars swd on(aea_compcode = sw_compcode AND aea_sewadarcode = sw_sewcode)"
      nflags = true
    end
    if sewadar_status !=nil && sewadar_status !=''
        if sewadar_status == 'N' 
          iswhere   += " AND ( aea_status ='' OR aea_status ='N' )"
        else
          iswhere   += " AND aea_status ='#{sewadar_status}'"
        end
      
      @sewadar_status                = sewadar_status
      session[:eareqs_sewadar_status] = sewadar_status
    end
    if sewadar_requesttype != nil && sewadar_requesttype !=''
        iswhere   += " AND aea_applyfor     ='#{sewadar_requesttype}'"
        @sewadar_requesttype                = sewadar_requesttype
        session[:eareqs_sewadar_requesttype] = sewadar_requesttype
    end
    if search_from_date !=nil && search_from_date !=''
        session[:eareqs_search_from_date]     = search_from_date
        @search_from_date                     = search_from_date
        iswhere     += " AND aea_approvedated >='#{year_month_days_formatted(search_from_date)}' "

    end
    if search_upto_date !=nil && search_upto_date !=''
        session[:eareqs_search_upto_date]     = search_upto_date
        @search_upto_date                     = search_upto_date
        iswhere     += " AND aea_approvedated <='#{year_month_days_formatted(search_upto_date)}' "
    end

     if nflags
        isselect = "trn_apply_education_aids.*,swd.id as swedId"
        listmarrigeobj = TrnApplyEducationAid.select(isselect).joins(jons).where(iswhere).order("aea_requestno DESC")
     else
       listmarrigeobj = TrnApplyEducationAid.where(iswhere).order("aea_requestno DESC")
     end
	 
	 return listmarrigeobj


 end

end
