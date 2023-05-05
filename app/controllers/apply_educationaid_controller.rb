class ApplyEducationaidController < ApplicationController
	before_action :require_login
	before_action :allowed_security
	skip_before_action :verify_authenticity_token,:only=>[:index,:search,:educationaid_list,:ajax_process]
	include ErpModule::Common
	helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_class_series,:get_sewdar_designation_detail,:get_all_department_detail,:get_ho_location,:get_global_office_detail
	helper_method :format_oblig_date,:get_family_relation_detail,:get_all_department_detail,:get_first_my_sewadar,:get_personal_information
	helper_method :global_sewadar_kyc_information,:get_global_users,:get_member_listed,:get_common_unversity_firstrecord,:get_voucher_detail
	def index
		@authorizedId  =   session[:autherizedUserId]
		@compCodes     =   session[:loggedUserCompCode]
		tdslimits      =   0		
		@lastEntryNo   =   last_entry_no
		@HeadHrp       =   MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
		if @HeadHrp
			tdslimits    = @HeadHrp.hph_deductedlimited
			@HrMonths    = get_month_listed_data(@HeadHrp.hph_months)
			@Hryears     = @HeadHrp.hph_years
		end
		    
			@mydepartcode     = nil
			mydeprtcode       = ""
			@ListEducation    = nil
			@AlldependentList = nil
			@Allsewobj        = nil
			if session[:sec_sewdar_code]
				sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code])
				if sewobjs
					@mydepartcode = sewobjs.sw_depcode
					mydeprtcode   = sewobjs.sw_depcode
				end
			end
			if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
		   	    @sewDepart       = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment ='' AND departCode = ? ",@compCodes,mydeprtcode).order("departDescription ASC")
				   if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
					  @Allsewobj       = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_sewcode = ? AND sw_leavingdate='0000-00-00'",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")
				   else
					 @Allsewobj       = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_depcode = ? AND sw_leavingdate='0000-00-00'",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")
				   end
				      
			else
				@sewDepart       = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compCodes).order("departDescription ASC")
			end   
		
	
		if params[:id] !=nil && params[:id] != ''
			docs = params[:id].to_s.split("_")
			@compDetail  = MstCompany.where(["cmp_companycode = ?", @compCodes]).first
			voucherdata  = pending_print_education_voucher_report(docs[1])
			rooturl      = "#{root_url}"
			if docs[1] == 'prt'	
			
				respond_to do |format|
				  format.html
				  format.pdf do
					pdf = ApproveeducationsPdf.new(voucherdata,@compDetail,rooturl,@username,@inchargename)
					send_data pdf.render,:filename => "1_pending_vouchers_report.pdf", :type => "application/pdf", :disposition => "inline"
				  end
				end
			elsif docs[1] == 'vrt'				
				respond_to do |format|
				  format.html
				  format.pdf do
					pdf = VieweducationPdf.new(voucherdata,@compDetail,rooturl,@username,@inchargename)
					send_data pdf.render,:filename => "1_pending_vouchers_report.pdf", :type => "application/pdf", :disposition => "inline"
				  end
				end	
			else
				

					@ListEducation = TrnApplyEducationAid.where("aea_compcode = ? AND id = ?",@compCodes,params[:id].to_i).first
					if @ListEducation
						@Allsewobj     = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_depcode = ? AND sw_leavingdate='0000-00-00'",@compCodes,@ListEducation.aea_departcode).order("sw_sewadar_name ASC")
						if  @ListEducation.aea_applyfor.to_s == 'dependent'
							@AlldependentList =  MstSewdarKycFamilyDetail.where("skf_compcode =? AND skf_relation IN('Son','Daughter') AND skf_sewcode =? AND skf_family_dependent='Y' AND skf_married_status<>'Y' AND skf_datebirth<>'0000-00-00' AND (DATE_FORMAT(FROM_DAYS(DATEDIFF(now(),skf_datebirth)), '%Y')+0)<=25",@compCodes,@ListEducation.aea_sewadarcode).order("skf_dependent ASC")
						end
					
					end	

			end
			
		end
	end

	def show
	   @compcodes  = session[:loggedUserCompCode]		 
	 end
	
   
	def ajax_process
		if params[:identity] !=nil && params[:identity]  != '' && params[:identity] == 'Y'
		   get_sewadar_amount_list();
		   return
		end

