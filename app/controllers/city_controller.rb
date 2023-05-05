class CityController < ApplicationController
  before_action :require_login
   before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted
 def index
   @compcodes      = session[:loggedUserCompCode]
   @Listdistrict   = get_city_list
   printcontroll   = "1_prt_excel_city_list"
   @printpath     = city_path(printcontroll,:format=>"pdf")
   printpdf        = "1_prt_pdf_city_list"
   @printpdfpath   = city_path(printpdf,:format=>"pdf")
   if params[:id] != nil && params[:id] != ''
       ids = params[:id].to_s.split("_")
       if ids[1] == 'prt' && ids[2] == 'excel'
         print_excel_listed
         send_data @ExcelList.to_generate_city, :filename=> "city-list-#{Date.today}.csv"
         return
       elsif ids[1] == 'prt' && ids[2] == 'pdf'
              @rootUrl  = "#{root_url}"
               dataprint = print_excel_listed
               respond_to do |format|
                    format.html
                    format.pdf do
                       pdf = CityPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                       send_data pdf.render,:filename => "1_prt_city_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                end
       end
   end
   
  end
  
 def add_city
     @compcodes = session[:loggedUserCompCode]
     @ListSate  = MstState.where("sts_compcode =?",@compcodes).order("sts_description ASC")
     @DistList  = nil
     @ListDist  = nil
     if params[:id].to_i >0
            @ListDist     = MstCity.where("ct_compcode = ? AND id = ?",@compcodes,params[:id]).first
            if @ListDist              
               @DistList  = MstDistrict.where("dts_compcode =? AND dts_statecode =?",@compcodes,@ListDist.ct_statecode).order("dts_description ASC")
            end
     end

end
 
def ajax_process
   @compcodes = session[:loggedUserCompCode]
  if params[:identity]!=nil && params[:identity]!= '' && params[:identity] == 'Y'
    get_district_code()
    return
  elsif params[:identity]!=nil && params[:identity]!= '' && params[:identity] == 'TBS'
    get_sublocation_tab()
    return
   elsif params[:identity]!=nil && params[:identity]!= '' && params[:identity] == 'DTBS'
    get_department_tab()
    return
  elsif params[:identity]!=nil && params[:identity]!= '' && params[:identity] == 'SWDPT'
    get_all_sewdar_by_department()
    return
  elsif params[:identity]!=nil && params[:identity]!= '' && params[:identity] == 'SPWD'
    get_generated_password()
    return
  elsif params[:identity]!=nil && params[:identity]!= '' && params[:identity] == 'DIST'
    get_district_city_by_state()
    return
  elsif params[:identity]!=nil && params[:identity]!= '' && params[:identity] == 'ADDACOT'
    process_accomodtion_type()
    return
  elsif params[:identity]!=nil && params[:identity]!= '' && params[:identity] == 'DELACCD'
    process_delete_accomodtion_type()
    return
  elsif params[:identity]!=nil && params[:identity]!= '' && params[:identity] == 'ZNBRCH'
    get_all_branch_by_branch()
    return
  elsif params[:identity]!=nil && params[:identity]!= '' && params[:identity] == 'BRCHSEWA'
    get_all_sewadar_by_branches()
    return
  elsif params[:identity]!=nil && params[:identity]!= '' && params[:identity] == 'MEMCOD'
    get_all_coordinator_ec_member()
    return
  elsif params[:identity]!=nil && params[:identity]!= '' && params[:identity] == 'DMY'
    get_months_years_selection()
    return
  end




