class DisciplineController < ApplicationController

    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_sewdar_designation_detail,:get_all_department_detail,:get_ho_location,:get_global_office_detail
    helper_method :set_dct,:set_ent,:get_personal_information,:get_office_information,:get_roles_information,:format_oblig_date,:get_university_deegre_listed,:get_my_selected_department_code
    helper_method :get_sewa_all_department,:get_sewa_all_qualification,:get_sewa_all_rolesresp,:get_sewa_all_designation,:get_first_my_sewadar,:get_subs_location
    helper_method :get_mysewdar_list_details
    def index
   @compCodes         = session[:loggedUserCompCode]
   @mydepartcode      = ''
   @ElectricList    = nil
   @lastEntryNo       = last_entry_no
   @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
   @printPath          = "all_formats/1_common_report.pdf"
   mydeprtcode        = ""
    if session[:sec_sewdar_code] != nil
          sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
          if sewobjs
              @mydepartcode = sewobjs.sw_depcode
              mydeprtcode   = sewobjs.sw_depcode
          end
      end
 if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
  
     @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment ='' AND departCode = ? ",@compCodes,mydeprtcode).order("departDescription ASC")
     if session[:requestuser_loggedintp].to_s == 'swd'
       @Allsewobj         = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")
     else
       @Allsewobj         = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_depcode = ?",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")
     end

 else
      @markedAllowed    = true
      @markedFieldAlw   = true
      @sewDepart        = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compCodes).order("departDescription ASC")
      @Allsewobj        = [] #MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode =?",@compCodes).order("sw_sewadar_name ASC")
 end
 
    ########### EDIT CASES ONLY ##########
     if params[:id].to_i >0
          @ElectricList    = TrnDiscipline.where("dsp_compcode =? AND id = ?",@compCodes,params[:id].to_i).first
      
          if @ElectricList
              departobj = get_department_detail(@ElectricList.ec_department)
              if departobj
                @myadminstrator = departobj.departDescription
              end
          end
      end

   @ListDispline = get_list_discipline

     
  end

def add_discipline

    @compCodes         = session[:loggedUserCompCode]
   @mydepartcode      = ''
   @ElectricList    = nil
   @lastEntryNo       = last_entry_no
   @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
   @printPath          = "all_formats/1_common_report.pdf"
   mydeprtcode        = ""
 if session[:sec_sewdar_code] != nil
       sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
       if sewobjs
           @mydepartcode = sewobjs.sw_depcode
           mydeprtcode   = sewobjs.sw_depcode
       end
  end
 if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
  
     @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment ='' AND departCode = ? ",@compCodes,mydeprtcode).order("departDescription ASC")
     if session[:requestuser_loggedintp].to_s == 'swd'
       @Allsewobj         = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")
     else
       @Allsewobj         = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_depcode = ?",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")
     end

 else
      @markedAllowed    = true
      @markedFieldAlw   = true
      @sewDepart        = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compCodes).order("departDescription ASC")
      @Allsewobj        = [] #MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode =?",@compCodes).order("sw_sewadar_name ASC")
 end
 
    ########### EDIT CASES ONLY ##########
     if params[:id].to_i >0
       @ElectricList    = TrnDiscipline.where("dsp_compcode =? AND id = ?",@compCodes,params[:id].to_i).first
   
       if @ElectricList
           departobj = get_department_detail(@ElectricList.ec_department)
           if departobj
             @myadminstrator = departobj.departDescription
           end
       end
   end

   



   
end
 def ajax_process
    @compcodes       = session[:loggedUserCompCode]
    if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
       session[:reqtypes] = params[:types]
       session[:req_sewdarcode] = params[:sewacode]
       respond_to do |format|
         format.json { render :json => { 'data'=>'', "message"=>'',:status=>true} }
       end
      return
   end

end


