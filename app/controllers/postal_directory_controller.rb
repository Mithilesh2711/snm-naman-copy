## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for designation
### FOR REST API ######
class PostalDirectoryController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    helper_method :get_state_detail, :get_city_detail, :get_district_detail
   def index
      @compCodes       = session[:loggedUserCompCode]
      @ListPostalDirectories = get_postal_directory_list
      printcontroll    = "1_prt_excel_postal_directory_list"
      @printpath       = postal_directory_path(printcontroll,:format=>"pdf")
      printpdf         = "1_prt_pdf_postal_directory_list"
      @printpdfpath    = postal_directory_path(printpdf,:format=>"pdf")
      
      if params[:id] != nil && params[:id] != ''
            ids = params[:id].to_s.split("_")
            if ids[1] == 'prt' && ids[2] == 'excel'
                @ExcelList = print_excel_listed
                send_data @ExcelList.to_generate_postal_directory, :filename=> "postal_directory_list_#{Date.today}.csv"
                return
            elsif ids[1] == 'prt' && ids[2] == 'pdf'
                @rootUrl  = "#{root_url}"
                dataprint = print_excel_listed
                respond_to do |format|
                     format.html
                     format.pdf do
                        pdf = PostalDirectoryPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                        send_data pdf.render,:filename => "1_prt_postal_directory_report.pdf", :type => "application/pdf", :disposition => "inline"
                     end
                 end
            end
      end
 
   end
 
   def add_postal_directory
     @compCodes  =  session[:loggedUserCompCode]
     @lastcodes  =  generate_postal_directory_series
     @ListSate = MstState.where("sts_compcode =?",@compCodes).order("sts_description ASC")
     @ListDist = nil
     @ListCity = nil
     @ListPostalDirectory = nil
     if params[:id].to_i >0
         @ListPostalDirectory  = MstPostalDirectory.where("pd_compcode = ? AND id = ?",@compCodes,params[:id]).first
         if @ListPostalDirectory              
            @ListDist  = MstDistrict.where("dts_compcode =? AND dts_statecode =?",@compcodes,@ListPostalDirectory.pd_state).order("dts_description ASC")
            @ListCity  = MstCity.where("ct_compcode =? AND ct_districtcode =?",@compcodes,@ListPostalDirectory.pd_district).order("ct_description ASC")
         end
     end
 
   end

   def ajax_process
    @compcodes = session[:loggedUserCompCode]
   if params[:identity] !=nil && params[:identity] !='' && params[:identity] == 'CITY'
        get_district_city
        return false
   elsif params[:identity] !=nil && params[:identity] !='' && params[:identity] == 'DIST'
        get_state_district
        return false
   end
   
