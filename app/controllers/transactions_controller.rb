class TransactionsController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_sewdar_designation_detail,:get_all_department_detail,:get_ho_location,:get_global_office_detail
    helper_method :set_dct,:set_ent,:get_personal_information,:get_office_information,:get_roles_information,:format_oblig_date,:get_university_deegre_listed,:get_my_selected_department_code
    helper_method :get_sewa_all_department,:get_sewa_all_qualification,:get_sewa_all_rolesresp,:get_sewa_all_designation,:get_first_my_sewadar,:get_subs_location
    helper_method :get_mysewdar_list_details,:get_month_listed_data
   def index
    @compCodes         = session[:loggedUserCompCode]
    @mydepartcode      = ''
    @ElectricList      = nil
    @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
    @HrMonths          = nil
    @Hryears           = nil
    if @HeadHrp
        @HrMonths = @HeadHrp.hph_months
        @Hryears  = @HeadHrp.hph_years
    end
   @sewadarCategory    = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
   @printPath          = "transactions/1_prt_transaction_report.pdf"
  
   mydeprtcode         = ""
   mydeprtcode         = ""
  if session[:sec_sewdar_code] != nil
        sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
        if sewobjs
            @mydepartcode = sewobjs.sw_depcode
            mydeprtcode   = sewobjs.sw_depcode
        end
  end
  if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
      @sewDepart            = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment ='' AND departCode = ? ",@compCodes,mydeprtcode).order("departDescription ASC")
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
     @ListTransaction       = get_list_transaction
     
  end
def show
  @compCodes   =  session[:loggedUserCompCode]
  $compcodes   =  @compCodes
  mydeprtcode         = ""
  mydeprtcode         = ""
 if session[:sec_sewdar_code] != nil
       sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
       if sewobjs
           @mydepartcode = sewobjs.sw_depcode
           mydeprtcode   = sewobjs.sw_depcode
       end
 end
 if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
    @sewDepart   = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment ='' AND departCode = ? ",@compCodes,mydeprtcode).order("departDescription ASC")
 else
    @sewDepart   = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compCodes).order("departDescription ASC")
 end
      if params[:id] !=nil && params[:id] !=''        
          sps = params[:id].to_s.split("_")
          if sps && sps[1].to_s == 'prt'
               @prdata = print_list_transaction()              
               if @prdata  !=nil              
                   send_data @prdata.to_get_transactionlist, :filename=> "transaction_reports-#{Date.today}.csv"
               end
          end
      end
end

def add_transaction

  @compCodes        =  session[:loggedUserCompCode]
  @nbegindate       =  2021
  @mydepartcode     =  ''
  @ElectricList     =  nil
  @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
  @HrMonths          = nil
  @Hryears           = nil
  if @HeadHrp
    @HrMonths = @HeadHrp.hph_months
    @Hryears  = @HeadHrp.hph_years
  end
   @sewadarCategory    = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
   @printPath          = "all_formats/1_common_report.pdf"
   mydeprtcode         = ""
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

   
end
def destroy
  @compcodes = session[:loggedUserCompCode]
  if params[:id].to_i >0
      delobj =  TrnTransaction.where("trns_compcode =? AND id = ?",@compcodes,params[:id]).first
       if delobj
           delobj.update(:trns_status=>'C')
               flash[:error] =  "Data Cancelled successfully."
               isFlags       =  true
               session[:isErrorhandled] = nil
         end
  end
  redirect_to "#{root_url}transactions"
