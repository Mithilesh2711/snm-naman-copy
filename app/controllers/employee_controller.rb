class EmployeeController < ApplicationController
   before_action :require_login
   before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:search]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_emp_attached_file,:get_employee_types
  helper_method :set_dct

  def index
    @compcodes     = session[:loggedUserCompCode]
   
    
    if params[:isModalDepartment]!='' && params[:isModalDepartment]!=nil && params[:isModalDepartment]=='Y'
       add_my_department
       return
    elsif params[:isModalDepartment]!='' && params[:isModalDepartment]!=nil && params[:isModalDepartment]=='LS'
       process_lead_sources
       return
   elsif params[:isModalDepartment]!='' && params[:isModalDepartment]!=nil && params[:isModalDepartment]=='DLT'
       process_lead_deleted
       return
    elsif params[:isModalDepartment]!='' && params[:isModalDepartment]!=nil && params[:isModalDepartment]=='NEWCOMP'
       add_new_company_detail
       return
    elsif params[:isModalDesgination]!='' && params[:isModalDesgination]!=nil && params[:isModalDesgination]=='Y'
       add_designation_items
       return
    elsif params[:isModalQualification]!='' && params[:isModalQualification]!=nil && params[:isModalQualification]=='Y'
       add_qualification_details
       return
    elsif params[:isComplainDetails]!='' && params[:isComplainDetails]!=nil && params[:isComplainDetails]=='Y'
       get_customer_details
       return
    elsif params[:iscustomerdetails]!='' && params[:iscustomerdetails]!=nil && params[:iscustomerdetails]=='Y'
       get_my_customer_group
       return
    elsif params[:isModalDepartment]!='' && params[:isModalDepartment]!=nil && params[:isModalDepartment]=='YS'
       add_my_payment_terms
       return
    elsif params[:isModalDepartment]!='' && params[:isModalDepartment]!=nil && params[:isModalDepartment]=='CRNC'
       add_currency_details
       return
    elsif params[:isModalDepartment]!='' && params[:isModalDepartment]!=nil && params[:isModalDepartment]=='MRKRF'
       add_market_reference_details
       return
    elsif params[:indedntity]!='' && params[:indedntity]!=nil && params[:indedntity]=='PRT'
       print_employee
       return
   elsif params[:indedntity]!='' && params[:indedntity]!=nil && params[:indedntity]=='LDPRT'
       print_leads
       return
    elsif params[:indedntity]!='' && params[:indedntity]!=nil && params[:indedntity]=='JOBORD'
       get_my_job_order_list
       return
   elsif params[:indedntity]!='' && params[:indedntity]!=nil && params[:indedntity]=='POORD'
       get_my_po_number_data_list
       return
    elsif params[:indedntity]!='' && params[:indedntity]!=nil && params[:indedntity]=='CHKOTP'
       check_user_allowedotp
       return
    elsif params[:indedntity]!='' && params[:indedntity]!=nil && params[:indedntity]=='MGP'
       get_material_sub_group
       return
    elsif params[:indedntity]!='' && params[:indedntity]!=nil && params[:indedntity]== 'CROPIMG'
       process_croped_files
       return
    end
    if params[:emplCode]!= nil
        get_personal_details()
        return
  end
  if params[:isXConfiguation]!=nil
      call_ajax_configuration_detail()
      return
  end
  if params[:cpId]!=nil
    get_configurations_details()
    return

  end
  if params[:isTdsConfiguration]!=nil
    call_ajax_tds_detail()
    return
  end
  if params[:isTdsItems]!=nil
    get_tds_added_details()
    return
  end
  if params[:isXKyc]!=nil
    call_ajax_kyc_detail()
    return
  end
  if params[:isKycItems]!=nil
    get_kyc_added_details()
    return
  end
  if params[:isXFamily]!=nil
    call_ajax_family_detail()
    return
  end
  if params[:isFamilyItems]!=nil
    get_family_nominee_details()
    return
  end
  if params[:isXSalary]!=nil
    add_ajax_salary_detail()
    return
  end
  if params[:isXSalaryItems]!=nil
    get_salaries_items_details()
    return
  end
  if params[:isEmployeeCard]!=nil && params[:isEmployeeCard]!=''
    add_card_details()
    return
  elsif params[:isCardEmpDetails]!=nil &&  params[:isCardEmpDetails]!='' && params[:isCardEmpDetails] =='Y'
    get_card_employee_details
    return
  elsif params[:ishourscalculate]!=nil &&  params[:ishourscalculate]!='' && params[:ishourscalculate] =='Y'
    calculate_shift_times
    return
  end
    @rootUrl = "#{root_url}"
    if session[:req_prints]!=nil && session[:req_prints]!='' && session[:req_prints] =='Y'
          @compDetail  = MstCompany.where(["cmp_companycode = ?", @compcodes]).first
          @ExcelList   = nil
           newarr      = search_employee_print
           respond_to do |format|
               format.html
                format.pdf do
                    pdf = EmployeeregisterPdf.new(newarr,@HeadPack,@newCustomer,@compDetail,@buyers,@rootUrl,'','',session,'')
                    send_data pdf.render,:filename => "1_employee_list.pdf", :type => "application/pdf", :disposition => "inline"
                end
           end
    elsif session[:req_prints]!=nil && session[:req_prints]!='' && session[:req_prints] =='E'
            @compDetail  = MstCompany.where(["cmp_companycode = ?", @compcodes]).first
            @ExcelList   = nil
             newarr      = search_employee_print
            send_data @ExcelList.to_generate_csv, :filename=> "employee_list-#{Date.today}.csv"
    end


  end

  def create
  @compcodes = session[:loggedUserCompCode]
  isFlags    = true
  mid        = params[:mid]
  begin
  if params[:emp_name]=='' || params[:emp_name]==nil
     flash[:error] =  "Please enter name!"
     isFlags = false
   elsif params[:emp_type]=='' || params[:emp_type]==nil
     flash[:error] =  "Please select type"
     isFlags = false
  elsif params[:emp_email]=='' || params[:emp_email]==nil
     flash[:error] =  "Please enter an email"
     isFlags = false
  elsif params[:emp_mobile]=='' || params[:emp_mobile]==nil
     flash[:error] =  "Please enter mobile number"
     isFlags = false
   elsif @compcodes==''  || @compcodes == nil
     flash[:error] =  "Invalid company!"
     isFlags = false
   else
       if params[:emp_pano]!='' && params[:emp_pano]!=nil
          if params[:emp_pano].to_s.length <10
             flash[:error] =  "PAN No should be 10 digits."
             isFlags = false
          end
       end
       if params[:emp_adhar_no]!='' && params[:emp_adhar_no]!=nil
          if params[:emp_adhar_no].to_s.length <12
             flash[:error] =  "Adhaar No should be 12 digits."
             isFlags = false
          end
       end
        emails        = params[:emp_email].to_s.delete(' ')
        mobiles       = params[:emp_mobile].to_s.delete(' ')
        currentemail  = params[:currentemail].to_s.delete(' ')
        currentmobile = params[:currentmobile].to_s.delete(' ')
        
         if mid.to_i >0
               if isFlags
                   if emails!=nil && emails!='' && currentemail!=nil && currentemail!='' && currentemail!=emails
                       isEmails = MstEmployee.where("emp_compcode=? AND emp_email=?",@compcodes,emails)
                       if isEmails.count >0
                         flash[:error] =  "This email id is already exists!, Please try another"
                         isFlags       = false
                       end
                    end
                end
               if isFlags
                    if mobiles!=nil && mobiles!='' && currentmobile!=nil && currentmobile!='' && currentmobile!=mobiles
                       isMobiles = MstEmployee.where("emp_compcode=? AND emp_mobile=?",@compcodes,mobiles)
                       if isMobiles.count >0
                         flash[:error] =  "This mobile no is already exists!, Please try another"
                         isFlags       = false
                       end
                     end
               end
               if isFlags
                 isupdt = MstEmployee.where("emp_compcode=? AND id=?",@compcodes,mid).first
                  if isupdt
                    isupdt.update(employee_params)
                    deletes_all_files()
                    new_attach_all_files(mid)
                    flash[:error] =  "Data updated successfully."
                    isFlags = true
                  end
               end
         else
            if isFlags
                if emails!=nil && emails!=''
                 isEmails = MstEmployee.where("emp_compcode=? AND emp_email=?",@compcodes,emails)
                 if isEmails.count >0
                   flash[:error] = "This email id is already exists!, Please try another"
                   isFlags       = false
                 end
               end
            end
             if isFlags
                  if mobiles!=nil && mobiles!=''
                     isMobiles = MstEmployee.where("emp_compcode=? AND emp_mobile=?",@compcodes,mobiles)
                     if isMobiles.count >0
                       flash[:error] = "This mobile no is already exists!, Please try another"
                       isFlags       = false
                     end
                  end
             end
             if isFlags
                 @mstEmp = MstEmployee.new(employee_params)
                  if @mstEmp.save
                    empid = p @mstEmp.id
                    new_attach_all_files(empid)
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
      
      session[:request_empname]   = params[:emp_name]
      session[:request_emptype]   = params[:emp_type]
      session[:request_empmobile] = params[:emp_mobile]
      session[:request_empemail]  = params[:emp_email]
      session[:request_empstate]  = params[:emp_state_code]
      session[:isErrorhandled] = 1
     else
       session[:request_params] = nil
       session.delete(:request_params)
       session[:isErrorhandled] = nil
     end
     if mid.to_i >0
       redirect_to "#{root_url}"+"employee/"+mid.to_s
     else
       redirect_to "#{root_url}"+"employee"
     end
     
  end

