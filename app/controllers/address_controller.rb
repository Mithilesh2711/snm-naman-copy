## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for designation
### FOR REST API ######
class AddressController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    helper_method :formatted_date, :format_oblig_date
   def index
      @compCodes       = session[:loggedUserCompCode]
      @ListAddresses = get_address_list
      printcontroll    = "1_prt_excel_address_list"
      @printpath       = address_path(printcontroll,:format=>"pdf")
      printpdf         = "1_prt_pdf_address_list"
      @printpdfpath    = address_path(printpdf,:format=>"pdf")
      
      if params[:id] != nil && params[:id] != ''
            ids = params[:id].to_s.split("_")
            if ids[1] == 'prt' && ids[2] == 'excel'
                @ExcelList = print_excel_listed
                send_data @ExcelList.to_generate_address, :filename=> "address_list_#{Date.today}.csv"
                return
            elsif ids[1] == 'prt' && ids[2] == 'pdf'
                @rootUrl  = "#{root_url}"
                dataprint = print_excel_listed
                respond_to do |format|
                     format.html
                     format.pdf do
                        pdf = AddressPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                        send_data pdf.render,:filename => "1_prt_address_report.pdf", :type => "application/pdf", :disposition => "inline"
                     end
                 end
            end
      end
 
   end
 
   def add_address
     @compCodes  =  session[:loggedUserCompCode]
     @cdate = Date.today
     @lastcodes  =  generate_address_series
     @ListSate = MstState.where("sts_compcode =?",@compCodes).order("sts_description ASC")
     @ListDist = nil
     @ListCity = MstCity.where("ct_compcode =?",@compCodes).order("ct_description ASC")
     @ListMember = Member.where("mbr_compcode =?",@compCodes).order("mbr_name ASC")
     @ListAddress = nil
     if params[:id].to_i >0
         @ListAddress  = MstAddress.where("adr_compcode = ? AND id = ?",@compCodes,params[:id]).first
         if @ListAddress              
            @ListDist  = MstDistrict.where("dts_compcode =? AND dts_statecode =?",@compCodes,@ListAddress.adr_state).order("dts_description ASC")
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
    elsif params[:identity] !=nil && params[:identity] !='' && params[:identity] == 'SEARCHCITY'
        get_city
        return false
   end
   