end
	def educationaid_list
		@compCodes  =  session[:loggedUserCompCode]
		@printPdf    = "apply_educationaid/1_prt_pending_voucher_report.pdf"
		@printXPdf   = "apply_educationaid/1_vrt_views_voucher_report.pdf"
		    @mydepartcode     = nil
			mydeprtcode       = ""			
			
			if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
				if session[:sec_sewdar_code] !=nil
					sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
					if sewobjs
					  @mydepartcode = mydeprtcode = sewobjs.sw_depcode
					end
				end
		  elsif session[:requestuser_loggedintp]  && ( session[:requestuser_loggedintp] == 'ec' || session[:requestuser_loggedintp] == 'cod' )
			
			  hodobjs = get_hod_listed_sewadar(session[:sec_ecmem_code])
			  if hodobjs       
				ecodes     = hodobjs.lds_membno  
				fdepart    = ""          
				deprtobj = get_all_coordinate_department(ecodes)
				  if deprtobj.length >0
					  deprtobj.each do |newdpts|
						fdepart += "'"+newdpts.departCode.to_s+"',"
					  end
				  end    
				  if fdepart !=nil && fdepart !=''
					  fdepart = fdepart.to_s.chop
				  end
					@mydepartcode = mydeprtcode = fdepart             
			   
			  end
		  end

		  
		  catcode = ""
		  if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
			@sewDepart        =   Department.select("compCode,departDescription,departCode").where("compCode = ? AND subdepartment = '' AND departCode = ?",@compCodes, @mydepartcode ).order("departDescription ASC")
			@newsewdarList    =   MstSewadar.where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")
				if @newsewdarList
					catcode = @newsewdarList[0].sw_catcode	
				end
		  elsif session[:requestuser_loggedintp]  && ( session[:requestuser_loggedintp] == 'ec' || session[:requestuser_loggedintp] == 'cod' )
			  if @mydepartcode !=nil && @mydepartcode !=''
				  @sewDepart         =   Department.select("compCode,departDescription,departCode").where("compCode = '#{@compCodes}' AND subdepartment ='' AND departCode IN(#{@mydepartcode})").order("departDescription ASC")
			  end
				@newsewdarList     =   MstSewadar.where("sw_compcode = ? AND sw_depcode = ?",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")
		  else
				@sewDepart         =  Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compCodes).order("departDescription ASC")  
		  end  
		  if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' 
				if catcode !=nil && catcode !=''
					@sewadarCategory   = MstSewadarCategory.where("sc_compcode =? AND sc_catcode=?",@compCodes,catcode).order("sc_position ASC")
				end			
		  else
			        @sewadarCategory   = MstSewadarCategory.where("sc_compcode =? AND sc_catcode NOT IN('DWD','VIV')",@compCodes).order("sc_position ASC")
		  end

		@printPath          = "apply_educationaid/1_eduaid_report.pdf"
		@MarriageListing = get_marriage_listing()
	end

	def create
		@compCodes  =  session[:loggedUserCompCode]
		isFlags     = true
		mid           = params[:mid]
		begin
		if params[:ama_requestno] == '' || params[:ama_requestno] == nil
		   flash[:error] =  "Request no is required."
		   isFlags = false
		elsif params[:ama_requestdate] == '' || params[:ama_requestdate] == nil
		   flash[:error] =  "Request date is required"
		   isFlags = false
		elsif params[:ama_departcode] == '' || params[:ama_departcode] == nil
			flash[:error] =  "department date is required"
			isFlags = false   
		elsif params[:ama_sewadarcode] == '' || params[:ama_sewadarcode] == nil
			flash[:error] =  "Sewadar name or code  required"
			isFlags = false   		
		
		else
			
			aea_status    = params[:aea_status] !=nil && params[:aea_status] !='' ? params[:aea_status] : ''
		  if params[:updateremark].to_s == 'RMK'
			    if params[:aea_remark].to_s.strip == nil || params[:aea_remark].to_s.strip == ''
					 if params[:aea_status] == 'R'
						flash[:error] = "Remark should not be blank"
				        isFlags       = false
					 end
					 
				end
				if isFlags
					chkdeprtobj   = TrnApplyEducationAid.where("aea_compcode = ? AND id = ?",@compCodes,mid).first
					if chkdeprtobj
						 if aea_status !=nil && aea_status !=''
							chkdeprtobj.update(:aea_status=>aea_status,:aea_remark=>params[:aea_remark].to_s.strip)
						 else
							chkdeprtobj.update(:aea_remark=>params[:aea_remark].to_s.strip)

						 end
						
							flash[:error] = "Remark updated successfully"
							isFlags       = true
					end
				end
		  else
		  departcode    = params[:ama_departcode].to_s.strip		
		  sewacode      = params[:ama_sewadarcode].to_s.strip
		  types         = params[:ama_applyfor].to_s.strip
		  dependent     = params[:ama_dependent].to_s.strip
		  myclassed     = params[:aea_forclass].to_s.strip
		  cursewacode   = params[:cursewacode].to_s.strip
		  curdepcode    = params[:curdependcode].to_s.strip
		  finadate      = started_finacial_dated(params[:ama_requestdate])
		  finadates     = finadate.to_s.split("/")      

		  if types.to_s == 'self'
				if mid.to_i >0
						if cursewacode.to_s!= sewacode.to_s
							
							chkdsobj      = TrnApplyEducationAid.where("aea_compcode = ? AND aea_sewadarcode = ? AND aea_status<>'R' AND aea_status<>'C' AND aea_requestdate >= '#{finadates[0]}' AND aea_requestdate <='#{finadates[1]}'",@compCodes,sewacode)
							if chkdsobj.length >0
								flash[:error] = "Education request is already applied"
								isFlags       = false
							end
					     end
				else
					chkdsobj      = TrnApplyEducationAid.where("aea_compcode = ? AND aea_sewadarcode = ? AND aea_status<>'R' AND aea_status<>'C' AND aea_requestdate >= '#{finadates[0]}' AND aea_requestdate <='#{finadates[1]}'",@compCodes,sewacode)
					if chkdsobj.length >0
						flash[:error] = "Education request is already applied"
						isFlags       = false
					end

				end
			elsif types.to_s == 'dependent'
				
				if mid.to_i >0
						if curdepcode.to_i != dependent.to_i
							chkdsobj      = TrnApplyEducationAid.where("aea_compcode = ? AND aea_dependent = ? AND aea_status<>'R' AND aea_status<>'C' AND aea_requestdate >= '#{finadates[0]}' AND aea_requestdate <='#{finadates[1]}'",@compCodes,dependent)
							if chkdsobj.length >0
								flash[:error] = "Education request is already applied"
								isFlags       = false
							end	
						end
				else
						chkdsobj      = TrnApplyEducationAid.where("aea_compcode = ? AND aea_dependent = ? AND aea_status<>'R' AND aea_status<>'C' AND aea_requestdate >= '#{finadates[0]}' AND aea_requestdate <='#{finadates[1]}'",@compCodes,dependent)
						if chkdsobj.length >0
							flash[:error] = "Education request is already applied"
							isFlags       = false
						end
				end

			end
				if types.to_s == 'self'
					if mid.to_i >0
						 if cursewacode.to_s!= sewacode.to_s
							chkdsobj      = TrnApplyEducationAid.where("aea_compcode = ? AND aea_sewadarcode = ? AND aea_forclass = ? AND aea_status<>'R' AND aea_status<>'C'",@compCodes,sewacode,myclassed)
							if chkdsobj.length >0
								flash[:error] = "This Education request is already applied against request no #{chkdsobj[0].aea_requestno} "
								isFlags       = false
							end
						 end		
					else
						chkdsobj      = TrnApplyEducationAid.where("aea_compcode = ? AND aea_sewadarcode = ? AND aea_forclass = ? AND aea_status<>'R' AND aea_status<>'C'",@compCodes,sewacode,myclassed)
						if chkdsobj.length >0
							flash[:error] = "This Education request is already applied against request no #{chkdsobj[0].aea_requestno} "
							isFlags       = false
						end

					end
						
				elsif types.to_s == 'dependent'
					if mid.to_i >0
						 if curdepcode.to_i != dependent.to_i
							chkdsobj      = TrnApplyEducationAid.where("aea_compcode = ? AND aea_dependent = ? AND aea_forclass = ? AND aea_status<>'R' AND aea_status<>'C'",@compCodes,dependent,myclassed)
								if chkdsobj.length >0
									flash[:error] = "This Education request is already applied against request no #{chkdsobj[0].aea_requestno} "
									isFlags       = false
								end
						 end		
					else
						chkdsobj      = TrnApplyEducationAid.where("aea_compcode = ? AND aea_dependent = ? AND aea_forclass = ? AND aea_status<>'R' AND aea_status<>'C'",@compCodes,dependent,myclassed)
						if chkdsobj.length >0
							flash[:error] = "This Education request is already applied against request no #{chkdsobj[0].aea_requestno} "
							isFlags       = false
						end

					end
				end
				if types.to_s == 'self'
						if isFlags					
						sewobjslisted = get_mysewdar_list_details(sewacode)
							if sewobjslisted
								dobslist = sewobjslisted.sw_date_of_birth
								if dobslist !=nil && dobslist !=''
									myages   = get_dob_calculate(year_month_days_formatted(dobslist))
									if myages.to_i >25
										flash[:error] = "Could not apply more than 25 years."
										isFlags       = false
									end
								else
									flash[:error] = "Could not apply due to date of birth is blank."
									isFlags       = false		
								end
								
							end
						end
				end		
		  		if isFlags
						if mid.to_i >0
					
								if isFlags
									chkdeprtobj   = TrnApplyEducationAid.where("aea_compcode = ? AND id = ?",@compCodes,mid).first
									if chkdeprtobj
										chkdeprtobj.update(education_params)
											flash[:error] = "Data updated successfully"
											isFlags       = true
									end
								end
					
						else
								
								if isFlags
									deprtsvobj = TrnApplyEducationAid.new(education_params)
									if deprtsvobj.save
										flash[:error] = "Data saved successfully"
										isFlags       = true
									end
								end
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
		 if !isFlags
			if mid.to_i >0
				redirect_to  "#{root_url}apply_educationaid/"+mid.to_s
			else
				redirect_to  "#{root_url}apply_educationaid"
			end
		  
		 else
		   redirect_to  "#{root_url}apply_educationaid/educationaid_list"
		 end
	end
	#### NO CANCEL DATA ###########
	def cancel
		@compcodes = session[:loggedUserCompCode]
		if params[:id].to_i >0
			 @Listobj =  TrnApplyEducationAid.where("aea_compcode =? AND id = ?",@compcodes,params[:id]).first
			 if @Listobj
					 @Listobj.update(:aea_status=>'C')
					 flash[:error] =  "Data cancelled successfully."
					 isFlags       =   true
					 session[:isErrorhandled] = nil
			 end
		end
		redirect_to "#{root_url}apply_educationaid/educationaid_list"
	 end

	def destroy
		@compcodes = session[:loggedUserCompCode]
		# if params[:id].to_i >0
		# 	 @Listobj =  TrnApplyEducationAid.where("aea_compcode =? AND id = ?",@compcodes,params[:id]).first
		# 	 if @Listobj
		# 			 @Listobj.destroy
		# 			 flash[:error] =  "Data deleted successfully."
		# 			 isFlags       =  true
		# 			 session[:isErrorhandled] = nil
		# 	 end
		# end
		# redirect_to "#{root_url}apply_educationaid/educationaid_list"
	 end

	private
	def last_entry_no
	  @isCode     = 0
	  @Startx     = '0000'
	  @recCodes   = TrnApplyEducationAid.where(["aea_compcode =? AND aea_requestno >0 ",@compCodes]).order('aea_requestno DESC').first
	  if @recCodes
	  @isCode    = @recCodes.aea_requestno.to_i
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

 private
 def education_params
      @isCode     = 0
	  @Startx     = '0000'
	  @recCodes   = TrnApplyEducationAid.where(["aea_compcode =? AND aea_requestno >0 ",@compCodes]).order('aea_requestno DESC').first
	  if @recCodes
	  @isCode    = @recCodes.aea_requestno.to_i
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
			params[:aea_requestno] = params[:ama_requestno] 
	    else
			params[:aea_requestno] = @sumXOfCode
		end
      
		dirf   = "education/a1"
		dirs   = "education/a2"
		dirths = "education/a3"
    rqdated  = 0
    if params[:ama_requestdate] !=nil && params[:ama_requestdate] !=''
      rqdated = year_month_days_formatted(params[:ama_requestdate])
    end
	currfilefirst = params[:currfilefirst] 
	currfilesecond = params[:currfilesecond] 
	currfilethird  = params[:currfilethird] 
	imagefirst  = ""
	imagesecond = ""
	imagethird  = ""
	if params[:ama_attachfirst] !=nil && params[:ama_attachfirst] !=''
		imagefirst = process_files(params[:ama_attachfirst],currfilefirst,dirf)

	end
	if imagefirst == nil || imagefirst == ''
		if currfilefirst !=nil && currfilefirst !='' 
			imagefirst = currfilefirst
		end
    end

	if params[:ama_attachsecond] !=nil && params[:ama_attachsecond] !=''
		imagesecond = process_files(params[:ama_attachsecond],currfilefirst,dirs)

	end
	if imagesecond == nil || imagesecond == ''
		if currfilesecond !=nil && currfilesecond !='' 
			imagesecond = currfilesecond
		end
    end
	if params[:ama_attachthird] !=nil && params[:ama_attachthird] !=''
		imagethird = process_files(params[:ama_attachthird],currfilefirst,dirths)

	end
	if imagethird == nil || imagethird == ''
		if currfilethird !=nil && currfilethird !='' 
			imagethird = currfilethird
		end
    end
	params[:ama_attachfirst]  = imagefirst
	params[:aea_attachsecond] = imagesecond
	params[:aea_attachthird]  = imagethird
    params[:aea_compcode]     = session[:loggedUserCompCode]
    params[:aea_departcode]   = params[:ama_departcode] !=nil && params[:ama_departcode] !='' ? params[:ama_departcode] : ''
    params[:aea_sewadarcode]  = params[:ama_sewadarcode]  !=nil && params[:ama_sewadarcode]  !='' ? params[:ama_sewadarcode]  : ''
    params[:aea_applyfor]     = params[:ama_applyfor] !=nil && params[:ama_applyfor] !='' ? params[:ama_applyfor] : ''



	params[:aea_dependent]         = params[:ama_dependent] !=nil && params[:ama_dependent] !='' ? params[:ama_dependent] : 0
	params[:aea_titlefirst]        = params[:ama_titlefirst] !=nil && params[:ama_titlefirst] !='' ? params[:ama_titlefirst] : ''
	params[:aea_tiitlesec]         = params[:ama_tiitlesec] !=nil && params[:ama_tiitlesec] !='' ? params[:ama_tiitlesec] : ''
	params[:aea_titlethird]        = params[:ama_titlethird] !=nil && params[:ama_titlethird] !='' ? params[:ama_titlethird] : ''
	params[:aea_forclass]          = params[:aea_forclass] !=nil && params[:aea_forclass] !='' ? params[:aea_forclass] : 0
	params[:aea_amount]            = params[:aea_amount] !=nil && params[:aea_amount] !='' ? params[:aea_amount] : 0
	params[:aea_remark]            = params[:aea_remark] !=nil && params[:aea_remark] !='' ? params[:aea_remark] : ''	
    params[:aea_requestdate]       = rqdated
    params.permit(:aea_compcode,:aea_amount,:aea_remark,:aea_requestno,:aea_requestdate,:aea_departcode,:aea_sewadarcode,:aea_applyfor,:aea_dependent,:ama_attachfirst,:aea_attachsecond,:aea_attachthird,:aea_titlefirst,:aea_tiitlesec,:aea_titlethird,:aea_forclass)
 end

 private
 def get_marriage_listing
	 compcode     = session[:loggedUserCompCode]
	 if params[:server_request]!=nil && params[:server_request]!= ''
		session[:aereq_filteroptioned] = nil	
		session[:aeeareqs_voucher_department] = nil
		session[:aeeareqs_voucher_category] = nil
		session[:aeeareqs_sewadar_status] = nil
		session[:aeeareqs_sewadar_requesttype] = nil
		session[:aeeareqs_search_from_date] = nil
		session[:aeeareqs_search_upto_date] = nil
		session[:aeeareqs_requestaccording] = nil
	 end
	 
	 voucher_department  = params[:voucher_department] !=nil && params[:voucher_department] !='' ? params[:voucher_department] : session[:aeeareqs_voucher_department]
	 voucher_category    = params[:voucher_category] !=nil && params[:voucher_category] !='' ? params[:voucher_category] : session[:aeeareqs_voucher_category]
	 sewadar_status      = params[:sewadar_status] !=nil && params[:sewadar_status] !='' ? params[:sewadar_status] : session[:aeeareqs_sewadar_status]
	 sewadar_requesttype = params[:sewadar_requesttype] !=nil && params[:sewadar_requesttype] !='' ? params[:sewadar_requesttype] : session[:aeeareqs_sewadar_requesttype]
	 search_from_date    = params[:search_from_date] !=nil && params[:search_from_date] !='' ? params[:search_from_date] : session[:aeeareqs_search_from_date]
	 search_upto_date    = params[:search_upto_date] !=nil && params[:search_upto_date] !='' ? params[:search_upto_date] : session[:aeeareqs_search_upto_date]
     requestaccording    = params[:requestaccording] !=nil && params[:requestaccording] !='' ? params[:requestaccording] : session[:aeeareqs_requestaccording]
	 
	 
	 
	 
	 filteroption = params[:filteroption] !=nil && params[:filteroption] != '' ? params[:filteroption] : session[:req_filteroptioned]
	 iswhere      = "aea_compcode ='#{compcode}'"
	 if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
		iswhere  += " AND aea_sewadarcode ='#{session[:sec_sewdar_code]}' AND aea_departcode ='#{@mydepartcode}' "
	 elsif session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'stf'
		iswhere  += " AND aea_departcode ='#{@mydepartcode}'"
	 else
			if voucher_department !=nil && voucher_department !=''
				session[:aeeareqs_voucher_department]   = voucher_department
				@voucher_department                  = voucher_department
				iswhere     += " AND aea_departcode ='#{voucher_department}' AND aea_departcode<>''"
			end	
	 end
	 
	 if filteroption !=nil && filteroption !=''
			session[:req_filteroptioned] = filteroption	
			@filteroption                = filteroption	
			if filteroption.to_s == 'all'
			else
				 if filteroption == 'N'
					iswhere  += " AND ( aea_status ='N' OR aea_status = '' )"
				 else
					iswhere  += " AND aea_status ='#{filteroption}'"
				 end
				
			end
	 end

	 ### OTHER FILTERS ##########
		
			
		nflags = false
		jons   = ""
		if voucher_category != nil && voucher_category !='' 
		  session[:aeeareqs_voucher_category] = voucher_category
		  @voucher_category  = voucher_category
		  iswhere   += " AND sw_catgeory LIKE '%#{voucher_category}%'"
		  jons      =  " LEFT JOIN  mst_sewadars swd on(aea_compcode = sw_compcode AND aea_sewadarcode = sw_sewcode)"
		  nflags = true
		end
		
			
		if sewadar_status !=nil && sewadar_status !=''
			if sewadar_status == 'N' 
			  iswhere   += " AND ( aea_status ='' OR aea_status ='N' )"
			else
			  iswhere   += " AND aea_status ='#{sewadar_status}'"
			end
		  
		  @sewadar_status                = sewadar_status
		  session[:aeeareqs_sewadar_status] = sewadar_status
		end
		if sewadar_requesttype != nil && sewadar_requesttype !=''
			iswhere   += " AND aea_applyfor     ='#{sewadar_requesttype}'"
			@sewadar_requesttype                = sewadar_requesttype
			session[:aeeareqs_sewadar_requesttype] = sewadar_requesttype
		end
		cflags = false
		if requestaccording !=nil && requestaccording !=''
			cflags = true
			session[:aeeareqs_requestaccording] = requestaccording
			if search_from_date !=nil && search_from_date !=''
				session[:aeeareqs_search_from_date]     = search_from_date
				@search_from_date                     = search_from_date
				iswhere     += " AND vd_voucherdate >='#{year_month_days_formatted(search_from_date)}' "			
			end
			if search_upto_date !=nil && search_upto_date !=''
				session[:aeeareqs_search_upto_date]     = search_upto_date
				@search_upto_date                     = search_upto_date
				iswhere     += " AND vd_voucherdate <='#{year_month_days_formatted(search_upto_date)}' "
			end
			@requestaccording = requestaccording
		else
				if search_from_date !=nil && search_from_date !=''
					session[:aeeareqs_search_from_date]     = search_from_date
					@search_from_date                     = search_from_date
					iswhere     += " AND aea_approvedated >='#{year_month_days_formatted(search_from_date)}' "			
				end
				if search_upto_date !=nil && search_upto_date !=''
					session[:aeeareqs_search_upto_date]     = search_upto_date
					@search_upto_date                     = search_upto_date
					iswhere     += " AND aea_approvedated <='#{year_month_days_formatted(search_upto_date)}' "
				end
		end		
		if nflags
			if cflags
				jons  +=  " JOIN  trn_voucher_details vds on(vd_compcode = aea_compcode AND vd_requestno = aea_requestno AND vd_requestfor='Education')"
			end
		else
			if cflags
				jons  +=  " JOIN  trn_voucher_details vds on(vd_compcode = aea_compcode AND vd_requestno = aea_requestno AND vd_requestfor='Education')"
			end
		end
		isselect       = "trn_apply_education_aids.*"
		if nflags 
			isselect       += ",swd.id as swedId"
		end
		if cflags
			isselect       += ",vds.id as VdsId"
		end
	 ##### END OTHER FILTER #########
	 if nflags || cflags
       
        listmarrigeobj = TrnApplyEducationAid.select(isselect).joins(jons).where(iswhere).order("aea_requestno DESC")
     else
        listmarrigeobj = TrnApplyEducationAid.where(iswhere).order("aea_requestno DESC")
     end	 
	 return listmarrigeobj

 end

 private
 def get_sewadar_amount_list
	compcode      = session[:loggedUserCompCode]
	sewacode      = params[:sewacode]
	forclass      = params[:forclass]
	types         = params[:types]
	
	amounts       = ""
	apobjs        = MstEducationalParameter.where("ep_compcode =? ",compcode).first
	sewaobj       = get_office_global_data(sewacode)
	newsewdar     = get_mysewdar_list_details(sewacode)
	genders       = ""
	totalsewa     = 0
	catcode       = ""
			if newsewdar
				genders = newsewdar.sw_gender 
				catcode = newsewdar.sw_catcode 			    
			end
			if sewaobj
				ep_fromfirstto = apobjs.ep_fromfirstto
				ep_uptofifth   = apobjs.ep_uptofifth
				ep_fromsixto   = apobjs.ep_fromsixto
				ep_uptotwelth  = apobjs.ep_uptotwelth

				joindated = sewaobj.so_joiningdate 
				 if joindated !=nil && joindated !=''
					totalsewa = get_dob_calculate(year_month_days_formatted(joindated))
					if catcode == 'SDP'
							if totalsewa.to_f  >=1								
								 if forclass.to_i >=ep_fromfirstto.to_i && forclass.to_i <=ep_uptofifth.to_i
									amounts = apobjs.ep_firstfifthamt
								 elsif forclass.to_i >=ep_fromsixto.to_i && forclass.to_i <=ep_uptotwelth.to_i
									 amounts = apobjs.ep_sixtotwelthamt
								elsif forclass.to_i == 13
									amounts = apobjs.ep_univfirstyearamt
								elsif forclass.to_i == 14
									amounts = apobjs.ep_univsecondyearamt
								elsif forclass.to_i == 15
									amounts = apobjs.ep_univthirdamt
								elsif forclass.to_i == 16
									amounts = apobjs.ep_postgraduateamt
								elsif forclass.to_i == 17
									amounts = apobjs.ep_postgraduatesecamt
								end
							end
					elsif catcode == 'VIT'
						if totalsewa.to_f  >=3								
							if forclass.to_i >=ep_fromfirstto.to_i && forclass.to_i <=ep_uptofifth.to_i
								amounts = apobjs.ep_firstfifthamt
							 elsif forclass.to_i >=ep_fromsixto.to_i && forclass.to_i <=ep_uptotwelth.to_i
								 amounts = apobjs.ep_sixtotwelthamt
							elsif forclass.to_i == 13
								amounts = apobjs.ep_univfirstyearamt
							elsif forclass.to_i == 14
								amounts = apobjs.ep_univsecondyearamt
							elsif forclass.to_i == 15
								amounts = apobjs.ep_univthirdamt
							elsif forclass.to_i == 16
								amounts = apobjs.ep_postgraduateamt
							elsif forclass.to_i == 17
								amounts = apobjs.ep_postgraduatesecamt
							end
						end
				 end
						

				 end
				## check age list ######	
			end
			isflags = true
			respond_to do |format|
				format.json { render :json => { 'data'=>amounts,:totalsewa=>totalsewa,:catcode=>catcode, :status=>isflags} }
			end
 end

 private
 def get_all_formats_data
  @compCodes   = session[:loggedUserCompCode]
  if session[:req_printsewacode] !=nil && session[:req_printsewacode] !=''  
	         @EducationAid    = get_education_aid_details(@compCodes,session[:req_printsewacode])    
			if @EducationAid  
			
			@seawdarsobj     = MstSewadar.where("sw_compcode =? AND sw_sewcode = ?",@compCodes,@EducationAid.aea_sewadarcode).first  
   			if @seawdarsobj
					@sewadarpersonal = get_personal_information(@compCodes,@seawdarsobj.sw_sewcode)
					@empChecked      = get_office_information(@compCodes,@seawdarsobj.sw_sewcode)
					@EmpKyc          = get_sewadar_kyc_information(@compCodes,@seawdarsobj.sw_sewcode)
					@EmpKycBank      = get_sewadar_kyc_bankdetail(@compCodes,@seawdarsobj.sw_sewcode)
					@EmpKycQulifc    = get_sewadar_kyc_qualification(@compCodes,@seawdarsobj.sw_sewcode)
					@EmpKycFamily    = get_sewadar_kyc_family(@compCodes,@seawdarsobj.sw_sewcode)
					@EmpWorkExp      = get_sewadar_work_experience(@compCodes,@seawdarsobj.sw_sewcode)
					
					 @EmpDepartment      = get_all_department_detail(@EducationAid.aea_departcode)
					if @sewadarpersonal
						@EmpStatelist    = get_state_detail(@sewadarpersonal.sp_pres_state)
						@EmpDistrict     = get_district_detail(@sewadarpersonal.sp_pres_distcity)
					end
					if @EmpDepartment
						@Hodlisted      = get_first_my_sewadar(@EmpDepartment.departHod)   
					end
					
				end
		    end

   end

 end

 private
 def get_personal_information(compcode,empcode)
		sewdarobj =  MstSewadarPersonalInfo.where("sp_compcode =? AND sp_sewcode =?",compcode,empcode).first
		return sewdarobj
 end

 private
 def get_office_information(compcode,empcode)
		sewdarobj =  MstSewadarOfficeInfo.where("so_compcode =? AND so_sewcode =?",compcode,empcode).first
		return sewdarobj
 end

  private
 def get_roles_information(compcode,rspcode)
		sewdarobj =  MstResponsibility.where("rsp_compcode =? AND rsp_rspcode =?",compcode,rspcode).first
		return sewdarobj
 end