end

 def ajax_process
    @compCodes       = session[:loggedUserCompCode]
    if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
        get_common_list()      
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
      
            if params[:trns_depcode] == nil || params[:trns_depcode] == ''
                flash[:error] =  "Department Name is required."
                isFlags = false             
          elsif params[:trns_empcode] == nil || params[:trns_empcode] == ''
                flash[:error] =  "Sewadar code is required."
                isFlags = false
          
          
            else
                departcode = params[:trns_depcode]
                empcode    = params[:trns_empcode]
                 if mid.to_i >0
                      
                             if isFlags
                                      stateupobj  = TrnTransaction.where("trns_compcode	 =? AND id = ?",@compcodes,mid).first
                                      if stateupobj
                                            stateupobj.update(transaction_params)
                                            process_common_trnsfer(params[:trns_empcode],params[:trns_change],params[:extenstion],params[:trns_type])
                                            flash[:error] = "Data updated successfully."
                                            isFlags       = true
                                      end
                              end
              
                     else
                         if params[:trns_type].to_s == 'Extension'
                              chextobj  = TrnTransaction.where("trns_compcode	 = ? AND trns_empcode = ? AND trns_depcode = ? AND YEAR(created_at)=YEAR(NOW()) AND trns_status<>'R'",@compcodes,empcode,departcode)
                              if chextobj.length >0
                                flash[:error] = "Extenstion could not enter more than 1 in a year."
                                isFlags       =  false                          
                              end

                         end
                         if isFlags
                             sewdarobjs = get_mysewdar_list_details(empcode)
                              if sewdarobjs
                                   dobs     = sewdarobjs.sw_date_of_birth
                                   myages   = get_dob_calculate(year_month_days_formatted(dobs))
                                   if myages.to_i >65
                                      flash[:error] = "Extenstion could not allowed more than 65 years."
                                      isFlags       =  false 
                                   end
                              end
                         end
                         if isFlags
                          chextobj  = TrnTransaction.where("trns_compcode	 = ? AND trns_empcode = ? AND trns_depcode = ?  AND trns_status<>'R'",@compcodes,empcode,departcode)
                            if chextobj.length >3
                                flash[:error] = "Extenstion could not allowed more than 3 times."
                                isFlags       =  false 
                            end
                         end                      


                            if isFlags
                                  @stsobj = TrnTransaction.new(transaction_params)
                                  if @stsobj.save  
                                      process_common_trnsfer(params[:trns_empcode],params[:trns_change],params[:extenstion],params[:trns_type])
                                      lastid = @stsobj.id.to_i
                                      session[:requested_lastid] = lastid
                                      flash[:error] =  "Data saved successfully."
                                      isFlags = true
                                  end
                            end
                    end       
                end
              rescue Exception => exc
                flash[:error] =  "ERROR: #{exc.message}"
                session[:isErrorhandled] = 1      
                isFlags = false
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
redirect_to "#{root_url}"+"transactions"

