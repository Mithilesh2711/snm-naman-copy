## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for generate tickets
### FOR REST API ######
class DepartmentController < ApplicationController
   before_action :require_login
   before_action :allowed_security
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    helper_method :get_department_detail,:total_all_counts
  def index
     @compCodes      = session[:loggedUserCompCode]
     
     @ListDeparts    = get_department_list
     printcontroll   = "1_prt_excel_department_list"
     @printpath      = department_path(printcontroll,:format=>"pdf")
     printpdf        = "1_prt_pdf_department_list"
     @printpdfpath   = department_path(printpdf,:format=>"pdf")
     ########## SUB DEPARTMENT VALUES ###
         @ListSubDeparts    = get_sub_department_list
         printconsub        = "1_prt_excel_subdepartment_list"
         @printpathsub      = sub_department_path(printconsub,:format=>"pdf")
         printpdfsub        = "1_prt_pdf_subdepartment_list"
         @printpdfpathsub   = sub_department_path(printpdfsub,:format=>"pdf")
    ### END SUB DEPARTMENT  ####
     if params[:id] != nil && params[:id] != ''
           ids = params[:id].to_s.split("_")
           if ids[1] == 'prt' && ids[2] == 'excel'
               @ExcelList = print_excel_listed
               send_data @ExcelList.to_generate_department, :filename=> "department_list_#{Date.today}.csv"
               return
           elsif ids[1] == 'prt' && ids[2] == 'pdf'
                 @rootUrl  = "#{root_url}"
                 dataprint = print_excel_listed
                 respond_to do |format|
                      format.html
                      format.pdf do
                         pdf = DepartmentPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                         send_data pdf.render,:filename => "1_prt_department_report.pdf", :type => "application/pdf", :disposition => "inline"
                      end
                  end
           end
     end
     
  end
  def sub_department
     @compCodes      = session[:loggedUserCompCode]
     @ListDeparts    = get_sub_department_list
     printcontroll   = "1_prt_excel_subdepartment_list"
     @printpath      = sub_department_path(printcontroll,:format=>"pdf")
     printpdf        = "1_prt_pdf_subdepartment_list"
     @printpdfpath   = sub_department_path(printpdf,:format=>"pdf")

  end
  
  def ajax_process
      @compCodes  =  session[:loggedUserCompCode]
      if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
        find_sub_department_list_ajax()
        return
      end
  end

  def add_department
    @compCodes      =  session[:loggedUserCompCode]
    @HeadofDpt      =  MstLedger.where("lds_compcode =? AND lds_type ='EC' ",@compCodes).order("lds_name ASC")
    @cordiNator     =  MstLedger.where("lds_compcode =? AND LOWER(lds_type) <>'ec' ",@compCodes).order("lds_name ASC")
    @lastcode       =  generate_department_series
    @ListDepart = nil
    if params[:id].to_i >0
        @ListDepart  = Department.where("compCode = ? AND id = ?",@compCodes,params[:id]).first
    end
    
  end

  def create
  @compCodes  =  session[:loggedUserCompCode]
  isFlags     = true
  begin
  if params[:departCode] == '' || params[:departCode] == nil
     flash[:error] =  "Please enter department code!"
     isFlags = false
  elsif params[:departDescription] == '' || params[:departDescription] == nil
     flash[:error] =  "Please enter department description"
     isFlags = false
  
  else
    
    curdepartcode = params[:cur_depart_code].to_s.strip
    departcode    = params[:departCode].to_s.strip
    mid           = params[:mid]
    if mid.to_i >0

          if curdepartcode.to_s.downcase != departcode.to_s.downcase
              @chekDepart   = Department.where("compCode = ? AND LOWER(departCode) = ? AND subdepartment =''",@compCodes,departcode.to_s.downcase)
              if @chekDepart.length >0
                    flash[:error] = "This department code is already taken!"
                    isFlags       = false
              end
            
          end
            if isFlags
                chkdeprtobj   = Department.where("compCode = ? AND id = ?",@compCodes,mid).first
                if chkdeprtobj
                  chkdeprtobj.update(depart_params)
                      flash[:error] = "Data updated successfully"
                      isFlags       = true
                end
            end

    else
          @chekDepart   = Department.where("compCode = ? AND LOWER(departCode) = ? AND subdepartment =''",@compCodes,departcode.to_s.downcase)
          if @chekDepart.length >0
                flash[:error] = "This department code is already taken!"
                isFlags       = false
          end
            if isFlags
                deprtsvobj = Department.new(depart_params)
                 if deprtsvobj.save
                    flash[:error] = "Data saved successfully"
                    isFlags       = true
                 end
            end
    end
    
  end
  
  if !isFlags
    session[:isErrorhandled] = 1
    #session[:postedpamams]   = params
  else
    session[:isErrorhandled] = nil
    session[:postedpamams]   = nil
    isFlags = true
  end
   rescue Exception => exc
       flash[:error] =  "ERROR: #{exc.message}"
       session[:isErrorhandled] = 1
      # session[:postedpamams]   = params
       isFlags = false
   end
   if isFlags
     redirect_to  "#{root_url}department"
   else
     redirect_to  "#{root_url}department/add_department"
   end
  
