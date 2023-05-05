class MedicalAidController < ApplicationController
 before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_sewdar_designation_detail,:get_all_department_detail
    helper_method :set_dct,:set_ent,:get_personal_information,:get_office_information,:get_roles_information,:format_oblig_date,:get_university_deegre_listed
    helper_method :get_sewa_all_department,:get_sewa_all_qualification,:get_sewa_all_rolesresp,:get_sewa_all_designation,:get_first_my_sewadar
    helper_method :get_sewadar_dependent_listed,:get_sewadar_kyc_family,:get_sewadar_kyc_qualification,:get_dependent_education_detail
  def index
     @compCodes         = session[:loggedUserCompCode]
     @mydepartcode      = ''
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
       @Allsewobj        = MstSewadar.select("sw_compcode").where("sw_compcode =?",@compCodes)
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
            session[:reqs_sewadar_code]        = nil
            session[:reqs_sewadar_name]        = nil
            session[:reqs_sewadar_designation] = nil
            session[:reqs_sewadar_string]      = nil
            session[:reqs_sewadar_categories]  = nil
            session[:reqs_sewadar_departments] = nil
            session[:reqs_sewadar_rolesresp]   = nil
            session[:reqs_sewadar_mysttatus]   = nil
            session[:reqs_sewadar_genders]     = nil
            session[:reqs_sewadar_codetype]    = nil
            session[:reqs_sewadar_fromdate]    = nil
            session[:reqs_sewadar_uptodate]    = nil
            session[:reqs_sewadar_accorddated] = nil
            session[:reqs_sewadar_tpes]        = nil
            session[:reqs_sewadar_noneupdated] = nil
      end
      
    sewadar_code        = params[:sewadar_code].to_s.strip !=nil && params[:sewadar_code].to_s.strip !='' ? params[:sewadar_code].to_s.strip : session[:reqs_sewadar_code].to_s.strip
    sewadar_name        = params[:sewadar_name].to_s.strip !=nil && params[:sewadar_name].to_s.strip !='' ? params[:sewadar_name].to_s.strip : session[:reqs_sewadar_name].to_s.strip
    sewadar_designation = params[:sewadar_designation].to_s.strip !=nil && params[:sewadar_designation].to_s.strip !='' ? params[:sewadar_designation].to_s.strip : session[:reqs_sewadar_designation].to_s.strip
    sewadar_string      = params[:sewadar_string].to_s.strip !=nil && params[:sewadar_string].to_s.strip != '' ? params[:sewadar_string].to_s.strip : session[:reqs_sewadar_string].to_s.strip

    sewadar_categories   = params[:sewadar_categories].to_s.strip !=nil && params[:sewadar_categories].to_s.strip != ''  ? params[:sewadar_categories].to_s.strip : session[:reqs_sewadar_categories]
    sewadar_departments  = params[:sewadar_departments].to_s.strip !=nil && params[:sewadar_departments].to_s.strip != ''  ? params[:sewadar_departments].to_s.strip : session[:reqs_sewadar_departments]
    sewadar_rolesresp    = params[:sewadar_rolesresp].to_s.strip !=nil && params[:sewadar_rolesresp].to_s.strip != ''  ? params[:sewadar_rolesresp].to_s.strip : session[:reqs_sewadar_rolesresp]

    sewadar_mysttatus    = params[:sewadar_mysttatus].to_s.strip !=nil && params[:sewadar_mysttatus].to_s.strip != ''  ? params[:sewadar_mysttatus].to_s.strip : session[:reqs_sewadar_mysttatus]
    sewadar_genders      = params[:sewadar_genders].to_s.strip !=nil && params[:sewadar_genders].to_s.strip != ''  ? params[:sewadar_genders].to_s.strip : session[:reqs_sewadar_genders]
    sewadar_codetype     = params[:sewadar_codetype] !=nil && params[:sewadar_codetype] != ''  ? params[:sewadar_codetype] : session[:reqs_sewadar_codetype]

    sewadar_fromdate     = params[:sewadar_fromdate] !=nil && params[:sewadar_fromdate] != ''  ? year_month_days_formatted(params[:sewadar_fromdate]) : session[:reqs_sewadar_fromdate]
    sewadar_uptodate     = params[:sewadar_uptodate] !=nil && params[:sewadar_uptodate] != ''  ? year_month_days_formatted(params[:sewadar_uptodate]) : session[:reqs_sewadar_uptodate]
    sewadar_accorddated  = params[:sewadar_accorddated] !=nil && params[:sewadar_accorddated] != ''  ? params[:sewadar_accorddated] : session[:reqs_sewadar_accorddated]
    sewadar_tpes         = params[:sewadar_tpes] !=nil && params[:sewadar_tpes] != ''  ? params[:sewadar_tpes] : session[:reqs_sewadar_tpes]
    sewadar_noneupdated  = params[:sewadar_noneupdated] !=nil && params[:sewadar_noneupdated] !='' ? params[:sewadar_noneupdated] : session[:reqs_sewadar_noneupdated]


    myflagsjs = false
    mytflags   = false
    mydateflags = false
    mynonedate  = false
    
    iswhere = "sw_compcode ='#{@compCodes}'"
    if sewadar_accorddated !=nil && sewadar_accorddated !=''
        session[:reqs_sewadar_accorddated] = sewadar_accorddated
        @sewadar_accorddated               = sewadar_accorddated
         mydateflags = true
    end
    if sewadar_noneupdated  !=nil && sewadar_noneupdated  !=''
        session[:reqs_sewadar_noneupdated] = sewadar_noneupdated
        @sewadar_noneupdated               = sewadar_noneupdated
        mynonedate = true
    end
    
    if mydateflags && mynonedate
     ### execute query
    elsif mydateflags
        if sewadar_fromdate !=nil && sewadar_fromdate !=''
              iswhere += " AND DATE(mst_sewadars.updated_at) >='#{sewadar_fromdate}'"
              session[:reqs_sewadar_fromdate] = sewadar_fromdate
              @sewadar_fromdate               = sewadar_fromdate
         end
         if sewadar_uptodate !=nil && sewadar_uptodate !=''
              iswhere += " AND DATE(mst_sewadars.updated_at) <='#{sewadar_uptodate}'"
              session[:reqs_sewadar_uptodate] = sewadar_uptodate
              @sewadar_uptodate         = sewadar_uptodate
         end
    elsif  mynonedate
         iswhere += " AND DATE(mst_sewadars.updated_at) ='0000-00-00 00:00:00.000000'"
    end
    if sewadar_tpes !=nil && sewadar_tpes !=''
      @sewadar_tpes = sewadar_tpes
      session[:reqs_sewadar_tpes] = sewadar_tpes
    end
    

    if sewadar_categories !=nil && sewadar_categories !=''
      iswhere += " AND sw_catgeory LIKE '%#{sewadar_categories}%'"
      session[:reqs_sewadar_categories] = sewadar_categories
      @sewadar_categories             = sewadar_categories
    end
    if sewadar_departments !=nil && sewadar_departments !=''
      iswhere += " AND sw_depcode LIKE '%#{sewadar_departments}%'"
      session[:reqs_sewadar_departments] = sewadar_departments
      @sewadar_departments              = sewadar_departments
    end
    if sewadar_rolesresp !=nil && sewadar_rolesresp !=''
      iswhere += " AND so_respcode LIKE '%#{sewadar_rolesresp}%'"
      session[:reqs_sewadar_rolesresp] = sewadar_rolesresp
      @sewadar_rolesresp              = sewadar_rolesresp
      mytflags = true
    end

    if sewadar_mysttatus !=nil && sewadar_mysttatus !=''
       if sewadar_mysttatus == 'Working'
         iswhere += " AND sw_joiningdate<>'0000-00-00'"
       elsif sewadar_mysttatus == 'Left'
         iswhere += " AND sw_leavingdate<>'0000-00-00' "
       else
         ### Execute code if required
       end
        session[:reqs_sewadar_mysttatus] = sewadar_mysttatus
        @sewadar_mysttatus               = sewadar_mysttatus
    end
    if sewadar_genders !=nil && sewadar_genders !=''
      if sewadar_genders !='All'
       iswhere += " AND sw_gender = '#{sewadar_genders}'"
      end
      session[:reqs_sewadar_genders] = sewadar_genders
      @sewadar_genders              = sewadar_genders
    end
    
    
    if sewadar_designation !=nil && sewadar_designation !=''
      iswhere += " AND sw_desigcode = '#{sewadar_designation}'"
      session[:reqs_sewadar_designation]  = sewadar_designation
      @sewadar_designation               = sewadar_designation
    end
    if sewadar_codetype !=nil && sewadar_codetype !=''
      @sewadar_codetype                  =  sewadar_codetype
      session[:reqs_sewadar_codetype]    =  sewadar_codetype
    end
     if sewadar_string !=nil && sewadar_string != ''      
        session[:reqs_sewadar_string]      = sewadar_string
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
    
      if session[:autherizedUserType] && session[:autherizedUserType].to_s != 'adm'  &&  session[:requestuser_loggedintp] != 'hr'
        iswhere += " AND sw_depcode = '#{@mydepartcode}'"
      end
      if mytflags && myflagsjs
          jons  = " LEFT JOIN mst_sewadar_office_infos offc on(so_compcode = sw_compcode AND sw_sewcode = so_sewcode)"
          jons += " LEFT JOIN mst_sewadar_personal_infos spi on(sp_compcode = sw_compcode AND sw_sewcode = sp_sewcode)"
          isselects = "mst_sewadars.*,spi.id as SpId,offc.id as offsId"
      elsif mytflags
         jons = " LEFT JOIN mst_sewadar_office_infos offc on(so_compcode = sw_compcode AND sw_sewcode = so_sewcode)"
         isselects = "mst_sewadars.*,offc.id as offsId"
       elsif myflagsjs
         jons = " LEFT JOIN mst_sewadar_personal_infos spi on(sp_compcode = sw_compcode AND sw_sewcode = sp_sewcode)"
         isselects = "mst_sewadars.*,spi.id as SpId"
      end
    listobj =[]
    if params[:requestserver] !=nil && params[:requestserver] != ''
      if( @sewadar_tpes !=nil && @sewadar_tpes !='')
             if myflagsjs || mytflags
             listobj =  MstSewadar.select(isselects).joins(jons).where(iswhere).order("sw_sewcode ASC")
           else
             listobj =  MstSewadar.where(iswhere).order("sw_sewcode ASC")
           end
      end
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
  def get_dependent_education_detail(compcode,dependent)
    chkdsobj      = TrnApplyEducationAid.where("aea_compcode = ? AND aea_dependent = ? AND aea_status<>'R' AND aea_status<>'C' AND YEAR(aea_requestdate)=YEAR(NOW()) AND aea_voucherno<>''",compcode,dependent).first

  end

  private
  def get_sewadar_kyc_qualification(compcode,sewcode)
       arritem   = []
       isselct   = "mst_sewadar_kyc_qualifications.*,'' as universityboard,'' as  degreedip,'' as passingyear"
       sewdarobj = MstSewadarKycQualification.select(isselct).where("skq_compcode =? AND skq_sewcode = ?",compcode,sewcode).order("skq_passingyear ASC")
       if sewdarobj.length >0
         sewdarobj.each do |qualif|
             unobj =   get_name_global_university(qualif.skq_universityboard)
             if unobj
               qualif.universityboard = unobj.un_description
             end
             qlfobj = get_name_global_qualification(qualif.skq_degreedip)
             if qlfobj !=nil
               qualif.degreedip       =  qlfobj.ql_qualdescription
               qualif.passingyear     =  qualif.skq_passingyear
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
end