def employee_refresh
   session[:request_params] = nil
   session[:sales_search]   = nil
   session[:salessearchId]  = nil
   session[:req_prints]     = nil
   session[:newempsearch]   = nil
   session.delete(:request_params)
   redirect_to "#{root_url}"+"employee"
end
def show
   @compcodes      = session[:loggedUserCompCode]
    
   
end



def destroy
 customerId     =  params[:id].to_i
 @compcodes     =  session[:loggedUserCompCode]
 @customerId    =  customerId
 @isDelFlags = false
# check_customer_group_sales
 if @isDelFlags
       flash[:error] =  "Sorry!! Unable to deletion!"
       session[:isErrorhandled] = 1
 else
       @MstDelete   =  MstEmployee.where("emp_compcode=? AND id=? ",@compcodes,customerId).first
       if @MstDelete
          @MstDelete.destroy
          flash[:error] =  "Data deleted successfully."
          session[:isErrorhandled] = nil
        end
  end
  redirect_to "#{root_url}"+"employee"
end




private
def search_salesman_list
  iswhere = "emp_compcode='#{@compcodes}'"
  if @tseach!=nil && @tseach!=''
    issearchparm   = "%"+@tseach.to_s+"%"
    iswhere        += " AND  emp_name LIKE '#{issearchparm}' OR  emp_email LIKE '#{issearchparm}' OR emp_mobile LIKE '#{issearchparm}'"
  end
  if @newempsearch!=nil && @newempsearch!=''
    iswhere        += " AND  emp_type= '#{@newempsearch}'"
  end
  objist   =   MstEmployee.select("mst_employees.*,'' as types").where(iswhere).paginate(:page =>@pages,:per_page => 25).order('id DESC')
  return objist
end