end

 def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
           @ListSate =  Department.where("compCode =? AND id = ?",@compcodes,params[:id]).first
           if @ListSate
                   cheobjs =   check_existing_dpertment(@compcodes,@ListSate.departCode)
                   if cheobjs
                       flash[:error] =  "Sorry !! Data could not be deleted  due to somewhere used."
                       isFlags       =  true
                       session[:isErrorhandled] = 1
                   else
                       @ListSate.destroy
                       flash[:error] =  "Data deleted successfully."
                       isFlags       =  true
                       session[:isErrorhandled] = nil
                   end
           end
    end
    redirect_to "#{root_url}department"
 end


private
def depart_params
   
    params[:compCode]          = session[:loggedUserCompCode]
    params[:departCode]        = params[:departCode] !=nil && params[:departCode] !='' ? params[:departCode].to_s.delete(' ').upcase : ''
    params[:departNumberofemp] = params[:departNumberofemp]!=nil && params[:departNumberofemp] !='' ? params[:departNumberofemp] : 0
    params[:departHod]         = params[:departHod]!=nil && params[:departHod] !='' ? params[:departHod] : ''
    params[:departType]        = params[:departType] !=nil && params[:departType] !='' ? params[:departType] : ''    
    params[:helpdesk]          = params[:helpdesk] !=nil && params[:helpdesk] !='' ? params[:helpdesk] : 'N'
    params[:cordinate]         = params[:cordinate] !=nil && params[:cordinate] !='' ? params[:cordinate] : 'N'
    params[:cordinatevalue]    = params[:cordinatevalue] !=nil && params[:cordinatevalue] !='' ? params[:cordinatevalue] : ''

    params.permit(:departCode,:helpdesk,:cordinate,:cordinatevalue,:compCode,:departDescription,:departNumberofemp,:departHod,:departType)
end

private
  def get_department_list
   if params[:page].to_i >0
     pages = params[:page]
  else
     pages = 1
  end
     if params[:requestserver] !=nil && params[:requestserver] != ''
        session[:req_search_departcode] = nil
     end
      search_departcode = params[:search_departcode] !=nil && params[:search_departcode] != '' ? params[:search_departcode].to_s.strip : session[:req_search_departcode]
      iswhere = "compCode ='#{@compCodes}' AND subdepartment =''"
      if search_departcode !=nil && search_departcode !=''
        iswhere += " AND departCode LIKE '%#{search_departcode}%' OR  departDescription LIKE '%#{search_departcode}%' OR departHod LIKE '%#{search_departcode}%'"
        @search_departcode = search_departcode
        session[:req_search_departcode] = search_departcode
      end
      stsobj =  Department.where(iswhere).order("departCode DESC")
      return stsobj
  end

  private
  def print_excel_listed
     search_departcode =  session[:req_search_departcode]
      iswhere          = "compCode ='#{@compCodes}' AND subdepartment =''"
      if search_departcode !=nil && search_departcode !=''
        iswhere += " AND departCode LIKE '%#{search_departcode}%' OR  departDescription LIKE '%#{search_departcode}%' OR departHod LIKE '%#{search_departcode}%'"
      end
      stsobj =  Department.where(iswhere).order("departCode DESC")
      return stsobj
  end


