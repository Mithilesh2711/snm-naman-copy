class MemberListController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:search,:ledger_list]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_ledger_attached_file,:get_employee_types
  helper_method :get_new_company_portal,:get_my_all_designation,:get_sewdar_designation_detail,:format_oblig_date

  def index
    @compcodes      = session[:loggedUserCompCode]
    cid             = '99'
    @isFlags        = false
    @Lsite          = nil
    @companyState   = 
    @tseach         = ''
    @topts          = ''
    @newempsearch   = ''
    @search_member  = nil
    if params[:page]!=nil && params[:page].to_i >0
        @pages = params[:page]
     else
        @pages = 1
     end
     if params[:salessearchId]!='' && params[:salessearchId]!=nil
       session[:req_search_member] = nil
       session[:salessearchId]     = nil
     end
    salessearchid = params[:salessearchId]!='' && params[:salessearchId]!=nil ? params[:salessearchId] : session[:salessearchId]
    employeeserch  = params[:search_member]!='' && params[:search_member]!=nil ? params[:search_member] : session[:req_search_member]
    if salessearchid!='' && salessearchid!=nil && salessearchid=='Y'
       #### execute code if required
    else
       params[:lds_type]       = params[:member] !=nil && params[:member] !='' ? set_dct(params[:member]):  session[:reqs_lds_type]
    end
    @search_member  = employeeserch
    @newempsearch   = employeeserch
    @memberlist     = search_salesman_list()
    printcontroll   = "1_prt_excel_member_list"
    @printpath      = member_list_path(printcontroll,:format=>"pdf")
    printpdf        = "1_prt_pdf_member_list"
    @printpdfpath   = member_list_path(printpdf,:format=>"pdf")
    
   if params[:id] != nil && params[:id] != ''
         ids = params[:id].to_s.split("_")
         if ids[1] == 'prt' && ids[2] == 'excel'
          $printedexcel =  print_excel_listed
           send_data @ExcelList.to_generate_members, :filename=> "member_list-#{Date.today}.csv"
           return
         elsif ids[1] == 'prt' && ids[2] == 'pdf'
                @rootUrl  = "#{root_url}"
                 dataprint = print_excel_listed
                 respond_to do |format|
                      format.html
                      format.pdf do
                         pdf = MemberlistPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                         send_data pdf.render,:filename => "1_prt_member_report.pdf", :type => "application/pdf", :disposition => "inline"
                      end
                  end
         end
   end


  end
 def add_member
     @compcodes       = session[:loggedUserCompCode]
     @HeadOffices     = MstHeadOffice.where("hof_compcode =?",@compcodes).order("hof_description ASC")
     @subLocobj       = nil 
     @mstXEmpEdit     = nil
     printcontroll    = "1_prt_excel_member_list"
      @printpath      = member_list_path(printcontroll,:format=>"pdf")
      if  params[:id].to_i >0
          @mstXEmpEdit     = MstLedger.where("lds_compcode=? AND id=?",@compcodes,params[:id].to_i).first
          if @mstXEmpEdit
            @subLocobj       = MstSubLocation.where("sl_compcode =? AND sl_locid = ?",@compcodes,@mstXEmpEdit.lds_location).order("sl_description ASC")
          end
          
      end
     @lastnumber =  generate_member_series
     
  end
  
  def create
  @compcodes = session[:loggedUserCompCode]
  isFlags    = true
  mid        = params[:mid]
  #begin
  if params[:emp_name]=='' || params[:emp_name]==nil
         flash[:error] =  "Please enter name"
         isFlags       = false
   elsif params[:lds_type]=='' || params[:lds_type]==nil
         flash[:error] =  "Please select type"
         isFlags       = false
   elsif @compcodes==''  || @compcodes == nil
       flash[:error] =  "Invalid company!"
       isFlags       = false
   else
       if params[:emp_pano]!='' && params[:emp_pano]!=nil
          if params[:emp_pano].to_s.length <10
             flash[:error] =  "PAN should be 10 digits."
             isFlags = false
          end
       end
       if params[:emp_adhar_no]!='' && params[:emp_adhar_no]!=nil
          if params[:emp_adhar_no].to_s.length <12
             flash[:error] =  "Aadhaar No. should be 12 digits."
             isFlags = false
          end
       end
        emails        = params[:emp_email].to_s.delete(' ')
        mobiles       = params[:emp_mobile].to_s.delete(' ')
        currentemail  = params[:currentemail].to_s.delete(' ')
        currentmobile = params[:currentmobile].to_s.delete(' ')
        currledger    = params[:currledger].to_s.delete(' ').downcase
        ledgername    = params[:emp_name].to_s.delete(' ').downcase
        ledgertype    = params[:lds_type].to_s.strip
         if mid.to_i >0
               if isFlags
                   if currledger !=nil && currledger !='' && ledgername !=nil && ledgername !='' && ledgername != currledger
                       ledgernm  = MstLedger.where("lds_compcode =?  AND LOWER(REPLACE(lds_name,' ','')) =? AND lds_type = ?",@compcodes,ledgername,ledgertype)
                       if ledgernm.length >0
                         flash[:error] =  "This name is already exists in #{ledgertype}!, Please try another"
                         isFlags       = false
                       end
                    end
                end
               if isFlags
                   if emails!=nil && emails!='' && currentemail!=nil && currentemail!='' && currentemail!=emails
                       isEmails = MstLedger.where("lds_compcode =?  AND lds_email =?",@compcodes,emails)
                       if isEmails.count >0
                         flash[:error] =  "This email id is already exists!, Please try another"
                         isFlags       = false
                       end
                    end
                end
               if isFlags
                    if mobiles!=nil && mobiles!='' && currentmobile!=nil && currentmobile!='' && currentmobile!=mobiles
                       isMobiles = MstLedger.where("lds_compcode =? AND lds_mobile =?",@compcodes,mobiles)
                       if isMobiles.count >0
                         flash[:error] =  "This mobile no is already exists!, Please try another"
                         isFlags       = false
                       end
                     end
               end
               if isFlags
                 isupdt = MstLedger.where("lds_compcode =? AND id=?",@compcodes,mid).first
                  if isupdt
                    isupdt.update(ledgers_params)
                    deletes_all_files()
                    new_attach_all_files(mid)
                    flash[:error] =  "Data updated successfully."
                    isFlags = true
                  end
               end
         else
           if isFlags
               if  ledgername !=nil && ledgername !='' 
                   ledgernm  = MstLedger.where("lds_compcode =?  AND LOWER(REPLACE(lds_name,' ','')) =? AND lds_type = ?",@compcodes,ledgername,ledgertype)
                   if ledgernm.length >0
                     flash[:error] =  "This name is already exists in #{ledgertype}!, Please try another"
                     isFlags       = false
                   end
                end
            end
            if isFlags
                if emails!=nil && emails!=''
                 isEmails = MstLedger.where("lds_compcode =?  AND lds_email =?",@compcodes,emails)
                 if isEmails.count >0
                   flash[:error] = "This email id is already exists!, Please try another"
                   isFlags       = false
                 end
               end
            end
             if isFlags
                  if mobiles!=nil && mobiles!=''
                     isMobiles = MstLedger.where("lds_compcode =? AND lds_mobile =?",@compcodes,mobiles)
                     if isMobiles.count >0
                       flash[:error] = "This mobile no is already exists!, Please try another"
                       isFlags       = false
                     end
                  end
             end
             if isFlags
                 @mstEmp = MstLedger.new(ledgers_params)
                  if @mstEmp.save
                    empid = p @mstEmp.id
                    new_attach_all_files(empid)
                    flash[:error] =  "Data saved successfully."
                    isFlags = true
                  end
             end

         end






   end
