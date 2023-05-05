class ZoneDistrictController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  helper_method :get_zone_name_detail
   
 def index
   @compcodes      = session[:loggedUserCompCode]
   @filter_search  = nil
   @Listdistrict   = get_district_list
   printcontroll   = "1_prt_excel_zone_district_list"
   @printpath      = zone_district_path(printcontroll,:format=>"pdf")
   printpdf        = "1_prt_pdf_zone_district_list"
   @printpdfpath   = zone_district_path(printpdf,:format=>"pdf")
    @ExcelList = nil
   if params[:id] != nil && params[:id] != ''
       ids = params[:id].to_s.split("_")
       if ids[1] == 'prt' && ids[2] == 'excel'
           $arreitems = print_excel_listed
           send_data @ExcelList.to_generate_zone_district, :filename=> "zone_district_list-#{Date.today}.csv"
           return
       elsif  ids[1] == 'prt' && ids[2] == 'pdf'
              @rootUrl  = "#{root_url}"
               dataprint = print_excel_listed
               respond_to do |format|
                    format.html
                    format.pdf do
                       pdf = ZonedistrictPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                       send_data pdf.render,:filename => "1_prt_zone_district_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                end
       end
   end
   
  end
  def add_zone_district
     @compcodes  = session[:loggedUserCompCode]
     @ListZone   = MstZone.where("zn_compcode = ?",@compcodes).order("zn_name ASC")
     @lastNumber = generate_district_zones_series()
     @ListDist = nil
     if params[:id].to_i >0
       @ListDist = MstZoneDistrict.where("zd_compcode = ? AND id = ?",@compcodes,params[:id]).first
     end


