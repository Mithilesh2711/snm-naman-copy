## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process banking KYC,Attachment,QUALIF etc
### FOR REST API ######
class SewadarInformationController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_sewdar_designation_detail,:get_all_department_detail
    helper_method :set_dct,:set_ent,:get_personal_information,:get_office_information,:get_roles_information,:format_oblig_date,:get_university_deegre_listed
    helper_method :get_sewa_all_department,:get_sewa_all_qualification,:get_sewa_all_rolesresp,:get_sewa_all_designation,:get_first_my_sewadar
    helper_method :get_unversity_firstrecord
    def index
     @compCodes         = session[:loggedUserCompCode]
     @mydepartcode      = ''
     @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
     @familylisted      = total_sewadar_kyc_family(@compCodes)
     if session[:sec_sewdar_code] 
       sewobjs =  get_sewdara_inofrmation_first(session[:sec_sewdar_code] )
       if sewobjs
          @mydepartcode = sewobjs.sw_depcode
       end
     end
     @Totalcounts      = nil
     @sewdarList        = get_sewadar_listing()
     @ListDesignation   = Designation.where("compcode = ?",@compCodes).order("ds_description ASC")
     if session[:autherizedUserType] && session[:autherizedUserType].to_s != 'adm'   
          if session[:requestuser_loggedintp].to_s == 'hr'
            @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =?",@compCodes)
          else
            @Allsewobj         = MstSewadar.select("sw_compcode").where("sw_compcode =? AND sw_depcode = ?",@compCodes,@mydepartcode)
          end       
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
  def add_sewadar
    # @datesss = Date.today
    @compCodes       = session[:loggedUserCompCode]
    @seawdarsobj     = nil
    @sewadarpersonal = nil
    @empChecked      = nil
    @subLocobj       = nil
    @sewadarDist     = nil
    @sewadarpsDist   = nil
    @sewSubDepart    = nil
    @Allsewobjx      = MstSewadar.select("sw_sewadar_name,sw_sewcode").where("sw_compcode =?",@compCodes).order("sw_sewadar_name ASC")
    @sewadarState    = MstState.where("sts_compcode =?",@compCodes).order("sts_description ASC")
    @BrachListed     = MstBranchList.where("bl_compcode =?",@compCodes).order("bl_branchname ASC")
    @HeadOffices     = MstHeadOffice.where("hof_compcode =?",@compCodes).order("hof_description ASC")
    @ListZone        = MstZone.where("zn_compcode = ?",@compCodes).order("zn_name ASC")
    @sewadarCategory = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
    @Hrsobj          = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
    @accomodType     = MstAccomodationType.where("at_compcode =?",@compCodes).order("at_description ASC")
    @ListUniversity  = get_all_unversity_list()
    @ZonalBranch     = nil
    myprofessid      = params[:id].to_i >0 ? params[:id] : session[:request_processlogid]
    if myprofessid.to_i >0
        @seawdarsobj      = MstSewadar.where("sw_compcode =? AND id = ?",@compCodes, myprofessid).first
        if @seawdarsobj
              @sewadarpersonal = get_personal_information(@compCodes,@seawdarsobj.sw_sewcode)
              @empChecked      = get_office_information(@compCodes,@seawdarsobj.sw_sewcode)
              @EmpKyc          = get_sewadar_kyc_information(@compCodes,@seawdarsobj.sw_sewcode)
              @EmpKycBank      = get_sewadar_kyc_bankdetail(@compCodes,@seawdarsobj.sw_sewcode)
              @EmpKycQulifc    = get_sewadar_kyc_qualification(@compCodes,@seawdarsobj.sw_sewcode)
              @EmpKycFamily    = get_sewadar_kyc_family(@compCodes,@seawdarsobj.sw_sewcode)
              @EmpWorkExp      = get_sewadar_work_experience(@compCodes,@seawdarsobj.sw_sewcode)
              if @sewadarpersonal
                @sewadarDist     = MstDistrict.where("dts_compcode =? AND dts_statecode =?",@compCodes,@sewadarpersonal.sp_perma_state).order("dts_description ASC")
                @sewadarpsDist   = MstDistrict.where("dts_compcode =? AND dts_statecode =?",@compCodes,@sewadarpersonal.sp_pres_state).order("dts_description ASC")
              end
              if @empChecked
                @sewSubDepart    = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment<>'' AND subdepartment =?",@compCodes,@empChecked.so_deprtcode).order("departDescription ASC")
                @subLocobj       = MstSubLocation.where("sl_compcode =? AND sl_locid = ?",@compCodes,@empChecked.so_location).order("sl_description ASC")
                @ZonalBranch     = MstBranch.where("bch_compcode =? AND bch_zonecode = ?",@compCodes,@empChecked.so_zone).order("bch_branchname ASC")
              end
        end
      
    end
    
  end
  def sewadar_info_grid
    
  end
  
  def ajax_process
         @compCodes       = session[:loggedUserCompCode]
         if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
            process_sewadar_creatation();
            return
         elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'GS'
            category_wise_series()
            return
         elsif  params[:identity] != nil && params[:identity] != '' && params[:identity] ==  'OFFICE'
           process_save_office()
           return false
         elsif  params[:identity] != nil && params[:identity] != '' && params[:identity] ==  'KYC'
           process_kyc()
           return false         
        elsif  params[:identity] != nil && params[:identity] != '' && params[:identity] ==  'FCLT'
           upadte_facilities()
           return false
         elsif  params[:identity] != nil && params[:identity] != '' && params[:identity] ==  'MNTNC'
           update_maiantaince()
           return false         
         elsif  params[:identity] != nil && params[:identity] != '' && params[:identity] ==  'BIRTHCALC'
           get_birth_date_calculation()
           return false
         elsif  params[:identity] != nil && params[:identity] != '' && params[:identity] ==  'QLFUNV'
           get_unversity_deegre()
           return false
         elsif  params[:identity] != nil && params[:identity] != '' && params[:identity] ==  'DURTN'
           get_durations()
           return false
         elsif  params[:identity] != nil && params[:identity] != '' && params[:identity] ==  'DISTCITY'
           get_distcity()
           return false
        elsif  params[:identity] != nil && params[:identity] != '' && params[:identity] ==  'DISTSTATES'
           get_state_listed()
           return false
         elsif  params[:identity] != nil && params[:identity] != '' && params[:identity] ==  'TOTALSEWA'
           get_total_sewa_calculation()
           return false
          elsif  params[:identity] != nil && params[:identity] != '' && params[:identity] ==  'SUBDEPART'
           get_department_detail()
           return false
         elsif  params[:identity] != nil && params[:identity] != '' && params[:identity] ==  'SUBLOC'
           get_all_sub_selected_loc()
           return false
         elsif  params[:identity] != nil && params[:identity] != '' && params[:identity] ==  'ADDQUALF'
           process_save_existing_qualification()
           return false
        elsif  params[:identity] != nil && params[:identity] != '' && params[:identity] ==  'DELETEEACH'
           delete_common_records()
           return false
       elsif  params[:identity] != nil && params[:identity] != '' && params[:identity] ==  'ADDWKEXP'
           process_work_detail()
           return false
       elsif  params[:identity] != nil && params[:identity] != '' && params[:identity] ==  'ADDFML'
           save_family_list_detail()
           return false
        end






  end

  def destroy
    compcodes  = session[:loggedUserCompCode]
    delid      = params[:id]
    isflags    = true
    ApplicationRecord.transaction do
        begin
                 if delid.to_i >0
                     sewdarobj =   MstSewadar.where("sw_compcode =? AND id = ?",compcodes,delid).first
                      if sewdarobj
                          sewcode = sewdarobj.sw_sewcode
                           if sewdarobj.destroy
                               flash[:error] =  "Data deleted successfully."
                                isflags      =  true
                                delete_sewadar_bank(sewcode)
                                delete_sewadar_kyc(sewcode)
                                delete_sewadar_personal(sewcode)
                                delete_sewadar_office(sewcode)
                                delete_sewadar_qualification(sewcode)
                                delete_sewadar_family(sewcode)
                                delete_sewadar_workexp(sewcode)
                           end
                      end
                 end
           rescue Exception => exc
                  flash[:error]   = "#{exc.message}"
                  isflags         = false
                  raise ActiveRecord::Rollback
            end
      end
      if !isflags
         session[:request_params] = params
         session[:isErrorhandled] = 1
         isflags                  = false
     else
         session[:request_params] = nil
         session[:isErrorhandled] = nil
         session.delete(:request_params)
     end
      redirect_to "#{root_url}sewadar_information"
  end

  def refresh_sewadar_information
    session[:req_sewadar_code]        = nil
    session[:req_sewadar_name]        = nil
    session[:req_sewadar_designation] = nil
    session[:req_sewadar_string]      = nil
    session[:req_sewadar_categories]  = nil
    session[:req_sewadar_departments] = nil
    session[:req_sewadar_rolesresp]   = nil
    session[:req_sewadar_mysttatus]   = nil
    session[:req_sewadar_genders]     = nil
    redirect_to "#{root_url}sewadar_information"

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
  def process_sewadar_creatation
      @seriescode = ""
      @profileimg = ""
      message     = ""
      mid         = ""
      isflags     = true
      @sewCatCodes = ''
       ApplicationRecord.transaction do
      begin
     if params[:sw_sewadar_name] == nil  ||  params[:sw_sewadar_name] == ''
           message = "Sewadar name is required."
           isflags = false
      
      elsif params[:sw_date_of_birth] == nil  ||  params[:sw_date_of_birth] == ''
           message = "Date of birth is required."
           isflags = false
      else
              sewdcat       =  params[:sw_catgeory] !=nil && params[:sw_catgeory] !='' ?  params[:sw_catgeory].to_s.strip : ''
              sewcatobj     =  MstSewadarCategory.where("sc_compcode =? AND sc_name=?",@compCodes,sewdcat).first
              if sewcatobj
                 seadarcatcode = sewcatobj.sc_catcode
                 @sewCatCodes  = sewcatobj.sc_catcode
              end              
              sewdarcode    =  params[:sw_sewcode] !=nil && params[:sw_sewcode] !='' ?  params[:sw_sewcode].to_s.strip : ''
              sewdobj       =  MstSewadar.where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,sewdarcode).first
              if sewdobj
                  sewdobj.update(sewadar_params)
                  process_personalinfo(@seriescode)
                  office_list_details(sewdarcode,params[:so_blessedbrahma],params[:sp_gyandate])
                   message = "Data updated successfully."
                   isflags = true
                   mid     = sewdobj.id
              else
                sewsvobj = MstSewadar.new(sewadar_params)
                 if sewsvobj.save
                    mid = sewsvobj.id
                    session[:request_processlogid] = mid
                    process_personalinfo(@seriescode)
                    office_list_details(sewdarcode,params[:so_blessedbrahma],params[:sp_gyandate])
                    message = "Data saved successfully."
                    isflags = true
                 end
              end
      end
            rescue Exception => exc
                  message   = "#{exc.message}"
                  isflags   = false
                  raise ActiveRecord::Rollback
            end
      end
      respond_to do |format|
        format.json { render :json => { 'data'=>mid,"myimgs"=>@profileimg, "message"=>message,:status=>isflags} }
      end
  end
  
  private
  def category_wise_series
       isfalgs = false
       catwiseries = generate_sewadar_series()
       if catwiseries
         isfalgs =true
       end
       respond_to do |format|
        format.json { render :json => { 'data'=>catwiseries, "message"=>'',:status=>isfalgs} }
      end
      
  end

  private
  def generate_sewadar_series
        cattype      =  params[:catname] != nil && params[:catname] != '' ? params[:catname].to_s.strip : '' 
        mycatttype   =  cattype      
        sewcatobj    =  MstSewadarCategory.where("sc_compcode = ? AND sc_name = ?",@compCodes,cattype).first
        if sewcatobj
          catcodes = sewcatobj.sc_catcode            
        end
       
        @recCodes    = nil
        if mycatttype == 'SEWADAR TEMPORARY'         
          prefixobj    = 'SD'
        elsif mycatttype == 'SEWADAR REGULAR'          
          prefixobj    = 'SD'
        elsif mycatttype == 'SEWADAR ASSOCIATE A'         
            prefixobj    = 'SD'
        elsif mycatttype == 'VOLUNTEER'          
            prefixobj    = 'VL'
        elsif mycatttype == 'SEWADAR ASSOCIATE B'         
            prefixobj    = 'SD'
          elsif mycatttype == 'DAILY WAGERS'          
            prefixobj    = 'DW'
        end
        if mycatttype == 'DAILY WAGERS' || mycatttype == 'VOLUNTEER'
          @recCodes     = MstSewadar.select("sw_sewcode").where(["sw_compcode = ? AND sw_catcode = ? AND sw_sewcode<>''", @compCodes,catcodes]).order("sw_sewcode DESC").first 
        else
          @recCodes     = MstSewadar.select("sw_sewcode").where(["sw_compcode = ? AND sw_catcode NOT IN('DW','VIV') AND sw_sewcode<>''", @compCodes]).order("sw_sewcode DESC").first 

        end

            
       @Startx       = 6
        @isCode      = 0
        
        if @recCodes
          @isCode1    = @recCodes.sw_sewcode.to_s.gsub(/[^\d]/, '')
          @isCode     = @isCode1.to_i
        end
        @sumXOfCode    = @isCode.to_i + 1
        newlength      = @sumXOfCode.to_s.length
        genleth        = @Startx.to_i-newlength.to_i
        zeroseires     = serial_global_number(genleth)
        @sumXOfCode    = zeroseires.to_s+@sumXOfCode.to_s
        myprefix       = prefixobj
        
        if myprefix !=nil && myprefix !=''
        myprefix = myprefix.to_s+@sumXOfCode.to_s
        else
        myprefix = @sumXOfCode
        end
  return myprefix


  end

  private
  def sewadar_params
        params[:sw_compcode]        = session[:loggedUserCompCode]
        params[:sw_catgeory]        = params[:sw_catgeory] !=nil && params[:sw_catgeory] !='' ?  params[:sw_catgeory] : ''
        params[:catname]            = params[:sw_catgeory] !=nil && params[:sw_catgeory] !='' ?  params[:sw_catgeory] : ''
        if params[:mid].to_i >0
           params[:sw_sewcode]      = @seriescode = params[:sw_sewcode] !=nil && params[:sw_sewcode] !='' ?  params[:sw_sewcode] : ''
        else
           params[:sw_sewcode]      = @seriescode = generate_sewadar_series()
        end
               
        mycatttype                  = params[:sw_catgeory] !=nil && params[:sw_catgeory] !='' ?  params[:sw_catgeory] : ''
        catcodes                    = @sewCatCodes        
        params[:sw_sewadar_name]    = params[:sw_sewadar_name] !=nil && params[:sw_sewadar_name] !='' ?  params[:sw_sewadar_name] : ''
        params[:sw_sewadar_prefix]  = params[:sw_sewadar_prefix] !=nil && params[:sw_sewadar_prefix] !='' ?  params[:sw_sewadar_prefix] : ''
        params[:sw_father_name]     = params[:sw_father_name] !=nil && params[:sw_father_name] !='' ?  params[:sw_father_name] : ''
        params[:sw_father_prefix]   = params[:sw_father_prefix] !=nil && params[:sw_father_prefix] !='' ?  params[:sw_father_prefix] : ''        
        params[:sw_maritalstatus]   = params[:sw_maritalstatus] !=nil && params[:sw_maritalstatus] !='' ?  params[:sw_maritalstatus] : ''
        params[:sw_gender]          = params[:sw_gender] !=nil && params[:sw_gender] !='' ?  params[:sw_gender] : ''
        params[:sw_husbprefix]      = params[:sw_husbprefix] !=nil && params[:sw_husbprefix] !='' ?  params[:sw_husbprefix] : ''
        params[:sw_husbandname]     = params[:sw_husbandname] !=nil && params[:sw_husbandname] !='' ?  params[:sw_husbandname] : ''
        params[:sw_catcode]         = catcodes
        sewimages                   = params[:sw_image] !=nil && params[:sw_image] !='' ?  File.basename(params[:sw_image]) : ''

        myimages                    = ""
        if sewimages.to_s != "personnel_boy.png"  && ( params[:myattachpropfile] != '' && params[:myattachpropfile] != nil )
         
          if params[:sw_image] !=nil && params[:sw_image] !=''
            if params[:myattachpropfile] !=nil && params[:myattachpropfile] !=''
              myimages = @profileimg = process_croped_files()
            end              
          end
            
        end
        if myimages == nil ||  myimages == ''
        
          if params[:currentimgs] != nil && params[:currentimgs] !=''
            myimages = @profileimg =  params[:currentimgs]
          end
      end
      params[:sw_image] = myimages
      bdate = 0
      if params[:sw_date_of_birth] !=nil && params[:sw_date_of_birth] !=''
       bdate = year_month_days_formatted(params[:sw_date_of_birth])
      end
     params[:sw_date_of_birth] = bdate
     if params[:mid].to_i >0
       params.permit(:sw_compcode,:sw_husbprefix,:sw_husbandname,:sw_motherprefix,:sw_mothername,:sw_sewcode,:sw_catcode,:sw_sewadar_name,:sw_sewadar_prefix,:sw_father_name,:sw_father_prefix,:sw_date_of_birth,:sw_maritalstatus,:sw_gender,:sw_catgeory,:sw_image)
     else
       params.permit(:sw_compcode,:sw_husbprefix,:sw_husbandname,:sw_motherprefix,:sw_mothername,:sw_sewcode,:sw_catcode,:sw_sewadar_name,:sw_sewadar_prefix,:sw_father_name,:sw_father_prefix,:sw_date_of_birth,:sw_maritalstatus,:sw_gender,:sw_catgeory,:sw_image)
     end
     
  end

  private
  def process_personalinfo(sewcode)
          params[:sp_sewcode] =  sewcode
          compcode            =  session[:loggedUserCompCode]
          params[:sewcode]    = sewcode
          processsvobj =  MstSewadarPersonalInfo.where("sp_compcode =? AND sp_sewcode = ?",compcode,sewcode).first
          if processsvobj
            processsvobj.update(sewadar_personal)
            process_sewa_personal_insewdar(sewcode,params[:sp_mobileno],params[:sp_personal_email])            
             
             ### execute message if required
          else
            prosvsobj  = MstSewadarPersonalInfo.new(sewadar_personal)
              if prosvsobj.save
                process_sewa_personal_insewdar(sewcode,params[:sp_mobileno],params[:sp_personal_email])               
               
                ### execute message if required
              end
          end
  end

  private
  def sewadar_personal
      ######## ADD PRESONAL INFORMATION ###
       params[:sp_compcode]        = session[:loggedUserCompCode]
       params[:sp_sewcode]         = params[:sp_sewcode] !=nil && params[:sp_sewcode] !='' ?  params[:sp_sewcode] : ''
       params.permit(:sp_compcode,:sp_mandalcode,:sp_sewcode,:sp_perma_houseaddress,:sp_perma_distcity,:sp_perma_state,:sp_perma_pincode,:sp_pres_residenttype,:sp_pres_houseaddress,:sp_pres_distcity,:sp_pres_state,:sp_pres_pincode,:sp_mobileno,:sp_officemobno,:sp_landlineno,:sp_personal_email,:sp_officialmail,:sp_emergency_name,:sp_emergency_relation,:sp_emergency_mobno)

  end
  
  ### PROCESS SEVADAR IMAGES #####
  private
  def process_croped_files
    dirsewad      =  Rails.root.join "public", "images", "sewadar"
    extractfile   =  params[:sw_image]
    start         =  extractfile.index(',') + 1
    file          =  set_dct(extractfile[start..-1] )
    file_type     =  "jpg"
    new_name_file =  Time.now.to_i
    new_file_type =  "#{new_name_file}." + file_type
    #### DELETE ORIGIN #############
    if file != '' && file != nil
       if params[:currentimg]!= '' && params[:currentimg]!= nil
         unlinkpath    = Rails.root.join "public", "images", "sewadar",params[:currentimg].to_s
         process_unlinks_the_files(unlinkpath)
       end
    end
    ######### Upload here ######################
    File.open("#{dirsewad}/" + new_file_type, "wb")  do |f|
      f.write(file)      
    end
    return new_file_type
 end

  private
  def get_sewadar_listing
      if params[:page].to_i >0
      pages = params[:page]
      else
      pages = 1
      end
      jons = ""
      if params[:requestserver] !=nil && params[:requestserver] != ''
        session[:req_sewadar_code]        = nil
        session[:req_sewadar_name]        = nil
        session[:req_sewadar_designation] = nil
        session[:req_sewadar_string]      = nil
        session[:req_sewadar_categories]  = nil
        session[:req_sewadar_departments] = nil
        session[:req_sewadar_rolesresp]   = nil
        session[:req_sewadar_mysttatus]   = nil
        session[:req_sewadar_genders]     = nil
      end
    sewadar_code        = params[:sewadar_code].to_s.strip !=nil && params[:sewadar_code].to_s.strip !='' ? params[:sewadar_code].to_s.strip : session[:req_sewadar_code].to_s.strip
    sewadar_name        = params[:sewadar_name].to_s.strip !=nil && params[:sewadar_name].to_s.strip !='' ? params[:sewadar_name].to_s.strip : session[:req_sewadar_name].to_s.strip
    sewadar_designation = params[:sewadar_designation].to_s.strip !=nil && params[:sewadar_designation].to_s.strip !='' ? params[:sewadar_designation].to_s.strip : session[:req_sewadar_designation].to_s.strip
    sewadar_string      = params[:sewadar_string].to_s.strip !=nil && params[:sewadar_string].to_s.strip != '' ? params[:sewadar_string].to_s.strip : session[:req_sewadar_string].to_s.strip

    sewadar_categories   = params[:sewadar_categories].to_s.strip !=nil && params[:sewadar_categories].to_s.strip != ''  ? params[:sewadar_categories].to_s.strip : session[:req_sewadar_categories]
    sewadar_departments  = params[:sewadar_departments].to_s.strip !=nil && params[:sewadar_departments].to_s.strip != ''  ? params[:sewadar_departments].to_s.strip : session[:req_sewadar_departments]
    sewadar_rolesresp    = params[:sewadar_rolesresp].to_s.strip !=nil && params[:sewadar_rolesresp].to_s.strip != ''  ? params[:sewadar_rolesresp].to_s.strip : session[:req_sewadar_rolesresp]

    sewadar_mysttatus    = params[:sewadar_mysttatus].to_s.strip !=nil && params[:sewadar_mysttatus].to_s.strip != ''  ? params[:sewadar_mysttatus].to_s.strip : session[:req_sewadar_mysttatus]
    sewadar_genders      = params[:sewadar_genders].to_s.strip !=nil && params[:sewadar_genders].to_s.strip != ''  ? params[:sewadar_genders].to_s.strip : session[:req_sewadar_genders]
    sewadar_codetype     = params[:sewadar_codetype] !=nil && params[:sewadar_codetype] != ''  ? params[:sewadar_codetype] : session[:req_sewadar_codetype]

    myflagsjs = false
    mytflags   = false
    iswhere = "sw_compcode ='#{@compCodes}'"
    if sewadar_categories !=nil && sewadar_categories !=''
      iswhere += " AND sw_catgeory LIKE '%#{sewadar_categories}%'"
      session[:req_sewadar_categories] = sewadar_categories
      @sewadar_categories             = sewadar_categories
    end
    if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'stf' || session[:requestuser_loggedintp].to_s == 'swd'
          iswhere += " AND sw_depcode LIKE '%#{@mydepartcode}%'"
          session[:req_sewadar_departments] = @mydepartcode
          @sewadar_departments              = @mydepartcode
       
    else
          if sewadar_departments !=nil && sewadar_departments !=''
            iswhere += " AND sw_depcode LIKE '%#{sewadar_departments}%'"
            session[:req_sewadar_departments] = sewadar_departments
            @sewadar_departments              = sewadar_departments
          end
    end
    
    
    
    if sewadar_rolesresp !=nil && sewadar_rolesresp !=''
      iswhere += " AND so_respcode LIKE '%#{sewadar_rolesresp}%'"
      session[:req_sewadar_rolesresp] = sewadar_rolesresp
      @sewadar_rolesresp              = sewadar_rolesresp
      mytflags = true
    end

    if sewadar_mysttatus !=nil && sewadar_mysttatus !=''
       if sewadar_mysttatus == 'Working'
         iswhere += " AND sw_joiningdate<>'0000-00-00' AND sw_leavingdate='0000-00-00'"
       elsif sewadar_mysttatus == 'Left'
         iswhere += " AND sw_leavingdate<>'0000-00-00' "
       elsif sewadar_mysttatus == 'All'
          ### Execute code if required  
       else
         ### Execute code if required
       end
        session[:req_sewadar_mysttatus] = sewadar_mysttatus
        @sewadar_mysttatus              = sewadar_mysttatus
    end
    if sewadar_genders !=nil && sewadar_genders !=''
      if sewadar_genders !='All'
       iswhere += " AND sw_gender = '#{sewadar_genders}'"
      end
      session[:req_sewadar_genders] = sewadar_genders
      @sewadar_genders              = sewadar_genders
    end
    
    if sewadar_code !=nil && sewadar_code !=''      
      iswhere += " AND sw_sewcode LIKE '%#{sewadar_code}%'"
      session[:req_sewadar_code] = sewadar_code
      @sewadar_code              = sewadar_code
    end
    if sewadar_name !=nil && sewadar_name !=''
      iswhere += " AND sw_sewadar_name LIKE '%#{sewadar_name}%'"
      session[:req_sewadar_name]  = sewadar_name
      @sewadar_name               = sewadar_name
    end
    if sewadar_designation !=nil && sewadar_designation !=''
      iswhere += " AND sw_desigcode = '#{sewadar_designation}'"
      session[:req_sewadar_designation]  = sewadar_designation
      @sewadar_designation               = sewadar_designation
    end

     if sewadar_codetype !=nil && sewadar_codetype !=''
      @sewadar_codetype                  =  sewadar_codetype
      session[:reqsewadar_codetype]    =  sewadar_codetype
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


    # if session[:autherizedUserType] && session[:autherizedUserType].to_s != 'adm'
    #   iswhere += " AND sw_depcode = '#{@mydepartcode}'"
    # end
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
     
     if myflagsjs || mytflags
       listobj =  MstSewadar.select(isselects).joins(jons).where(iswhere).paginate(:page =>pages,:per_page => 20).order("sw_sewcode ASC,sw_sewadar_name ASC")
     else
       listobj =  MstSewadar.where(iswhere).paginate(:page =>pages,:per_page => 20).order("sw_sewcode ASC,sw_sewadar_name ASC")
     end
    @Totalcounts =  total_sewadar_counts(iswhere,myflagsjs,mytflags)
    
    return listobj

  end
  
  private
  def total_sewadar_counts(iswhere,myflagsjs,mytflags)
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
      if myflagsjs || mytflags
        listobj =  MstSewadar.joins(jons).where(iswhere)
      else
        listobj =  MstSewadar.where(iswhere)
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
       arrfamily = []    
       isselect  = "mst_sewdar_kyc_family_details.*,DATE_FORMAT(skf_datebirth,'%d/%m/%Y') as bdate1,DATE_FORMAT(skf_datebirth,'%d-%b-%Y') as bdate2,'' as university"
       sewdarobj =  MstSewdarKycFamilyDetail.select(isselect).where("skf_compcode =? AND skf_sewcode =?",compcode,sewcode).order("skf_dependent ASC")
       if sewdarobj.length >0
            sewdarobj.each do |newfm|
                swobjs = get_unversity_firstrecord(newfm.skf_university)
                if swobjs
                    newfm.university = swobjs.un_description
                end
                arrfamily.push newfm
            end
       end
       return arrfamily
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
  def process_save_office
      compcode            = session[:loggedUserCompCode]
    
      params[:so_sewcode] = sewacode = params[:sewcode]
      message             = ""
      isflags             = true
      ApplicationRecord.transaction do
       begin
      svuobj      =  MstSewadarOfficeInfo.where("so_compcode = ? AND so_sewcode = ?",compcode,sewacode).first
        @OfficeObjc = svuobj
       if svuobj
         svuobj.update(process_office_params)
         process_sewa_interal_detail(sewacode,params[:so_desigcode],params[:so_deprtcode],params[:so_qualifcode],params[:so_joiningdate],params[:so_leavingdate],params[:sw_branchtype],params[:sw_location],params[:so_oldsewdar])
         message = "Data updated successfully."
         isflags = true
       else
         svsobj = MstSewadarOfficeInfo.new(process_office_params)
          if svsobj.save
            process_sewa_interal_detail(sewacode,params[:so_desigcode],params[:so_deprtcode],params[:so_qualifcode],params[:so_joiningdate],params[:so_leavingdate],params[:sw_branchtype],params[:sw_location],params[:so_oldsewdar])
            ### execute message
             message = "Data saved successfully."
             isflags = true
          end
       end
       rescue Exception => exc
              message   = "#{exc.message}"+params[:so_leavingdate].to_s
              isflags   = false
              raise ActiveRecord::Rollback
            end
      end
      listsewaobj =  MstSewadarOfficeInfo.select("so_innote_hr,so_outnote_sewdar").where("so_compcode = ? AND so_sewcode = ?",compcode,sewacode).first
       respond_to do |format|
        format.json { render :json => { 'data'=>'','infodata'=>listsewaobj, "message"=>message,:status=>isflags} }
      end
  end

  private
  def process_office_params
    ######## ADD PRESONAL INFORMATION ###
       params[:so_compcode]        = session[:loggedUserCompCode]
       params[:so_sewcode]         = params[:so_sewcode] !=nil && params[:so_sewcode] !='' ?  params[:so_sewcode] : ''       
       
       seldate   = 0
       joindate  = 0
       reudate   = 0
       anudate   = 0
       leavedate = 0
       fnaldate  = 0
       newrnotehrs    = ""
       newrnotesewadar = ""
       Time.zone   =  "Kolkata"
       localtimes  =  Time.zone.now.strftime('%I:%M%p')
       cdated      =  formatted_date(Time.now.to_date)
       notehrs     =  params[:so_innote_hr]  !=nil && params[:so_innote_hr]  !='' ? params[:so_innote_hr] : ''
       noteoutsw   =  params[:so_outnote_sewdar]  !=nil && params[:so_outnote_sewdar]  !='' ? params[:so_outnote_sewdar] : ''

        if @OfficeObjc
          sqlinnotehr      = @OfficeObjc.so_innote_hr
          sqloutnotesew    = @OfficeObjc.so_outnote_sewdar
           if notehrs !=nil && notehrs !=''
             newrnotehrs     = session[:loggedusername].to_s+" "+cdated.to_s+" "+localtimes.to_s+"<br/>"+notehrs.to_s+"<br/>"+sqlinnotehr.to_s
           else
             newrnotehrs    = sqlinnotehr
           end
            if noteoutsw !=nil && noteoutsw !='' 
              newrnotesewadar = session[:loggedusername].to_s+" "+cdated.to_s+" "+localtimes.to_s+"<br/>"+noteoutsw.to_s+"<br/>"+sqloutnotesew.to_s
            else
              newrnotesewadar = sqloutnotesew
            end
           
        end

       if params[:so_settmentdate] !=nil && params[:so_settmentdate] !=''
          seldate = year_month_days_formatted(params[:so_settmentdate])
       end
       if params[:so_joiningdate] !=nil && params[:so_joiningdate] !=''
         joindate = year_month_days_formatted(params[:so_joiningdate])
       end
       if params[:so_regularizationdate] !=nil && params[:so_regularizationdate] !=''
         reudate = year_month_days_formatted(params[:so_regularizationdate])
       end
       if params[:so_superannuationdate] !=nil && params[:so_superannuationdate] !=''
         anudate = year_month_days_formatted(params[:so_superannuationdate])
       end

       if params[:so_leavingdate] !=nil && params[:so_leavingdate] !=''
         leavedate = year_month_days_formatted(params[:so_leavingdate])
       end
       if params[:so_fullfinaldate] !=nil && params[:so_fullfinaldate] !=''
         fnaldate = year_month_days_formatted(params[:so_fullfinaldate])
       end
       params[:so_joiningdate]        = joindate
       params[:so_regularizationdate] = reudate
       params[:so_superannuationdate] = anudate
       params[:so_leavingdate]        = leavedate
       params[:so_fullfinaldate]      = fnaldate
       params[:so_settmentdat]        = seldate
       params[:so_location]           = params[:sw_location]  !=nil && params[:sw_location]  !='' ? params[:sw_location] : 0
       params[:so_sublocation]        = params[:so_sublocation]  !=nil && params[:so_sublocation]  !='' ? params[:so_sublocation] : 0
       params[:so_innote_hr]          = newrnotehrs
       params[:so_outnote_sewdar]     = newrnotesewadar       
       params.permit(:so_compcode,:so_innote_hr,:so_outnote_sewdar,:so_subdepartment,:so_location,:so_sublocation,:so_zone,:so_branch,:so_oldsewdar,:so_biomatriccard,:so_sewcode,:so_desigcode,:so_deprtcode,:so_respcode,:so_qualifcode,:so_joiningdate,:so_regularizationdate,:so_superannuationdate,:so_leavingdate,:so_fullfinaldate,:so_leavingreason)

  end

  #### PROCESS FACILITIES ####
  private
  def upadte_facilities
      compcode            = session[:loggedUserCompCode]
      params[:so_sewcode] = sewacode = params[:sewcode]
      message             = ""
      isflags             = true
      ApplicationRecord.transaction do
       begin
      svuobj =  MstSewadarOfficeInfo.where("so_compcode = ? AND so_sewcode = ?",compcode,sewacode).first
       if svuobj
         svuobj.update(params_facilities)
         message = "Data saved successfully."
         isflags = true       
       end
       rescue Exception => exc
              message   = "#{exc.message}"
              isflags   = false
              #raise ActiveRecord::Rollback
            end
      end
       respond_to do |format|
        format.json { render :json => { 'data'=>'', "message"=>message,:status=>isflags} }
      end
  end

  private
  def params_facilities
       gdate     = 0
       if params[:sp_gyandate] !=nil && params[:sp_gyandate] !=''
          gdate = year_month_days_formatted(params[:sp_gyandate])
       end
       params[:sp_gyandate] = gdate
      params.permit(:so_licgroup,:so_healthinsurance,:so_blessedbrahma,:sp_gyandate)
  end

  ########## PROCESS MAINTAINCE #####
  private
  def update_maiantaince
      compcode            = session[:loggedUserCompCode]
      params[:so_sewcode] = sewacode = params[:sewcode]
      message             = ""
      isflags             = true
	  @allowedsvs         = false
      ApplicationRecord.transaction do
       begin
      svuobj =  MstSewadarOfficeInfo.where("so_compcode = ? AND so_sewcode = ?",compcode,sewacode).first
       if svuobj
         svuobj.update(params_maintaince)
		 save_single_yes_no_list(sewacode,params[:sk_electricconsumption],params[:sk_accomodations],params[:sw_meterno],params[:electexmption],params[:accomoexmption],params[:sk_accomotype])
         save_physical_details(sewacode,params[:sk_prevemployeeid],params[:sk_language],params[:sk_category],params[:sk_physicalissue],params[:sk_internwork])
         message = "Data saved successfully."
         isflags = true
	   else
	      @allowedsvs = true
	      svuobj = MstSewadarOfficeInfo.new(params_maintaince)
		  if svuobj.save
				 save_single_yes_no_list(sewacode,params[:sk_electricconsumption],params[:sk_accomodations],params[:sw_meterno],params[:electexmption],params[:accomoexmption],params[:sk_accomotype])
				 save_physical_details(sewacode,params[:sk_prevemployeeid],params[:sk_language],params[:sk_category],params[:sk_physicalissue],params[:sk_internwork])
				 message = "Data saved successfully."
				 isflags = true
	       end		 
       end
       rescue Exception => exc
              message   = "#{exc.message}"
              isflags   = false
              #raise ActiveRecord::Rollback
            end
      end
       respond_to do |format|
        format.json { render :json => { 'data'=>'', "message"=>message,:status=>isflags} }
      end
  end

  private
  def params_maintaince
       params[:so_basic]           = params[:so_basic] !=nil && params[:so_basic] !='' ? params[:so_basic] : 0
       params[:so_hra]             = params[:so_hra] !=nil && params[:so_hra] !='' ? params[:so_hra] : 0
       params[:so_conveyance]      = params[:so_conveyance] !=nil && params[:so_conveyance] !='' ? params[:so_conveyance] : 0
       params[:so_totalgross]      = params[:so_totalgross] !=nil && params[:so_totalgross] !='' ? params[:so_totalgross] : 0
       params[:so_extrapf]         = params[:so_extrapf] !=nil && params[:so_extrapf] !='' ? params[:so_extrapf] : 0
	  params[:so_compcode]         = session[:loggedUserCompCode]
      params[:so_licgroup]         = params[:licgroup] !=nil && params[:licgroup] !='' ? params[:licgroup] : 'N'
      params[:so_healthinsurance]  = params[:healthgroup] !=nil && params[:healthgroup] !='' ? params[:healthgroup] : 'N'
      params[:so_healthslab]       = params[:slabamt] !=nil && params[:slabamt] !='' ? params[:slabamt] : 0
      params[:so_sewcode]          = params[:so_sewcode]
	  if @allowedsvs
	   params.permit(:so_compcode,:so_sewcode,:so_basic,:so_hra,:so_conveyance,:so_totalgross,:so_pf,:so_pfno,:so_uan,:so_extrapf,:so_settmentdate,:so_esi,:so_esino,:so_dispensary,:so_ot,:so_licgroup,:so_healthinsurance,:so_healthslab)
	  else
	   params.permit(:so_basic,:so_hra,:so_conveyance,:so_totalgross,:so_pf,:so_pfno,:so_uan,:so_extrapf,:so_settmentdate,:so_esi,:so_esino,:so_dispensary,:so_ot,:so_licgroup,:so_healthinsurance,:so_healthslab)
	  end
      
  end

  private
  def save_physical_details(sewcode,sk_prevemployeeid,sk_language,sk_category,sk_physicalissue,sk_internwork)
        compcode = session[:loggedUserCompCode]
        kycobj   = MstSewadarKyc.where("sk_compcode =? AND sk_sewcode = ?",compcode,sewcode).first
        if kycobj
          kycobj.update(:sk_prevemployeeid=>sk_prevemployeeid,:sk_language=>sk_language,:sk_category=>sk_category,:sk_physicalissue=>sk_physicalissue,:sk_internwork=>sk_internwork)
        end
  end
  
  private
  def office_list_details(sewcode,so_blessedbrahma,sp_gyandate1)
         compcode = session[:loggedUserCompCode]
         so_blessedbrahma = so_blessedbrahma !=nil && so_blessedbrahma !='' ? so_blessedbrahma : 0
         sp_gyandate      = sp_gyandate1 !=nil && sp_gyandate1 != '' ? year_month_days_formatted(sp_gyandate1) : 0
         svuobj           = MstSewadarOfficeInfo.where("so_compcode = ? AND so_sewcode = ?",compcode,sewcode).first
        if svuobj          
           svuobj.update(:so_blessedbrahma=>so_blessedbrahma,:sp_gyandate=>sp_gyandate)
        else
            svbsobj = MstSewadarOfficeInfo.new(:so_compcode=>compcode,:so_innote_hr=>'',:so_outnote_sewdar=>'',:so_blessedbrahma=>so_blessedbrahma,:sp_gyandate=>sp_gyandate,:so_location=>0,:so_sublocation=>0,:so_sewcode=>sewcode,:so_joiningdate=>0,:so_regularizationdate=>0,:so_superannuationdate=>0,:so_leavingdate=>0,:so_fullfinaldate=>0,:so_settmentdate=>0)
            svbsobj.save
       end
  end
  ####### END MAINTAINANCE ######

  #### PROCESS KYC ####
    private
    def process_kyc
            sewcode              = params[:sewcode] !=nil && params[:sewcode] !='' ?  params[:sewcode] : ''
            compcode             = session[:loggedUserCompCode]
            message              = ""
            isflags              = true
            
            params[:sbk_sewcode] = sewcode
            if sewcode == nil || sewcode == ''
              return
            end
           
            ApplicationRecord.transaction do
                begin
                  svuobj               = MstSewadarKycBank.where("skb_compcode =? AND sbk_sewcode =?",compcode,sewcode).first
                  if svuobj
                       svuobj.update(bank_params)
                       process_kyc_detail(sewcode)                      
                       message = "Data updated successfully."
                       isflags              = true
                  else
                        mstsevabkobj        = MstSewadarKycBank.new(bank_params)
                        if mstsevabkobj.save
                          process_kyc_detail(sewcode)                         
                         
                           message = "Data saved successfully."
                           isflags              = true
                        end
                  end
                  rescue Exception => exc
                    message   = "#{exc.message}"
                    isflags   = false
                    raise ActiveRecord::Rollback
                  end
            end
            respond_to do |format|
             format.json { render :json => { 'data'=>'', "message"=>message,:status=>isflags} }
           end
    end

   
    private
    def bank_params
        params[:skb_compcode]       = session[:loggedUserCompCode]
        params[:sbk_sewcode]        = params[:sbk_sewcode] !=nil && params[:sbk_sewcode] !='' ?  params[:sbk_sewcode] : ''
        params[:skb_bank]           = params[:skb_bank] !=nil && params[:skb_bank] !='' ?  params[:skb_bank] : ''
        params[:skb_branch]         = params[:skb_branch] !=nil && params[:skb_branch] !='' ?  params[:skb_branch] : ''
        params[:skb_address]        = params[:skb_address] !=nil && params[:skb_address] !='' ?  params[:skb_address] : ''
        params[:skb_accountno]      = params[:skb_accountno] !=nil && params[:skb_accountno] !='' ?  params[:skb_accountno] : ''
        params[:skb_ifccocde]       = params[:skb_ifccocde] !=nil && params[:skb_ifccocde] !='' ?  params[:skb_ifccocde] : ''       
        params.permit(:skb_compcode,:sbk_sewcode,:skb_bank,:skb_branch,:skb_address,:skb_accountno,:skb_ifccocde)
    end

    private
    def process_kyc_detail(sewcode)
          sewcompcode          =  session[:loggedUserCompCode]
          params[:sk_sewcode]  =  sewcode
          sewakyuobj           =  MstSewadarKyc.where("sk_compcode = ? AND sk_sewcode = ?",sewcompcode,sewcode).first
          if sewakyuobj
            sewakyuobj.update(params_kyc_detail)
             ### EXECUTE MESSAGE
          else
             sewkycobj = MstSewadarKyc.new(params_kyc_detail)
              if sewkycobj.save
                ### EXECUTE MESSAGE
              end
          end
    end
    
    private
    def params_kyc_detail
      params[:sk_compcode]        = session[:loggedUserCompCode]
      params[:sk_sewcode]         = params[:sk_sewcode] !=nil && params[:sk_sewcode] !='' ?  params[:sk_sewcode] : ''
      curr_adhar                  = params[:curr_adhar] !=nil && params[:curr_adhar] !='' ? params[:curr_adhar] : ''
      adhar       = ""
      adhardir    = "adhar"
      pancard     = ""
      pandir      = "pan"
      driverlc    = ""
      driverdir   = "driverlnc"
      otherdoc    = ""
      otherdocdir = "otherdoc"
      othdoc2     = ""
      othdoc2dir  = "otherdoc2"
      ### ADHAR DOC PROCESS
       if params[:skadhar] !=nil && params[:skadhar] !=''
            adhar = process_files(params[:skadhar],curr_adhar,adhardir)
       end
       if adhar == nil || adhar == ''
             if curr_adhar !=nil && curr_adhar !=''
               adhar = curr_adhar
             end
       end
       params[:sk_adhar] = adhar
       ## PANCAR DOC PROCESS
       if params[:skpan] !=nil && params[:skpan] !=''
            pancard = process_files(params[:skpan],params[:curr_pan],pandir)
       end
       if pancard == nil || pancard == ''
             if params[:curr_pan] !=nil && params[:curr_pan] !=''
               pancard = params[:curr_pan]
             end
       end
       params[:sk_pan] = pancard
       ## DRIVER LICENCE DOC PROCESS
      if params[:skdlfile] !=nil && params[:skdlfile] !=''
            driverlc = process_files(params[:skdlfile],params[:curr_dl],driverdir)
       end
       if driverlc == nil || driverlc == ''
             if params[:curr_dl] !=nil && params[:curr_dl] !=''
               driverlc = params[:curr_dl]
             end
       end
       params[:sk_drivelicence] = driverlc
       ## OTHER  DOC PROCESS
      if params[:skothdoc] !=nil && params[:skothdoc] !=''
            otherdoc = process_files(params[:skothdoc],params[:curr_otherdoc],othdoc2dir)
       end
       if otherdoc == nil || otherdoc == ''
             if params[:curr_otherdoc] !=nil && params[:curr_otherdoc] !=''
               otherdoc = params[:curr_otherdoc]
             end
       end
       params[:sk_otherdoc] = otherdoc
       ## OTHER  DOC 2 PROCESS
      if params[:skothdoc2] != nil && params[:skothdoc2] != ''
            othdoc2 = process_files(params[:skothdoc2],params[:curr_otherdoc2],otherdocdir)
       end
       if othdoc2 == nil || othdoc2 == ''
             if params[:curr_otherdoc2] !=nil && params[:curr_otherdoc2] !=''
               othdoc2 = params[:curr_otherdoc2]
             end
       end
       params[:sk_otherdoc2]          = othdoc2     
       
      params.permit(:sk_compcode,:sk_sewcode,:sk_adhar,:sk_adharno,:sk_pan,:sk_panno,:sk_drivelicence,:sk_dlnos,:sk_otherdoc,:sk_otherdocno,:sk_otherdoc2,:sk_otherdocno2)
    end
    
   ### PROCESS QUALIFICATION DETAIL
    private
    def process_qualification(sewcode)
       compcodes             = session[:loggedUserCompCode]
       cdir                  = "qualfattch"
       skq_qualtype          = params[:skq_qualtype] !=nil && params[:skq_qualtype]!='' ? params[:skq_qualtype] : ''
       skq_universityboard   = params[:skq_universityboard] !=nil && params[:skq_universityboard] !='' ? params[:skq_universityboard] : 0
       skq_degreedip         = params[:skq_degreedip] !=nil && params[:skq_degreedip] !='' ? params[:skq_degreedip] : 0
       skq_passingyear       = params[:skq_passingyear] !=nil && params[:skq_passingyear] !='' ? params[:skq_passingyear] : ''
       skq_duration          = params[:skq_duration] !=nil && params[:skq_duration] !='' ? params[:skq_duration] : ''
       skq_percenatge        = params[:skq_percenatge] !=nil && params[:skq_percenatge] !='' ? params[:skq_percenatge] : 0
       cur_qlf_attch         = params[:cur_qlf_attch] !=nil && params[:cur_qlf_attch] !='' ? params[:cur_qlf_attch] : ''
       footerid              = params[:qualiffooterid] !=nil && params[:qualiffooterid] !='' ? params[:qualiffooterid] : 0
       counts = 0;
        if params[:skq_attach]!=nil && params[:skq_attach]!=''
             files      = params[:skq_attach]
             skq_attach = process_files(files,cur_qlf_attch,cdir)
        else
             skq_attach = ''
         end
         if skq_attach == nil  || skq_attach == ''
            if cur_qlf_attch !=nil && cur_qlf_attch !=''
              skq_attach = cur_qlf_attch
            end
         end
         if skq_qualtype !=nil && skq_qualtype !=''
             process_save_qualification(compcodes,sewcode,skq_qualtype,skq_universityboard,skq_degreedip,skq_passingyear,skq_duration,skq_percenatge,skq_attach,footerid)
             counts = 1;
         end
         return counts;

  end

    private
    def process_save_qualification(skq_compcode,skq_sewcode,skq_qualtype,skq_universityboard,skq_degreedip,skq_passingyear,skq_duration,skq_percenatge,skq_attach,footerid)
        mstseuobj =   MstSewadarKycQualification.where("skq_compcode =? AND id = ?",skq_compcode,footerid).first
        if mstseuobj
          mstseuobj.update(:skq_sewcode=>skq_sewcode,:skq_qualtype=>skq_qualtype,:skq_universityboard=>skq_universityboard,:skq_degreedip=>skq_degreedip,:skq_passingyear=>skq_passingyear,:skq_duration=>skq_duration,:skq_percenatge=>skq_percenatge,:skq_attach=>skq_attach)
            ## execute message if required
        else
           
            mstsvqlobj = MstSewadarKycQualification.new(:skq_compcode=>skq_compcode,:skq_sewcode=>skq_sewcode,:skq_qualtype=>skq_qualtype,:skq_universityboard=>skq_universityboard,:skq_degreedip=>skq_degreedip,:skq_passingyear=>skq_passingyear,:skq_duration=>skq_duration,:skq_percenatge=>skq_percenatge,:skq_attach=>skq_attach)
            if mstsvqlobj.save
                ## execute message if required
            end
        end
    end
    
   private
  def new_attach_files(files,cnt,curfile)
    file_name     =  files.original_filename  if  ( files !='' &&  files != nil)
    file          =  files.read
    file_type     =  file_name.split('.').last
    new_name_file = Time.now.to_i+cnt.to_i
    new_file_name = "#{new_name_file}." + file_type    
    mypath        = Rails.root.join "public", "images", "qualfattch"
    ######### Upload here ######################
    File.open("#{mypath}/" +new_file_name, "wb")  do |f|
      f.write(file)
    end
    if ( files !='' &&  files != nil)
        if curfile !=nil && curfile !=''
           curpath = Rails.root.join "public", "images", "qualfattch",curfile
           process_unlinks_the_files(curpath)
        end
    end
    return new_file_name
    
  end

  ## PROCESS FAMILY DETAIL
  #

  private
  def save_family_list_detail
      compcodes = session[:loggedUserCompCode]
      sewcode   = params[:sewcode] !=nil && params[:sewcode] !='' ?  params[:sewcode] : ''
      dependent = params[:skf_dependent]
      mid       = params[:familyfooterid]
      isflags   = false
      message   = ""
      
      if sewcode == nil || sewcode == ''
         message = "Sewadar code is required"
      elsif dependent == nil || dependent == ''
         message = "Dependent is required"
      else
          procesdata = process_family_detail()
          if procesdata.to_i >0
              if mid.to_i  >0
                  message = "Data updated successfully."
                  isflags = true
              else
                 message = "Data saved successfully."
                 isflags = true
              end
          end
      end
      stsobj = get_sewadar_kyc_family(compcodes,sewcode)
      if stsobj.length >0

      end

      respond_to do |format|
        format.json { render :json => { 'data'=>stsobj, "message"=>message,:status=>isflags} }
       end


  end



   private
   def process_family_detail
      compcodes       = session[:loggedUserCompCode]
      cdirect         = "docfamily"
      processcount    = 0
      sewcode         = params[:sewcode]!=nil && params[:sewcode]!=nil ? params[:sewcode] : ''
      skf_dependent   = params[:skf_dependent] !=nil && params[:skf_dependent] !='' ? params[:skf_dependent] : ''
      skf_relation    = params[:skf_relation] !=nil && params[:skf_relation] !='' ? params[:skf_relation] : ''
      skf_datebirth   = params[:skf_datebirth] !=nil && params[:skf_datebirth] !='' ? year_month_days_formatted(params[:skf_datebirth]) : ''
      skf_address     = params[:skf_address] !=nil && params[:skf_address] !='' ? params[:skf_address] : ''
      skf_occupation  = params[:skf_occupation] !=nil && params[:skf_occupation] !='' ? params[:skf_occupation] : ''
      skf_nominee     = params[:skf_nominee] !=nil && params[:skf_nominee] !='' ? params[:skf_nominee] : 'N'
      skf_percentage  = params[:skf_percentage] !=nil && params[:skf_percentage] !='' ? params[:skf_percentage] : 0
      skf_nomineebank = params[:skf_nomineebank] !=nil && params[:skf_nomineebank] !='' ? params[:skf_nomineebank] : ''
      skf_optedpolicy = params[:skf_optedpolicy] !=nil && params[:skf_optedpolicy] !='' ? params[:skf_optedpolicy] : ''
      skf_pannumber   = params[:skf_pannumber] !=nil && params[:skf_pannumber] !='' ? params[:skf_pannumber] : ''
      skf_attachment  = params[:skf_attachment] !=nil && params[:skf_attachment] !='' ? params[:skf_attachment] : ''
      currttachment   = params[:currattachment] !=nil && params[:currattachment] !='' ? params[:currattachment] :''
      skf_gender      = params[:skf_gender] !=nil && params[:skf_gender] !='' ? params[:skf_gender] : ''
      footerid        = params[:familyfooterid]  !=nil && params[:familyfooterid] !='' ? params[:familyfooterid] : 0
      skf_married_status    = params[:marriedstatus] !=nil && params[:marriedstatus] !='' ?  params[:marriedstatus] : ''
      skf_working_withsnm   = params[:workingwthsnm] !=nil && params[:workingwthsnm] !='' ?  params[:workingwthsnm] : ''
      skf_working_sewacode  = params[:workingseacode] !=nil && params[:workingseacode] !='' ?  params[:workingseacode] : ''
      skf_family_dependent  = params[:skf_family_dependent] !=nil && params[:skf_family_dependent] !='' ?  params[:skf_family_dependent] : ''
      skf_others            = params[:skf_others] !=nil && params[:skf_others] !='' ?  params[:skf_others] : ''
      skf_university        = params[:skf_university] !=nil && params[:skf_university] !='' ?  params[:skf_university] : 0
      
      
      if skf_attachment !=nil && skf_attachment !=''
            skf_attachment = process_files(skf_attachment,currttachment,cdirect)     
       end
       if skf_attachment == nil || skf_attachment == ''
              if currttachment !=nil && currttachment !=''
                  skf_attachment = currttachment
              end
       end
       
       if skf_dependent !=nil && skf_dependent !=''
           process_save_family(compcodes,sewcode,skf_dependent,skf_relation,skf_datebirth,skf_address,skf_occupation,skf_nominee,skf_percentage,skf_nomineebank,skf_optedpolicy,skf_pannumber,skf_attachment,skf_gender,footerid,skf_married_status,skf_working_withsnm,skf_working_sewacode,skf_family_dependent,skf_others,skf_university)
           processcount +=1
       end
   end
   
   private
   def process_save_family(skf_compcode,skf_sewcode,skf_dependent,skf_relation,skf_datebirth,skf_address,skf_occupation,skf_nominee,skf_percentage,skf_nomineebank,skf_optedpolicy,skf_pannumber,skf_attachment,skf_gender,footerid,skf_married_status,skf_working_withsnm,skf_working_sewacode,skf_family_dependent,skf_otherrelation,skf_university)
            svuobj = MstSewdarKycFamilyDetail.where("skf_compcode =?  AND id = ?",skf_compcode,footerid).first
            if svuobj
                 svuobj.update(:skf_dependent=>skf_dependent,:skf_otherrelation=>skf_otherrelation,:skf_married_status=>skf_married_status,:skf_working_withsnm=>skf_working_withsnm,:skf_working_sewacode=>skf_working_sewacode,:skf_gender=>skf_gender,:skf_pannumber=>skf_pannumber,:skf_attachment=>skf_attachment,:skf_relation=>skf_relation,:skf_datebirth=>skf_datebirth,:skf_address=>skf_address,:skf_occupation=>skf_occupation,:skf_nominee=>skf_nominee,:skf_percentage=>skf_percentage,:skf_nomineebank=>skf_nomineebank,:skf_optedpolicy=>skf_optedpolicy,:skf_family_dependent=>skf_family_dependent,:skf_university=>skf_university)
                 ### SAVE EXECUTE
            else                
                svupobj = MstSewdarKycFamilyDetail.new(:skf_compcode=>skf_compcode,:skf_otherrelation=>skf_otherrelation,:skf_sewcode=>skf_sewcode,:skf_married_status=>skf_married_status,:skf_working_withsnm=>skf_working_withsnm,:skf_working_sewacode=>skf_working_sewacode,:skf_gender=>skf_gender,:skf_dependent=>skf_dependent,:skf_pannumber=>skf_pannumber,:skf_attachment=>skf_attachment,:skf_relation=>skf_relation,:skf_datebirth=>skf_datebirth,:skf_address=>skf_address,:skf_occupation=>skf_occupation,:skf_nominee=>skf_nominee,:skf_percentage=>skf_percentage,:skf_nomineebank=>skf_nomineebank,:skf_optedpolicy=>skf_optedpolicy,:skf_family_dependent=>skf_family_dependent,:skf_university=>skf_university)
                if svupobj.save
                  ### SAVE EXECUTE
                end
          end
   end
  ### END PROCESS KYC ##

   ### PROCESS WORK EXPERIENCE ####
   private
   def process_work_detail
      compcodes = session[:loggedUserCompCode]
      sewcode   = params[:sewcode] !=nil && params[:sewcode] !='' ?  params[:sewcode] : ''
      sewemploy = params[:swe_employer]
      isflags   = false
      message   = ""
      mid       = params[:workexpfooterid]
      if sewcode == nil || sewcode == ''
         message = "Sewadar code is required"
      elsif sewemploy == nil || sewemploy == ''
         message = "Employer is required"
      else
          procesdata = process_work_experience()
          if procesdata.to_i >0
              if mid.to_i  >0
                  message = "Data updated successfully."
                  isflags = true
              else
                 message = "Data saved successfully."
                 isflags = true
              end
          end
      end
      stsobj =  get_sewadar_work_experience(compcodes,sewcode)
      respond_to do |format|
        format.json { render :json => { 'data'=>stsobj, "message"=>message,:status=>isflags} }
       end
   end
   
   private
   def process_work_experience
      compcodes     = session[:loggedUserCompCode]
      sewcode       = params[:sewcode] !=nil && params[:sewcode] !='' ?  params[:sewcode] : ''
      procescount   = 0
      swe_employer          = params[:swe_employer] !=nil && params[:swe_employer] !='' ? params[:swe_employer] : ''
      swe_designation       = params[:swe_designation] !=nil && params[:swe_designation] !='' ? params[:swe_designation] : ''
      swe_responsiblity     = params[:swe_responsiblity] !=nil && params[:swe_responsiblity] !='' ? params[:swe_responsiblity] : ''
      swe_from              = params[:swe_from] !=nil && params[:swe_from] !='' ? params[:swe_from] : ''
      swe_to                = params[:swe_to] !=nil && params[:swe_to] !='' ? params[:swe_to] : ''
      swe_reasonleaving     = params[:swe_reasonleaving] !=nil && params[:swe_reasonleaving] !='' ? params[:swe_reasonleaving] : ''
      swe_retirebenfit      = params[:swe_retirebenfit] !=nil && params[:swe_retirebenfit] !='' ? params[:swe_retirebenfit] : 'N'
      swe_gettingpension    = params[:swe_gettingpension] !=nil && params[:swe_gettingpension] !='' ? params[:swe_gettingpension] : 'N'
      swe_medicalfacilities = params[:swe_medicalfacilities] !=nil && params[:swe_medicalfacilities] !='' ? params[:swe_medicalfacilities] : 'N'
      footerid              = params[:workexpfooterid]
       if swe_employer !=nil && swe_employer !='' && sewcode !=nil && sewcode !=''
           params_save_workexp(compcodes,sewcode,swe_employer,swe_designation,swe_responsiblity,swe_from,swe_to,swe_reasonleaving,swe_retirebenfit,swe_gettingpension,swe_medicalfacilities,footerid)
            procescount +=1
     end
      
     
       return procescount
   end

   private
   def params_save_workexp(swe_compcode,swe_sewcode,swe_employer,swe_designation,swe_responsiblity,swe_from,swe_to,swe_reasonleaving,swe_retirebenfit,swe_gettingpension,swe_medicalfacilities,footerid)
     svuobj = MstSewadarWorkExperience.where("swe_compcode =? AND id =?",swe_compcode,footerid).first
       if svuobj
         svuobj.update(:swe_sewcode=>swe_sewcode,:swe_employer=>swe_employer,:swe_designation=>swe_designation,:swe_responsiblity=>swe_responsiblity,:swe_from=>swe_from,:swe_to=>swe_to,:swe_reasonleaving=>swe_reasonleaving,:swe_retirebenfit=>swe_retirebenfit,:swe_gettingpension=>swe_gettingpension,:swe_medicalfacilities=>swe_medicalfacilities)
          ### EXECUTE MESSAGE
     else
           svsobj = MstSewadarWorkExperience.new(:swe_compcode=>swe_compcode,:swe_sewcode=>swe_sewcode,:swe_employer=>swe_employer,:swe_designation=>swe_designation,:swe_responsiblity=>swe_responsiblity,:swe_from=>swe_from,:swe_to=>swe_to,:swe_reasonleaving=>swe_reasonleaving,:swe_retirebenfit=>swe_retirebenfit,:swe_gettingpension=>swe_gettingpension,:swe_medicalfacilities=>swe_medicalfacilities)
            if svsobj.save
              ### EXECUTE MESSAGE
            end
       end
   end
   
   private
   def save_single_yes_no_list(sewcode,electricconsumption,accomodation,electricmeter,electricexmep,accomodexempt,accomodationtype)
		compcodes        =  session[:loggedUserCompCode]
    electricexmep    =  electricexmep !=nil && electricexmep !='' ? electricexmep : 'N'
    accomodexempt    =  accomodexempt !=nil && accomodexempt !='' ? accomodexempt : 'N'
    accomodationtype =  accomodationtype !=nil && accomodationtype !='' ? accomodationtype : 0
		sewdadobj     =  MstSewadar.where("sw_compcode =? AND sw_sewcode =?",compcodes,sewcode).first
		if sewdadobj
		   sewdadobj.update(:sw_isaccommodation=>accomodation,:sw_accomodationtype=>accomodationtype,:sw_iselectricconsump=>electricconsumption,:sw_meterno=>electricmeter,:sw_electricexemption=>electricexmep,:sw_accomodexemption=>accomodexempt);
		end
   end

   private
   def process_sewa_interal_detail(sewcode,desigcode,departcode,qualifcode,joiningdate,leavingdate,branchtype,locations,so_oldsewdar)
       gdate     = 0
       lvdate    = 0
       locations    = locations !=nil && locations !='' ? locations : 0
       oldsewdar    = so_oldsewdar !=nil && so_oldsewdar !='' ? so_oldsewdar : ''
       if joiningdate.to_s.strip !=nil && joiningdate.to_s.strip !='' && joiningdate.to_s.strip !='0'
         gdate = year_month_days_formatted(joiningdate.to_s.strip)
       end
       if leavingdate.to_s.strip !=nil && leavingdate.to_s.strip !='' && leavingdate.to_s.strip !='0'
        
         lvdate = year_month_days_formatted(leavingdate.to_s.strip)
       end
          compcodes  =  session[:loggedUserCompCode]
          sewdadobj  =  MstSewadar.where("sw_compcode =? AND sw_sewcode =?",compcodes,sewcode).first
          if sewdadobj
            sewdadobj.update(:sw_desigcode=>desigcode,:sw_depcode=>departcode,:sw_qualfcode=>qualifcode,:sw_joiningdate=>gdate,:sw_leavingdate=>lvdate,:sw_branchtype=>branchtype,:sw_location=>locations,:sw_oldsewdarcode=>oldsewdar)
          end
   end

   private
   def get_total_sewa_calculation
       newdate = ''
       isflags = false      
       if params[:joiningdated] != nil && params[:joiningdated] != ''             
              newdate = get_dob_calculate(year_month_days_formatted(params[:joiningdated]))
              isflags = true
       end
        respond_to do |format|
             format.json { render :json => { 'data'=>newdate, "message"=>'',:status=>isflags} }
           end
   end

   private
   def get_birth_date_calculation
       newdate  = ''
       isflags  = false
       myages   = ''
       sewaleft = ""
       if params[:birthdate] !=nil && params[:birthdate] !=''
              
              newdate   = Date.parse(params[:birthdate].to_s)+62.years
              newdate   = format_oblig_date(newdate)
              isflags = true
              myages   = get_dob_calculate(year_month_days_formatted(params[:birthdate]))
              sewaleft = get_dob_calculate(year_month_days_formatted(newdate))
              sewaleft  = sewaleft.to_s.delete("-")
       end
        respond_to do |format|
             format.json { render :json => { 'data'=>newdate, "message"=>'','ages'=>myages,'leftsewa'=>sewaleft,:status=>isflags} }
           end
   end


   private
   def process_sewa_personal_insewdar(sewcode,mobile,email)
       mobile =  mobile !=nil && mobile !='' ? mobile : ''
       email  = email !=nil && email !='' ?  email : ''
          compcodes  =  session[:loggedUserCompCode]
          sewdadobj  =  MstSewadar.where("sw_compcode =? AND sw_sewcode =?",compcodes,sewcode).first
          if sewdadobj
            sewdadobj.update(:sw_mobile=>mobile,:sw_email=>email)
          end
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
   def process_save_existing_qualification
      compcodes = session[:loggedUserCompCode]
      sewcode   = params[:sewcode]
      qltype    = params[:skq_qualtype]
      footerid  = params[:qualiffooterid] !=nil && params[:qualiffooterid] !='' ? params[:qualiffooterid] : 0
      isflags   = false
      message   = ""
      if sewcode !=nil && sewcode != '' && qltype != nil && qltype !=''
            procescount =  process_qualification(sewcode)
            if procescount.to_i >0
              isflags = true
              if footerid.to_i >0
                message = "Data updated sucessfully"
              else
                message = "Data saved sucessfully"
              end
              
            else
              message = "Data could not be processed due to technical issue."
            end
      end
     stesobj = get_sewadar_kyc_qualification(compcodes,sewcode)
     respond_to do |format|
             format.json { render :json => { 'data'=>stesobj,"message"=>message,:status=>isflags} }
       end
   end

   private
   def delete_common_records
      compcodes = session[:loggedUserCompCode]
      sewcode   = params[:sewcode]
      delid     = params[:delid]
      types     = params[:types]
      isflags   = false
      message   = ""
      stesobj   = []
      if types == 'QLF'
            sewdarobj = MstSewadarKycQualification.where("skq_compcode =? AND id = ?",compcodes,delid).first
            if sewdarobj
               attchfile = sewdarobj.skq_attach
               if sewdarobj.destroy
                 if attchfile !=nil && attchfile !=''
                   curpath = Rails.root.join "public", "images", "qualfattch",attchfile
                   process_unlinks_the_files(curpath)
                 end
                  isflags = true
                  message = "Data deleted successfully."
               end
            else
              message = "No record(s) match for delete."
            end
            stesobj = get_sewadar_kyc_qualification(compcodes,sewcode)

      elsif types == 'WEP'
            sewdarobj = MstSewadarWorkExperience.where("swe_compcode =? AND id = ?",compcodes,delid).first
            if sewdarobj
              
               if sewdarobj.destroy                 
                  isflags = true
                  message = "Data deleted successfully."
               end
            else
                  message = "No record(s) match for delete."
            end
            stesobj = get_sewadar_work_experience(compcodes,sewcode)

     elsif types == 'FML'
            sewdarobj = MstSewdarKycFamilyDetail.where("skf_compcode = ? AND id = ?",compcodes,delid).first
            if sewdarobj

               if sewdarobj.destroy
                  isflags = true
                  message = "Data deleted successfully."
               end
            else
                  message = "No record(s) match for delete."
            end
            stesobj = get_sewadar_kyc_family(compcodes,sewcode)

      end
       respond_to do |format|
             format.json { render :json => { 'data'=>stesobj,"message"=>message,:status=>isflags} }
       end
   end

   private
   def get_all_unversity_list
       qualification = params[:qualification]
       isflags       = false
       iswhere       = "un_compcode ='#{@compCodes}' " #AND FIND_IN_SET('#{qualification.to_s.strip}',un_qltype) >0
       unobj         =  MstUniversity.where(iswhere).group("un_description").order("un_description ASC")       
       return unobj       
   end
   private
   def get_unversity_firstrecord(id)       
       iswhere       = "un_compcode ='#{@compCodes}' AND id = '#{id}'" #AND FIND_IN_SET('#{qualification.to_s.strip}',un_qltype) >0
       unobj         =  MstUniversity.where(iswhere).first      
       return unobj       
   end

end