#   rescue Exception => exc
#        flash[:error]            = "#{exc.message}"
#        session[:isErrorhandled] = 1
#        isFlags = false
#   end
     if !isFlags
            session[:request_emp_name]          = params[:emp_name]
            session[:request_emp_pano]          = params[:emp_pano]
            session[:request_emp_adhar_no]      = params[:emp_adhar_no]
            session[:request_emp_mobile]        = params[:emp_mobile]
            session[:request_emp_email]         = params[:emp_email]
            session[:request_lds_officialemail] = params[:lds_officialemail]
            session[:isErrorhandled] = 1
     else
            session[:request_params]             = nil
            session[:request_emp_name]           = nil
            session[:request_emp_pano]           = nil
            session[:request_emp_adhar_no]       = nil
            session[:request_emp_mobile]         = nil
            session[:request_emp_email]          = nil
            session[:request_lds_officialemail]  = nil
            session.delete(:request_params)
            session[:isErrorhandled] = nil
     end
     if mid.to_i >0
       redirect_to "#{root_url}"+"member_list/add_member/"+mid.to_s+"?member="+set_ent(params[:lds_type]).to_s
     else
       redirect_to "#{root_url}"+"member_list/add_member?member="+set_ent(params[:lds_type]).to_s
     end

  end
  
 
 