def create
    @compcodes = session[:loggedUserCompCode]
   isFlags    = true
   lastid     = 0
   mid           = params[:mid]
   ApplicationRecord.transaction do
     begin
         if params[:dsp_reqno] == nil || params[:dsp_reqno] == ''
            flash[:error] =  "Entry no is required."
            isFlags = false
         elsif params[:dsp_depcode] == nil || params[:dsp_depcode] == ''
            flash[:error] =  "Department is required."
            isFlags = false
         elsif params[:dsp_date] == nil || params[:dsp_date] == ''
            flash[:error] =  "Discipline Date is required."
            isFlags = false             
       elsif params[:dsp_empcode] == nil || params[:dsp_empcode] == ''
            flash[:error] =  "Sewadar code is required."
            isFlags = false
       
         else
             
             hrmonths      = params[:hrmonths]
             hryears       = params[:hryears]
             sewcode       = params[:dsp_empcode]
             if mid.to_i >0
                   
                   if isFlags
                      stateupobj  = TrnDiscipline.where("dsp_compcode =? AND id = ?",@compcodes,mid).first
                       if stateupobj
                            stateupobj.update(electric_params)
                             flash[:error] = "Data updated successfully."
                             isFlags       = true
                       end
                   end
           
                  end
                      
                        if isFlags
                             @stsobj = TrnDiscipline.new(electric_params)
                             if @stsobj.save  
                                                  lastid = @stsobj.id.to_i
                                session[:requested_lastid] = lastid
                                flash[:error] =  "Data saved successfully."
                                isFlags = true
                             end

                        end
             end
         end
         
           
       
end
if !isFlags
    session[:isErrorhandled] = 1
    isFlags = false
else
    session[:request_params] = nil
    session[:isErrorhandled] = nil
    session.delete(:request_params)
end
redirect_to "#{root_url}"+"discipline"