private
def employee_params
  params[:emp_compcode]      = session[:loggedUserCompCode]
  params[:emp_name]          = params[:emp_name].to_s.strip ? params[:emp_name].to_s.strip : ''
  params[:emp_email]         = params[:emp_email].to_s.delete(' ')? params[:emp_email].to_s.delete(' '):''
  params[:emp_mobile]        = params[:emp_mobile].to_s.delete(' ') ? params[:emp_mobile].to_s.delete(' '):''
  params[:emp_pano]          = params[:emp_pano].to_s.delete(' ')!='' ? params[:emp_pano].to_s.delete(' ').upcase : ''
  params[:emp_adhar_no]      = params[:emp_adhar_no].to_s.delete(' ')!=''  ? params[:emp_adhar_no].to_s.delete(' '):''
  params[:emp_type]          = params[:emp_type].to_s.delete(' ')!='' ? params[:emp_type].to_s.strip : ''
  params[:emp_address]       = params[:emp_address].to_s.delete(' ')!=''  ? params[:emp_address].to_s.strip : ''
  params[:emp_department]    = params[:emp_department].to_s.delete(' ')!=''  ? params[:emp_department].to_s.strip : 0
  params[:emp_designation]   = params[:emp_designation].to_s.delete(' ')!=''  ? params[:emp_designation].to_s.strip : 0
  params[:emp_qualification] = params[:emp_qualification].to_s.delete(' ')!=''  ? params[:emp_qualification].to_s.strip : 0
  params[:emp_pin_no]        = params[:emp_pin_no].to_s.delete(' ')!=''  ? params[:emp_pin_no].to_s.strip : ''
  lengthx                    = params[:emp_state_code]!='' && params[:emp_state_code]!=nil  ? params[:emp_state_code].length : 0

  params[:emp_altmobile]     = params[:emp_altmobile]!='' && params[:emp_altmobile]!=nil  ? params[:emp_altmobile] : ''
  params[:emp_famrelation]   = params[:emp_famrelation]!='' && params[:emp_famrelation]!=nil  ? params[:emp_famrelation] : ''  
  params[:emp_basic]         = params[:emp_basic]!='' && params[:emp_basic]!=nil  ? params[:emp_basic] : 0
  params[:emp_hra]           = params[:emp_hra]!='' && params[:emp_hra]!=nil  ? params[:emp_hra] : 0
  params[:emp_convenience]   = params[:emp_convenience]!='' && params[:emp_convenience]!=nil  ? params[:emp_convenience] : 0
  params[:emp_total]         = params[:emp_total]!='' && params[:emp_total]!=nil  ? params[:emp_total] : 0
  params[:emp_company]       = params[:emp_company]!='' && params[:emp_company]!=nil  ? params[:emp_company] : 0
  bod       = 0
  joindate  = 0
  leavingdt = 0
  if params[:emp_bod]!='' && params[:emp_bod]!=nil 
       bod = year_month_days_formatted(params[:emp_bod])
  end
  if params[:emp_joindate]!='' && params[:emp_joindate]!=nil 
      joindate = year_month_days_formatted(params[:emp_joindate])
  end
  if params[:emp_leavingdate]!='' && params[:emp_leavingdate]!=nil
       leavingdt = year_month_days_formatted(params[:emp_leavingdate])
  end
  params[:emp_bod]         = bod
  params[:emp_joindate]    = joindate
  params[:emp_leavingdate] = leavingdt
  

   if params[:cmp_logos]=='' || params[:cmp_logos]==nil
       params[:emp_img] = ''
   end
   if params[:cmp_logos]!= '' && params[:cmp_logos]!=nil
      @new_file_name_with_type = upload_users_image()
      params[:emp_img]       = @new_file_name_with_type
   end
   if @new_file_name_with_type == nil
      if params[:currentcomplogo]!= ''
        params[:emp_img] = params[:currentcomplogo]
      end
   end
  panfiles   = nil
  adharfiles = nil
    if params[:pancardFile]=='' || params[:pancardFile]==nil
       params[:emp_pan] = ''
    end
    if params[:pancardFile]!= '' && params[:pancardFile]!=nil
        panfiles               = process_pancard_file()
        params[:emp_pan]       = panfiles
    end
    if panfiles == nil
      if params[:currentpanfile]!= '' && params[:currentpanfile]!= nil
         params[:emp_pan] = params[:currentpanfile]
      end
    end

    if params[:adharFile]=='' || params[:adharFile]==nil
       params[:emp_adhaar] = ''
    end
    if params[:adharFile]!= '' && params[:adharFile]!=nil
        adharfiles           = process_adhar_files()
        params[:emp_adhaar]  = adharfiles
    end
    if adharfiles == nil
      if params[:currentadharfile]!= '' && params[:currentadharfile]!= nil
         params[:emp_adhaar] = params[:currentadharfile]
      end
    end

  params[:emp_shift]      = params[:emp_shift]!=nil && params[:emp_shift]!='' ? params[:emp_shift] : 0
  params[:emp_category]   = params[:emp_category]!=nil && params[:emp_category]!='' ? params[:emp_category] : 0
  params[:emp_pantitle]   = params[:pancardTitle]!=nil && params[:pancardTitle]!='' ? params[:pancardTitle] : ''
  params[:emp_adhartitle] = params[:adharTitle]!=nil && params[:adharTitle]!='' ? params[:adharTitle] : ''  
  params[:emp_state_code] = params[:emp_state_code]!=nil && params[:emp_state_code]!='' ? params[:emp_state_code] : 0
  params.permit(:emp_compcode,:emp_shift,:emp_category,:emp_company,:emp_adhartitle,:emp_pantitle,:emp_pan,:emp_adhaar,:emp_altmobile,:emp_famrelation,:emp_bod,:emp_joindate,:emp_leavingdate,:emp_basic,:emp_hra,:emp_convenience,:emp_total,:emp_img,:emp_state_code,:emp_name,:emp_email,:emp_mobile,:emp_pano,:emp_adhar_no,:emp_type,:emp_address,:emp_department,:emp_designation,:emp_qualification,:emp_pin_no)
end


private
def check_customer_group_sales
    @isDelFlags = false
    @isItems  = MstCustomer.select('id').where("(cs_compcode = ? AND cs_salesman = ? )",@compcodes,@customerId)
   if @isItems.count >0
      @isDelFlags = true
   end
end

private
def add_my_department
   @compcodes = session[:loggedUserCompCode]
  isFlags = true
  message = ''
  if params[:dp_name]=='' || params[:dp_name]==nil
     message =  "Please enter department name"
     isFlags = false
   elsif @compcodes==''  || @compcodes == nil
     message  =  "Invalid company!"
     isFlags = false
   else
      dpname      = params[:dp_name]!=nil && params[:dp_name]!='' ? params[:dp_name].to_s.delete(' ').downcase : ''
      currdepat   = params[:currdepat]!=nil && params[:currdepat]!='' ? params[:currdepat].to_s.delete(' ').downcase : ''
      mid         = params[:mid]
      if mid.to_i >0
              if dpname!=currdepat
                     if isFlags
                         @Mstdepart  = MstDepartment.where("dp_compcode=? AND replace(lower(dp_name),' ','') =?",@compcodes,dpname)
                          if  @Mstdepart.count >0
                              message =  "Your entered department name already exist's, Please try another one!"
                              isFlags       = false
                          end
                     end
              end
              if isFlags
                     isupdt =  MstDepartment.where("dp_compcode=? AND id =?",@compcodes,mid).first
                     if isupdt
                       isupdt.update(department_params)
                        message =  "Data updated successfully."
                       isFlags = true
                     end
              end
      else
           if isFlags
                  @Mstdepart  = MstDepartment.where("dp_compcode=? AND replace(lower(dp_name),' ','') =?",@compcodes,dpname)
                  if  @Mstdepart.count >0
                      message =  "Your entered department name already exist's, Please try another one!"
                      isFlags       = false
                  end
           end
           if isFlags
               @mstGroup = MstDepartment.new(department_params)
               if @mstGroup.save
                  message  =  "Data saved successfully!"
                  isFlags        = true
                end
           end

      end
      

      
   end
   mydeparts = MstDepartment.where("dp_compcode=?",@compcodes)
   respond_to do |format|
     format.json { render :json => { 'depdata'=>mydeparts, "isStatus"=>isFlags,"message"=>message } }
  end
end
private
def department_params
  params[:dp_compcode] = session[:loggedUserCompCode]
  params[:dp_code]     = params[:dp_code]!=nil && params[:dp_code]!= '' ? params[:dp_code].to_s.delete(' ').upcase : ''
  params[:dp_name]     = params[:dp_name]!=nil && params[:dp_name]!='' ? params[:dp_name].to_s.strip : ''
  params.permit(:dp_compcode,:dp_code,:dp_name)
end

private
def add_designation_items
  isFlags    = true
  @compcodes = session[:loggedUserCompCode]  
  if params[:description] == ''
     message =  "Please enter description!"
     isFlags = false
  elsif  @compcodes == ''
     message =  "Undefine company code!"
     isFlags = false
  else
    params[:compCode] = @compcodes
    currdesn          = params[:currdesn]!=nil && params[:currdesn]!='' ? params[:currdesn] : ''
    dpname            = params[:description].to_s.delete(' ').downcase
    mid               = params[:mid]
    if mid.to_i >0
        if currdesn!=dpname
              @chekDesignation  = Designation.where("compCode=? AND replace(lower(description),' ','') =?",@compcodes,dpname)
              if  @chekDesignation.length >0
                  message =  "This designaton code is already exist,s"
                  isFlags = false
              end
        end
        if isFlags
              isdegupd  = Designation.where("compCode=? AND id =?",@compcodes,mid).first
               if isdegupd
                  isdegupd.update(designation_params)
                   message =  "Data updated successfully."
                  isFlags = true
               end
        end
    else
        @chekDesignation  = Designation.where("compCode=? AND replace(lower(description),' ','') =?",@compcodes,dpname)
        if  @chekDesignation.length >0
            message =  "This designaton code is already exist,s"
            isFlags = false
        end
        if isFlags
             @desigination = Designation.new(designation_params)
             if @desigination.save
                message =  "Data saved successfully"
                isFlags = true
             end
        end
    end
    
    
       
  end
   mydsign = Designation.where("compCode=?",@compcodes)
   respond_to do |format|
     format.json { render :json => { 'depdata'=>mydsign, "isStatus"=>isFlags,"message"=>message } }
  end