def member_list_refresh
    session[:request_params]             = nil
    session[:request_emp_name]           = nil
    session[:request_emp_pano]           = nil
    session[:request_emp_adhar_no]       = nil
    session[:request_emp_mobile]         = nil
    session[:request_emp_email]          = nil
    session[:request_lds_officialemail]  = nil
   session.delete(:request_params)
   redirect_to "#{root_url}"+"member_list"
end
def show
   @compcodes      = session[:loggedUserCompCode]
  

end



def destroy
 customerid     =  params[:id].to_i
 @compcodes     =  session[:loggedUserCompCode]
 @customerId    =  customerid
 @isDelFlags = false
 @MstDelete   =  MstLedger.where("lds_compcode =? AND id=? ",@compcodes,customerid).first
if @MstDelete
  @MstDelete.destroy
  flash[:error]            =  "Data deleted successfully."
  session[:isErrorhandled] =  nil
end
  redirect_to "#{root_url}"+"member_list?member=?"+params[:member].to_s
end

private
def check_customer_group_sales
 prsobj =  TrnPurchaseProperty.where("prp_compcode = ? AND prp_sellerid = ?",@compcodes,@customerId)
 if prsobj.length >0
   @isDelFlags = true
 end
 saleobj =  TrnSalePropertyHead.where("sph_compcode =? AND sph_buyerid = ?",@compcodes,@customerId)
 if saleobj.length >0
   @isDelFlags = true
 end
 
end


private
def search_salesman_list
  ldstype     =  params[:lds_type] !=nil && params[:lds_type] !='' ? params[:lds_type] : session[:reqs_lds_type]
  iswhere = "lds_compcode ='#{@compcodes}'"
  if @newempsearch != nil && @newempsearch != ''
    issearchparm   = "%"+@newempsearch.to_s+"%"
    iswhere        += " AND  lds_name LIKE '#{issearchparm}' OR  lds_mobile LIKE '#{issearchparm}' OR lds_email LIKE '#{issearchparm}'"
  end 
  if ldstype !=nil && ldstype !=''         
       session[:reqs_lds_type]     = ldstype       
  end
   iswhere        += " AND  lds_type='#{ldstype}'"
  objist     =   MstLedger.where(iswhere).paginate(:page =>@pages,:per_page => 10).order('lds_membno ASC')
  return objist
end

private
def print_excel_listed
  ldstype    =  session[:reqs_lds_type]
  membsearch =  session[:req_search_member]
  iswhere    = "lds_compcode ='#{@compcodes}'"
  if membsearch != nil && membsearch != ''
    issearchparm   = "%"+membsearch.to_s+"%"
    iswhere        += " AND  lds_name LIKE '#{issearchparm}' OR  lds_mobile LIKE '#{issearchparm}' OR lds_email LIKE '#{issearchparm}'"
  end
   iswhere += " AND  lds_type='#{ldstype}'"
  arrs       = []
  objist     = MstLedger.select("mst_ledgers.*,'' as email,'' as offemail,'' as panno,'' as adharno,'' as mobileno,'' as mydesignation").where(iswhere).order('lds_membno ASC')
  if objist.length >0
    @ExcelList = objist
        objist.each do |newlds|
            newlds.email     = set_dct(newlds.lds_email)
            newlds.offemail  = set_dct(newlds.lds_officialemail)
            newlds.panno     = set_dct(newlds.lds_panno)
            newlds.adharno   = set_dct(newlds.lds_adharno)
            newlds.mobileno  = set_dct(newlds.lds_mobile)            
            dsobj            = get_sewdar_designation_detail(newlds.lds_designcode)
            if dsobj
              newlds.mydesignation = dsobj.ds_description
            end
            arrs.push newlds
        end
  end
  
  return arrs
end