private
 def get_sewadar_kyc_information(compcode,sewcode)
	  sewdarobj =  MstSewadarKyc.where("sk_compcode =? AND sk_sewcode =?",compcode,sewcode).first
	  return sewdarobj
 end
 private
 def get_sewadar_kyc_bankdetail(compcode,sewcode)
	  sewdarobj =  MstSewadarKycBank.where("skb_compcode =? AND sbk_sewcode =?",compcode,sewcode).first
	  return sewdarobj
 end

 private
 def get_sewadar_kyc_qualification(compcode,sewcode)
	  sewdarobj =  MstSewadarKycQualification.where("skq_compcode =? AND skq_sewcode = ?",compcode,sewcode).order("skq_passingyear DESC")
	  return sewdarobj
 end

 private
 def get_sewadar_kyc_family(compcode,sewcode)
	  sewdarobj =  MstSewdarKycFamilyDetail.where("skf_compcode =? AND skf_sewcode =?",compcode,sewcode).order("skf_dependent ASC")
	  return sewdarobj
 end

 private
 def get_sewadar_work_experience(compcode,sewcode)
	  sewdarobj =  MstSewadarWorkExperience.where("swe_compcode =? AND swe_sewcode =?",compcode,sewcode).order("swe_employer ASC")
	  return sewdarobj
 end
 private
 def get_education_aid_details(compcode,uid)
	  sewdarobj =  TrnApplyEducationAid.where("aea_compcode =? AND id=?",compcode,uid).first
	  return sewdarobj
 end

 private
 def get_voucher_detail(requestno)
	 compcodes = session[:loggedUserCompCode]
	 objx      = TrnVoucherDetail.where(["vd_compcode = ? AND vd_requestno = ? AND vd_status<>'C'",compcodes,requestno]).first
	 return objx
 end

 private
 def pending_print_education_voucher_report(type="")
	arrobj              = []	
	filteroption        = session[:req_filteroptioned]
	voucher_department  = session[:aeeareqs_voucher_department]
	voucher_category    = session[:aeeareqs_voucher_category]
	sewadar_status      = session[:aeeareqs_sewadar_status]
	sewadar_requesttype = session[:aeeareqs_sewadar_requesttype]
	search_from_date    = session[:aeeareqs_search_from_date]
	search_upto_date    = session[:aeeareqs_search_upto_date]
	requestaccording    = session[:aeeareqs_requestaccording]
   iswhere   = "aea_compcode = '#{@compCodes}'"
   if type !=nil && type !='' && type =='vrt'
	iswhere   += " AND aea_voucherno <>''"
   end
   if voucher_department !=nil && voucher_department !=''		
		@voucher_department  = voucher_department
		iswhere     += " AND aea_departcode ='#{voucher_department}' AND aea_departcode<>''"
  end
  ### OTHER FILTERS ##########	
			
  nflags = false
  jons   = ""
  if voucher_category != nil && voucher_category !='' 	
	iswhere   += " AND sw_catgeory LIKE '%#{voucher_category}%'"	
	nflags    = true
  end
  if sewadar_status !=nil && sewadar_status !=''
	  if sewadar_status == 'N' 
		iswhere   += " AND ( aea_status ='' OR aea_status ='N' )"
	  else
		iswhere   += " AND aea_status ='#{sewadar_status}'"
	  end	
	 @sewadar_status = sewadar_status
	
  end
  if sewadar_requesttype != nil && sewadar_requesttype !=''
	  iswhere   += " AND aea_applyfor     ='#{sewadar_requesttype}'"	  
  end

       cflags = false
		if requestaccording !=nil && requestaccording !=''
			cflags = true
			
			if search_from_date !=nil && search_from_date !=''
				
				iswhere     += " AND vd_voucherdate >='#{year_month_days_formatted(search_from_date)}' "			
			end
			if search_upto_date !=nil && search_upto_date !=''
				
				iswhere     += " AND vd_voucherdate <='#{year_month_days_formatted(search_upto_date)}' "
			end
			@requestaccording = requestaccording
		else
				if search_from_date !=nil && search_from_date !=''
					
					iswhere     += " AND aea_approvedated >='#{year_month_days_formatted(search_from_date)}' "			
				end
				if search_upto_date !=nil && search_upto_date !=''
					
					iswhere     += " AND aea_approvedated <='#{year_month_days_formatted(search_upto_date)}' "
				end
		end		
		if nflags
				if cflags
					jons  +=  "  JOIN  trn_voucher_details vds on(vd_compcode = aea_compcode AND vd_requestno = aea_requestno AND vd_requestfor='Education')"
				end
		else
				if cflags
					jons  +=  "  JOIN  trn_voucher_details vds on(vd_compcode = aea_compcode AND vd_requestno = aea_requestno AND vd_requestfor='Education')"
				end
		end
		isselect       = "trn_apply_education_aids.*"
		if nflags 
			isselect       += ",swd.id as swedId"
		end
		if cflags
			isselect       += ",vds.id as VdsId"
		end
	 ##### END OTHER FILTER #########
	