end
private
def designation_params 
  params[:designationCode] = params[:designationCode]!=nil && params[:designationCode]!='' ? params[:designationCode] : '';
  params[:description] = params[:description]!=nil && params[:description]!='' ? params[:description].to_s.strip : '';
  params.permit(:designationCode,:compCode,:description,:userId)
end

private
def get_my_customer_group
  @compCodes  =  session[:loggedUserCompCode]
  customerid   = params[:customerId]!=nil && params[:customerId]!='' ? params[:customerId] : 0
  custgrp     = ''  
  isFlags      = false
  city         = ''
  customers    = MstCustomer.select('grp.id as grpId,grp.gp_name,mst_customers.id,cs_city').joins(" LEFT JOIN mst_groups grp ON(grp.gp_compcode=cs_compcode AND grp.id=cs_groupname)").where("cs_compcode =? and  mst_customers.id=?",@compCodes,customerid).first
  if customers
    custgrp = customers.gp_name
    city    =  customers.cs_city
    isFlags = true
  end
  contactname  = MstContactPersonDetail.select('cps_name,id').where("cpd_compcode =? and cpd_customer=?",@compCodes,customerid)
  respond_to do |format|
     format.json { render :json => { 'custgrp'=>custgrp,"data"=>contactname,"myCity"=>city, "isStatus"=>isFlags,"message"=>'' } }
  end
  
end



private
def get_customer_details
  @compCodes  =  session[:loggedUserCompCode]
  complainno  = params[:complainno]
  customername = ''
  custmobile   = ''
  custdate     = ''
  isFlags      = false
  @complainno = TrnRegisterComplain.select("cs_customername,cs_mobilenumber,rc_date").joins(" JOIN mst_customers ON(cs_compcode=rc_compcode AND mst_customers.id=rc_complaint_customer)").where("rc_compcode=? AND rc_complain_no=?",@compCodes,complainno).first
  if @complainno
    customername = @complainno.cs_customername
    custmobile   = @complainno.cs_mobilenumber
    custdate     = @complainno.rc_date
    isFlags      = true
    if custdate!=nil && custdate!=''
      dt = Date.parse(custdate.to_s)
      custdate = dt.strftime("%d-%m-%Y")
    end
  end
  respond_to do |format|
     format.json { render :json => { 'customername'=>customername,'custmobile'=>custmobile,'custdate'=>custdate, "isStatus"=>isFlags,"message"=>'' } }
  end
end

private
def add_qualification_details
 @compCodes  =  session[:loggedUserCompCode]
  isFlags = true
  message = ''
  if params[:ql_qualdescription] == ''
     message =  "Please enter qualification description"
     isFlags = false
  elsif  @compCodes == ''
     message =  "Undefine company code!"
     isFlags = false
   else
    qualificat        = params[:ql_qualdescription].to_s.delete(' ').downcase
    currqualf         = params[:currqualf]!=nil && params[:currqualf]!='' ? params[:currqualf] : ''
    mid               = params[:mid]
    if mid.to_i >0
          if qualificat!=currqualf
               if isFlags
                   @chekQualf = MstQualification.where("ql_compcode = ? AND replace(LOWER(ql_qualdescription),' ','') = ?",@compCodes,qualificat);
                    if  @chekQualf.length >0
                        message =  "This qualification name is already taken, try to another!"
                        isFlags = false
                    end
                end
          end
          if isFlags
               isqlfupdt =   MstQualification.where("ql_compcode = ? AND id = ?",@compCodes,mid).first;
               if isqlfupdt
                  isqlfupdt.update(qualification_params)
                   message =  "Data updated successfully."
                  isFlags = true
               end
          end
    else
            if isFlags
               @chekQualf = MstQualification.where("ql_compcode = ? AND replace(LOWER(ql_qualdescription),' ','') = ?",@compCodes,qualificat);
                if  @chekQualf.length >0
                    message =  "This qualification name is already taken, try to another!"
                    isFlags = false
                end
            end
            if isFlags
                 @Qualification = MstQualification.new(qualification_params)
                 if @Qualification.save
                    message =  "Data saved successfully."
                    isFlags = true
                 end
            end
    end
   
    
  end
  myqualf = MstQualification.where("ql_compcode=?",@compCodes)
   respond_to do |format|
     format.json { render :json => { 'depdata'=>myqualf, "isStatus"=>isFlags,"message"=>message } }
  end
end
private
def qualification_params
  compcodes                   = session[:loggedUserCompCode]
  params[:ql_compcode]        = compcodes
  params[:ql_qualification]   = params[:ql_qualification]!=nil && params[:ql_qualification]!='' ? params[:ql_qualification].upcase : ''
  params[:ql_qualdescription] = params[:ql_qualdescription]!=nil && params[:ql_qualdescription]!='' ? params[:ql_qualdescription].to_s.strip : ''
  params.permit(:ql_compcode,:ql_qualification,:ql_qualdescription)
end

private
def add_my_payment_terms
  @compcodes = session[:loggedUserCompCode]
  compcode    = params[:dp_code].to_s.delete(' ')
  isFlags    = true
  message    = ''
 if params[:add_pm_terms]=='' || params[:add_pm_terms]==nil
     message = "Please enter department name"
     isFlags = false
   
   else
      
      if isFlags
        dpname      = params[:add_pm_terms].to_s.delete(' ').downcase
        #pts_compcode=? AND 
        @Mstdepart  = MstPaymentTerm.where("replace(lower(pts_description),' ','') =?",dpname)
          if  @Mstdepart.count >0
              message =  "Your entered payment terms already exist's, Please try another one!"
              isFlags =  false
          end
      end

      if isFlags
         @mstGroup = MstPaymentTerm.new(params_payment_terms)
         if @mstGroup.save
            message  =  "Data saved successfully."
            isFlags        = true
          end
      end
   end
   mydeparts = MstPaymentTerm.all.order("pts_description ASC")
   respond_to do |format|
     format.json { render :json => { 'depdata'=>mydeparts, "isStatus"=>isFlags,"message"=>message } }
  end
end

private
def params_payment_terms
  dpname                = params[:add_pm_terms].to_s.strip  
  params[:pts_description] = dpname
  params.permit(:pts_description)
end