private
def ledgers_params
  params[:lds_compcode]      = session[:loggedUserCompCode]
  params[:lds_name]          = params[:emp_name].to_s.strip ? params[:emp_name].to_s.strip : ''
  params[:lds_email]         = params[:emp_email].to_s.delete(' ')? set_ent(params[:emp_email].to_s.delete(' ')):''
  params[:lds_mobile]        = params[:emp_mobile].to_s.delete(' ') ? set_ent(params[:emp_mobile].to_s.delete(' ')):''
  params[:lds_panno]         = params[:emp_pano].to_s.delete(' ')!='' ? set_ent(params[:emp_pano].to_s.delete(' ')):''
  params[:lds_adharno]       = params[:emp_adhar_no].to_s.delete(' ')!=''  ? set_ent(params[:emp_adhar_no].to_s.delete(' ')):''
  params[:lds_type]          = params[:lds_type]!='' && params[:lds_type]!=nil ? params[:lds_type].to_s.strip : ''  
  params[:lds_pin]           = params[:emp_pin_no].to_s.delete(' ')!=''  ? params[:emp_pin_no].to_s.strip : ''

  params[:lds_state]         = 0
  if params[:mid].to_i >0
      params[:lds_membno]      =  params[:lds_membno] !=nil && params[:lds_membno] !='' ?  params[:lds_membno] : ''
  else
      params[:lds_membno]      =  generate_member_series()
  end
  imagprofiles = ""
   if params[:attachpropfile] == '' || params[:attachpropfile]== nil
       params[:lds_profile] = ''
   end
   sewimages  = params[:attachpropfile] !=nil && params[:attachpropfile] !='' ?  File.basename(params[:attachpropfile]) : ''
   if sewimages.to_s != "personnel_boy.png"
       if  sewimages != '' && sewimages != nil
           imagprofiles    = upload_users_image()
       end
   end
   if imagprofiles == nil  || imagprofiles == ''
      if params[:currentcomplogo] != '' && params[:currentcomplogo] != nil
          imagprofiles = params[:currentcomplogo]
      end
   end
  params[:lds_profile] = imagprofiles
  panfiles             = nil
  adharfiles           = nil
    if params[:pancardFile]=='' || params[:pancardFile]==nil
       params[:lds_pan] = ''
    end
    if params[:pancardFile]!= '' && params[:pancardFile]!=nil
        panfiles               = process_pancard_file()
        params[:lds_pan]       = panfiles
    end
    if panfiles == nil
      if params[:currentpanfile]!= '' && params[:currentpanfile]!= nil
         params[:lds_pan] = params[:currentpanfile]
      end
    end

    if params[:adharFile]=='' || params[:adharFile]==nil
       params[:lds_adhar] = ''
    end
    if params[:adharFile]!= '' && params[:adharFile]!=nil
        adharfiles           = process_adhar_files()
        params[:lds_adhar]   = adharfiles
    end
    if adharfiles == nil
      if params[:currentadharfile]!= '' && params[:currentadharfile]!= nil
         params[:lds_adhar] = params[:currentadharfile]
      end
    end

  dobs = 0
  if params[:lds_dob] !=nil && params[:lds_dob] !=''
     dobs = year_month_days_formatted(params[:lds_dob])
  end

  params[:lds_dob]              = dobs
  params[:lds_pan_title]        = params[:pancardTitle]!=nil && params[:pancardTitle]!='' ? params[:pancardTitle] : ''
  params[:lds_adhar_title]      = params[:adharTitle]!=nil && params[:adharTitle]!='' ? params[:adharTitle] : ''
  params[:lds_officialemail]    = params[:lds_officialemail]!=nil && params[:lds_officialemail]!='' ? set_ent(params[:lds_officialemail]) : ''
  params[:lds_address]          = params[:lds_address]!=nil && params[:lds_address]!='' ? params[:lds_address] : ''
  params[:lds_prefix]           = params[:lds_prefix] !=nil && params[:lds_prefix] !='' ? params[:lds_prefix] : ''
  params[:lds_personal_mobno]   = params[:lds_personal_mobno]!=nil && params[:lds_personal_mobno]!='' ? set_ent(params[:lds_personal_mobno]) : ''
  params[:lds_location]         = params[:lds_location]!=nil && params[:lds_location]!='' ? params[:lds_location] : 0
  params[:lds_sublocation]      = params[:lds_sublocation]!=nil && params[:lds_sublocation]!='' ? params[:lds_sublocation] : 0
  
  params.permit(:lds_compcode,:lds_personal_mobno,:lds_location,:lds_sublocation,:lds_dob,:lds_designcode,:lds_prefix,:lds_address,:lds_membno,:lds_officialemail,:lds_name,:lds_type,:lds_panno,:lds_adharno,:lds_mobile,:lds_email,:lds_address,:lds_pin,:lds_state,:lds_profile,:lds_adhar,:lds_adhar_title,:lds_pan,:lds_pan_title)