##### END OTHER FILTER #########
   if filteroption !=nil && filteroption !=''
	  if filteroption.to_s != 'all'
		if filteroption == 'N'
			iswhere  += " AND ( aea_status ='N' OR aea_status = '' )"
		 else
			iswhere  += " AND aea_status ='#{filteroption}'"
		 end
		 	
	  end	  
   end
  
   isselect  = "trn_apply_education_aids.*,'' as sewdarname,'' as refercode,'' as dsicode,'' as vd_userid,aea_applyfor as vd_requestfor"
   isselect  += ",'' as dates,'' as prevbalance,'' as department,'' as deginname,'' as totalsewa,'' as installamount,'' as selfdob,'' as classname"
   isselect  += ",'' as relatoinname,'' as aadhaarno,'' as doblist,'' as approvedby,'' as lds_profile,'' as selfadhar,'' as sw_gender"
   isselect  += ",'' as sanctionno,'' as sanctiondate,'' as financialYear,'' as schoolunversity"
   if nflags || cflags
		loansobj = TrnApplyEducationAid.select(isselect).joins(jons).where(iswhere).order("aea_requestno ASC")
  else        
	   loansobj = TrnApplyEducationAid.select(isselect).where(iswhere).order("aea_requestno ASC")
  end

   if loansobj.length >0
		loansobj.each do |newvch|
		  sewdobjs   = get_mysewdar_list_details(newvch.aea_sewadarcode)
		  if sewdobjs
			  newvch.sewdarname   = sewdobjs.sw_sewadar_name
			  newvch.refercode    = sewdobjs.sw_oldsewdarcode
			  newvch.dsicode      = sewdobjs.sw_desigcode
			  newvch.dates        = sewdobjs.sw_joiningdate
			  newvch.selfdob      = sewdobjs.sw_date_of_birth
			  newvch.sw_gender    = sewdobjs.sw_gender
			  newvch.totalsewa    = get_dob_calculate(format_oblig_date(sewdobjs.sw_joiningdate))
			  newvch.prevbalance  = ""
			  sewdptobj           = get_all_department_detail(sewdobjs.sw_depcode)
				if sewdptobj
					 newvch.department = sewdptobj.departDescription
				end
				desobjs = get_sewdar_designation_detail(sewdobjs.sw_desigcode)
				if desobjs
					newvch.deginname = desobjs.ds_description
				end
				relaobj = get_family_relation_detail(newvch.aea_dependent);
				if relaobj
					newvch.relatoinname = relaobj.skf_dependent
					newvch.aadhaarno    = relaobj.skf_pannumber
					newvch.doblist      = relaobj.skf_datebirth	
					skunvobj     = get_common_unversity_firstrecord(relaobj.skf_university)
					if skunvobj
						newvch.schoolunversity = skunvobj.un_description
					end
					
				end

				seapprovedobj = get_global_users(newvch.aea_approvedby)
				if seapprovedobj
					membercode  = seapprovedobj.ecmember
					ldsobj      = get_member_listed(membercode)
					if ldsobj
						newvch.approvedby  = ldsobj.lds_name
						newvch.lds_profile = ldsobj.lds_profile
					end
					
				end
				kycobj    =  global_sewadar_kyc_information(newvch.aea_sewadarcode)  
				if kycobj
					newvch.selfadhar = kycobj.sk_adharno
				end
				educationvoucher = get_education_voucher(newvch.aea_requestno)
				if educationvoucher !=nil
					newvch.sanctionno    = educationvoucher.vd_voucherno
					newvch.sanctiondate  = educationvoucher.vd_voucherdate
					if educationvoucher.vd_voucherdate !=nil && educationvoucher.vd_voucherdate !=''
						newvch.financialYear = get_finacial_years(educationvoucher.vd_voucherdate)
					end
					
				end
				
				newvch.classname = get_class_series(newvch.aea_forclass) 

		  end
		  
		  arrobj.push newvch
		end
   end
   return arrobj

 end

end