private
def add_currency_details  
  @compcodes = session[:loggedUserCompCode]
  isFlags    = true
  message    = ''  
  if params[:my_currency]=='' || params[:my_currency]==nil
         message = "Please enter currency name."
         isFlags = false
  elsif params[:my_sysmbol]=='' || params[:my_sysmbol]==nil
         message = "Please enter currency symbol."
       isFlags = false
   else

      if isFlags
           dpname      = params[:my_currency].to_s.delete(' ').downcase
           @Mstdepart  = MstCurrency.where("replace(lower(cc_name),' ','') =?",dpname)
          if  @Mstdepart.length >0
              message =  "Your entered currency name is already exist's, Please try another one!"
              isFlags =  false
          end
      end

      if isFlags
         @mstGroup = MstCurrency.new(params_currency)
         if @mstGroup.save
            message  =  "Data saved successfully."
            isFlags        = true
          end
      end
   end
     mydeparts = MstCurrency.all.order("TRIM(cc_name) ASC")
     respond_to do |format|
       format.json { render :json => { 'depdata'=>mydeparts, "isStatus"=>isFlags,"message"=>message } }
    end
end

private
def params_currency
  params[:cc_name]     = params[:my_currency].to_s.strip
  params[:cc_symbols]  = params[:my_sysmbol].to_s.strip
  params[:cc_compcode] = session[:loggedUserCompCode]

  params.permit(:cc_compcode,:cc_name,:cc_symbols)
  
end


private
def add_market_reference_details
  @compcodes = session[:loggedUserCompCode]
  isFlags    = true
  message    = ''

  if params[:sl_name]=='' || params[:sl_name]==nil
       message = "Please enter market reference name."
       isFlags = false
   else

      if isFlags
           dpname      = params[:sl_name].to_s.delete(' ').downcase
           @Mstdepart  = MstSale.where("replace(lower(sl_name),' ','') =?",dpname)
           if  @Mstdepart.length >0
              message =  "Your entered market reference name is already exist's, Please try another one!"
              isFlags =  false
           end
      end

      if isFlags
         @mstGroup = MstSale.new(params_market_reference)
         if @mstGroup.save
            message  =  "Data saved successfully."
            isFlags   = true
          end
      end
   end
     mydeparts = MstSale.all.order("TRIM(sl_name) ASC")
     respond_to do |format|
       format.json { render :json => { 'depdata'=>mydeparts, "isStatus"=>isFlags,"message"=>message } }
    end
end

private
def params_market_reference
  params[:sl_name]        = params[:sl_name]!=nil && params[:sl_name]!='' ? params[:sl_name].to_s.strip : ''
  params[:sl_email]       = params[:sl_email]!=nil && params[:sl_email]!='' ? params[:sl_email].to_s.strip : ''
  params[:sl_mobileno]    = params[:sl_mobileno]!=nil && params[:sl_mobileno]!='' ? params[:sl_mobileno].to_s.strip : ''
  params[:sl_location]    = params[:sl_location]!=nil && params[:sl_location]!='' ? params[:sl_location].to_s.strip : ''
  params[:sl_address]     = params[:sl_address]!=nil && params[:sl_address]!='' ? params[:sl_address].to_s.strip : ''
  params[:sl_state]       = params[:sl_state]!=nil && params[:sl_state]!='' ? params[:sl_state].to_s.strip : ''
  params[:sl_pin]         = params[:sl_pin]!=nil && params[:sl_pin]!='' ? params[:sl_pin].to_s.strip : ''
  params[:sl_designation] = params[:sl_designation]!=nil && params[:sl_designation]!='' ? params[:sl_designation].to_s.strip : ''
  params[:sl_compcode]    = session[:loggedUserCompCode]
  params.permit(:sl_name,:sl_email,:sl_mobileno,:sl_location,:sl_address,:sl_state,:sl_pin,:sl_designation,:sl_compcode)

end

private
def corp_image_size
  @paXths = Rails.root.join "public", "images", "emp","thumb"
  file = "#{@paths}/"+@Imgs
  if File.exist?(file)
  image = MiniMagick::Image.new(file)
  image.resize "500x50"
  image.write("#{@paXths}/"+@Imgs)
  end
end
private
  def upload_users_image
    file_name     =  params[:cmp_logos].original_filename  if  ( params[:cmp_logos] !='')
    file          =  params[:cmp_logos].read
    file_type     =  file_name.split('.').last
    new_name_file =  Time.now.to_i
    new_file_name_with_type = "#{new_name_file}." + file_type
    @Imgs  = new_file_name_with_type
    @paths = Rails.root.join "public", "images", "emp"
    #### Delete Origins#############
    if params[:cmp_logos]!= '' && params[:cmp_logos]!= nil
       if params[:currentcomplogo]!= '' && params[:currentcomplogo]!= nil
          @curpath1 = Rails.root.join "public", "images", "emp",params[:currentcomplogo].to_s
          unlinks_the_files(@curpath1)
       end
    end
    if params[:cmp_logos]!= '' && params[:cmp_logos]!= nil
       if params[:currentcomplogo]!= '' && params[:currentcomplogo]!= nil
          @curpath2 = Rails.root.join "public", "images", "emp","thumb",params[:currentcomplogo].to_s
          unlinks_the_files(@curpath2)
       end
    end
    ######### Upload here ######################
    File.open("#{@paths}/" + new_file_name_with_type, "wb")  do |f|
      f.write(file)
    end
     corp_image_size
    return new_file_name_with_type
  end

  
  private
def process_enquiry_files(compcodes,files,docid,fileid,cfl_title)
      if  fileid!=nil && fileid!='' && files!=nil && files!=''
             selobj = MstEmpAttachment.where("sma_compcode=? AND id=?",compcodes,docid).first
              if selobj
                  selobj.update(:sma_attachment=>files,:sma_title=>cfl_title)
              else
                  objenq = MstEmpAttachment.new(:sma_compcode=>compcodes,:sma_siteno=>fileid,:sma_attachment=>files,:sma_title=>cfl_title)
                  if objenq.save
                    ## execute message
                  end
              end
      end
end


private
def new_attach_all_files(fileid)

     if params[:processedit]!=nil && params[:processedit]!=''
         i = 0
         k = 1

            params[:processedit].each do |fil|
                if  params["myreceivedocumentid#{i}"].to_i >0
                       recvdocuments = params["myreceivedocumentid#{i}"]
                       cftitle       = params["cfl_title#{i}"]
                       currentfile   = params["existfile#{i}"]
                       nremove       = params["removefiles#{i}"]
                       if params["receivefile#{i}"]!=nil && params["receivefile#{i}"]!=''
                             filename      =  params["receivefile#{i}"]
                             filex         =  new_attach_files(filename,k)
                             process_enquiry_files(@compcodes,filex,recvdocuments,fileid,cftitle)
                       else
                            if currentfile!=nil && currentfile!=''
                                filex         = currentfile
                                if nremove.to_i <=0
                                  process_enquiry_files(@compcodes,filex,recvdocuments,fileid,cftitle)
                                end
                            end
                       end
                end

                 i +=1
                 k +=1
           end
     end
     if params[:receivefile]!=nil && params[:receivefile]!=''
           m = 0
           c = 1

            params[:receivefile].each do |fil|
                if  params[:myreceivedocumentid][m].to_i <=0
                      recvdocuments = params[:myreceivedocumentid][m]
                      cftitle       = params[:cfl_title][m]
                       if params[:receivefile][m]!=nil && params[:receivefile][m]!=''
                             filename      =  params[:receivefile][m]

                             filex         =  new_attach_files(filename,c)

                             process_enquiry_files(@compcodes,filex,recvdocuments,fileid,cftitle)
                       end
                end
                 m +=1
                 c +=1
           end
     end

