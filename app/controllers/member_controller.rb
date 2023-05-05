## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for designation
### FOR REST API ######
class MemberController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    helper_method :formatted_date, :format_oblig_date
   def index
      @compCodes       = session[:loggedUserCompCode]
      @ListMembers = get_member_list
      printcontroll    = "1_prt_excel_member_list"
      @printpath       = member_path(printcontroll,:format=>"pdf")
      printpdf         = "1_prt_pdf_member_list"
      @printpdfpath    = member_path(printpdf,:format=>"pdf")
      
      if params[:id] != nil && params[:id] != ''
            ids = params[:id].to_s.split("_")
            if ids[1] == 'prt' && ids[2] == 'excel'
                @ExcelList = print_excel_listed
                send_data @ExcelList.to_generate_member, :filename=> "member_list_#{Date.today}.csv"
                return
            elsif ids[1] == 'prt' && ids[2] == 'pdf'
                @rootUrl  = "#{root_url}"
                dataprint = print_excel_listed
                respond_to do |format|
                     format.html
                     format.pdf do
                        pdf = MemberPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                        send_data pdf.render,:filename => "1_prt_member_report.pdf", :type => "application/pdf", :disposition => "inline"
                     end
                 end
            end
      end
 
   end
 
   def add_member
     @compCodes  =  session[:loggedUserCompCode]
     @cdate = Date.today
     @lastcodes  =  generate_member_series
     @ListSate = MstState.where("sts_compcode =?",@compCodes).order("sts_description ASC")
     @ListDist = nil
     @ListCity = MstCity.where("ct_compcode =?",@compCodes).order("ct_description ASC")
     @ListMember = nil
     if params[:id].to_i >0
         @ListMember  = Member.where("mbr_compcode = ? AND id = ?",@compCodes,params[:id]).first
         if @ListMember              
            @ListDist  = MstDistrict.where("dts_compcode =? AND dts_statecode =?",@compCodes,@ListMember.mbr_state).order("dts_description ASC")
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
   if params[:mbr_code] == '' || params[:mbr_code] == nil
      flash[:error] =  "Member code is required."
      isFlags = false
   elsif params[:mbr_name] == '' || params[:mbr_name] == nil
      flash[:error] =  "Member name is required."
      isFlags = false
    elsif params[:mbr_state] == nil || params[:mbr_state] == ''
        flash[:error] =  "Member state is required."
        isFlags = false
    elsif params[:mbr_city] == nil || params[:mbr_city] == ''
        flash[:error] =  "Member city is required."
        isFlags = false
    elsif params[:mbr_district] == nil || params[:mbr_district] == ''
        flash[:error] =  "Member district is required."
        isFlags = false
    elsif params[:mbr_pincode] == nil || params[:mbr_pincode] == ''
        flash[:error] =  "Member pincode is required."
        isFlags = false
    elsif params[:mbr_mobile] == nil || params[:mbr_mobile] == ''
        flash[:error] =  "Member mobile is required."
        isFlags = false
    elsif params[:mbr_addr_l1] == nil || params[:mbr_address] == ''
        flash[:error] =  "Member address is required."
        isFlags = false
    elsif params[:mbr_email] == nil || params[:mbr_email] == ''
        flash[:error] =  "Member email is required."
        isFlags = false
 
   else
 
     curcode = params[:curmbrcode].to_s.strip
     codes    = params[:mbr_code].to_s.strip
     mobile = params[:mbr_mobile].to_s.strip
     email = params[:mbr_email].to_s.strip
     mid           = params[:mid]
     
     if mid.to_i >0
 
           if curcode.to_s.downcase != codes.to_s.downcase
               @checkmbr   = Member.where("mbr_compcode = ? AND LOWER(mbr_mobile) = ? AND LOWER(mbr_email) = ?",@compCodes,mobile.to_s.downcase,email.to_s.downcase)
               if @checkmbr.length >0
                     flash[:error] = "This Member is already taken!"
                     isFlags       = false
               end
 
           end
             if isFlags
                 chkobj   = Member.where("mbr_compcode = ? AND id = ?",@compCodes,mid).first
                 if chkobj
                   chkobj.update(mbr_params)
                       flash[:error] = "Data updated successfully"
                       isFlags       = true
                       add_logs?(chkobj)
                 end
             end
 
     else
            @checkmbr   = Member.where("mbr_compcode = ? AND LOWER(mbr_mobile) = ? AND LOWER(mbr_email) = ?",@compCodes,mobile.to_s.downcase,email.to_s.downcase)
            if @checkmbr.length >0
                flash[:error] = "This Member is already taken!"
                isFlags       = false
            end
              if isFlags
                    obj = Member.new(mbr_params)
                    if obj.save
                       flash[:error] = "Data saved successfully"
                       isFlags       = true
                       add_logs?(obj)
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
       redirect_to  "#{root_url}member"
     else
       redirect_to  "#{root_url}member/add_member"
     end
   
 end
 
  def destroy
     @compcodes = session[:loggedUserCompCode]
     if params[:id].to_i >0
          @Obj =  Member.where("mbr_compcode =? AND id = ?",@compcodes,params[:id]).first
          if @Obj
 
            @Obj.destroy
            flash[:error] =  "Data deleted successfully."
            isFlags       =  true
            session[:isErrorhandled] = nil
                  
          end
     end
     redirect_to "#{root_url}member"
  end

  def view_logs
    @compcodes = session[:loggedUserCompCode]
    @Member = Member.where("mbr_compcode =? AND id=?",@compcodes,params[:id]).first
    @ListMemberLogs = get_member_logs_list
    
  end
 
 
 private
 def mbr_params
     params[:mbr_compcode]         = session[:loggedUserCompCode]
     params[:mbr_code]         = params[:mbr_code] !=nil && params[:mbr_code] !='' ? params[:mbr_code].to_s.delete(' ').upcase : ''
     params[:mbr_name]   = params[:mbr_name]!=nil && params[:mbr_name] !='' ? params[:mbr_name].to_s.strip : ''
     params[:mbr_status]   = params[:mbr_status]!=nil && params[:mbr_status] !='' ? params[:mbr_status].to_s.strip : ''
     params[:mbr_state] = params[:mbr_state]!=nil && params[:mbr_state] !='' ? params[:mbr_state].to_s.strip : ''
     params[:mbr_city] = params[:mbr_city]!=nil && params[:mbr_city] !='' ? params[:mbr_city].to_s.strip : ''
     params[:mbr_district] = params[:mbr_district]!=nil && params[:mbr_district] !='' ? params[:mbr_district].to_s.strip : ''
     params[:mbr_mobile] = params[:mbr_mobile]!=nil && params[:mbr_mobile] !='' ? params[:mbr_mobile].to_s.strip : ''
     params[:mbr_mobile2] = params[:mbr_mobile2]!=nil && params[:mbr_mobile2] !='' ? params[:mbr_mobile2].to_s.strip : ''
     params[:mbr_email] = params[:mbr_email]!=nil && params[:mbr_email] !='' ? params[:mbr_email].to_s.strip : ''
     params[:mbr_addr_l1] = params[:mbr_addr_l1]!=nil && params[:mbr_addr_l1] !='' ? params[:mbr_addr_l1].to_s.strip : ''
     params[:mbr_addr_l2] = params[:mbr_addr_l2]!=nil && params[:mbr_addr_l2] !='' ? params[:mbr_addr_l2].to_s.strip : ''
     params[:mbr_co_title] = params[:mbr_co_title]!=nil && params[:mbr_co_title] !='' ? params[:mbr_co_title].to_s.strip : ''
     params[:mbr_co_name] = params[:mbr_co_name]!=nil && params[:mbr_co_name] !='' ? params[:mbr_co_name].to_s.strip : ''
     params[:mbr_title] = params[:mbr_title]!=nil && params[:mbr_title] !='' ? params[:mbr_title].to_s.strip : ''     
     params[:mbr_pincode] = params[:mbr_pincode]!=nil && params[:mbr_pincode] !='' ? params[:mbr_pincode].to_s.strip : ''
     params[:mbr_dob] = params[:mbr_dob]!=nil && params[:mbr_dob] !='' ? params[:mbr_dob].to_s.strip : ''
     params[:mbr_education] = params[:mbr_education]!=nil && params[:mbr_education] !='' ? params[:mbr_education].to_s.strip : ''
     params[:mbr_gender] = params[:mbr_gender]!=nil && params[:mbr_gender] !='' ? params[:mbr_gender].to_s.strip : ''
     params[:mbr_occupation] = params[:mbr_occupation]!=nil && params[:mbr_occupation] !='' ? params[:mbr_occupation].to_s.strip : ''
     params[:mbr_pan] = params[:mbr_pan]!=nil && params[:mbr_pan] !='' ? params[:mbr_pan].to_s.strip : ''
     params[:mbr_reason_change] = params[:mbr_reason_change]!=nil && params[:mbr_reason_change] !='' ? params[:mbr_reason_change].to_s.strip : ''
     cityob = MstCity.where("ct_compcode =? AND ct_citycode =?",@compCodes,params[:mbr_city]).first
     distob = MstDistrict.where("dts_compcode =? AND dts_districtcode =?",@compCodes,params[:mbr_district]).first
     stateob = MstState.where("sts_compcode =? AND sts_code =?",@compCodes,params[:mbr_state]).first
     params[:mbr_full_address] = params[:mbr_title] + " " + params[:mbr_name] + " " + params[:mbr_co_title] + " " + params[:mbr_co_name] + " " + params[:mbr_addr_l1] + " " + params[:mbr_addr_l2] + " " + cityob.ct_description + " " + distob.dts_description + " " + stateob.sts_description + " " + params[:mbr_mobile]
     params.permit(:mbr_compcode,:mbr_code,:mbr_name,:mbr_status,:mbr_city,:mbr_state,:mbr_district,:mbr_mobile,:mbr_mobile2,:mbr_full_address,:mbr_email,:mbr_dob,:mbr_education,:mbr_pincode,:mbr_addr_l1,:mbr_addr_l2,:mbr_co_name,:mbr_co_title,:mbr_gender,:mbr_occupation,:mbr_pan,:mbr_reason_change,:mbr_title)
 end
 
 private
   def get_member_list
        if params[:page].to_i >0
          pages = params[:page]
       else
          pages = 1
       end
      if params[:requestserver] !=nil && params[:requestserver] != ''
         session[:req_search_design] = nil
      end
       search_member = params[:search_member] !=nil && params[:search_member] != '' ? params[:search_member].to_s.strip : session[:req_search_design]
       iswhere = "mbr_compcode ='#{@compCodes}'"
       if search_member !=nil && search_member !=''
         iswhere += " AND ( mbr_code LIKE '%#{search_member}%' OR  mbr_name LIKE '%#{search_member}%' OR  mbr_city LIKE '%#{search_member}%' OR  mbr_state LIKE '%#{search_member}%' OR  mbr_district LIKE '%#{search_member}%' ) "
         @search_member = search_member
         session[:req_search_design] = search_member
       end
       stsobj =  Member.where(iswhere).paginate(:page =>pages,:per_page => 10).order("mbr_name ASC")
       return stsobj
   end

   private
   def get_member_logs_list
        
        if params[:page].to_i >0
          pages = params[:page]
       else
          pages = 1
       end
      if params[:requestserver] !=nil && params[:requestserver] != ''
         session[:req_search_design] = nil
      end
       stsobj =  MemberLogs.where("ml_compcode =? AND ml_member_code =?",@compcodes,@Member.mbr_code).paginate(:page =>pages,:per_page => 10).order("created_at DESC")
       return stsobj 
   end
 
   private
   def print_excel_listed
        search_member =  session[:req_search_design]
         iswhere = "mbr_compcode ='#{@compCodes}'"
         if search_member !=nil && search_member !=''
           iswhere += " AND ( mbr_code LIKE '%#{search_member}%' OR  mbr_name LIKE '%#{search_member}%' ) "
           @search_member = search_member
           session[:req_search_design] = search_member
         end
         pdobj =  Member.where(iswhere).order("mbr_name ASC")
         return pdobj
   end
   
  private
 def generate_member_series
   prefixobj    = get_common_prefix('Member')
   @Startx      = prefixobj ? prefixobj.sn_length : ''
   @isCode      = 0
   @recCodes    = Member.select("mbr_code").where(["mbr_compcode = ? AND mbr_code<>''", @compCodes]).last
   if @recCodes
      @isCode1    = @recCodes.mbr_code.to_s.gsub(/[^\d]/, '')
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
        cityobj     = MstCity.where("mbr_code LIKE '%#{text}%'").order("ct_description ASC")
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

  private
  def add_logs?(old)
    compcode = session[:loggedUserCompCode]
    title = old.mbr_reason_change
    description = ""
    old.previous_changes.each do |k,v|
        if k.to_s != "mbr_full_address" && k.to_s != "updated_at" && k.to_s != "mbr_reason_change"  
            description += k.to_s+" => "+v[0].to_s+" TO "+v[1].to_s + " "
        end
    end

    obj = MemberLogs.new(ml_compcode:compcode,ml_title:title,ml_description:description,ml_member_code:old.mbr_code)
    obj.save
  end
   
 
end
 