end



  private
  def transaction_params
      cdirect = "transaction"                     
      params[:trns_compcode]      = session[:loggedUserCompCode]
      params[:trns_depcode]       = params[:trns_depcode]  !=nil && params[:trns_depcode]  !='' ? params[:trns_depcode]  : ''
      params[:trns_empcode]       = params[:trns_empcode]  !=nil && params[:trns_empcode]  !='' ? params[:trns_empcode]  : ''
      params[:trns_rem]           = params[:trns_rem]  !=nil && params[:trns_rem]  !='' ? params[:trns_rem]  : ''
      params[:trns_type]          = params[:trns_type]  !=nil && params[:trns_type]  !='' ? params[:trns_type]  : ''
      params[:trns_old]           = params[:trns_old]  !=nil && params[:trns_old]  !='' ? params[:trns_old]  : ''
      newchanges                  = params[:trns_change]  !=nil && params[:trns_change]  !='' ? params[:trns_change]  : ''
      params[:trns_mon]           = params[:trns_mon]  !=nil && params[:trns_mon]  !='' ? params[:trns_mon]  : ''
      params[:trns_year]          = params[:trns_year]  !=nil && params[:trns_year]  !='' ? params[:trns_year]  : ''
      currfile                    = params[:currfile]  !=nil && params[:currfile]  !='' ? params[:currfile]  : ''
      params[:trns_dated]         = params[:trns_dated]  !=nil && params[:trns_dated]  !='' ? year_month_days_formatted(params[:trns_dated])  : 0

      attachfile  = ""
      if params[:trns_attachemnet] !=nil && params[:trns_attachemnet] !='' 
         attachfile = process_files(params[:trns_attachemnet],currfile,cdirect)
      end
      if attachfile == nil || attachfile == ''
          if currfile !=nil && currfile !=''
              attachfile = currfile
          end
      end
      params[:trns_attachemnet]  = attachfile
      if( params[:trns_type] == 'Extension' )
        params[:trns_change]  =  params[:extenstion] !=nil &&  params[:extenstion] !='' ?  params[:extenstion] : 0 
      else
        params[:trns_change]  = newchanges
      end      

     params.permit(:trns_compcode,:trns_dated,:trns_attachemnet,:trns_depcode,:trns_empcode,:trns_rem,:trns_old,:trns_type,:trns_change,:trns_mon,:trns_year)
  end


  
  
    def get_list_transaction
        @compCodes = session[:loggedUserCompCode]
        if params[:requestserver] !=nil && params[:requestserver] != ''
            session[:dpreq_sewadar_code]        = nil           
            session[:dpreq_sewadar_string]      = nil
            session[:dpreq_sewadar_departments] = nil
            session[:trans_search_fromdated]    = nil
            session[:trans_search_uptodated]    = nil
        end

        sewadar_string       = params[:sewadar_string].to_s.strip !=nil && params[:sewadar_string].to_s.strip != '' ? params[:sewadar_string].to_s.strip : session[:dpreq_sewadar_string].to_s.strip
        sewadar_departments  = params[:sewadar_departments].to_s.strip !=nil && params[:sewadar_departments].to_s.strip != ''  ? params[:sewadar_departments].to_s.strip : session[:dpreq_sewadar_departments]
        sewadar_codetype     = params[:sewadar_codetype] !=nil && params[:sewadar_codetype] != ''  ? params[:sewadar_codetype] : session[:dpreq_sewadar_codetype]
        search_fromdated     = params[:search_fromdated]!=nil && params[:search_fromdated]!='' ? params[:search_fromdated] : session[:trans_search_fromdated]
        search_uptodated     = params[:search_uptodated]!=nil && params[:search_uptodated]!='' ? params[:search_uptodated] : session[:trans_search_uptodated]
        myflagsjs            = false
        mytflags             = false
        iswhere = "trns_compcode ='#{@compCodes}'"
        if search_fromdated !=nil && search_fromdated!=''
           iswhere += " AND trns_dated >='#{year_month_days_formatted(search_fromdated)}'"
           @search_fromdated = search_fromdated
           session[:trans_search_fromdated] = search_fromdated
        end
        if search_uptodated !=nil && search_uptodated!=''
          iswhere += " AND trns_dated <='#{year_month_days_formatted(search_uptodated)}'"
          @search_uptodated                = search_uptodated
          session[:trans_search_uptodated] = search_uptodated
       end
        if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'stf' || session[:requestuser_loggedintp].to_s == 'swd'
              iswhere += " AND trns_depcode LIKE '%#{@mydepartcode}%'"
              session[:dpreq_sewadar_departments] = @mydepartcode
              @sewadar_departments              = @mydepartcode
           
        else
              if sewadar_departments !=nil && sewadar_departments !=''
                iswhere += " AND trns_depcode LIKE '%#{sewadar_departments}%'"
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
             iswhere += " AND trns_empcode LIKE '%#{sewadar_string.to_s.strip}%' "
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
          jons =   " LEFT JOIN  mst_sewadars swd on(trns_compcode = sw_compcode AND trns_empcode = sw_sewcode)"
          jons +=  " LEFT JOIN mst_sewadar_personal_infos spi on(sp_compcode = trns_compcode AND trns_empcode = sp_sewcode)"
         isselects = "trn_transactions.*,spi.id as SpId,swd.id as wwdId"
         listdata  = TrnTransaction.select(isselects).joins(jons).where(iswhere).order('trns_change DESC')
    end

    def print_list_transaction
      @compCodes = session[:loggedUserCompCode]
     

      sewadar_string       = session[:dpreq_sewadar_string]
      sewadar_departments  = session[:dpreq_sewadar_departments]
      sewadar_codetype     = session[:dpreq_sewadar_codetype]
      search_fromdated     = session[:trans_search_fromdated]
      search_uptodated     = session[:trans_search_uptodated]
      myflagsjs            = false
      mytflags             = false
      iswhere = "trns_compcode ='#{@compCodes}'"
      if search_fromdated !=nil && search_fromdated!=''
         iswhere += " AND trns_dated >='#{year_month_days_formatted(search_fromdated)}'"        
      end
      if search_uptodated !=nil && search_uptodated!=''
        iswhere += " AND trns_dated <='#{year_month_days_formatted(search_uptodated)}'"       
     end
      if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'stf' || session[:requestuser_loggedintp].to_s == 'swd'
            iswhere += " AND trns_depcode LIKE '%#{@mydepartcode}%'"         
         
      else
            if sewadar_departments !=nil && sewadar_departments !=''
              iswhere += " AND trns_depcode LIKE '%#{sewadar_departments}%'"
              
            end
      end
      
      
      
     
      if sewadar_string !=nil && sewadar_string != ''
         
          myflagsjs = true  
        if sewadar_codetype !=nil && sewadar_codetype !='' && sewadar_codetype  =='mycode'
           iswhere += " AND trns_empcode LIKE '%#{sewadar_string.to_s.strip}%' "
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
        jons =   " LEFT JOIN  mst_sewadars swd on(trns_compcode = sw_compcode AND trns_empcode = sw_sewcode)"
        jons +=  " LEFT JOIN mst_sewadar_personal_infos spi on(sp_compcode = trns_compcode AND trns_empcode = sp_sewcode)"
       isselects = "trn_transactions.*,'' as trnsmon,'' as trnsdated,'' as trnsstatus,spi.id as SpId,swd.id as wwdId,sw_oldsewdarcode,sw_sewadar_name,sw_sewcode,sw_gender,sw_catgeory,'' as department,'' as genders"
       listdata  = TrnTransaction.select(isselects).joins(jons).where(iswhere).order('trns_change DESC')
  end

  private
  def get_common_list
      comonobj    = []
      types       = params[:type]
      swdcode     = params[:sewcode]
      isflags     = false
      department  = ""
      designation = ""
      category    = ""
      superannuat = ""
      sewdarobj   = MstSewadar.where("sw_compcode =? AND sw_sewcode = ?",@compCodes,swdcode).first
      if types.to_s == 'Department'
           if sewdarobj
                olddptobj  = get_all_department_detail(sewdarobj.sw_depcode)
                 if olddptobj
                   department = olddptobj.departDescription
                 end
           end          
          comonobj   = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compCodes).order("departDescription ASC")
      elsif types.to_s == 'Designation'
         if sewdarobj
            olddesobj  = get_sewdar_designation_detail(sewdarobj.sw_desigcode)
            if olddesobj
              designation = olddesobj.ds_description
            end
         end  
         comonobj  = Designation.where("compcode = ?",@compCodes).order("ds_description ASC")  
      elsif types.to_s == 'Category'
        if sewdarobj
           category = sewdarobj.sw_catgeory
         end 
         comonobj  = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_name ASC")
      elsif types.to_s == 'Extension'
          officeobj    = find_office_information(@compCodes,swdcode)
          if officeobj
            superannuat = formatted_date(officeobj.so_superannuationdate)
            isflags = true
          end
      end
      if comonobj && comonobj.length >0
        isflags = true
      end
      respond_to do |format|
        format.json { render :json => { 'data'=>comonobj,"superannuat"=>superannuat, "department"=>department,"designation"=>designation,"category"=>category,:status=>isflags} }
      end
  end

  private
  def find_office_information(compcode,empcode)
         sewdarobj =  MstSewadarOfficeInfo.where("so_compcode =? AND so_sewcode =?",compcode,empcode).first
         return sewdarobj
  end