end

private
def deletes_all_files
   compcodes    = session[:loggedUserCompCode]
  i =0
  if params[:processedit]!=nil && params[:processedit]!=''
       params[:processedit].each do |fls|
          if  params["removefiles#{i}"]!=nil &&  params["removefiles#{i}"]!=''
            remove_processs_files(compcodes,params["removefiles#{i}"])
          end
          i +=1
       end
  end
end

private
def remove_processs_files(compcodes,docid)
  selobj = MstEmpAttachment.where("sma_compcode=? AND id=?",compcodes,docid).first
  if selobj
    filname      = selobj.sma_attachment
    path_to_file = Rails.root.join "public", "images","emp", "docattach",filname
    unlinks_the_files(path_to_file)
    selobj.destroy
  end
end

private
  def unlinks_the_files(path_to_file)
    File.delete(path_to_file) if File.exist?(path_to_file)
  end

private
  def new_attach_files(files,cnt)
    file_name     =  files.original_filename  if  ( files !='')
    file          =  files.read
    file_type     =  file_name.split('.').last
    new_name_file = Time.now.to_i+cnt.to_i
    new_file_name = "#{new_name_file}." + file_type
    @Imgs         = new_file_name
    @paths        = Rails.root.join "public", "images", "emp", "docattach"
    ######### Upload here ######################
    File.open("#{@paths}/" +new_file_name, "wb")  do |f|
      f.write(file)
    end
    return new_file_name
  end

  private
  def print_leads
    isstatus = false
      if params[:ischecked]!=nil && params[:ischecked]!='' && params[:ischecked] =='Y'
           session[:req_lead_prints]   = 'Y'
           session[:req_lead_search]   = params[:salessearch]
           isstatus               = true
      elsif params[:ischecked]!=nil && params[:ischecked]!='' && params[:ischecked] =='E'
           session[:req_lead_prints]   = 'E'
           session[:req_lead_search]   = params[:salessearch]
           isstatus               = true
      else
        session[:req_lead_prints] = 'N'
      end
      respond_to do |format|
        format.json { render :json => { 'depdata'=>'', "status"=>isstatus,"message"=>'' } }
      end
  end
  ####### PRINT EMPLOYEE ########
  private
  def print_employee
      isstatus = false
      if params[:ischecked]!=nil && params[:ischecked]!='' && params[:ischecked] =='Y'
           session[:req_prints]   = 'Y'
           session[:req_search]   = params[:salessearch]
           isstatus               = true
      elsif params[:ischecked]!=nil && params[:ischecked]!='' && params[:ischecked] =='E'
           session[:req_prints]   = 'E'
           session[:req_search]   = params[:salessearch]
           isstatus               = true
      else
        session[:req_prints] = 'N'
      end
      respond_to do |format|
        format.json { render :json => { 'depdata'=>'', "status"=>isstatus,"message"=>'' } }
      end
  end


   private
   def get_my_po_number_data_list
      isstatus = false
      pono     = params[:pono].to_s.strip
      types    = params[:odtypes]!=nil && params[:odtypes]!='' ? params[:odtypes] : 'Export'
      iswhere  = " qt_compcode = '#{@compcodes}' AND qt_quotno = '#{pono}' AND qdt_balan_qty >0"
      jons       = " JOIN trn_purchase_work_order_details pod ON(qdt_compcode = qt_compcode AND qdt_quotno = qt_quotno)"
      select   = "pod.*,trn_purchase_work_orders.id as headId,qt_quotdate"
      checkjob =  TrnPurchaseWorkOrder.select(select).joins(jons).where(iswhere).order("qdt_itemcode ASC")
      arrp     = []
      if checkjob.length >0
        checkjob.each do |prd|
        #  compcode  =  prd.dt_compcode
        #  pdcodes   =  prd.dt_itemcode
        #  pdobj     =  get_name_of_product(compcode,pdcodes)
        #  if pdobj
        #    prd.pdweight    = pdobj.pd_weight
        #    prd.newpurrates = pdobj.pd_purchaserate
        #  end
          
          arrp.push prd
        end
        isstatus = true
      end
      respond_to do |format|
        format.json { render :json => { 'data'=>arrp, "status"=>isstatus } }
      end
      
   end

  private
  def get_my_job_order_list
      isstatus = false
      orderno  = params[:orderno].to_s.strip
      types    = params[:odtypes]!=nil && params[:odtypes]!='' ? params[:odtypes] : 'Export'
      iswhere  = " hd_compcode  = '#{@compcodes}' AND hd_billnumber = '#{orderno}' AND hd_type ='#{types}' AND hd_loc ='#{@isLoc}'"
      jons     = "INNER JOIN trn_proforma_details trn ON(dt_compcode = hd_compcode AND dt_sale_type = hd_sale_type AND dt_billnumber = hd_billnumber AND dt_type = hd_type)"
      select   = "trn.*,trn_proforma_hdrs.id as headId,'' as pdweight,'' as alreadyqty,'' as balanceqty,'' as newpurrates"
      checkjob  =  TrnProformaHdr.select(select).joins(jons).where(iswhere).order("dt_itemcode ASC")
      arrp      = []
      if checkjob.length >0
        checkjob.each do |prd|
          compcode  =  prd.dt_compcode
          pdcodes   =  prd.dt_itemcode
          pdobj     =  get_name_of_product(compcode,pdcodes)
          if pdobj
            prd.pdweight    = pdobj.pd_weight
            prd.newpurrates = pdobj.pd_purchaserate
          end
          poobj  = get_podetail_against_jobdetail(compcode,orderno,pdcodes)
          if poobj
              prd.alreadyqty = poobj
          end
           balqty = prd.dt_quantity.to_f-poobj.to_f
           prd.balanceqty = balqty
          arrp.push prd
        end
        isstatus = true
      end
      respond_to do |format|
        format.json { render :json => { 'data'=>arrp, "status"=>isstatus } }
      end
  end

  private
  def get_podetail_against_jobdetail(compcode,ordnumber,itemcode)
     odqty   = 0
    jons     = "INNER JOIN trn_purchase_work_order_details trn ON(qt_compcode = qdt_compcode AND qt_quotno = qdt_quotno)"
    isselect = "SUM(qdt_quantity) as aldod"
    jobords =  TrnPurchaseWorkOrder.select(isselect).joins(jons).where("qt_compcode =? AND qt_refno = ? AND qdt_itemcode= ? ",compcode,ordnumber,itemcode)
    if jobords.length >0
      odqty = jobords[0].aldod
    end
    return odqty
    
  end


  private
  def search_employee_print
      arr = []
      iswhere = "emp_compcode='#{@compcodes}'"
      if  session[:req_search]!=nil &&  session[:req_search]!=''
        issearchparm   = "%"+session[:req_search].to_s+"%"
        iswhere        += " AND  emp_name LIKE '#{issearchparm}' OR  emp_email LIKE '#{issearchparm}' OR emp_mobile LIKE '#{issearchparm}'"
      end
       myitems   = MstEmployee.select("mst_employees.*,'' as types").where(iswhere).order("emp_name ASC")
       @ExcelList = myitems
       if myitems.length >0
               myitems.each do |ems|
                  empid  = ems.emp_type
                  empobj = get_employee_types(@compcodes,empid)
                  if empobj
                    ems.types = empobj.etp_name
                  end
                  arr.push ems
              end
       end
       return arr
       
  end
  private
  def check_user_allowedotp
      isstatus      =  false
      @compcodes    =  session[:loggedUserCompCode]
      @logedId      =  session[:autherizedUserId]
      @loginuser    =  @logedId
      @amtAllow     =  nil
      @qntAllow     =  nil
      @poUpdate     =  nil
      @sendEml      =  nil
      @sendSms      =  nil
      siteno        =  params[:siteno]!=nil && params[:siteno]!='' ? params[:siteno] : ''
      mywhere       =  "spe_compcode='#{@compcodes}' AND spe_siteno='#{siteno}' AND spe_user1='#{@loginuser}' OR spe_user2='#{@loginuser}' OR spe_user3='#{@loginuser}' OR spe_user4='#{@loginuser}'"
      probj         =  MstSitePermission.select("spe_blocked_status,spe_site_descid,spe_sendsms,spe_sendemail,spe_siteno").where(mywhere)
       if probj.length >0
         probj.each do |excss|
               if excss.spe_site_descid.to_i == 4
                 @qntAllow = excss.spe_blocked_status
               end
               if excss.spe_site_descid.to_i == 5
                 @amtAllow = excss.spe_blocked_status
               end
               if excss.spe_site_descid.to_i == 2
                     @poUpdate = 1
                     if excss.spe_sendsms =='Y'
                       @sendSms =1
                     end
                     if excss.spe_sendemail =='Y'
                       @sendEml =1
                     end
               end
               
         end
         isstatus = true
     end
      respond_to do |format|
        format.json { render :json => { 'amtAllow'=>@amtAllow,"qntAllow"=>@qntAllow,"poUpdate"=>@poUpdate,"sendEml"=>@sendEml,"sendSms"=>@sendSms, "status"=>isstatus,"message"=>'' } }
      end
  end