private
def generate_department_series
  prefixobj    = get_common_prefix('Department')
  @Startx      = prefixobj ? prefixobj.sn_length : ''
  @isCode      = 0
  @recCodes    = Department.select("departCode").where(["compCode = ? AND departCode<>'' AND subdepartment=''", @compCodes]).last
  if @recCodes
     @isCode1    = @recCodes.departCode.to_s.gsub(/[^\d]/, '')
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
  private
  def get_sub_department_list
   if params[:page].to_i >0
     pages = params[:page]
  else
     pages = 1
  end
     if params[:requestserver] !=nil && params[:requestserver] != ''
        session[:req_search_departcode] = nil
     end
      search_departcode = params[:search_departcode] !=nil && params[:search_departcode] != '' ? params[:search_departcode].to_s.strip : session[:req_search_departcode]
      iswhere = "compCode ='#{@compCodes}' AND subdepartment<>''"
      if search_departcode !=nil && search_departcode !=''
        iswhere += " AND departCode LIKE '%#{search_departcode}%' OR  departDescription LIKE '%#{search_departcode}%' OR subdepartment LIKE '%#{search_departcode}%'"
        @search_departcode = search_departcode
        session[:req_search_departcode] = search_departcode
      end
      stsobj =  Department.where(iswhere).order("departDescription ASC")
      return stsobj
  end


  private
  def find_sub_department_list_ajax
  
      search_departcode = params[:subdepart] !=nil && params[:subdepart] != '' ? params[:subdepart].to_s.strip : ''
      iswhere = "compCode ='#{@compCodes}' AND subdepartment<>''"
      if search_departcode !=nil && search_departcode !=''
        iswhere += " AND departCode LIKE '%#{search_departcode}%' OR  departDescription LIKE '%#{search_departcode}%' OR subdepartment LIKE '%#{search_departcode}%'"
        
        session[:req_search_subdepartcode] = search_departcode
      end
      isfalgs = false
      arrdp = []
      stsobj =  Department.select("'' as department,departments.*").where(iswhere).order("departDescription ASC")
      if stsobj.length >0
            stsobj.each do  |newdep|             
                depobj = get_department_detail(newdep.subdepartment)
                if depobj
                  newdep.department = depobj.departDescription
                end
                arrdp.push newdep
            end
            isfalgs = true
      end
     
     respond_to do |format|
        format.json { render :json => { 'data'=>stsobj, "message"=>'',:status=>isfalgs} }
     end
  end

  private
  def check_existing_dpertment(compcodes,dptcodes)
    istruefalse = false
    iswhere     = "compCode ='#{compcodes}' AND subdepartment<>'' AND subdepartment ='#{dptcodes}'"
    chedpts     = Department.select("compCode").where(iswhere)
     if chedpts.length >0
       istruefalse = true
     end
      sewobj     = MstSewadarOfficeInfo.select("so_compcode").where("so_compcode = ? AND so_deprtcode =?",compcodes,dptcodes)
       if sewobj.length >0
         istruefalse = true
       end
       return istruefalse
  end

  private
  def total_all_counts(type)
      counts = 0
      @compCodes      = session[:loggedUserCompCode]
      
      if type == 'DPT'
        iswhere = "compCode ='#{@compCodes}' AND subdepartment=''"
      elsif type == 'SDPT'
        iswhere = "compCode ='#{@compCodes}' AND subdepartment<>''"
       elsif type == 'CELL'
        iswhere = "compCode ='#{@compCodes}' AND departType ='Cell'"
      end
      stsobj =  Department.where(iswhere).order("departDescription ASC")
      if stsobj.length >0
        counts = stsobj.length
      end
      return counts
  end
end