###### PROCESS COMMON TRANSFER ACTIONS ##########
private
def process_common_trnsfer(empcode,change,extenstion,type)
      compcodes   =  session[:loggedUserCompCode]
      if empcode != nil && empcode != ''
            if type.to_s == 'Department' ### TRANSFER DEPARTMENT
                  depcode = change
                  transfer_department(empcode,depcode)
                  transfer_office_department(empcode,depcode)
                  transfer_leave_department(empcode,depcode)
                  transfer_co_od_department(empcode,depcode)
                  transfer_advance_department(empcode,depcode)
                  transfer_education_department(empcode,depcode)
                  transfer_marriage_department(empcode,depcode)
                  transfer_electricconsumption_department(empcode,depcode)

            elsif type.to_s == 'Designation' ### TRANSFER DESIGNATION
                  design = change
                  transfer_designation(empcode,design)
                  transfer_office_designation(empcode,design)                
            elsif type.to_s == 'Category' ### TRANSFER CATEGORY
                category = change
                transfer_category(empcode,category)
                transfer_leave_Category(empcode,category)
                transfer_co_od_Category(empcode,category)
            elsif type.to_s == 'Extension' ### TRANSFER SUPER ANNUATION              
                transfer_extension(compcodes,empcode,extenstion)
            end
      end      