private
def get_material_sub_group
  @compcodes  = session[:loggedUserCompCode]
  groupid     = params[:groupid]!=nil && params[:groupid]!='' ? params[:groupid] : 0
  isstatus    = false
    isobj       = MstProductCategory.where("pc_compcode=? AND pc_group_id=?",@compcodes,groupid.to_i).order("pc_categoryname ASC")
      if isobj
        isstatus = true
     end
     respond_to do |format|
       format.json { render :json => { 'data'=>isobj, "isStatus"=>isstatus} }
     end
end


private
def add_new_company_detail
  @compcodes = session[:loggedUserCompCode]
  isFlags    = true
  message    = ''
  if params[:emp_company]=='' || params[:emp_company]==nil
     message =  "Please enter name"
     isFlags = false
   elsif @compcodes==''  || @compcodes == nil
     message  =  "Invalid company."
     isFlags  =  false
   else
      dpname      = params[:emp_company]!=nil && params[:emp_company]!='' ? params[:emp_company].to_s.delete(' ').downcase : ''
      currdepat   = params[:currdepat]!=nil && params[:currdepat]!='' ? params[:currdepat].to_s.delete(' ').downcase : ''
      mid         = params[:mid]
      if mid.to_i >0
              if dpname!=currdepat
                     if isFlags
                         necompobj  = MstNewCompany.where("nc_compcode=? AND replace(lower(nc_name),' ','') =?",@compcodes,dpname)
                          if  necompobj.count >0
                              message =  "Your entered company name already exist's, Please try another one!"
                              isFlags       = false
                          end
                     end
              end
              if isFlags
                     isupdt =  MstNewCompany.where("nc_compcode=? AND id =?",@compcodes,mid).first
                     if isupdt
                       isupdt.update(new_company_params)
                        message  = "Data updated successfully."
                       isFlags   = true
                     end
              end
      else
           if isFlags
                 necompobj  = MstNewCompany.where("nc_compcode=? AND replace(lower(nc_name),' ','') =?",@compcodes,dpname)
                  if  necompobj.count >0
                      message =  "Your entered company name already exist's, Please try another one!"
                      isFlags = false
                  end
           end
           if isFlags
               compobj = MstNewCompany.new(new_company_params)
               if compobj.save
                  message  =  "Data saved successfully."
                  isFlags  =  true
                end
           end

      end



   end
   mydeparts = MstNewCompany.where("nc_compcode=?",@compcodes)
   respond_to do |format|
     format.json { render :json => { 'depdata'=>mydeparts, "isStatus"=>isFlags,"message"=>message } }
  end
end

private
def new_company_params
  params[:nc_compcode] = session[:loggedUserCompCode]  
  params[:nc_name]     = params[:emp_company]!=nil && params[:emp_company]!='' ? params[:emp_company].to_s.strip : ''
  params.permit(:nc_compcode,:nc_name)
end

######## PROCESS PAN FILES ##############
private
  def process_pancard_file
    file_name     =  params[:pancardFile].original_filename  if  ( params[:pancardFile] !='')
    file          =  params[:pancardFile].read
    file_type     =  file_name.split('.').last
    new_name_file = Time.now.to_i
    new_file_type = "#{new_name_file}." + file_type
    @panImgs      = new_file_type
    panpath       = Rails.root.join "public", "images", "emp","pan"
    #### Delete Origins#############
    if params[:pancardFile]!= '' && params[:pancardFile]!= nil
       if params[:currentpanfile]!= '' && params[:currentpanfile]!= nil
          unlinkpath    = Rails.root.join "public", "images", "emp","pan",params[:currentpanfile].to_s
          unlinks_the_files(unlinkpath)
       end
    end
    
    ######### Upload here ######################
    File.open("#{panpath}/" + new_file_type, "wb")  do |f|
      f.write(file)
    end   
    return new_file_type
  end

  ######## PROCESS ADHAR FILES ##############
  private
  def process_adhar_files
    file_name     =  params[:adharFile].original_filename  if  ( params[:adharFile] !='')
    file          =  params[:adharFile].read
    file_type     =  file_name.split('.').last
    new_name_file =  Time.now.to_i
    new_file_type =  "#{new_name_file}." + file_type
    @adharImgs    =  new_file_type
    adharpath     =  Rails.root.join "public", "images", "emp","adhar"
    #### DELETE ORIGIN #############
    if params[:adharFile]!= '' && params[:adharFile]!= nil
       if params[:currentadharfile]!= '' && params[:currentadharfile]!= nil
          unlinkpath    = Rails.root.join "public", "images", "emp","adhar",params[:currentadharfile].to_s
          unlinks_the_files(unlinkpath)
       end
    end
    ######### Upload here ######################
    File.open("#{adharpath}/" + new_file_type, "wb")  do |f|
      f.write(file)
    end
    return new_file_type
  end


  private
  def process_croped_files
    adharpath     =  Rails.root.join "public", "images", "tmpimg"
   # Dir.foreach(adharpath) {|f| File.delete("#{adharpath}/#{f}") if f != '.' && f != '..'}
    status        =  false
    extractfile   =  params[:filename]
    start         =  extractfile.index(',') + 1
    file          =  set_dct(extractfile[start..-1] )
    file_type     =  "jpg"
    new_name_file =  Time.now.to_i
    new_file_type =  "#{new_name_file}." + file_type
    @adharImgs    =  new_file_type
    
    #### DELETE ORIGIN #############
    if file != '' && file != nil
       if params[:currentfile]!= '' && params[:currentfile]!= nil
         unlinkpath    = Rails.root.join "public", "images", "tmpimg",params[:currentfile].to_s        
         unlinks_the_files(unlinkpath)
       end
    end
    ######### Upload here ######################
    File.open("#{adharpath}/" + new_file_type, "wb")  do |f|
      f.write(file)
       status = true
    end
   # upload_logo_server_image(new_name_file)
    respond_to do |format|
     format.json { render :json => { 'data'=>new_file_type, "status"=>status,"message"=>''} }
    end

 end