end





private
def corp_image_size
  @paXths = Rails.root.join "public","ledger","profile","thumb"
  file = "#{@paths}/"+@Imgs
  if File.exist?(file)
    image = MiniMagick::Image.new(file)
    image.resize "80x80"
    image.write("#{@paXths}/"+@Imgs)
  end
end

private
  def upload_users_image
   
    dirsewad      =  Rails.root.join "public", "images", "ledger","profile"
    dirsewathm    =  Rails.root.join "public", "images", "ledger","profile","thumb"
    extractfile   =  params[:attachpropfile]
    start         =  extractfile.index(',') + 1
    file          =  set_dct(extractfile[start..-1] )
    file_type     =  "jpg"
    new_name_file =  Time.now.to_i
    new_file_type =  "#{new_name_file}." + file_type
    #### DELETE ORIGIN #############
    if file != '' && file != nil
       if params[:currentcomplogo]!= '' && params[:currentcomplogo]!= nil
           unlinkpath   = Rails.root.join "public", "images", "ledger","profile",params[:currentcomplogo].to_s
           curpath1     = Rails.root.join "public","ledger","profile","thumb",params[:currentcomplogo].to_s
           process_unlinks_the_files(unlinkpath)
           process_unlinks_the_files(curpath1)
       end
    end
    ######### Upload here ######################
    File.open("#{dirsewad}/" + new_file_type, "wb")  do |f|
      f.write(file)
    end
    File.open("#{dirsewathm}/" + new_file_type, "wb")  do |f|
      f.write(file)
    end
    @Imgs = new_file_type
   # corp_image_size
    return new_file_type



  end


  private
def process_enquiry_files(compcodes,files,docid,fileid,cfl_title)
      if  fileid!=nil && fileid!='' && files!=nil && files!=''
             selobj = MstLedgerAttachment.where("sma_compcode=? AND id=?",compcodes,docid).first
              if selobj
                  selobj.update(:sma_attachment=>files,:sma_title=>cfl_title)
              else
                  objenq = MstLedgerAttachment.new(:sma_compcode=>compcodes,:sma_siteno=>fileid,:sma_attachment=>files,:sma_title=>cfl_title)
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
  selobj = MstLedgerAttachment.where("sma_compcode=? AND id=?",compcodes,docid).first
  if selobj
    filname      = selobj.sma_attachment
    path_to_file = Rails.root.join "public", "images","ledger", "other",filname
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
    @paths        = Rails.root.join "public", "images","ledger", "other"
    ######### Upload here ######################
    File.open("#{@paths}/" +new_file_name, "wb")  do |f|
      f.write(file)
    end
    return new_file_name
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
  



######## PROCESS PAN FILES ##############
private
  def process_pancard_file
    file_name     =  params[:pancardFile].original_filename  if  ( params[:pancardFile] !='')
    file          =  params[:pancardFile].read
    file_type     =  file_name.split('.').last
    new_name_file = Time.now.to_i
    new_file_type = "#{new_name_file}." + file_type
    @panImgs      = new_file_type
    panpath       = Rails.root.join "public", "images", "ledger","pan"
    #### Delete Origins#############
    if params[:pancardFile]!= '' && params[:pancardFile]!= nil
       if params[:currentpanfile]!= '' && params[:currentpanfile]!= nil
          unlinkpath    = Rails.root.join "public", "images", "ledger","pan",params[:currentpanfile].to_s
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
    adharpath     =  Rails.root.join "public", "images", "ledger","adhar"
    #### DELETE ORIGIN #############
    if params[:adharFile]!= '' && params[:adharFile]!= nil
       if params[:currentadharfile]!= '' && params[:currentadharfile]!= nil
          unlinkpath    = Rails.root.join "public", "images", "ledger","adhar",params[:currentadharfile].to_s
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
def generate_member_series
  ldstype      = params[:member]!=nil && params[:member] !='' ? set_dct(params[:member]) : params[:lds_type]
  prefixobj    = get_common_prefix('Member')
  @Startx      = prefixobj ? prefixobj.sn_length : ''
  @isCode      = 0
  @recCodes    = MstLedger.select("lds_membno").where(["lds_compcode = ? AND lds_membno<>''", @compcodes]).last
  if @recCodes
     @isCode1    = @recCodes.lds_membno.to_s.gsub(/[^\d]/, '')
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