end
#### END PROCESS COMMON ACTIONS ###################
  ########## REFELECT TRANSACTION TO RELATED DATABASE TABLES ###########
  private
  def transfer_department(empcode,depcode)
        compcodes   =  session[:loggedUserCompCode]
        iswhere     =  "sw_compcode ='#{compcodes}' AND sw_sewcode ='#{empcode}'"      
        sbsobj      =  MstSewadar.where(iswhere).first
        if sbsobj
            sbsobj.update(:sw_depcode=>depcode)
        end
  end

  private
  def transfer_category(empcode,catcode)
        compcodes   =  session[:loggedUserCompCode]
        catnames    =  ""
        sewdarobj   =  MstSewadarCategory.where("sc_compcode =? AND sc_catcode = ?",compcodes,catcode).first 
        if sewdarobj
            catnames = sewdarobj.sc_name
        end
        iswhere     =  "sw_compcode ='#{compcodes}' AND sw_sewcode ='#{empcode}'"      
        sbsobj      =  MstSewadar.where(iswhere).first
        if sbsobj
            sbsobj.update(:sw_catcode=>catcode,:sw_catgeory=>catnames)
        end
  end

  private
  def transfer_designation(empcode,desicode)
        compcodes   =  session[:loggedUserCompCode]       
        iswhere     =  "sw_compcode ='#{compcodes}' AND sw_sewcode ='#{empcode}'"      
        sbsobj      =  MstSewadar.where(iswhere).first
        if sbsobj
            sbsobj.update(:sw_desigcode=>desicode)
        end
  end
  private
  def transfer_extension(compcode,empcode,extendates)
        extendate   = extendates !=nil && extendates !='' ? year_month_days_formatted(extendates) : ''
        if extendate !=nil && extendate!=''
              sewdarobj =  MstSewadarOfficeInfo.where("so_compcode =? AND so_sewcode =?",compcode,empcode).first
              if sewdarobj
                  sewdarobj.update(:so_superannuationdate=>extendate)
              end
       end    
  end

  private
  def transfer_office_department(empcode,depcode)
      compcodes   =  session[:loggedUserCompCode]       
      sewdarobj   =  MstSewadarOfficeInfo.where("so_compcode =? AND so_sewcode =?",compcodes,empcode).first
      if sewdarobj
          sewdarobj.update(:so_deprtcode=>depcode)
      end   
  end

  private
  def transfer_office_designation(empcode,designcode)
      compcodes   =  session[:loggedUserCompCode]       
      sewdarobj   =  MstSewadarOfficeInfo.where("so_compcode =? AND so_sewcode =?",compcodes,empcode).first
      if sewdarobj
          sewdarobj.update(:so_desigcode=>designcode)
      end   
  end

  private
  def transfer_leave_department(empcode,depcode)
    compcodes =  session[:loggedUserCompCode] 
    iswhere   = "ls_compcode ='#{compcodes}' AND ls_status IN('','N','P') AND ls_empcode='#{empcode}'"
    leavobj   = TrnLeave.where(iswhere)
    if leavobj.length >0
       leavobj.update_all(:ls_depcode=>depcode)
    end

  end

  private
  def transfer_leave_Category(empcode,catgeory)
    compcodes =  session[:loggedUserCompCode] 
    iswhere   = "ls_compcode ='#{compcodes}' AND ls_status IN('','N','P') AND ls_empcode='#{empcode}'"
    leavobj   = TrnLeave.where(iswhere)
    if leavobj.length >0
       leavobj.update_all(:ls_category=>catgeory)
    end

  end


  private
  def transfer_co_od_department(empcode,depcode)
    compcodes =  session[:loggedUserCompCode] 
    iswhere   = "ls_compcode ='#{compcodes}' AND ls_status IN('','N','P') AND ls_empcode='#{empcode}'"
    leavobj   = TrnRequestCoOd.where(iswhere)
    if leavobj.length >0
       leavobj.update_all(:ls_depcode=>depcode)
    end

  end
  
  private
  def transfer_co_od_Category(empcode,catgeory)
    compcodes =  session[:loggedUserCompCode] 
    iswhere   = "ls_compcode ='#{compcodes}' AND ls_status IN('','N','P') AND ls_empcode ='#{empcode}' "
    leavobj   = TrnRequestCoOd.where(iswhere)
    if leavobj.length >0
       leavobj.update_all(:ls_category=>catgeory)
    end

  end

  private
  def transfer_advance_department(empcode,depcode)
    compcodes =  session[:loggedUserCompCode] 
    iswhere   = "al_compcode ='#{compcodes}' AND al_approvestatus IN('','N') AND al_sewadarcode='#{empcode}'"
    lsobj     = TrnAdvanceLoan.where(iswhere)
    if lsobj.length >0
      lsobj.update_all(:al_depcode=>depcode)
    end

  end

  private
  def transfer_education_department(empcode,depcode)
    compcodes =  session[:loggedUserCompCode] 
    iswhere   = "aea_compcode ='#{compcodes}' AND aea_status IN('','N') AND aea_sewadarcode ='#{empcode}'"
    lsobj     = TrnApplyEducationAid.where(iswhere)
    if lsobj.length >0
      lsobj.update_all(:aea_departcode=>depcode)
    end

  end

  private
  def transfer_marriage_department(empcode,depcode)
    compcodes =  session[:loggedUserCompCode] 
    iswhere   = "ama_compcode ='#{compcodes}' AND ama_status IN('','N') AND ama_sewadarcode ='#{empcode}'"
    lsobj     = TrnApplyMarriageAid.where(iswhere)
    if lsobj.length >0
      lsobj.update_all(:ama_departcode=>depcode)
    end

  end
  private
  def transfer_electricconsumption_department(empcode,depcode)
    compcodes =  session[:loggedUserCompCode] 
    iswhere   = "ec_compcode ='#{compcodes}' AND ec_sewdarcode ='#{empcode}'"
    lsobj     = TrnElectricConsumption.where(iswhere)
    if lsobj.length >0
      lsobj.update_all(:ec_department=>depcode)
    end

  end

  
  ########## END REFELECT TRANSACTION TO RELATED DATABASE TABLES ###########


end