private
def new_inq_corp_image_size
    filesmall = "#{@paths}/"+@Imgs
    if File.exist?(filesmall)
      imgsmall = MiniMagick::Image.new(filesmall)
      imgsmall.resize "500x500"
      imgsmall.write("#{@paths}/"+@Imgs)
    end
    filethumb = "#{@paths2}/"+@Imgs
    if File.exist?(filethumb)
      imgthumb = MiniMagick::Image.new(filethumb)
      imgthumb.resize "50x50"
      imgthumb.write("#{@paths}/"+@Imgs)
    end
end

private
  def upload_logo_server_image(new_name_file)
    file_name     =  params[:pct_origin_img].original_filename  if  ( params[:pct_origin_img] !='')
    currimage     =  params[:currImage]!=nil && params[:currImage]!='' ? params[:currImage]:''
    file          =  params[:pct_origin_img].read
    file_type     =  file_name.split('.').last       
    new_file_name = "#{new_name_file}." + file_type
    @Imgs         = new_file_name
    #### Delete Origins#############
    if params[:pct_origin_img]!= '' && params[:pct_origin_img]!= nil
         if currimage!= '' && currimage!= nil             
             @curpath3 = Rails.root.join "public", "images", "images", "tmpimg","larg",currimage.to_s
             @curpath4 = Rails.root.join "public", "images", "images", "tmpimg","thumb",currimage.to_s
             unlinks_the_files(@curpath3)
             unlinks_the_files(@curpath4)
         end
    end
    @paths = Rails.root.join "public", "images", "tmpimg","larg"
    @paths2 = Rails.root.join "public", "images", "tmpimg","thumb"
    File.open("#{@paths}/" + new_file_name, "wb")  do |f|
      f.write(file)
    end
    File.open("#{@paths2}/" + new_file_name, "wb")  do |f|
      f.write(file)
    end
   # new_inq_corp_image_size()
    
  end
private
def calculate_shift_times
    @compcodes   = session[:loggedUserCompCode] ? session[:loggedUserCompCode]: ''
    fromtimes    = params[:FromTime]!=nil && params[:FromTime]!='' ? params[:FromTime] : ''
    endtimes     = params[:EndTime]!=nil && params[:EndTime]!='' ? params[:EndTime] : ''
    atm          = 0
    message      = ''
    isflags      = false
        if fromtimes!='' && fromtimes!=nil && endtimes!=nil && endtimes!=''
              if endtimes.to_time > fromtimes.to_time
                mytm    = (endtimes.to_time-fromtimes.to_time).round
                atm     = Time.at(mytm).utc.strftime("%H:%M")
                isflags      = true
              else
                   message = 'Shift end time should be greater than start shift time'
                   isflags = false
              end
        else
               message = 'Please enter start shift time & end shift time'
        end
      respond_to do |format|
      format.json { render :json => { 'dataTime'=>atm,'message'=>message,:status=>isflags } }
      end
 end
 
private
def process_lead_deleted
  message     = ""
  isstatus    = true
   mid        = params[:mid]
   chkdl      = MstLead.where("lds_compcode = ? AND lds_leadsource = ?",@compcodes,mid)
   if chkdl.length >0
     message  = "Could not deleted due to somewhere used."
     isstatus = false
   else
       delobj =  MstLeadSource.where("ls_compcode =? AND id =?",@compcodes,mid).first
       if delobj
          delobj.destroy
            message = "Data Deleted Successfully."
            isstatus = true
       end
   end
     newlds =  MstLeadSource.where("ls_compcode = ?",@compcodes).order("ls_name ASC")
     respond_to do |format|
      format.json { render :json => { 'depdata'=>newlds,'message'=>message,:status=>isstatus } }
     end
   
end

private
def process_lead_sources
  @compcodes = session[:loggedUserCompCode]
  isFlags    = true
  message    = ''
  if params[:dp_name]=='' || params[:dp_name]==nil
     message =  "Please enter name"
     isFlags = false
   elsif @compcodes==''  || @compcodes == nil
     message  =  "Invalid company!"
     isFlags = false
   else
      dpname      = params[:dp_name]!=nil && params[:dp_name]!='' ? params[:dp_name].to_s.delete(' ').downcase : ''
      currdepat   = params[:currdepat]!=nil && params[:currdepat]!='' ? params[:currdepat].to_s.delete(' ').downcase : ''
      mid         = params[:mid]
      if mid.to_i >0
              if dpname!=currdepat
                     if isFlags
                         @Mstdepart  = MstLeadSource.where("ls_compcode =? AND replace(lower(ls_name),' ','') =?",@compcodes,dpname)
                          if  @Mstdepart.length >0
                              message =  "Your entered name is already exist's, Please try another one!"
                              isFlags       = false
                          end
                     end
              end
              if isFlags
                     isupdt =  MstLeadSource.where("ls_compcode =? AND id =?",@compcodes,mid).first
                     if isupdt
                       isupdt.update(lead_params)
                        message =  "Data updated successfully."
                       isFlags = true
                     end
              end
      else
           if isFlags
                  @Mstdepart  = MstLeadSource.where("ls_compcode =? AND replace(lower(ls_name),' ','') =?",@compcodes,dpname)
                  if  @Mstdepart.length >0
                      message =  "Your entered name is already exist's, Please try another one!"
                      isFlags       = false
                  end
           end
           if isFlags
               @mstGroup = MstLeadSource.new(lead_params)
               if @mstGroup.save
                  message  =  "Data saved successfully!"
                  isFlags        = true
                end
           end

      end



   end
   mydeparts = MstLeadSource.where("ls_compcode =?",@compcodes)
   respond_to do |format|
     format.json { render :json => { 'depdata'=>mydeparts, "isStatus"=>isFlags,"message"=>message } }
  end
end
private
def lead_params
  params[:ls_compcode] = session[:loggedUserCompCode]  
  params[:ls_name]     = params[:dp_name]!=nil && params[:dp_name]!='' ? params[:dp_name].to_s.strip : ''
  params.permit(:ls_compcode,:ls_name)
end




end ### End class