end
 
   def create
   @compCodes  =  session[:loggedUserCompCode]
   isFlags     = true
   begin
   if params[:adr_code] == '' || params[:adr_code] == nil
      flash[:error] =  "Address code is required."
      isFlags = false
   elsif params[:adr_name] == '' || params[:adr_name] == nil
      flash[:error] =  "Address name is required."
      isFlags = false
    elsif params[:adr_country] == '' || params[:adr_country] == nil
        flash[:error] =  "Address country is required."
        isFlags = false
    elsif params[:adr_state] == nil || params[:adr_state] == ''
        flash[:error] =  "Address state is required."
        isFlags = false
    elsif params[:adr_city] == nil || params[:adr_city] == ''
        flash[:error] =  "Address city is required."
        isFlags = false
    elsif params[:adr_district] == nil || params[:adr_district] == ''
        flash[:error] =  "Address district is required."
        isFlags = false
    elsif params[:adr_pincode] == nil || params[:adr_pincode] == ''
        flash[:error] =  "Address pincode is required."
        isFlags = false
    elsif params[:adr_line1] == nil || params[:adr_line1] == ''
        flash[:error] =  "Address line is required."
        isFlags = false
 
   else
 
     curcode = params[:curadrcode].to_s.strip
     codes    = params[:adr_code].to_s.strip
     member = params[:adr_membercode].to_s.strip
     name = params[:adr_name].to_s.strip
     mid           = params[:mid]
     
     if mid.to_i >0
 
           if curcode.to_s.downcase != codes.to_s.downcase
               @checkadr   = MstAddress.where("adr_compcode = ? AND LOWER(adr_membercode) = ? AND LOWER(adr_name) = ?",@compCodes,member.to_s.downcase,name.to_s.downcase)
               if @checkadr.length >0
                     flash[:error] = "This Address is already taken!"
                     isFlags       = false
               end
 
           end
             if isFlags
                 chkobj   = MstAddress.where("adr_compcode = ? AND id = ?",@compCodes,mid).first
                 if chkobj
                   chkobj.update(adr_params)
                       flash[:error] = "Data updated successfully"
                       isFlags       = true
                 end
             end
 
     else
            @checkadr   = MstAddress.where("adr_compcode = ? AND LOWER(adr_membercode) = ? AND LOWER(adr_name) = ?",@compCodes,member.to_s.downcase,name.to_s.downcase)
            if @checkadr.length >0
                flash[:error] = "This Address is already taken!"
                isFlags       = false
            end
              if isFlags
                    obj = MstAddress.new(adr_params)
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
       redirect_to  "#{root_url}address"
     else
       redirect_to  "#{root_url}address/add_address"
     end
   
 end
 
  def destroy
     @compcodes = session[:loggedUserCompCode]
     if params[:id].to_i >0
          @Obj =  MstAddress.where("adr_compcode =? AND id = ?",@compcodes,params[:id]).first
          if @Obj
 
            @Obj.destroy
            flash[:error] =  "Data deleted successfully."
            isFlags       =  true
            session[:isErrorhandled] = nil
                  
          end
     end
     redirect_to "#{root_url}address"
  end

 
 
 private
 def adr_params
     params[:adr_compcode]         = session[:loggedUserCompCode]
     params[:adr_code]         = params[:adr_code] !=nil && params[:adr_code] !='' ? params[:adr_code].to_s.delete(' ').upcase : ''
     params[:adr_name]   = params[:adr_name]!=nil && params[:adr_name] !='' ? params[:adr_name].to_s.strip : ''
     params[:adr_status]   = params[:adr_status]!=nil && params[:adr_status] !='' ? params[:adr_status].to_s.strip : ''
     params[:adr_state] = params[:adr_state]!=nil && params[:adr_state] !='' ? params[:adr_state].to_s.strip : ''
     params[:adr_city] = params[:adr_city]!=nil && params[:adr_city] !='' ? params[:adr_city].to_s.strip : ''
     params[:adr_district] = params[:adr_district]!=nil && params[:adr_district] !='' ? params[:adr_district].to_s.strip : ''
     params[:adr_mobile] = params[:adr_mobile]!=nil && params[:adr_mobile] !='' ? params[:adr_mobile].to_s.strip : ''
     params[:adr_email] = params[:adr_email]!=nil && params[:adr_email] !='' ? params[:adr_email].to_s.strip : ''
     params[:adr_line1] = params[:adr_line1]!=nil && params[:adr_line1] !='' ? params[:adr_line1].to_s.strip : ''
     params[:adr_line2] = params[:adr_line2]!=nil && params[:adr_line2] !='' ? params[:adr_line2].to_s.strip : ''
     params[:adr_country] = params[:adr_country]!=nil && params[:adr_country] !='' ? params[:adr_country].to_s.strip : ''
     params[:adr_membercode] = params[:adr_membercode]!=nil && params[:adr_membercode] !='' ? params[:adr_membercode].to_s.strip : ''
     params[:adr_pincode] = params[:adr_pincode]!=nil && params[:adr_pincode] !='' ? params[:adr_pincode].to_s.strip : ''     
     cityob = MstCity.where("ct_compcode =? AND ct_citycode =?",@compCodes,params[:adr_city]).first
     distob = MstDistrict.where("dts_compcode =? AND dts_districtcode =?",@compCodes,params[:adr_district]).first
     stateob = MstState.where("sts_compcode =? AND sts_code =?",@compCodes,params[:adr_state]).first
     params[:adr_fulladdress] = params[:adr_line1] + " " + params[:adr_line2] + " " + cityob.ct_description + " " + distob.dts_description + " " + stateob.sts_description + " " + params[:adr_country] + " " + params[:adr_mobile]
     params.permit(:adr_compcode,:adr_code,:adr_name,:adr_status,:adr_city,:adr_state,:adr_district,:adr_mobile,:adr_country,:adr_fulladdress,:adr_email,:adr_membercode,:adr_line1,:adr_line2,:adr_pincode)
 end
 
 private
   def get_address_list
        if params[:page].to_i >0
          pages = params[:page]
       else
          pages = 1
       end
      if params[:requestserver] !=nil && params[:requestserver] != ''
         session[:req_search_design] = nil
      end
       search_address = params[:search_address] !=nil && params[:search_address] != '' ? params[:search_address].to_s.strip : session[:req_search_design]
       iswhere = "adr_compcode ='#{@compCodes}'"
       if search_address !=nil && search_address !=''
         iswhere += " AND ( adr_code LIKE '%#{search_address}%' OR  adr_name LIKE '%#{search_address}%' OR  adr_city LIKE '%#{search_address}%' OR  adr_state LIKE '%#{search_address}%' OR  adr_district LIKE '%#{search_address}%' ) "
         @search_address = search_address
         session[:req_search_design] = search_address
       end
       stsobj =  MstAddress.where(iswhere).paginate(:page =>pages,:per_page => 10).order("adr_name ASC")
       return stsobj
   end
 
   private
   def print_excel_listed
        search_address =  session[:req_search_design]
         iswhere = "adr_compcode ='#{@compCodes}'"
         if search_address !=nil && search_address !=''
           iswhere += " AND ( adr_code LIKE '%#{search_address}%' OR  adr_name LIKE '%#{search_address}%' ) "
           @search_address = search_address
           session[:req_search_design] = search_address
         end
         pdobj =  MstAddress.where(iswhere).order("adr_name ASC")
         return pdobj
   end
   
  private
 def generate_address_series
   prefixobj    = get_common_prefix('Address')
   @Startx      = prefixobj ? prefixobj.sn_length : ''
   @isCode      = 0
   @recCodes    = MstAddress.select("adr_code").where(["adr_compcode = ? AND adr_code<>''", @compCodes]).last
   if @recCodes
      @isCode1    = @recCodes.adr_code.to_s.gsub(/[^\d]/, '')
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
 def get_city
     text = params[:text]
     isfalgs  = false
     types     = params[:type]
     cityobj   = []
     if types == 'SEARCHCITY'
        cityobj     = MstCity.where("ct_citycode LIKE '%#{text}%'").order("ct_description ASC")
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
 