end

  def create
     @compcodes = session[:loggedUserCompCode]
    isFlags    = true
    begin
        if params[:ct_statecode] == nil || params[:ct_statecode] == ''
           flash[:error] =  "State code is required."
           isFlags = false
        elsif params[:ct_districtcode] == nil || params[:ct_districtcode] == ''
           flash[:error] =  "District code is required."
           isFlags = false
       elsif params[:ct_citycode] == nil || params[:ct_citycode] == ''
           flash[:error] =  "City code is required."
           isFlags = false
        elsif   params[:ct_description] == nil || params[:ct_description] == ''
           flash[:error] =  "City name is required."
           isFlags = false
        else
            mid          = params[:mid]
            curcitycode  = params[:cur_dist_code].to_s.strip
            citycode     = params[:dts_districtcode].to_s.strip
            statecode    = params[:dts_statecode].to_s.strip
            districtcode = params[:dts_statecode].to_s.strip
            
            if mid.to_i >0
                  if curcitycode.to_s.downcase != citycode.to_s.downcase

                       chekcity = MstCity.where("ct_compcode =? AND LOWER(ct_statecode) = ? AND LOWER(ct_districtcode) = ? AND LOWER(ct_citycode) = ?",@compcodes,statecode.to_s.downcase,districtcode.to_s.downcase,citycode.to_s.downcase)
                       if chekcity.length >0
                            flash[:error] =  "Entered city code is already taken."
                            isFlags = false
                       end
                  end
                  if isFlags
                     stateupobj  = MstCity.where("ct_compcode =? AND id = ?",@compcodes,mid).first
                      if stateupobj
                           stateupobj.update(city_params)
                           flash[:error] =  "Data updated successfully."
                            isFlags = true
                      end
                  end
            else
                      chekcity = MstCity.where("ct_compcode =? AND LOWER(ct_statecode) = ? AND LOWER(ct_districtcode) = ? AND LOWER(ct_citycode) = ?",@compcodes,statecode.to_s.downcase,districtcode.to_s.downcase,citycode.to_s.downcase)
                       if chekcity.length >0
                            flash[:error] =  "Entered city code is already taken."
                            isFlags = false
                       end
                       if isFlags
                            stsobj = MstCity.new(city_params)
                            if stsobj.save
                               flash[:error] =  "Data saved successfully."
                               isFlags = true
                            end

                       end
            end
        end
          rescue Exception => exc
          flash[:error] =   "#{exc.message}"
          session[:isErrorhandled] = 1
          isFlags = false
      end

     if !isFlags
         session[:request_params] = params
         session[:isErrorhandled] = 1
         isFlags = false
     else
         session[:request_params] = nil
         session[:isErrorhandled] = nil
         session.delete(:request_params)
     end
     if isFlags
       redirect_to "#{root_url}"+"city"
     else
       redirect_to "#{root_url}"+"city/add_city"
     end
      
  end

  def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         @ListCity =  MstCity.where("ct_compcode =? AND id = ?",@compcodes,params[:id]).first
         if @ListCity
              @ListCity.destroy
              flash[:error] =  "Data deleted successfully."
              isFlags       = true
              session[:isErrorhandled] = 1
         end
    end
    redirect_to "#{root_url}city"
 end

  private
  def city_params
    params[:ct_compcode]          = session[:loggedUserCompCode]
    params[:ct_statecode]         = params[:ct_statecode] !=nil && params[:ct_statecode] !='' ? params[:ct_statecode] : ''
    params[:ct_districtcode]      = params[:ct_districtcode] !=nil && params[:ct_districtcode] !='' ? params[:ct_districtcode] : ''
    params[:ct_citycode]          = params[:ct_citycode] !=nil && params[:ct_citycode] !='' ? params[:ct_citycode] : ''
    params[:ct_description]       = params[:ct_description] !=nil && params[:ct_description] !='' ? params[:ct_description] : ''
    params.permit(:ct_compcode,:ct_statecode,:ct_districtcode,:ct_citycode,:ct_description)
    
  end

  private
  def get_city_list
     if params[:page].to_i >0
    pages = params[:page]
  else
     pages = 1
  end
  if params[:requestserver] != nil && params[:requestserver] != ''
      session[:req_search_state]    = nil
      session[:req_search_district] = nil
      session[:req_search_city]     = nil
  end
  search_state    = params[:search_state] !=nil && params[:search_state] != '' ? params[:search_state] : session[:req_search_state]
  search_district = params[:search_district] !=nil && params[:search_district] != '' ? params[:search_district] : session[:req_search_district]
  search_city     = params[:search_city] !=nil && params[:search_city] != '' ? params[:search_city] : session[:req_search_city]
  iswhere   = "ct_compcode='#{@compcodes}'"
    if search_state != nil && search_state !=''
        iswhere +=" AND ct_statecode LIKE '%#{search_state}%'"
        @search_state = search_state
       session[:req_search_state] =  search_state
    end
    if search_district != nil && search_district !=''
        iswhere +=" AND ct_districtcode LIKE '%#{search_district}%'"
        @search_district = search_district
       session[:req_search_district] =  search_district
    end
    if search_city != nil && search_city !=''
        iswhere +=" AND ct_districtcode LIKE '%#{search_city}%'"
        @search_city    = search_city
        session[:req_search_city] =  search_city
    end
      stsobj =  MstCity.where(iswhere).paginate(:page =>pages,:per_page => 10).order("ct_description ASC")
      return stsobj
  end
  
  private
  def get_district_code
      statecode = params[:statecode]
      isfalgs  = false
      disobj     = MstDistrict.where("dts_compcode = ? AND dts_statecode = ?",@compcodes,statecode).order("dts_districtcode ASC")
      if disobj
        isfalgs = true
      end
      respond_to do |format|
        format.json { render :json => { 'data'=>disobj, "message"=>'',:status=>isfalgs} }
     end
     
  end

  private
  def get_district_city_by_state
     statecode = params[:statecode]
     types     = params[:type]
     arrttem   = []
     cityobj   = []
     if types == 'DIST'
        isfalgs  = false
        disobj     = MstDistrict.where("dts_compcode = ? AND dts_statecode = ?",@compcodes,statecode).order("dts_description ASC")
        cityobj    = MstCity.where("ct_compcode = ? AND ct_statecode = ?",@compcodes,statecode).order("ct_description ASC")
        if disobj
          arrttem = disobj
          isfalgs = true
        end
     end
      respond_to do |format|
        format.json { render :json => { 'data'=>arrttem,'cities'=>cityobj, "message"=>'',:status=>isfalgs} }
     end

  end

   private
  def get_sublocation_tab
     tabsname = params[:tabsname]
      isfalgs = false
      if tabsname != nil && tabsname !=''
        session[:requested_tabname] = tabsname.to_s.strip
        isfalgs = true
      end
      respond_to do |format|
        format.json { render :json => { 'data'=>'', "message"=>'',:status=>isfalgs} }
     end

  end

  private
  def get_department_tab
     tabsname = params[:tabsname]
      isfalgs = false
      if tabsname != nil && tabsname !=''
        session[:requested_dpt_tab] = tabsname.to_s.strip
        isfalgs = true
      end
      respond_to do |format|
        format.json { render :json => { 'data'=>'', "message"=>'',:status=>isfalgs} }
     end

  end
  
  private
  def get_all_sewdar_by_department
     departcode = params[:departcode]
      isfalgs   = false
      sewdobj      = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode =? AND sw_depcode = ?",@compcodes, departcode).order("sw_sewadar_name ASC")
      if sewdobj.length >0
        isfalgs = true
      end
      respond_to do |format|
        format.json { render :json => { 'data'=>sewdobj, "message"=>'',:status=>isfalgs} }
     end

  end

  private
  def get_generated_password
      gpassword = params[:Gepassw]
      isfalgs   = false
      gpassord  = ""
      if gpassword != nil && gpassword !=''
          gpassord =  _random_string_(10)
          isfalgs = true
      end
      respond_to do |format|
        format.json { render :json => { 'data'=>gpassord, "message"=>'',:status=>isfalgs} }
     end

  end


  private
  def print_excel_listed
    
  search_state    =  session[:req_search_state]
  search_district =  session[:req_search_district]
  search_city     =  session[:req_search_city]
  
  iswhere   = "ct_compcode='#{@compcodes}'"
    if search_state != nil && search_state !=''
        iswhere +=" AND ct_statecode LIKE '%#{search_state}%'"
        
    end
    if search_district != nil && search_district !=''
        iswhere +=" AND ct_districtcode LIKE '%#{search_district}%'"
       
    end
    if search_city != nil && search_city !=''
        iswhere +=" AND ct_districtcode LIKE '%#{search_city}%'"
        
    end
      arrs   = []
      isselect = "'' as statename,'' as distname,mst_cities.*"
      stsobj =  MstCity.select(isselect).where(iswhere).order("ct_description ASC")
      if stsobj.length >0
        @ExcelList = stsobj
          stsobj.each do |newst|
             stsobj = get_state_detail(newst.ct_statecode)
              if stsobj
                newst.statename = stsobj.sts_description
              end
              disobj = get_district_detail(newst.ct_districtcode)
              if disobj
                newst.distname = disobj.dts_description
              end
              arrs.push newst
          end
      end
      return arrs
  end

  private
  def process_accomodtion_type
      mid        = params[:mid]
      descripts  = params[:description].to_s.strip
      prevdecrip = params[:prevsdescrip].to_s.strip
      isfalgs = true
      
      if mid.to_i >0
         
         if descripts.to_s.downcase != prevdecrip.to_s.downcase
                mstaccobj  = MstAccomodationType.where("at_compcode =? AND LOWER(at_description) = ?",@compcodes,descripts.to_s.downcase)
                if mstaccobj.length >0
                  message ="This type name is already taken."
                  isfalgs = false
                end
         end
         if isfalgs
             mstxaccobj  = MstAccomodationType.where("at_compcode =? AND id = ?",@compcodes,mid).first
              if mstxaccobj
                mstxaccobj.update(:at_description=>descripts)
                  message ="Data updated successfully."
                  isfalgs = true
              end
         end
      else
                mstaccobj  = MstAccomodationType.where("at_compcode =? AND LOWER(at_description) = ?",@compcodes,descripts.to_s.downcase)
                if mstaccobj.length >0
                  message ="This type name is already taken."
                  isfalgs = false
                end

                if isfalgs
                    svsobj = MstAccomodationType.new(:at_compcode=>@compcodes,:at_description=>descripts)
                     if svsobj.save
                        message ="Data saved successfully."
                        isfalgs = true
                     end
                end
      end
      gpassord  = MstAccomodationType.where("at_compcode =?",@compcodes).order("at_description ASC")
      respond_to do |format|
        format.json { render :json => { 'data'=>gpassord, "message"=>message,:status=>isfalgs} }
     end

  end
   private
  def process_delete_accomodtion_type
      mid        = params[:mid]
      isfalgs    = true
      message    = ""
      if mid.to_i >0
           chkdelobj = MstAccomodationDetail.where("ad_compcode =? AND ad_accomodtype = ?",@compcodes,mid)
           if chkdelobj.length >0
                 message = "Could not be deleted due to used in accomodation."
                 isfalgs = false
           end
           if isfalgs
                delobhs  = MstAccomodationType.where("at_compcode =? AND id = ?",@compcodes,mid).first
                if delobhs
                     delobhs.destroy
                     message = "Data deleted successfully."
                     isfalgs = true
                end
           end
      end      
      gpassord  = MstAccomodationType.where("at_compcode =?",@compcodes).order("at_description ASC")
      respond_to do |format|
        format.json { render :json => { 'data'=>gpassord, "message"=>message,:status=>isfalgs} }
      end
  end

  private
  def get_all_branch_by_branch
      zonecode   = params[:zonecode]
      isfalgs    = false
      zoneobj    = MstBranch.where("bch_compcode = ? AND bch_zonecode = ?",@compcodes,zonecode).order("bch_branchname ASC")
      if zoneobj.length >0
         isfalgs = true
      end
      respond_to do |format|
        format.json { render :json => { 'data'=>zoneobj, "message"=>'',:status=>isfalgs} }
     end

  end

  private
  def get_all_sewadar_by_branches
      brccode      = params[:brccode].to_s.strip
      isfalgs      = false
      sewdobj      = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode =? AND sw_branchtype = 'Branch'",@compcodes).order("sw_sewadar_name ASC")
      if sewdobj.length >0
         isfalgs = true
      end
      respond_to do |format|
        format.json { render :json => { 'data'=>sewdobj, "message"=>'',:status=>isfalgs} }
      end

  end

  private
  def get_all_coordinator_ec_member
         ectype   = params[:type].to_s.strip
         if( ectype.to_s == 'ec' )
               ectype = 'EC'
               ecobjs = MstLedger.where("lds_compcode =? AND lds_type=?",@compcodes,ectype).order("lds_name ASC")
         elsif( ectype.to_s == 'cod' )
             ecobjs = MstLedger.where("lds_compcode =? AND lds_type<>'ec'",@compcodes).order("lds_name ASC")
              ectype = 'Cordinators'
         end
         
       
       if ecobjs.length >0
         isfalgs = true
       end

     respond_to do |format|
        format.json { render :json => { 'data'=>ecobjs, "message"=>'',:status=>isfalgs} }
      end
  end

  private
  def get_months_years_selection
      years      = params[:years]
      months     = params[:months]
      enddated   = ""
      startdated = ""
      isfalgs    = false
      if years.to_i >0 && months.to_i >0
          isfalgs = true
          if months.to_i == 1  
              yrsx        = years.to_i-1     
              startdated  = "26-12-"+yrsx.to_s
          else
              monthsx     = months.to_i-1 
              monthsx     = monthsx.to_s.length<2 ? "0"+monthsx.to_s : monthsx    
              startdated  = "26-"+monthsx.to_s+"-"+years.to_s 
          end
          monthss  = months.to_s.length<2 ? "0"+months.to_s : months
          enddated = "25-"+monthss.to_s+"-"+years.to_s
     end
      respond_to do |format|
        format.json { render :json => { 'enddated'=>formatted_date(enddated),'startdated'=>formatted_date(startdated), "message"=>'',:status=>isfalgs} }
      end
  end
  
end
