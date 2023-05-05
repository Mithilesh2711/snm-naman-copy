## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for designation
### FOR REST API ######
class IndividualHeadController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    helper_method :get_state_detail, :get_city_detail, :get_district_detail
   def index
      @compCodes       = session[:loggedUserCompCode]
      @ListIndividualHeads = get_individual_head_list
      printcontroll    = "1_prt_excel_individual_head_list"
      @printpath       = individual_head_path(printcontroll,:format=>"pdf")
      printpdf         = "1_prt_pdf_individual_head_list"
      @printpdfpath    = individual_head_path(printpdf,:format=>"pdf")
      
      if params[:id] != nil && params[:id] != ''
            ids = params[:id].to_s.split("_")
            if ids[1] == 'prt' && ids[2] == 'excel'
                @ExcelList = print_excel_listed
                send_data @ExcelList.to_generate_individual_head, :filename=> "individual_head_list_#{Date.today}.csv"
                return
            elsif ids[1] == 'prt' && ids[2] == 'pdf'
                @rootUrl  = "#{root_url}"
                dataprint = print_excel_listed
                respond_to do |format|
                     format.html
                     format.pdf do
                        pdf = IndividualHeadPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                        send_data pdf.render,:filename => "1_prt_individual_head_report.pdf", :type => "application/pdf", :disposition => "inline"
                     end
                 end
            end
      end
 
   end
 
   def add_individual_head
     @compCodes  =  session[:loggedUserCompCode]
     @lastcodes  =  generate_individual_head_series
     @ListSate = MstState.where("sts_compcode =?",@compCodes).order("sts_description ASC")
     @ListDist = nil
     @ListCity = MstCity.where("ct_compcode =?",@compCodes).order("ct_description ASC")
     @ListDM = MstDispatchMode.where("dm_compcode =?",@compCodes).order("dm_name ASC")
     @ListDT = MstDispatchType.where("dt_compcode =?",@compCodes).order("dt_name ASC")
     @ListIndividualHead = nil
     if params[:id].to_i >0
         @ListIndividualHead  = MstIndividualHead.where("ih_compcode = ? AND id = ?",@compCodes,params[:id]).first
         if @ListIndividualHead              
            @ListDist  = MstDistrict.where("dts_compcode =? AND dts_statecode =?",@compcodes,@ListIndividualHead.ih_state).order("dts_description ASC")
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
   if params[:ih_code] == '' || params[:ih_code] == nil
      flash[:error] =  "IndividualHead code is required."
      isFlags = false
   elsif params[:ih_name] == '' || params[:ih_name] == nil
      flash[:error] =  "IndividualHead name is required."
      isFlags = false
   elsif params[:ih_country] == nil || params[:ih_country] == ''
        flash[:error] =  "IndividualHead country is required."
        isFlags = false
    elsif params[:ih_state] == nil || params[:ih_state] == ''
        flash[:error] =  "IndividualHead state is required."
        isFlags = false
    elsif params[:ih_city] == nil || params[:ih_city] == ''
        flash[:error] =  "IndividualHead city is required."
        isFlags = false
    elsif params[:ih_district] == nil || params[:ih_district] == ''
        flash[:error] =  "IndividualHead district is required."
        isFlags = false
    elsif params[:ih_pincode] == nil || params[:ih_pincode] == ''
        flash[:error] =  "IndividualHead pincode is required."
        isFlags = false
    elsif params[:ih_phone] == nil || params[:ih_phone] == ''
        flash[:error] =  "IndividualHead phone is required."
        isFlags = false
    elsif params[:ih_mobile] == nil || params[:ih_mobile] == ''
        flash[:error] =  "IndividualHead mobile is required."
        isFlags = false
    elsif params[:ih_address] == nil || params[:ih_address] == ''
        flash[:error] =  "IndividualHead address is required."
        isFlags = false
    elsif params[:ih_email] == nil || params[:ih_email] == ''
        flash[:error] =  "IndividualHead email is required."
        isFlags = false
    elsif params[:ih_dispatch_mode] == nil || params[:ih_dispatch_mode] == ''
        flash[:error] =  "IndividualHead dispatch mode is required."
        isFlags = false
    elsif params[:ih_dispatch_type] == nil || params[:ih_dispatch_type] == ''
        flash[:error] =  "IndividualHead dispatch type is required."
        isFlags = false
 
   else
 
     curcode = params[:curihcode].to_s.strip
     codes    = params[:ih_code].to_s.strip
     mobile = params[:ih_mobile].to_s.strip
     email = params[:ih_email].to_s.strip
     mid           = params[:mid]
     
     if mid.to_i >0
 
           if curcode.to_s.downcase != codes.to_s.downcase
               @checkIh   = MstIndividualHead.where("ih_compcode = ? AND LOWER(ih_mobile) = ? AND LOWER(ih_email) = ?",@compCodes,mobile.to_s.downcase,email.to_s.downcase)
               if @checkIh.length >0
                     flash[:error] = "This IndividualHead is already taken!"
                     isFlags       = false
               end
 
           end
             if isFlags
                 chkobj   = MstIndividualHead.where("ih_compcode = ? AND id = ?",@compCodes,mid).first
                 if chkobj
                   chkobj.update(ih_params)
                       flash[:error] = "Data updated successfully"
                       isFlags       = true
                 end
             end
 
     else
            @checkIh   = MstIndividualHead.where("ih_compcode = ? AND LOWER(ih_mobile) = ? AND LOWER(ih_email) = ?",@compCodes,mobile.to_s.downcase,email.to_s.downcase)
            if @checkIh.length >0
                flash[:error] = "This IndividualHead is already taken!"
                isFlags       = false
            end
              if isFlags
                    obj = MstIndividualHead.new(ih_params)
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
       redirect_to  "#{root_url}individual_head"
     else
       redirect_to  "#{root_url}individual_head/add_individual_head"
     end
   
 end
 
  def destroy
     @compcodes = session[:loggedUserCompCode]
     if params[:id].to_i >0
          @Obj =  MstIndividualHead.where("ih_compcode =? AND id = ?",@compcodes,params[:id]).first
          if @Obj
 
            @Obj.destroy
            flash[:error] =  "Data deleted successfully."
            isFlags       =  true
            session[:isErrorhandled] = nil
                  
          end
     end
     redirect_to "#{root_url}individual_head"
  end
 
 
 private
 def ih_params
     params[:ih_compcode]         = session[:loggedUserCompCode]
     params[:ih_code]         = params[:ih_code] !=nil && params[:ih_code] !='' ? params[:ih_code].to_s.delete(' ').upcase : ''
     params[:ih_name]   = params[:ih_name]!=nil && params[:ih_name] !='' ? params[:ih_name].to_s.strip : ''
     params[:ih_status]   = params[:ih_status]!=nil && params[:ih_status] !='' ? params[:ih_status].to_s.strip : ''
     params[:ih_state] = params[:ih_state]!=nil && params[:ih_state] !='' ? params[:ih_state].to_s.strip : ''
     params[:ih_country] = params[:ih_country]!=nil && params[:ih_country] !='' ? params[:ih_country].to_s.strip : ''
     params[:ih_city] = params[:ih_city]!=nil && params[:ih_city] !='' ? params[:ih_city].to_s.strip : ''
     params[:ih_district] = params[:ih_district]!=nil && params[:ih_district] !='' ? params[:ih_district].to_s.strip : ''
     params[:ih_mobile] = params[:ih_mobile]!=nil && params[:ih_mobile] !='' ? params[:ih_mobile].to_s.strip : ''
     params[:ih_phone] = params[:ih_phone]!=nil && params[:ih_phone] !='' ? params[:ih_phone].to_s.strip : ''
     params[:ih_email] = params[:ih_email]!=nil && params[:ih_email] !='' ? params[:ih_email].to_s.strip : ''
     params[:ih_address] = params[:ih_address]!=nil && params[:ih_address] !='' ? params[:ih_address].to_s.strip : ''
     params[:ih_dispatch_mode] = params[:ih_dispatch_mode]!=nil && params[:ih_dispatch_mode] !='' ? params[:ih_dispatch_mode].to_s.strip : ''
     params[:ih_dispatch_type] = params[:ih_dispatch_type]!=nil && params[:ih_dispatch_type] !='' ? params[:ih_dispatch_type].to_s.strip : ''
     params[:ih_pincode] = params[:ih_pincode]!=nil && params[:ih_pincode] !='' ? params[:ih_pincode].to_s.strip : ''
     params.permit(:ih_compcode,:ih_code,:ih_name,:ih_status,:ih_city,:ih_country,:ih_state,:ih_district,:ih_mobile,:ih_address,:ih_phone,:ih_email,:ih_dispatch_mode,:ih_dispatch_type,:ih_pincode)
 end
 
 private
   def get_individual_head_list
        if params[:page].to_i >0
          pages = params[:page]
       else
          pages = 1
       end
      if params[:requestserver] !=nil && params[:requestserver] != ''
         session[:req_search_design] = nil
      end
       search_individual_head = params[:search_individual_head] !=nil && params[:search_individual_head] != '' ? params[:search_individual_head].to_s.strip : session[:req_search_design]
       iswhere = "ih_compcode ='#{@compCodes}'"
       if search_individual_head !=nil && search_individual_head !=''
         iswhere += " AND ( ih_code LIKE '%#{search_individual_head}%' OR  ih_name LIKE '%#{search_individual_head}% OR  ih_city LIKE '%#{search_individual_head}% OR  ih_state LIKE '%#{search_individual_head}% OR  ih_district LIKE '%#{search_individual_head}% OR  ih_country LIKE '%#{search_individual_head}%' ) "
         @search_individual_head = search_individual_head
         session[:req_search_design] = search_individual_head
       end
       stsobj =  MstIndividualHead.where(iswhere).paginate(:page =>pages,:per_page => 10).order("ih_name ASC")
       return stsobj
   end
 
   private
   def print_excel_listed
        search_individual_head =  session[:req_search_design]
         iswhere = "ih_compcode ='#{@compCodes}'"
         if search_individual_head !=nil && search_individual_head !=''
           iswhere += " AND ( ih_code LIKE '%#{search_individual_head}%' OR  ih_name LIKE '%#{search_individual_head}%' ) "
           @search_individual_head = search_individual_head
           session[:req_search_design] = search_individual_head
         end
         pdobj =  MstIndividualHead.where(iswhere).order("ih_name ASC")
         return pdobj
   end
   
  private
 def generate_individual_head_series
   prefixobj    = get_common_prefix('IndividualHead')
   @Startx      = prefixobj ? prefixobj.sn_length : ''
   @isCode      = 0
   @recCodes    = MstIndividualHead.select("ih_code").where(["ih_compcode = ? AND ih_code<>''", @compCodes]).last
   if @recCodes
      @isCode1    = @recCodes.ih_code.to_s.gsub(/[^\d]/, '')
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
        cityobj     = MstCity.where("ih_code LIKE '%#{text}%'").order("ct_description ASC")
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
 