class ZoneController < ApplicationController
	before_action :require_login
   before_action :allowed_security
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  def index
    @compcodes = session[:loggedUserCompCode]
   @ListZones       = get_zone_list
   printcontroll   = "1_prt_excel_zone_list"
   @printpath     = zone_path(printcontroll,:format=>"pdf")
   printpdf        = "1_prt_pdf_zone_list"
   @printpdfpath   = zone_path(printpdf,:format=>"pdf")
   if params[:id] != nil && params[:id] != ''
       ids = params[:id].to_s.split("_")
       if ids[1] == 'prt' && ids[2] == 'excel'
         print_excel_listed
         send_data @ExcelList.to_generate_zone, :filename=> "zone-list-#{Date.today}.csv"
         return
       elsif ids[1] == 'prt' && ids[2] == 'pdf'
              @rootUrl  = "#{root_url}"
               dataprint = print_excel_listed
               respond_to do |format|
                    format.html
                    format.pdf do
                       pdf = ZonePdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                       send_data pdf.render,:filename => "1_prt_zone_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                end
       end
   end

  end
  
  def add_zone
     @compcodes    = session[:loggedUserCompCode]
     @lastnumber   = generate_zones_series
     @ListDepart   = nil
     @ZonalBranch  = nil
     @ZonalAddress = nil
     if params[:id].to_i >0
          @ListDepart  = MstZone.where("zn_compcode = ? AND id = ?",@compcodes,params[:id]).first
          if @ListDepart
            @ZonalBranch   =  MstBranch.where("bch_compcode =? AND bch_zonecode = ?",@compcodes,@ListDepart.zn_zonecode).order("bch_branchname ASC")
            @ZonalAddress  =  MstBranch.select("bch_branchcode,bch_branchname,bch_address").where(["bch_compcode = ? AND bch_branchcode = ?", @compcodes,@ListDepart.zn_zoneoffice]).first
          end
          
     end
end

def create
    @compcodes = session[:loggedUserCompCode]
    isFlags    = true
    begin
        if params[:zn_zonecode] == nil || params[:zn_zonecode] == ''
           flash[:error] =  "Zone code is required."
           isFlags = false
        elsif params[:zn_number] == nil || params[:zn_number] == ''
           flash[:error] =  "Zone number is required."
           isFlags = false
       elsif params[:zn_name] == nil || params[:zn_name] == ''
           flash[:error] =  "Zone name is required."
           isFlags = false
        elsif   params[:zn_inchmobile] == nil || params[:zn_inchmobile] == ''
           flash[:error] =  "Mobile number is required."
           isFlags = false
        else
            mid          = params[:mid]
            zonnumber    = params[:zn_number].to_s.strip
            czonenumber   = params[:cur_description].to_s.strip
            

            if mid.to_i >0
                  if zonnumber.to_s.downcase != czonenumber.to_s.downcase
                       zoneobj = MstZone.where("zn_compcode =? AND LOWER(zn_number) = ?",@compcodes,zonnumber.to_s.downcase)
                       if zoneobj.length >0
                            flash[:error] =  "Entered zone number is already taken."
                            isFlags = false
                       end
                  end
                  if isFlags
                     stateupobj  = MstZone.where("zn_compcode =? AND id = ?",@compcodes,mid).first
                      if stateupobj
                           stateupobj.update(zone_params)
                           flash[:error] =  "Data updated successfully."
                            isFlags = true
                      end
                  end
            else
                       zoneobj = MstZone.where("zn_compcode =? AND LOWER(zn_number) = ?",@compcodes,zonnumber.to_s.downcase)
                       if zoneobj.length >0
                            flash[:error] =  "Entered zone number is already taken."
                            isFlags = false
                       end
                       if isFlags
                            stsobj = MstZone.new(zone_params)
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
         session[:request_zonnumber] = params
         session[:isErrorhandled] = 1
         isFlags = false
     else
         session[:request_params] = nil
         session[:isErrorhandled] = nil
         session.delete(:request_params)
     end
     if isFlags
       redirect_to "#{root_url}"+"zone"
     else
       redirect_to "#{root_url}"+"zone/add_zone"
     end

end
 

 def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         @ListZone =  MstZone.where("zn_compcode =? AND id = ?",@compcodes,params[:id]).first
         if @ListZone
              @ListZone.destroy
              flash[:error] =  "Data deleted successfully."
              isFlags       = true
              session[:isErrorhandled] = nil
         end
    end
    redirect_to "#{root_url}zone"
 end


private
  def zone_params
    params[:zn_compcode]         = session[:loggedUserCompCode]    
    params[:zn_number]           = params[:zn_number] !=nil && params[:zn_number] !='' ? params[:zn_number] : ''
    params[:zn_name]             = params[:zn_name] !=nil && params[:zn_name] !='' ? params[:zn_name] : ''
    params[:zn_incharge]         = params[:zn_incharge] !=nil && params[:zn_incharge] !='' ? params[:zn_incharge] : ''
    params[:zn_inchmobile]       = params[:zn_inchmobile] !=nil && params[:zn_inchmobile] !='' ? params[:zn_inchmobile] : ''
    if params[:mid].to_i >0
       params[:zn_zonecode]      = params[:zn_zonecode] !=nil && params[:ct_statecode] !='' ? params[:zn_zonecode] : ''
    else
       params[:zn_zonecode]      = generate_zones_series
    end
    params.permit(:zn_compcode,:zn_zonecode,:zn_number,:zn_name,:zn_incharge,:zn_inchmobile,:zn_addcontact,:zn_landlineno,:zn_inchargaddress,:zn_inchargesnm_email,:zn_zone_email,:zn_zoneoffice)

  end

private
  def get_zone_list
      if params[:page].to_i >0
           pages = params[:page]
      else
          pages = 1
      end
      if params[:requestserver] != nil && params[:requestserver] != ''
          session[:req_search_zones]    = nil
      end
  
      search_zone  = params[:search_zone] !=nil && params[:search_zone] != '' ? params[:search_zone] :  session[:req_search_zones]
      iswhere   = "zn_compcode ='#{@compcodes}'"
      if search_zone != nil && search_zone !=''
          iswhere +=" AND ( zn_zonecode LIKE '%#{search_zone}%' OR zn_number  LIKE '%#{search_zone}%' OR zn_name  LIKE '%#{search_zone}%' )"
          @search_zone               = search_zone
         session[:req_search_zones]  =  search_zone
      end
    
      stsobj =  MstZone.where(iswhere).paginate(:page =>pages,:per_page => 10).order("zn_zonecode ASC")
      return stsobj
  end
  
  private
  def print_excel_listed
      search_zone  = session[:req_search_zones]
      iswhere      = "zn_compcode ='#{@compcodes}'"
      if search_zone != nil && search_zone !=''
          iswhere +=" AND ( zn_zonecode LIKE '%#{search_zone}%' OR zn_number  LIKE '%#{search_zone}%' OR zn_name  LIKE '%#{search_zone}%' )"          
      end
      stsobj =  MstZone.where(iswhere).order("zn_zonecode ASC")
      if stsobj.length >0
        @ExcelList = stsobj
      end
      return stsobj
  end

private
def generate_zones_series
  prefixobj    = get_common_prefix('Zone')
  @Startx      = prefixobj ? prefixobj.sn_length : ''
  @isCode      = 0
  @recCodes    = MstZone.select("zn_zonecode").where(["zn_compcode = ? AND zn_zonecode<>''", @compcodes]).last
  if @recCodes
     @isCode1    = @recCodes.zn_zonecode.to_s.gsub(/[^\d]/, '')
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