end
 
   def create
   @compCodes  =  session[:loggedUserCompCode]
   isFlags     = true
   begin
   if params[:pd_code] == '' || params[:pd_code] == nil
      flash[:error] =  "PostalDirectory code is required."
      isFlags = false
   elsif params[:pd_name] == '' || params[:pd_name] == nil
      flash[:error] =  "PostalDirectory name is required."
      isFlags = false
   elsif params[:pd_country] == nil || params[:pd_country] == ''
        flash[:error] =  "PostalDirectory country is required."
        isFlags = false
    elsif params[:pd_state] == nil || params[:pd_state] == ''
        flash[:error] =  "PostalDirectory state is required."
        isFlags = false
    elsif params[:pd_city] == nil || params[:pd_city] == ''
        flash[:error] =  "PostalDirectory city is required."
        isFlags = false
    elsif params[:pd_district] == nil || params[:pd_district] == ''
        flash[:error] =  "PostalDirectory district is required."
        isFlags = false
    elsif params[:pd_pincode] == nil || params[:pd_pincode] == ''
        flash[:error] =  "PostalDirectory pincode is required."
        isFlags = false
    elsif params[:pd_tehsil] == nil || params[:pd_tehsil] == ''
        flash[:error] =  "PostalDirectory tehsil is required."
        isFlags = false
 
   else
 
     curcode = params[:curpdcode].to_s.strip
     codes    = params[:pd_code].to_s.strip
     state = params[:pd_state].to_s.strip
     city = params[:pd_city].to_s.strip
     district =params[:pd_district].to_s.strip
     country =params[:pd_country].to_s.strip
     mid           = params[:mid]
     
     if mid.to_i >0
 
           if curcode.to_s.downcase != codes.to_s.downcase
               @checkPd   = MstPostalDirectory.where("pd_compcode = ? AND LOWER(pd_country) = ? AND LOWER(pd_state) = ? AND LOWER(pd_district) = ? AND LOWER(pd_city) = ?",@compCodes,country.to_s.downcase,state.to_s.downcase,district.to_s.downcase,city.to_s.downcase)
               if @checkPd.length >0
                     flash[:error] = "This PostalDirectory is already taken!"
                     isFlags       = false
               end
 
           end
             if isFlags
                 chkobj   = MstPostalDirectory.where("pd_compcode = ? AND id = ?",@compCodes,mid).first
                 if chkobj
                   chkobj.update(pd_params)
                       flash[:error] = "Data updated successfully"
                       isFlags       = true
                 end
             end
 
     else
                @checkPd   = MstPostalDirectory.where("pd_compcode = ? AND LOWER(pd_country) = ? AND LOWER(pd_state) = ? AND LOWER(pd_district) = ? AND LOWER(pd_city) = ?",@compCodes,country.to_s.downcase,state.to_s.downcase,district.to_s.downcase,city.to_s.downcase)
                if @checkPd.length >0
                        flash[:error] = "This PostalDirectory is already taken!"
                        isFlags       = false
                end
              if isFlags
                    obj = MstPostalDirectory.new(pd_params)
                    if obj.save
                       flash[:error] = "Data saved successfully"
                       isFlags       = true
                    end
              end
     end
 
   end
 
   if !isFlags
     session[:isErrorhandled] = 1
     
   else
     session[:isErrorhandled] = nil
     session[:postedpamams]   = nil
     isFlags = true
   end
    rescue Exception => exc
        flash[:error] =  "ERROR: #{exc.message}"
        session[:isErrorhandled] = 1
      
        isFlags = false
    end
     if isFlags
       redirect_to  "#{root_url}postal_directory"
     else
       redirect_to  "#{root_url}postal_directory/add_postal_directory"
     end
   
 end
 
  def destroy
     @compcodes = session[:loggedUserCompCode]
     if params[:id].to_i >0
          @Obj =  MstPostalDirectory.where("pd_compcode =? AND id = ?",@compcodes,params[:id]).first
          if @Obj
 
            @Obj.destroy
            flash[:error] =  "Data deleted successfully."
            isFlags       =  true
            session[:isErrorhandled] = nil
                  
          end
     end
     redirect_to "#{root_url}postal_directory"
  end
 
 
 private
 def pd_params
     params[:pd_compcode]         = session[:loggedUserCompCode]
     params[:pd_code]         = params[:pd_code] !=nil && params[:pd_code] !='' ? params[:pd_code].to_s.delete(' ').upcase : ''
     params[:pd_name]   = params[:pd_name]!=nil && params[:pd_name] !='' ? params[:pd_name].to_s.strip : ''
     params[:pd_status]   = params[:pd_status]!=nil && params[:pd_status] !='' ? params[:pd_status].to_s.strip : ''
     params[:pd_state] = params[:pd_state]!=nil && params[:pd_state] !='' ? params[:pd_state].to_s.strip : ''
     params[:pd_country] = params[:pd_country]!=nil && params[:pd_country] !='' ? params[:pd_country].to_s.strip : ''
     params[:pd_city] = params[:pd_city]!=nil && params[:pd_city] !='' ? params[:pd_city].to_s.strip : ''
     params[:pd_district] = params[:pd_district]!=nil && params[:pd_district] !='' ? params[:pd_district].to_s.strip : ''
     params[:pd_tehsil] = params[:pd_tehsil]!=nil && params[:pd_tehsil] !='' ? params[:pd_tehsil].to_s.strip : ''
     params[:pd_pincode] = params[:pd_pincode]!=nil && params[:pd_pincode] !='' ? params[:pd_pincode].to_s.strip : ''
     params.permit(:pd_compcode,:pd_code,:pd_name,:pd_status,:pd_city,:pd_country,:pd_state,:pd_district,:pd_tehsil,:pd_pincode)
 end
 
 private
   def get_postal_directory_list
        if params[:page].to_i >0
          pages = params[:page]
       else
          pages = 1
       end
      if params[:requestserver] !=nil && params[:requestserver] != ''
         session[:req_search_design] = nil
      end
       search_postal_directory = params[:search_postal_directory] !=nil && params[:search_postal_directory] != '' ? params[:search_postal_directory].to_s.strip : session[:req_search_design]
       iswhere = "pd_compcode ='#{@compCodes}'"
       if search_postal_directory !=nil && search_postal_directory !=''
         iswhere += " AND ( pd_code LIKE '%#{search_postal_directory}%' OR  pd_name LIKE '%#{search_postal_directory}% OR  pd_city LIKE '%#{search_postal_directory}% OR  pd_state LIKE '%#{search_postal_directory}% OR  pd_district LIKE '%#{search_postal_directory}% OR  pd_country LIKE '%#{search_postal_directory}%' ) "
         @search_postal_directory = search_postal_directory
         session[:req_search_design] = search_postal_directory
       end
       stsobj =  MstPostalDirectory.where(iswhere).paginate(:page =>pages,:per_page => 10).order("pd_name ASC")
       return stsobj
   end
 
   private
   def print_excel_listed
        search_postal_directory =  session[:req_search_design]
         iswhere = "pd_compcode ='#{@compCodes}'"
         if search_postal_directory !=nil && search_postal_directory !=''
           iswhere += " AND ( pd_code LIKE '%#{search_postal_directory}%' OR  pd_name LIKE '%#{search_postal_directory}%' ) "
           @search_postal_directory = search_postal_directory
           session[:req_search_design] = search_postal_directory
         end
         pdobj =  MstPostalDirectory.where(iswhere).order("pd_name ASC")
         return pdobj
   end
   
  private
 def generate_postal_directory_series
   prefixobj    = get_common_prefix('PostalDirectory')
   @Startx      = prefixobj ? prefixobj.sn_length : ''
   @isCode      = 0
   @recCodes    = MstPostalDirectory.select("pd_code").where(["pd_compcode = ? AND pd_code<>''", @compCodes]).last
   if @recCodes
      @isCode1    = @recCodes.pd_code.to_s.gsub(/[^\d]/, '')
      @isCode     = @isCode1.to_i
 
   end
   @sumXOfCode    = @isCode.to_i + 1
   newlength      = @sumXOfCode.to_s.length
   genleth        = @Startx.to_i-newlength.to_i
   zeroseires     = serial_global_number(genleth)
   @sumXOfCode    = zeroseires.to_s+@sumXOfCode.to_s
   myprefix        = ""
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

 private
 def get_district_city
     statecode = params[:statecode]
     districtcode = params[:districtcode]
     isfalgs  = false
     types     = params[:type]
     cityobj   = []
     if types == 'CITY'
        stobj       = MstState.where("sts_compcode = ? AND sts_statecode = ?",@compcodes,statecode).order("dts_description ASC")
        cityobj     = MstCity.where("ct_compcode = ? AND ct_statecode = ?",@compcodes,stobj.sts_stategstcode).order("ct_description ASC")
        if cityobj
        isfalgs = true
        end
    end
     respond_to do |format|
       format.json { render :json => { 'data'=>cityobj, "message"=>'',:status=>isfalgs} }
    end
    
 end

 private
  def get_state_district
     statecode = params[:statecode]
     types     = params[:type]
     arrttem   = []
     cityobj   = []
     if types == 'DIST'
        isfalgs  = false
        # stobj       = MstState.where("sts_compcode = ? AND sts_statecode = ?",@compcodes,statecode).order("dts_description ASC")
        disobj     = MstDistrict.where("dts_compcode = ? AND dts_statecode = ?",@compcodes,statecode).order("dts_description ASC")
        # cityobj    = MstCity.where("ct_compcode = ? AND ct_statecode = ?",@compcodes,stobj.sts_stategstcode).order("ct_description ASC")
        if disobj
          arrttem = disobj
          isfalgs = true
        end
     end
      respond_to do |format|
        format.json { render :json => { 'data'=>arrttem,'cities'=>cityobj, "message"=>'',:status=>isfalgs} }
     end

  end
   
 
end
 