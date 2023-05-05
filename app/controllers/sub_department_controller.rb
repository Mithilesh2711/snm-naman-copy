class SubDepartmentController < ApplicationController
   before_action :require_login
   before_action :allowed_security
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
   helper_method :get_department_detail
   
  def index
     @compCodes      = session[:loggedUserCompCode]
     @ListDeparts    = get_department_list
     printcontroll   = "1_prt_excel_subdepartment_list"
     @printpath      = sub_department_path(printcontroll,:format=>"pdf")
     printpdf        = "1_prt_pdf_subdepartment_list"
     @printpdfpath   = sub_department_path(printpdf,:format=>"pdf")
     if params[:id] != nil && params[:id] != ''
           ids = params[:id].to_s.split("_")
           if ids[1] == 'prt' && ids[2] == 'excel'
                $allrecords = print_excel_listed
               send_data @ExcelList.to_generate_sub_department, :filename=> "sub_department_list_#{Date.today}.csv"
               return
           elsif ids[1] == 'prt' && ids[2] == 'pdf'
                 @rootUrl  = "#{root_url}"
                 dataprint = print_excel_listed
                 respond_to do |format|
                      format.html
                      format.pdf do
                         pdf = SubdepartmentPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                         send_data pdf.render,:filename => "1_prt_subdepartment_report.pdf", :type => "application/pdf", :disposition => "inline"
                      end
                  end
           end
     end

  end

  def add_sub_department
    @compCodes       =  session[:loggedUserCompCode]
    @lastcodes       =  generate_department_series
    @ListAllDepart   =  Department.where("compCode = ? AND subdepartment=''",@compCodes).order("departDescription ASC")
    @ListDepart = nil
    if params[:id].to_i >0
        @ListDepart  = Department.where("compCode = ? AND id = ?",@compCodes,params[:id]).first
    end

  end

  def sub_department
    
  end

  def create
  @compCodes  =  session[:loggedUserCompCode]
  isFlags     = true
  begin
  if params[:subdepartment] == '' || params[:subdepartment] == nil
     flash[:error] =  "Department is required"
     isFlags = false
  elsif params[:departCode] == '' || params[:departCode] == nil
     flash[:error] =  "Sub department code is required"
     isFlags = false
   elsif params[:departDescription] == '' || params[:departDescription] == nil
     flash[:error] =  "Sub department description is required"
     isFlags = false
  else

    curdepartcode = params[:cur_depart_code].to_s.strip
    departcode    = params[:departCode].to_s.strip
    subdepart     = params[:subdepartment].to_s.strip
    mid           = params[:mid]
    if mid.to_i >0

          if curdepartcode.to_s.downcase != departcode.to_s.downcase
              @chekDepart   = Department.where("compCode = ? AND LOWER(departCode) = ? AND LOWER(subdepartment) =?",@compCodes,departcode.to_s.downcase,subdepart.to_s.downcase)
              if @chekDepart.length >0
                    flash[:error] = "This sub department code is already taken!"
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
             @chekDepart   = Department.where("compCode = ? AND LOWER(departCode) = ? AND LOWER(subdepartment) =?",@compCodes,departcode.to_s.downcase,subdepart.to_s.downcase)
              if @chekDepart.length >0
                    flash[:error] = "This sub department code is already taken!"
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
     redirect_to "#{root_url}department"
   else
     redirect_to "#{root_url}sub_department/add_sub_department"
   end
  
end

 def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         @ListSate =  Department.where("compCode =? AND id = ?",@compcodes,params[:id]).first
         if @ListSate
                 @ListSate.destroy
                 flash[:error] =  "Data deleted successfully."
                 isFlags       =  true
                 session[:isErrorhandled] = nil
         end
    end
    redirect_to "#{root_url}department"
 end


private
def depart_params

    params[:compCode]          = session[:loggedUserCompCode]
    params[:departCode]        = params[:departCode] !=nil && params[:departCode] !='' ? params[:departCode].to_s.delete(' ').upcase : ''
    params[:departNumberofemp] =  0
    params[:departHod]         = ''
    params[:departType]        = ''
    params[:subdepartment]     = params[:subdepartment] !=nil && params[:subdepartment] !='' ? params[:subdepartment].to_s.strip: ''
    params[:departDescription] = params[:departDescription] !=nil && params[:departDescription] !='' ? params[:departDescription].to_s.strip: ''
    params.permit(:departCode,:compCode,:departDescription,:departNumberofemp,:departHod,:departType,:subdepartment)
end

private
  def get_department_list
   if params[:page].to_i >0
     pages = params[:page]
  else
     pages = 1
  end
     if params[:requestserver] !=nil && params[:requestserver] != ''
        params[:req_search_subdepartcode] = nil
     end
      search_departcode = params[:search_departcode] !=nil && params[:search_departcode] != '' ? params[:search_departcode].to_s.strip :  params[:req_search_subdepartcode]
      iswhere = "compCode ='#{@compCodes}' AND subdepartment<>''"
      if search_departcode !=nil && search_departcode !=''
        iswhere += " AND departCode LIKE '%#{search_departcode}%' OR  departDescription LIKE '%#{search_departcode}%' OR subdepartment LIKE '%#{search_departcode}%'"
        @search_departcode = search_departcode
         params[:req_search_subdepartcode]= search_departcode
      end
      stsobj =  Department.where(iswhere).paginate(:page =>pages,:per_page => 20).order("departDescription ASC")
      return stsobj
  end

  private
  def print_excel_listed
     search_departcode =   session[:req_search_subdepartcode]
      iswhere          = "compCode ='#{@compCodes}' AND subdepartment<>''"
      if search_departcode !=nil && search_departcode !=''
        iswhere += " AND departCode LIKE '%#{search_departcode}%' OR  departDescription LIKE '%#{search_departcode}%' OR subdepartment LIKE '%#{search_departcode}%'"
      end
      arrs   = []
      isselect = "'' as department,departments.*"
      stsobj =  Department.select(isselect).where(iswhere).order("departDescription ASC")
      if stsobj.length >0
        @ExcelList = stsobj
          stsobj.each do |newdpt|
            dpobj = get_department_detail(newdpt.subdepartment);
            if dpobj
              newdpt.department = dpobj.departDescription
            end
            arrs.push newdpt
          end
      end
      return arrs
  end

  private
def generate_department_series
  prefixobj    = get_common_prefix('SubDepartment')
  @Startx      = prefixobj ? prefixobj.sn_length : ''
  @isCode      = 0
  @recCodes    = Department.select("departCode").where(["compCode = ? AND departCode<>'' AND subdepartment<>''", @compCodes]).last
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

end