end



  private
  def electric_params
    
    @isCode     = 0
    @Startx     = '0000'
    @recCodes   = TrnDiscipline.where(["dsp_compcode=? AND dsp_reqno >0 ",@compcodes]).order('dsp_reqno DESC').first
    if @recCodes
    @isCode    = @recCodes.dsp_reqno.to_i
    end
      @sumXOfCode    = @isCode.to_i + 1
      if  @sumXOfCode.to_s.length < 2
      @sumXOfCode = p @Startx.to_s + @sumXOfCode.to_s
      elsif @sumXOfCode.to_s.length < 3
      @sumXOfCode = p "000" + @sumXOfCode.to_s
      elsif @sumXOfCode.to_s.length < 4
      @sumXOfCode = p "00" + @sumXOfCode.to_s
      elsif @sumXOfCode.to_s.length < 5
      @sumXOfCode = p "0" + @sumXOfCode.to_s
      elsif @sumXOfCode.to_s.length >=5
      @sumXOfCode =  @sumXOfCode.to_i
      end

    if params[:mid].to_i >0
        params[:dsp_reqno] =  params[:dsp_reqno]
    else
        params[:dsp_reqno] =  @sumXOfCode
    end
      params[:dsp_compcode]      = session[:loggedUserCompCode]
      params[:dsp_date]          = params[:dsp_date]  !=nil && params[:dsp_date]  !='' ? year_month_days_formatted(params[:dsp_date])  : 0
      params[:dsp_depcode]       = params[:dsp_depcode]  !=nil && params[:dsp_depcode]  !='' ? params[:dsp_depcode]  : ''
      params[:dsp_empcode]       = params[:dsp_empcode]  !=nil && params[:dsp_empcode]  !='' ? params[:dsp_empcode]  : ''
      params[:dsp_rem]           = params[:dsp_rem]  !=nil && params[:dsp_rem]  !='' ? params[:dsp_rem]  : ''
      

    #   params[:ec_currentreading] = params[:ec_currentreading]  !=nil && params[:ec_currentreading]  !='' ? params[:ec_currentreading]  : 0
    #   params[:ec_totalunit]      = params[:ec_totalunit]  !=nil && params[:ec_totalunit]  !='' ? params[:ec_totalunit]  : 0
    #   params[:ec_reamrk]         = params[:ec_reamrk]  !=nil && params[:ec_reamrk]  !='' ? params[:ec_reamrk]  : ''
	#   params[:ec_totalamount]    = params[:ec_totalamount] != nil && params[:ec_totalamount] != '' ? params[:ec_totalamount] : 0
     params.permit(:dsp_compcode,:dsp_date,:dsp_depcode,:dsp_empcode,:dsp_rem,:dsp_reqno)
  end


  private
  def last_entry_no
    @isCode     = 0
    @Startx     = '0000'
    @recCodes   = TrnDiscipline.where(["dsp_compcode =? AND dsp_reqno >0 ",@compCodes]).order('dsp_reqno DESC').first
    if @recCodes
    @isCode    = @recCodes.dsp_reqno.to_i
    end
      @sumXOfCode    = @isCode.to_i + 1
      if  @sumXOfCode.to_s.length < 2
      @sumXOfCode = p @Startx.to_s + @sumXOfCode.to_s
      elsif @sumXOfCode.to_s.length < 3
      @sumXOfCode = p "000" + @sumXOfCode.to_s
      elsif @sumXOfCode.to_s.length < 4
      @sumXOfCode = p "00" + @sumXOfCode.to_s
      elsif @sumXOfCode.to_s.length < 5
      @sumXOfCode = p "0" + @sumXOfCode.to_s
      elsif @sumXOfCode.to_s.length >=5
      @sumXOfCode =  @sumXOfCode.to_i
      end
      return  @sumXOfCode
    end
  
    def get_list_discipline
        @compCodes = session[:loggedUserCompCode]
        if params[:requestserver] !=nil && params[:requestserver] != ''
            session[:dpreq_sewadar_code]        = nil           
            session[:dpreq_sewadar_string]      = nil
            session[:dpreq_sewadar_departments] = nil
        end

         sewadar_string      = params[:sewadar_string].to_s.strip !=nil && params[:sewadar_string].to_s.strip != '' ? params[:sewadar_string].to_s.strip : session[:dpreq_sewadar_string].to_s.strip
       
        sewadar_departments  = params[:sewadar_departments].to_s.strip !=nil && params[:sewadar_departments].to_s.strip != ''  ? params[:sewadar_departments].to_s.strip : session[:dpreq_sewadar_departments]
       
        sewadar_codetype     = params[:sewadar_codetype] !=nil && params[:sewadar_codetype] != ''  ? params[:sewadar_codetype] : session[:dpreq_sewadar_codetype]
    
        myflagsjs = false
        mytflags   = false
        iswhere = "dsp_compcode ='#{@compCodes}'"
       
        if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'stf' || session[:requestuser_loggedintp].to_s == 'swd'
              iswhere += " AND dsp_depcode LIKE '%#{@mydepartcode}%'"
              session[:dpreq_sewadar_departments] = @mydepartcode
              @sewadar_departments              = @mydepartcode
           
        else
              if sewadar_departments !=nil && sewadar_departments !=''
                iswhere += " AND dsp_depcode LIKE '%#{sewadar_departments}%'"
                session[:dpreq_sewadar_departments] = sewadar_departments
                @sewadar_departments              = sewadar_departments
              end
        end
        
        
        
         if sewadar_codetype !=nil && sewadar_codetype !=''
            @sewadar_codetype                  =  sewadar_codetype
            session[:dpreqsewadar_codetype]    =  sewadar_codetype
        end
        if sewadar_string !=nil && sewadar_string != ''
            session[:dpreqs_sewadar_string]      = sewadar_string
            @sewadar_string                    = sewadar_string
            myflagsjs = true
    
          if sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='mycode'
             iswhere += " AND dsp_empcode LIKE '%#{sewadar_string.to_s.strip}%' "
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
          jons = " LEFT JOIN  mst_sewadars swd on(dsp_compcode = sw_compcode AND dsp_empcode = sw_sewcode)"
          jons += " LEFT JOIN mst_sewadar_personal_infos spi on(sp_compcode = dsp_compcode AND dsp_empcode = sp_sewcode)"
         isselects = "trn_disciplines.*,spi.id as SpId,swd.id as wwdId"
         listdata  = TrnDiscipline.select(isselects).joins(jons).where(iswhere).order('dsp_date DESC')
    end
  end

