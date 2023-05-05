class ProcessUpdateInstallmentController < ApplicationController
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
   @printPath          = "all_formats/1_common_report.pdf"
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
    @ListTransaction   = get_list_transaction
     
  end

def add_installment

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
      delobj =  TrnInstallment.where("trns_compcode =? AND id = ?",@compcodes,params[:id]).first
       if delobj
            compcode  =  @compcodes
            amounts   =  delobj.trns_old
            requestno =  delobj.trns_type
            empcode   =  delobj.trns_empcode
              delobj.destroy
               process_update_installment(compcode,amounts,requestno,empcode)
               flash[:error] =  "Data deleted successfully."
               isFlags       =  true
               session[:isErrorhandled] = nil
       end
  end
  redirect_to "#{root_url}process_update_installment"
end

 def ajax_process
    @compCodes       = session[:loggedUserCompCode]
    if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
        get_common_list()      
      return
   elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'REQNO'       
		get_sewdar_advance_requestno();
		return    
    elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'REQAMT'       
		get_installment_amount();
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
            elsif params[:trns_type] == nil || params[:trns_type] == ''
                flash[:error] =  "Request no is required."
                isFlags = false
            elsif params[:trns_old] == nil || params[:trns_old] == ''
                flash[:error] =  "Old installment is required."
                isFlags = false 
            elsif params[:trns_change] == nil || params[:trns_change] == ''
                flash[:error] =  "Current installment is required."
                isFlags = false         
            else
                departcode = params[:trns_depcode]
                empcode    = params[:trns_empcode]
                 if mid.to_i >0
                      
                             if isFlags
                                      stateupobj  = TrnInstallment.where("trns_compcode	 =? AND id = ?",@compcodes,mid).first
                                      if stateupobj
                                            stateupobj.update(transaction_params)
                                            flash[:error] = "Data updated successfully."
                                            isFlags       = true
                                      end
                              end
              
                     else
                         
                      
                            if isFlags
                                  @stsobj = TrnInstallment.new(transaction_params)
                                  if @stsobj.save  
                                     process_update_installment(@compcodes,params[:trns_change],params[:trns_type],params[:trns_empcode])
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
redirect_to "#{root_url}"+"process_update_installment"

end

private
def process_update_installment(compcode,amounts,requestno,empcode)
    if amounts.to_f >0 && requestno !=nil && requestno !='' && empcode !=nil && empcode !=''
        iswhere   = "al_compcode ='#{compcode}' AND al_sewadarcode ='#{empcode}' AND al_requestno='#{requestno}'"
        loansobj  = TrnAdvanceLoan.where(iswhere).first
        if loansobj
            loansobj.update(:al_installpermonth=>amounts)
        end
     end       
end
 

  private
  def transaction_params
      cdirect = "installment"                     
      params[:trns_compcode]      = session[:loggedUserCompCode]
      params[:trns_depcode]       = params[:trns_depcode]  !=nil && params[:trns_depcode]  !='' ? params[:trns_depcode]  : ''
      params[:trns_empcode]       = params[:trns_empcode]  !=nil && params[:trns_empcode]  !='' ? params[:trns_empcode]  : ''
      params[:trns_rem]           = params[:trns_rem]  !=nil && params[:trns_rem]  !='' ? params[:trns_rem]  : ''
      params[:trns_type]          = params[:trns_type]  !=nil && params[:trns_type]  !='' ? params[:trns_type]  : ''
      params[:trns_old]           = params[:trns_old]  !=nil && params[:trns_old]  !='' ? params[:trns_old]  : 0
      newchanges                  = params[:trns_change]  !=nil && params[:trns_change]  !='' ? params[:trns_change]  : 0
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
        end

         sewadar_string      = params[:sewadar_string].to_s.strip !=nil && params[:sewadar_string].to_s.strip != '' ? params[:sewadar_string].to_s.strip : session[:dpreq_sewadar_string].to_s.strip
       
        sewadar_departments  = params[:sewadar_departments].to_s.strip !=nil && params[:sewadar_departments].to_s.strip != ''  ? params[:sewadar_departments].to_s.strip : session[:dpreq_sewadar_departments]
       
        sewadar_codetype     = params[:sewadar_codetype] !=nil && params[:sewadar_codetype] != ''  ? params[:sewadar_codetype] : session[:dpreq_sewadar_codetype]
    
        myflagsjs = false
        mytflags   = false
        iswhere = "trns_compcode ='#{@compCodes}'"
       
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
         isselects = "trn_installments.*,spi.id as SpId,swd.id as wwdId"
         listdata  = TrnInstallment.select(isselects).joins(jons).where(iswhere).order('trns_change DESC')
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
  private
  def get_sewdar_advance_requestno
        empcode  = params[:empcode]
        isflags  = false
        iswhere  = "al_compcode ='#{@compCodes}' AND al_sewadarcode ='#{empcode}' AND al_balances >0 AND al_approvestatus='A'"
        loansobj = TrnAdvanceLoan.select("al_requestno,al_installpermonth").where(iswhere).order('al_requestno ASC')
        if loansobj.length >0
            isflags = true
        end
          respond_to do |format|
            format.json { render :json => { 'data'=>loansobj,:status=>isflags} }
          end
    end

    private
    def get_installment_amount
        empcode   = params[:empcode]
        requestno = params[:requestno]
        isflags   = false
        iswhere   = "al_compcode ='#{@compCodes}' AND al_sewadarcode ='#{empcode}' AND al_requestno='#{requestno}' AND al_approvestatus='A'"
        loansobj  = TrnAdvanceLoan.select("al_requestno,al_installpermonth").where(iswhere).first
         if loansobj
             isflags = true
         end
          respond_to do |format|
            format.json { render :json => { 'data'=>loansobj,:status=>isflags} }
          end
    end

end