end
  
  def create
     @compcodes = session[:loggedUserCompCode]
    isFlags    = true
    begin
        if params[:zd_zonecode] == nil || params[:zd_zonecode] == ''
           flash[:error] =  "Zone code is required."
           isFlags = false
        elsif params[:zd_distcode] == nil || params[:zd_distcode] == ''
           flash[:error] =  "Zone district code is required."
           isFlags = false
        elsif   params[:zd_name] == nil || params[:zd_name] == ''
           flash[:error] =  "Zone name is required."
           isFlags = false
        else
            mid        = params[:mid]
            cdistcode  = params[:cur_description].to_s.strip
            zonecode   = params[:zd_zonecode].to_s.strip
            zonename   = params[:zd_name].to_s.strip
            
            if mid.to_i >0
                  if cdistcode.to_s.downcase != zonename.to_s.downcase

                       chkstate = MstZoneDistrict.where("zd_compcode =? AND LOWER(zd_zonecode) = ? AND LOWER(zd_name) = ?",@compcodes,zonecode.to_s.downcase,zonename.to_s.downcase)
                       if chkstate.length >0
                            flash[:error] =  "Entered district name is already taken."
                            isFlags = false
                       end
                  end
                  if isFlags
                     stateupobj  = MstZoneDistrict.where("zd_compcode =? AND id = ?",@compcodes,mid).first
                      if stateupobj
                           stateupobj.update(district_params)
                           flash[:error] =  "Data updated successfully."
                            isFlags = true
                      end
                  end
            else
                      chkstate = MstZoneDistrict.where("zd_compcode =? AND LOWER(zd_zonecode) = ? AND LOWER(zd_name) = ?",@compcodes,zonecode.to_s.downcase,zonename.to_s.downcase)
                       if chkstate.length >0
                            flash[:error] =  "Entered district name is already taken."
                            isFlags = false
                       end
                       if isFlags
                            stsobj = MstZoneDistrict.new(district_params)
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
      redirect_to "#{root_url}"+"zone_district"
     else
        redirect_to "#{root_url}"+"zone_district/add_zone_district"
     end
      
  end
  
  def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         @ListSate =  MstZoneDistrict.where("zd_compcode =? AND id = ?",@compcodes,params[:id]).first
         if @ListSate
                 @ListSate.destroy
                 flash[:error] =  "Data deleted successfully."
                 isFlags       = true
                 session[:isErrorhandled] = nil
              
         end
    end
    redirect_to "#{root_url}zone_district"
 end

  private
  def district_params
    params[:zd_compcode]          = session[:loggedUserCompCode]
    params[:zd_zonecode]          = params[:zd_zonecode] !=nil && params[:zd_zonecode] !='' ? params[:zd_zonecode].to_s.strip : ''   
    params[:zd_name]              = params[:zd_name] !=nil && params[:zd_name] !='' ? params[:zd_name].to_s.strip : ''
    if params[:mid].to_i >0
       params[:zd_distcode]       = params[:zd_distcode] !=nil && params[:zd_distcode] !='' ? params[:zd_distcode].to_s.strip : ''
    else
       params[:zd_distcode]       = generate_district_zones_series
    end
    params.permit(:zd_compcode,:zd_zonecode,:zd_distcode,:zd_name)
  end

  private
  def get_district_list
        if params[:page].to_i >0
        pages = params[:page]
        else
        pages = 1
        end
      if params[:requestserver]!=nil && params[:requestserver]!= ''
         session[:req_zone_district] = nil
      end
      filter_search = params[:zone_district] !=nil && params[:zone_district] != '' ? params[:zone_district].to_s.strip : session[:req_zone_district].to_s.strip
      iswhere = "zd_compcode ='#{@compcodes}'"
      if filter_search !=nil && filter_search !=''
        iswhere +=" AND ( zd_distcode LIKE '%#{filter_search}%' OR zd_name LIKE '%#{filter_search}%' )"
        @zone_district = filter_search
        session[:req_zone_district] = filter_search
      end

      stsobj =  MstZoneDistrict.where(iswhere).paginate(:page =>pages,:per_page => 10).order("zd_distcode ASC")
      return stsobj
  end

 private
 def print_excel_listed
   filter_search  = session[:req_zone_district]
    iswhere = "zd_compcode ='#{@compcodes}'"
   if filter_search !=nil && filter_search !=''
      iswhere +=" AND ( zd_distcode LIKE '%#{filter_search}%' OR zd_name LIKE '%#{filter_search}%' )"
    end
    arrprod = []
    stsobj =  MstZoneDistrict.select("mst_zone_districts.*,'' as myzones").where(iswhere).order("zd_distcode ASC")
    if stsobj.length >0
      @ExcelList = stsobj
          stsobj.each do |newdist|
             zoneobj = get_zone_name_detail(newdist.zd_zonecode)
              if zoneobj
                 newdist.myzones = zoneobj.zn_name
              end
            arrprod.push newdist
          end

     end
   
    return arrprod
    
 end
private
def generate_district_zones_series
  prefixobj    = get_common_prefix('ZoneDsitrict')
  @Startx      = prefixobj ? prefixobj.sn_length : ''
  @isCode      = 0
  @recCodes    = MstZoneDistrict.select("zd_distcode").where(["zd_compcode = ? AND zd_distcode<>''", @compcodes]).last
  if @recCodes
     @isCode1    = @recCodes.zd_distcode.to_s.gsub(/[^\d]/, '')
     @isCode     = @isCode1.to_i

  end
  @sumXOfCode    = @isCode.to_i + 1
  newlength      = @sumXOfCode.to_s.length
  genleth        = @Startx.to_i-newlength.to_i
  zeroseires     = serial_global_number(genleth)
  @sumXOfCode    = zeroseires.to_s+@sumXOfCode.to_s
  myprefix  = ""
  if prefixobj
      myprefix = prefixobj.sn_prefix
  end
  if myprefix !=nil && myprefix !=''
    myprefix = myprefix.to_s+@sumXOfCode.to_s
  else
    myprefix = @sumXOfCode
  end
  return myprefix

end



end
