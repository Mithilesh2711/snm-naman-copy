class SuperAnnuationController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_sewdar_designation_detail,:get_all_department_detail
    helper_method :set_dct,:set_ent,:get_personal_information,:get_office_information,:get_roles_information,:format_oblig_date,:get_university_deegre_listed
    helper_method :get_sewa_all_department,:get_sewa_all_qualification,:get_sewa_all_rolesresp,:get_sewa_all_designation,:get_first_my_sewadar
    helper_method :get_sewadar_dependent_listed,:get_sewadar_kyc_family,:get_first_my_sewadar
    def index
        @compCodes         = session[:loggedUserCompCode]
       # @nbegindate        =  2021
        @mydepartcode      = ''
        
        firstdated     = supernation_session_list(@compCodes,'ASC')
        lasteddated    = supernation_session_list(@compCodes,'DESC')
        begnewyers     = firstdated.to_s.split("-")
        lastyers       = lasteddated.to_s.split("-")
        @nbegindate    = begnewyers[0]
        @nedFinalYrs   = lastyers[0]
        @sewadarCategory = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
        @familylisted     = total_sewadar_kyc_family(@compCodes)
        if session[:sec_sewdar_code] 
          sewobjs =  get_sewdara_inofrmation_first(session[:sec_sewdar_code] )
          if sewobjs
             @mydepartcode = sewobjs.sw_depcode
          end
        end
   
        @sewdarList        = get_sewadar_listing()
        @ListDesignation   = Designation.where("compcode = ?",@compCodes).order("ds_description ASC")
        if session[:autherizedUserType] && session[:autherizedUserType].to_s != 'adm'      
         @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =? AND sw_depcode = ?",@compCodes,@mydepartcode)
        else
          @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =?",@compCodes)
       end
        
     end
   
     def new_sewadar_user
       session[:request_processlogid] = nil
       redirect_to "#{root_url}sewadar_information/add_sewadar"
     end
     def create
       
     end
     
     
     
   
     private
     def delete_sewadar_bank(sewcode)
         compcodes       = session[:loggedUserCompCode]
         sewobj = MstSewadarKycBank.where("skb_compcode =? AND sbk_sewcode =?",compcodes,sewcode).first
          if sewobj
             sewobj.destroy
          end
     end
   
      private
     def delete_sewadar_kyc(sewcode)
         compcodes  = session[:loggedUserCompCode]
         sewobj     = MstSewadarKyc.where("sk_compcode =? AND sk_sewcode =?",compcodes,sewcode).first
          if sewobj
             sewobj.destroy
          end
     end
   
      private
     def delete_sewadar_personal(sewcode)
         compcodes  = session[:loggedUserCompCode]
         sewobj     = MstSewadarPersonalInfo.where("sp_compcode =? AND sp_sewcode =?",compcodes,sewcode).first
          if sewobj
             sewobj.destroy
          end
     end
     
     private
     def delete_sewadar_office(sewcode)
         compcodes  = session[:loggedUserCompCode]
         sewobj     = MstSewadarOfficeInfo.where("so_compcode = ? AND so_sewcode =?",compcodes,sewcode).first
          if sewobj
             sewobj.destroy
          end
     end
   
     private
     def delete_sewadar_qualification(sewcode)
         compcodes  = session[:loggedUserCompCode]
         sewobj     = MstSewadarKycQualification.where("skq_compcode = ? AND skq_sewcode =?",compcodes,sewcode)
          if sewobj
             sewobj.destroy_all
          end
     end
   
     private
     def delete_sewadar_family(sewcode)
         compcodes  = session[:loggedUserCompCode]
         sewobj     = MstSewdarKycFamilyDetail.where("skf_compcode = ? AND skf_sewcode =?",compcodes,sewcode)
          if sewobj
             sewobj.destroy_all
          end
     end
   
      private
     def delete_sewadar_workexp(sewcode)
         compcodes  = session[:loggedUserCompCode]
         sewobj     = MstSewadarWorkExperience.where("swe_compcode = ? AND swe_sewcode =?",compcodes,sewcode)
          if sewobj
             sewobj.destroy_all
          end
     end
   
   
   
     private
     def get_sewadar_listing
         
         jons = ""
         if params[:requestserver] !=nil && params[:requestserver] != ''
               session[:supreqs_sewadar_code]        = nil
               session[:supreqs_sewadar_name]        = nil
               session[:supreqs_sewadar_designation] = nil
               session[:supreqs_sewadar_string]      = nil
               session[:supreqs_sewadar_categories]  = nil
               session[:supreqs_sewadar_departments] = nil
               session[:supreqs_sewadar_rolesresp]   = nil
               session[:supreqs_sewadar_mysttatus]   = nil
               session[:supreqs_sewadar_genders]     = nil
               session[:supreqs_sewadar_codetype]    = nil
               session[:supreqs_sewadar_fromdate]    = nil
               session[:supreqs_sewadar_uptodate]    = nil
               session[:supreqs_sewadar_accorddated] = nil
               session[:supreqs_sewadar_tpes]        = nil
               session[:supreqs_sewadar_noneupdated] = nil
               session[:supreqs_financial_years]  = nil
         end
         
       sewadar_code         = params[:sewadar_code].to_s.strip !=nil && params[:sewadar_code].to_s.strip !='' ? params[:sewadar_code].to_s.strip : session[:supreqs_sewadar_code].to_s.strip
       sewadar_name         = params[:sewadar_name].to_s.strip !=nil && params[:sewadar_name].to_s.strip !='' ? params[:sewadar_name].to_s.strip : session[:supreqs_sewadar_name].to_s.strip
       sewadar_string       = params[:sewadar_string].to_s.strip !=nil && params[:sewadar_string].to_s.strip != '' ? params[:sewadar_string].to_s.strip : session[:supreqs_sewadar_string].to_s.strip
       sewadar_categories   = params[:sewadar_categories].to_s.strip !=nil && params[:sewadar_categories].to_s.strip != ''  ? params[:sewadar_categories].to_s.strip : session[:supreqs_sewadar_categories]
       sewadar_departments  = params[:sewadar_departments].to_s.strip !=nil && params[:sewadar_departments].to_s.strip != ''  ? params[:sewadar_departments].to_s.strip : session[:supreqs_sewadar_departments]
       sewadar_codetype     = params[:sewadar_codetype] !=nil && params[:sewadar_codetype] != ''  ? params[:sewadar_codetype] : session[:supreqs_sewadar_codetype]
       financial_years      = params[:financial_years] !=nil && params[:financial_years] != ''  ? params[:financial_years] : session[:supreqs_financial_years] 
   
       myflagsjs   = false
       mytflags   = false
       mydateflags = false
       mynonedate  = false
       if financial_years !=nil && financial_years !=''
         session[:supreqs_financial_years]  = financial_years
         @financial_years = financial_years
       end
       startfinancial  = financial_years.to_s+"-04-01"
       endfinancial    = (financial_years.to_i+1).to_s+"-03-31"

       iswhere = "sw_compcode ='#{@compCodes}' AND sw_leavingdate ='0000-00-00' "
       iswhere += " AND DATE(so_superannuationdate) >='#{startfinancial}' AND DATE(so_superannuationdate)<='#{endfinancial}'"
       
   
       if sewadar_categories !=nil && sewadar_categories !=''
         iswhere += " AND sw_catgeory LIKE '%#{sewadar_categories}%'"
         session[:supreqs_sewadar_categories] = sewadar_categories
         @sewadar_categories             = sewadar_categories
       end
       if sewadar_departments !=nil && sewadar_departments !=''
         iswhere += " AND sw_depcode LIKE '%#{sewadar_departments}%'"
         session[:supreqs_sewadar_departments] = sewadar_departments
         @sewadar_departments              = sewadar_departments
       end
       
       if sewadar_codetype !=nil && sewadar_codetype !=''
         @sewadar_codetype                  =  sewadar_codetype
         session[:supreqs_sewadar_codetype]    =  sewadar_codetype
       end
        if sewadar_string !=nil && sewadar_string != ''      
           session[:supreqs_sewadar_string]      = sewadar_string
           @sewadar_string                    = sewadar_string
           myflagsjs = true
        
         if sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='mycode'
            iswhere += " AND sw_sewcode LIKE '%#{sewadar_string.to_s.strip}%' "
         elsif sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='myemail'
            iswhere += " AND sp_personal_email LIKE '%#{sewadar_string.to_s.strip}%' "
         elsif sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='mymobile'
            iswhere += " AND sp_mobileno LIKE '%#{sewadar_string.to_s.strip}%'  "
         elsif sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='myname'
            iswhere += " AND sw_sewadar_name LIKE '%#{sewadar_string.to_s.strip}%'  "
         elsif sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='myrefcode'
            iswhere += " AND sw_oldsewdarcode LIKE '%#{sewadar_string.to_s.strip}%' "
         end
   
       end
       
       jons      = " LEFT JOIN mst_sewadar_office_infos offc on(so_compcode = sw_compcode AND sw_sewcode = so_sewcode)"
       isselects = "mst_sewadars.*,so_superannuationdate"
       listobj =[]
       if params[:requestserver] !=nil && params[:requestserver] != ''
           listobj =  MstSewadar.select(isselects).joins(jons).where(iswhere).order("so_superannuationdate ASC")
       end    
       
       return listobj
   
     end
   
     private
     def get_sewdara_inofrmation_first(sewcode)
            compcode  = session[:loggedUserCompCode]
            sewdarobj =  MstSewadar.select("sw_depcode").where("sw_compcode =? AND sw_sewcode =?",compcode,sewcode).first
            return sewdarobj
     end
   
     private
     def get_personal_information(compcode,empcode)
            sewdarobj =  MstSewadarPersonalInfo.where("sp_compcode =? AND sp_sewcode =?",compcode,empcode).first
            return sewdarobj
     end
   
     private
     def get_office_information(compcode,empcode)
            sewdarobj =  MstSewadarOfficeInfo.where("so_compcode =? AND so_sewcode =?",compcode,empcode).first
            return sewdarobj
     end
   
      private
     def get_roles_information(compcode,rspcode)
            sewdarobj =  MstResponsibility.where("rsp_compcode =? AND rsp_rspcode =?",compcode,rspcode).first
            return sewdarobj
     end
   
   private
     def get_sewadar_kyc_information(compcode,sewcode)
          sewdarobj =  MstSewadarKyc.where("sk_compcode =? AND sk_sewcode =?",compcode,sewcode).first
          return sewdarobj
     end
     private
     def get_sewadar_kyc_bankdetail(compcode,sewcode)
          sewdarobj =  MstSewadarKycBank.where("skb_compcode =? AND sbk_sewcode =?",compcode,sewcode).first
          return sewdarobj
     end
   
     private
     def get_sewadar_kyc_qualification(compcode,sewcode)
          arritem   = []
          isselct   = "mst_sewadar_kyc_qualifications.*,'' as universityboard,'' as  degreedip"
          sewdarobj = MstSewadarKycQualification.select(isselct).where("skq_compcode =? AND skq_sewcode = ?",compcode,sewcode).order("skq_passingyear ASC")
          if sewdarobj.length >0
            sewdarobj.each do |qualif|
                unobj =   get_name_global_university(qualif.skq_universityboard)
                if unobj
                  qualif.universityboard = unobj.un_description
                end
                qlfobj = get_name_global_qualification(qualif.skq_degreedip)
                if qlfobj
                  qualif.degreedip  = qlfobj.ql_qualdescription
                end
                arritem.push qualif
            end
             
          end
          return arritem
     end
   
     private
     def get_sewadar_kyc_family(compcode,sewcode)      
          isselect  = "mst_sewdar_kyc_family_details.*,DATE_FORMAT(skf_datebirth,'%d/%m/%Y') as bdate1"
          sewdarobj =  MstSewdarKycFamilyDetail.select(isselect).where("skf_compcode =? AND skf_sewcode =?",compcode,sewcode).order("skf_dependent ASC")
          return sewdarobj
     end
   
     private
     def get_sewadar_dependent_listed(compcode,sewcode)
          isselect  = "GROUP_CONCAT(skf_dependent) as mydependent,GROUP_CONCAT(skf_relation) as myrelation"
          sewdarobj =  MstSewdarKycFamilyDetail.select(isselect).where("skf_compcode =? AND skf_sewcode =?",compcode,sewcode).first
          return sewdarobj
     end
   
     private
     def total_sewadar_kyc_family(compcode)
          isselect  = "mst_sewdar_kyc_family_details.*,DATE_FORMAT(skf_datebirth,'%d/%m/%Y') as bdate1"
          sewdarobj =  MstSewdarKycFamilyDetail.select(isselect).where("skf_compcode =?",compcode).group("skf_dependent").order("skf_dependent ASC")
          return sewdarobj
     end
   
     private
     def get_sewadar_work_experience(compcode,sewcode)
          sewdarobj =  MstSewadarWorkExperience.where("swe_compcode =? AND swe_sewcode =?",compcode,sewcode).order("swe_employer ASC")
          return sewdarobj
     end
   
     
     
    
   
      private
      def get_unversity_deegre
          qualification = params[:qualification]
          isflags       = false
          iswhere       = "un_compcode ='#{@compCodes}' AND FIND_IN_SET('#{qualification.to_s.strip}',un_qltype) >0"
          unobj =  MstUniversity.where(iswhere).group("un_description").order("un_description ASC")
          vhml  = "<option value="">-Select-</option>"
          qhtm  = "<option value="">-Select-</option>"
          if unobj.length >0
              unobj.each do |neunq|
                vhml +='<option value="'+neunq.id.to_s+'">'+neunq.un_description.to_s+'</option>';
              end
              isflags = true
          end
          qlfobj = MstQualification.where("ql_compcode = ? AND  LOWER(ql_qualification) = ?",@compCodes,qualification.to_s.strip.downcase).order("ql_qualdescription ASC")
          if qlfobj.length >0
            qlfobj.each do |newqlf|
              qhtm +='<option value="'+newqlf.id.to_s+'">'+newqlf.ql_qualdescription.to_s+'</option>';
            end
            isflags =true
          end
           respond_to do |format|
                format.json { render :json => { 'undata'=>vhml,'qldata'=>qhtm, "message"=>'',:status=>isflags} }
           end
      end
   
   
      private
      def get_department_detail
        departcode = params[:departcode]    
        isflags    = false
         qlfobj    = Department.select("departCode,departDescription").where("compCode = ? AND subdepartment = ? AND subdepartment<>''",@compCodes,departcode).order("departDescription ASC")
          if qlfobj.length >0        
            isflags = true
          end
          respond_to do |format|
                format.json { render :json => { 'data'=>qlfobj,"message"=>'',:status=>isflags} }
           end
      end
   
      private
      def get_all_sub_selected_loc
        locations  = params[:locations]
        isflags    = false
         qlfobj    = MstSubLocation.select("id,sl_description").where("sl_compcode = ? AND sl_locid = ?",@compCodes,locations).order("sl_description ASC")
          if qlfobj.length >0
            isflags = true
          end
          respond_to do |format|
                format.json { render :json => { 'data'=>qlfobj,"message"=>'',:status=>isflags} }
           end
      end
   
   
   
      private
      def get_durations
        qualification = params[:qualification]
        durations = ''
        isflags = false
         qlfobj   = MstQualification.select("ql_duration").where("ql_compcode = ? AND  id = ?",@compCodes,qualification).first
          if qlfobj
            durations = qlfobj.ql_duration
            isflags = true
          end
          respond_to do |format|
                format.json { render :json => { 'data'=>durations,"message"=>'',:status=>isflags} }
           end
      end
   
      private
      def get_distcity
          statecode  = params[:dstcity]
          isflags    = false
          qlfobj     = MstDistrict.where("dts_compcode =? AND dts_statecode = ?",@compCodes,statecode).order("dts_description ASC")
          if qlfobj.length >0           
              isflags   = true
          end
          respond_to do |format|
                format.json { render :json => { 'data'=>qlfobj,"message"=>'',:status=>isflags} }
          end
          
      end
   
      private
      def get_state_listed
          statecode  = params[:dstcity]
          isflags    = false
          stesobj    = MstState.where("sts_compcode =?",@compCodes).order("sts_description ASC")
          if stesobj.length >0
              isflags   = true
          end
          respond_to do |format|
                format.json { render :json => { 'data'=>stesobj,"message"=>'',:status=>isflags} }
          end
   
      end

      private
     def supernation_session_list(compcode,types)
        mydated = ""
          orders = ""
          if types =='ASC'
            orders = "so_superannuationdate ASC"
          elsif types =='DESC'
            orders = "so_superannuationdate DESC"
          end
          sewdarobj =  MstSewadarOfficeInfo.select("so_superannuationdate").where("so_compcode =? AND so_superannuationdate<>'0000-00-00'",compcode).order(orders).first
          if sewdarobj
            mydated = sewdarobj.so_superannuationdate
          end
          return mydated
     end

end
