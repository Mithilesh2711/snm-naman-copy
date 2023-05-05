## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for all marriage action & dbs
### FOR REST API ######
class ApplyMarriageaidController < ApplicationController
	before_action :require_login
	before_action :allowed_security
	skip_before_action :verify_authenticity_token,:only=>[:index,:search,:ajax_process,:marriageaid_list]
	include ErpModule::Common
	helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:global_sewadar_kyc_information,:get_member_listed
	helper_method :format_oblig_date,:get_family_relation_detail,:get_all_department_detail,:get_first_my_sewadar,:get_global_users
	def index
		@authorizedId  =   session[:autherizedUserId]
		@compCodes     =   session[:loggedUserCompCode]
		tdslimits      =   0
		@lastEntryNo       = last_entry_no
		@HeadHrp       =   MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
		if @HeadHrp
			tdslimits    = @HeadHrp.hph_deductedlimited
			@HrMonths    = get_month_listed_data(@HeadHrp.hph_months)
			@Hryears     = @HeadHrp.hph_years
		end
		
			@mydepartcode = nil
			mydeprtcode    = ""
			if session[:sec_sewdar_code]
				sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
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
			@MarriageItem = nil
			if params[:id]!=nil && params[:id]!= ''
				docs         = params[:id].to_s.split("_")
				@compDetail  = MstCompany.where(["cmp_companycode = ?", @compCodes]).first
				rooturl      = "#{root_url}"
				if docs[1] == 'prt'
					 voucherdata  =  print_download_marriage_detail()					 
						respond_to do |format|
							format.html
							format.pdf do
								pdf = ApprovemarriagePdf.new(voucherdata,@compDetail,rooturl,@username,@inchargename)
								send_data pdf.render,:filename => "1_prt_marriage_list_report.pdf", :type => "application/pdf", :disposition => "inline"
							end
						end

				else

						@MarriageItem    =  TrnApplyMarriageAid.where("ama_compcode = ? AND id = ?",@compCodes, params[:id].to_i).first
						if @MarriageItem
							@Allsewobj     = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_depcode = ? AND sw_leavingdate='0000-00-00'",@compCodes,@MarriageItem.ama_departcode).order("sw_sewadar_name ASC")
							if  @MarriageItem.ama_applyfor.to_s == 'dependent'
								@AlldependentList =  MstSewdarKycFamilyDetail.where("skf_compcode =? AND skf_sewcode =? AND skf_family_dependent='Y' AND skf_married_status<>'Y' AND skf_datebirth<>'0000-00-00' AND (DATE_FORMAT(FROM_DAYS(DATEDIFF(now(),skf_datebirth)), '%Y')+0)>=18 AND skf_relation IN('Son','Daughter') ",@compCodes,@MarriageItem.ama_sewadarcode).order("skf_dependent ASC")
							end

						end	
						
				end

			end


	end

	def ajax_process
             if params[:identity] !=nil && params[:identity]  != '' && params[:identity] == 'Y'
				get_sewadar_amount_list();
				return
			 end

	end

	def marriageaid_list
		@compcodes   =  session[:loggedUserCompCode]
		mydeprtcode    =  ""
    @newsewdarList =  nil
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

      if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
            @sewDepart        =   Department.select("compCode,departDescription,departCode").where("compCode = ? AND subdepartment = '' AND departCode = ?",@compcodes, @mydepartcode ).order("departDescription ASC")
            @newsewdarList    =   MstSewadar.where("sw_compcode = ? AND sw_sewcode = ?",@compcodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")

      elsif session[:requestuser_loggedintp]  && ( session[:requestuser_loggedintp] == 'ec' || session[:requestuser_loggedintp] == 'cod' )
          if @mydepartcode !=nil && @mydepartcode !=''
              @sewDepart      =   Department.select("compCode,departDescription,departCode").where("compCode = '#{@compcodes}' AND subdepartment ='' AND departCode IN(#{@mydepartcode})").order("departDescription ASC")
          end 
          @newsewdarList     =   MstSewadar.where("sw_compcode = ? AND sw_depcode = ?",@compcodes,mydeprtcode).order("sw_sewadar_name ASC")
      else
            @sewDepart         =  Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compcodes).order("departDescription ASC")  
      end   
   
      @sewadarCategory   = MstSewadarCategory.where("sc_compcode =? AND sc_catcode NOT IN('DWD','VIV') ",@compcodes).order("sc_position ASC") 

		@printPdf    = "apply_marriageaid/1_prt_pending_apply_marriageaid_report.pdf"
		@MarriageListing = get_marriage_listing()
	end

	def create
		@compCodes  =  session[:loggedUserCompCode]
		isFlags     = true
		mid         = params[:mid]
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
			if params[:updateremark].to_s == 'RMK'
					if params[:ama_remark].to_s.strip == nil || params[:ama_remark].to_s.strip == ''
						flash[:error] = "Remark should not be blank"
						isFlags       = false
					end
				
					if isFlags
							chkdeprtobj   = TrnApplyMarriageAid.where("ama_compcode = ? AND id = ?",@compCodes,mid).first
							if chkdeprtobj
								chkdeprtobj.update(:ama_remark=>params[:ama_remark].to_s.strip)
								flash[:error] = "Remark updated successfully"
								isFlags       =  true
							end
					end
				
		  else

		  
		  sewadarcode   = params[:ama_sewadarcode]
		  cursewacode   = params[:cursewacode]
		  curdepend     = params[:curdependent]	
		  dependent     = params[:ama_dependent]	
		  finadate      = started_finacial_dated(params[:ama_requestdate])
		  finadates     = finadate.to_s.split("/")     		
		  types         = params[:ama_applyfor]	

		  if types.to_s.downcase == 'self'
			    chkapplyobj   = TrnApplyMarriageAid.where("ama_compcode = ? AND ama_sewadarcode = ? AND ama_status<>'R' AND ama_status<>'C' AND ama_requestdate >='#{finadates[0]}' AND ama_requestdate <='#{finadates[1]}'",@compCodes,sewadarcode)
				if chkapplyobj.length >0
					flash[:error] = "You have already applied"
					isFlags        = false
				end	

		elsif types.to_s.downcase == 'dependent'
			   chkapplyobj   = TrnApplyMarriageAid.where("ama_compcode = ? AND ama_sewadarcode = ? AND ama_dependent =? AND ama_status<>'R' AND ama_status<>'C'  AND ama_requestdate >='#{finadates[0]}' AND ama_requestdate <='#{finadates[1]}'",@compCodes,sewadarcode,dependent)
				if chkapplyobj.length >0
					flash[:error] = "Dependent is already applied"
					isFlags        = false
				end

		end	



		  if mid.to_i >0
			   if types.to_s.downcase == 'self'
				    if cursewacode.to_s.strip != sewadarcode.to_s.strip
						chkapplyobj   = TrnApplyMarriageAid.where("ama_compcode = ? AND ama_sewadarcode = ? AND ama_status<>'R' AND ama_status<>'C'  AND ama_requestdate >='#{finadates[0]}' AND ama_requestdate <='#{finadates[1]}'",@compCodes,sewadarcode)
						if chkapplyobj.length >0
							flash[:error] = "You have already applied"
							isFlags        = false
						end	
					end

				elsif types.to_s.downcase == 'dependent'
				    if curdepend.to_s.strip != dependent.to_s.strip
						chkapplyobj   = TrnApplyMarriageAid.where("ama_compcode = ? AND ama_sewadarcode = ? AND ama_dependent =? AND ama_status<>'R' AND ama_status<>'C'  AND ama_requestdate >='#{finadates[0]}' AND ama_requestdate <='#{finadates[1]}'",@compCodes,sewadarcode,dependent)
						if chkapplyobj.length >0
							flash[:error] = "Dependent is already applied"
							isFlags        = false
						end	
					end

				end			
				  if isFlags
					  chkdeprtobj   = TrnApplyMarriageAid.where("ama_compcode = ? AND id = ?",@compCodes,mid).first
					  if chkdeprtobj
						chkdeprtobj.update(marriage_params)
							flash[:error] = "Data updated successfully"
							isFlags       = true
					  end
				  end
	  
		  else

			if types.to_s.downcase == 'self'
				chkapplyobj   = TrnApplyMarriageAid.where("ama_compcode = ? AND ama_sewadarcode = ? AND ama_status<>'R' AND ama_status<>'C' AND ama_requestdate >='#{finadates[0]}' AND ama_requestdate <='#{finadates[1]}'",@compCodes,sewadarcode)
					if chkapplyobj.length >0
						flash[:error] = "You have already applied"
						isFlags        = false
					end

			elsif types.to_s.downcase == 'dependent'
		
				chkapplyobj   = TrnApplyMarriageAid.where("ama_compcode = ? AND ama_sewadarcode = ? AND ama_dependent =? AND ama_status<>'R' AND ama_status<>'C'  AND ama_requestdate >='#{finadates[0]}' AND ama_requestdate <='#{finadates[1]}'",@compCodes,sewadarcode,dependent)
				if chkapplyobj.length >0
				    
					flash[:error] = "Dependent is already applied"
					isFlags        = false
				end

			end	
				
				  if isFlags
					  deprtsvobj = TrnApplyMarriageAid.new(marriage_params)
					   if deprtsvobj.save
						  flash[:error] = "Data saved successfully"
						  isFlags       = true
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
		   redirect_to  "#{root_url}apply_marriageaid"
		 else
		   redirect_to  "#{root_url}apply_marriageaid/marriageaid_list"
		 end
	end


	def cancel
		@compcodes = session[:loggedUserCompCode]
		if params[:id].to_i >0
			 @Listobj =  TrnApplyMarriageAid.where("ama_compcode =? AND id = ?",@compcodes,params[:id]).first
			 if @Listobj
					 @Listobj.update(:ama_status=>'C')
					 flash[:error] =  "Data cancelled successfully."
					 isFlags       =  true
					 session[:isErrorhandled] = nil
			 end
		end
		redirect_to "#{root_url}apply_marriageaid/marriageaid_list"
	 end

	def destroy
		@compcodes = session[:loggedUserCompCode]
		# if params[:id].to_i >0
		# 	 @Listobj =  TrnApplyMarriageAid.where("ama_compcode =? AND id = ?",@compcodes,params[:id]).first
		# 	 if @Listobj
		# 			 @Listobj.destroy
		# 			 flash[:error] =  "Data deleted successfully."
		# 			 isFlags       =  true
		# 			 session[:isErrorhandled] = nil
		# 	 end
		# end
		# redirect_to "#{root_url}apply_marriageaid/marriageaid_list"
	 end

	private
	def last_entry_no
	  @isCode     = 0
	  @Startx     = '0000'
	  @recCodes   = TrnApplyMarriageAid.where(["ama_compcode =? AND ama_requestno >0 ",@compCodes]).order('ama_requestno DESC').first
	  if @recCodes
	  @isCode    = @recCodes.ama_requestno.to_i
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
 def marriage_params
      @isCode     = 0
	  @Startx     = '0000'
	  @recCodes   = TrnApplyMarriageAid.where(["ama_compcode =? AND ama_requestno >0 ",@compCodes]).order('ama_requestno DESC').first
	  if @recCodes
	  @isCode    = @recCodes.ama_requestno.to_i
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
			params[:ama_requestno] = params[:ama_requestno] 
	    else
			params[:ama_requestno] = @sumXOfCode
		end
      
		dirf   = "marriage/m1"
		dirs   = "marriage/m2"
		dirths = "marriage/m3"
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
	params[:ama_attachfirst] = imagefirst
	params[:ama_attachsecond] = imagesecond
	params[:ama_attachthird]  = imagethird
    params[:ama_compcode]         = session[:loggedUserCompCode]
    params[:ama_departcode]       = params[:ama_departcode] !=nil && params[:ama_departcode] !='' ? params[:ama_departcode] : ''
    params[:ama_sewadarcode]      = params[:ama_sewadarcode]  !=nil && params[:ama_sewadarcode]  !='' ? params[:ama_sewadarcode]  : ''
    params[:ama_applyfor]         = params[:ama_applyfor] !=nil && params[:ama_applyfor] !='' ? params[:ama_applyfor] : ''



	params[:ama_dependent]         = params[:ama_dependent] !=nil && params[:ama_dependent] !='' ? params[:ama_dependent] : 0
	params[:ama_titlefirst]        = params[:ama_titlefirst] !=nil && params[:ama_titlefirst] !='' ? params[:ama_titlefirst] : ''
	params[:ama_tiitlesec]         = params[:ama_tiitlesec] !=nil && params[:ama_tiitlesec] !='' ? params[:ama_tiitlesec] : ''
	params[:ama_titlethird]        = params[:ama_titlethird] !=nil && params[:ama_titlethird] !='' ? params[:ama_titlethird] : ''

	params[:ama_amount]            = params[:ama_amount] !=nil && params[:ama_amount] !='' ? params[:ama_amount] : 0
	params[:ama_remark]            = params[:ama_remark] !=nil && params[:ama_remark] !='' ? params[:ama_remark] : ''
	
    params[:ama_requestdate]       = rqdated
    params.permit(:ama_compcode,:ama_requestno,:ama_requestdate,:ama_amount,:ama_remark,:ama_departcode,:ama_sewadarcode,:ama_applyfor,:ama_dependent,:ama_attachfirst,:ama_attachsecond,:ama_attachthird,:ama_titlefirst,:ama_tiitlesec,:ama_titlethird)
 end

 private
 def get_marriage_listing
	 compcode = session[:loggedUserCompCode]	 
	 if params[:server_request] != nil && params[:server_request] != ''
		session[:reqs_filteroptioned]           = nil	
		session[:amareqs_voucher_department]    = nil
        session[:amareqs_voucher_category]      = nil
        session[:amareqs_sewadar_status]        = nil
        session[:amareqs_sewadar_requesttype]   = nil

	 end
	 
    voucher_department  = params[:voucher_department] !=nil && params[:voucher_department] !='' ? params[:voucher_department] : session[:amareqs_voucher_department]
    voucher_category    = params[:voucher_category] !=nil && params[:voucher_category] !='' ? params[:voucher_category] : session[:amareqs_voucher_category]
    sewadar_status      = params[:sewadar_status] !=nil && params[:sewadar_status] !='' ? params[:sewadar_status] : session[:amareqs_sewadar_status]
    sewadar_requesttype = params[:sewadar_requesttype] !=nil && params[:sewadar_requesttype] !='' ? params[:sewadar_requesttype] : session[:amareqs_sewadar_requesttype]
    search_from_date    = params[:search_from_date] !=nil && params[:search_from_date] !='' ? params[:search_from_date] : session[:amreqs_search_from_date]
    search_upto_date    = params[:search_upto_date] !=nil && params[:search_upto_date] !='' ? params[:search_upto_date] : session[:amreqs_search_upto_date]
    filteroption        = params[:filteroption] !=nil && params[:filteroption] != '' ? params[:filteroption] : session[:reqs_filteroptioned]
	
	iswhere = "ama_compcode ='#{compcode}'"
	 if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
		iswhere  += " AND ama_sewadarcode ='#{session[:sec_sewdar_code]}' AND ama_departcode ='#{@mydepartcode}' "
		@voucher_department = @mydepartcode
	 elsif session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'stf'
		iswhere  += " AND ama_departcode ='#{@mydepartcode}'"
	 else
		if voucher_department !=nil && voucher_department !=''
			session[:amareqs_voucher_department]  = voucher_department
			@voucher_department                  = voucher_department
			iswhere     += " AND ama_departcode ='#{voucher_department}' AND ama_departcode<>''"
		 end
	 end

	 
    nflags = false
    jons   = ""
    if voucher_category != nil && voucher_category !='' 
      session[:amareqs_voucher_category] = voucher_category
      @voucher_category  = voucher_category
      iswhere   += " AND sw_catgeory LIKE '%#{voucher_category}%'"
      jons      =  " LEFT JOIN  mst_sewadars swd on(ama_compcode = sw_compcode AND ama_sewadarcode = sw_sewcode)"
      nflags    = true
    end
    if sewadar_status !=nil && sewadar_status !=''
        if sewadar_status == 'N' 
          iswhere   += " AND ( ama_status ='' OR ama_status ='N' )"
        else
          iswhere   += " AND ama_status ='#{sewadar_status}'"
        end
      
      @sewadar_status                = sewadar_status
      session[:amareqs_sewadar_status] = sewadar_status
    end
    if sewadar_requesttype != nil && sewadar_requesttype !=''
        iswhere   += " AND ama_applyfor     ='#{sewadar_requesttype}'"
        @sewadar_requesttype                = sewadar_requesttype
        session[:amareqs_sewadar_requesttype] = sewadar_requesttype
    end
    if search_from_date !=nil && search_from_date !=''
      session[:amreqs_search_from_date]     = search_from_date
      @search_from_date                     = search_from_date
      iswhere     += " AND ama_approvedated >='#{year_month_days_formatted(search_from_date)}' "

    end
    if search_upto_date !=nil && search_upto_date !=''
        session[:amreqs_search_upto_date]       = search_upto_date
        @search_upto_date                     = search_upto_date
        iswhere     += " AND ama_approvedated <='#{year_month_days_formatted(search_upto_date)}' "
    end

	 if filteroption !=nil && filteroption !=''
			session[:reqs_filteroptioned] = filteroption	
			@filteroption                 = filteroption	
			if filteroption.to_s == 'all'
				##ExECUTE PARAMETER IF RQUIRED
			else
				 if filteroption == 'N'
					iswhere  += " AND (ama_status ='N' OR ama_status = '' )"
				 else
					iswhere  += " AND ama_status ='#{filteroption}'"
				 end
				
			end
	 end
	 if nflags
        isselect = "trn_apply_marriage_aids.*,swd.id as swedId"
        listmarrigeobj = TrnApplyMarriageAid.select(isselect).joins(jons).where(iswhere).order("ama_requestno DESC")
     else
       listmarrigeobj = TrnApplyMarriageAid.where(iswhere).order("ama_requestno DESC")
     end
	 return listmarrigeobj

 end

 private
 def get_sewadar_amount_list
	compcode      = session[:loggedUserCompCode]
	sewacode      = params[:sewacode]
	dependentcode = params[:dependentcode]
	types         = params[:types]
	amounts       = ""
	apobjs        = MstMarriageParameter.where("mp_compcode =? ",compcode).first
	
	sewaobj       = get_office_global_data(sewacode)
	newsewdar     = get_mysewdar_list_details(sewacode)
	genders       = ""
	maritalstatus = ""
	catcode       = newsewdar.sw_catcode
	totalsewa     = 0
			if newsewdar
				genders        = newsewdar.sw_gender 
				catcode        = newsewdar.sw_catcode 
				maritalstatus  = newsewdar.sw_maritalstatus					    
			end
			
			if types.to_s =='dependent'
				sewfmlobj     = MstSewdarKycFamilyDetail.where("skf_compcode =? AND id= ?",compcode,dependentcode).first
				if sewfmlobj
					malestype = sewfmlobj.skf_gender
					  if malestype.to_s.downcase == 'female'
						   genders = 'F'
					  elsif malestype.to_s.downcase == 'male'
							genders = 'M'
					 end
				 end
			end
			if sewaobj
				 
				joindated = sewaobj.so_joiningdate 
				 if joindated !=nil && joindated !=''
					totalsewa = get_dob_calculate(year_month_days_formatted(joindated))
					if catcode.to_s == 'SDP'
							if( totalsewa.to_f >=apobjs.mp_totalsewaself )
									if( genders == 'M')
										amounts = apobjs.mp_totalsewaformale
									elsif ( genders == 'F')
										amounts = apobjs.mp_totalsewafemale
									end
							end
					elsif catcode.to_s == 'VIT'
						if( totalsewa.to_f >=apobjs.mp_totalsewaengage )
								if( genders == 'M')
									amounts = apobjs.mp_totalsewaformale
								elsif ( genders == 'F')
									amounts = apobjs.mp_totalsewafemale
								end
						end
				    end		

				 end
				## check age list ######	
			end
			isflags = true
			message = ""
			if types.to_s.downcase =='self'
				if maritalstatus.to_s == 'Y'
					message ="You are not eligible"
					amounts = 0
					totalsewa = ""
				end

			end
			respond_to do |format|
				format.json { render :json => { 'data'=>amounts,:totalsewa=>totalsewa, :status=>isflags,:message=>message} }
			end
 end
 private
 def print_download_marriage_detail
	compcode      = session[:loggedUserCompCode]	 
	filteroption = session[:reqs_filteroptioned]
	voucher_department  = session[:amareqs_voucher_department]
	voucher_category    = session[:amareqs_voucher_category]
	sewadar_status      = session[:amareqs_sewadar_status]
	sewadar_requesttype = session[:amareqs_sewadar_requesttype]
	search_from_date    = session[:amreqs_search_from_date]
	search_upto_date    = session[:amreqs_search_upto_date]
    
	 iswhere      = "ama_compcode ='#{compcode}'"
	 if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
		iswhere  += " AND ama_sewadarcode ='#{session[:sec_sewdar_code]}' AND ama_departcode ='#{@mydepartcode}' "
	 elsif session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'stf'
		iswhere  += " AND ama_departcode ='#{@mydepartcode}'"
	 else
		if voucher_department !=nil && voucher_department !=''			
			iswhere     += " AND ama_departcode ='#{voucher_department}' AND ama_departcode<>''"
		 end	
	 end
	 nflags = false
    jons   = ""
    if voucher_category != nil && voucher_category !='' 
     
      iswhere   += " AND sw_catgeory LIKE '%#{voucher_category}%'"
      jons      =  " LEFT JOIN  mst_sewadars swd on(ama_compcode = sw_compcode AND ama_sewadarcode = sw_sewcode)"
      nflags    = true
    end
    if sewadar_status !=nil && sewadar_status !=''
        if sewadar_status == 'N' 
          iswhere   += " AND ( ama_status ='' OR ama_status ='N' )"
        else
          iswhere   += " AND ama_status ='#{sewadar_status}'"
        end
      
    end
    if sewadar_requesttype != nil && sewadar_requesttype !=''
        iswhere   += " AND ama_applyfor     ='#{sewadar_requesttype}'"       
    end
    if search_from_date !=nil && search_from_date !=''
        iswhere     += " AND ama_approvedated >='#{year_month_days_formatted(search_from_date)}' "
    end
    if search_upto_date !=nil && search_upto_date !=''       
        iswhere     += " AND ama_approvedated <='#{year_month_days_formatted(search_upto_date)}' "
    end

	 if filteroption !=nil && filteroption !=''
			session[:reqs_filteroptioned] = filteroption	
			@filteroption                 = filteroption	
			if filteroption.to_s == 'all'
				##ExECUTE PARAMETER IF RQUIRED
			else
				 if filteroption == 'N'
					iswhere  += " AND (ama_status ='N' OR ama_status = '' )"
				 else
					iswhere  += " AND ama_status ='#{filteroption}'"
				 end
				
			end
	 end
	 arrobj = []
	 isselect  = "trn_apply_marriage_aids.*,'' as sewdarname,'' as refercode,'' as dsicode,'' as vd_userid,ama_applyfor as vd_requestfor"
   isselect  += ",'' as dates,'' as prevbalance,'' as department,'' as deginname,'' as totalsewa,'' as installamount,'' as selfdob,'' as classname"
   isselect  += ",'' as relatoinname,'' as aadhaarno,'' as doblist,'' as approvedby,'' as lds_profile,'' as selfadhar,'' as sw_gender"
  
   if nflags
		isselect += ",swd.id as swedId"
		listmarrigeobj = TrnApplyMarriageAid.select(isselect).joins(jons).where(iswhere).order("ama_requestno DESC")
	else
	    listmarrigeobj = TrnApplyMarriageAid.select(isselect).where(iswhere).order("ama_requestno DESC")
	end

	 
	 if listmarrigeobj.length >0
		listmarrigeobj.each do |newvch|

			sewdobjs   = get_mysewdar_list_details(newvch.ama_sewadarcode)
			if sewdobjs
				newvch.sewdarname   = sewdobjs.sw_sewadar_name
				newvch.refercode    = sewdobjs.sw_oldsewdarcode
				newvch.dsicode      = sewdobjs.sw_desigcode
				newvch.dates        = sewdobjs.sw_joiningdate
				newvch.selfdob      = sewdobjs.sw_date_of_birth
				newvch.sw_gender    = sewdobjs.sw_gender
				newvch.deginname    = sewdobjs.sw_catgeory
				newvch.totalsewa    = get_dob_calculate(format_oblig_date(sewdobjs.sw_joiningdate))
				newvch.prevbalance  = ""
				sewdptobj           = get_all_department_detail(sewdobjs.sw_depcode)
				  if sewdptobj
					   newvch.department = sewdptobj.departDescription
				  end
				#   desobjs = get_sewdar_designation_detail(sewdobjs.sw_desigcode)
				#   if desobjs
				# 	  newvch.deginname = desobjs.ds_description
				#   end
				  relaobj = get_family_relation_detail(newvch.ama_dependent);
				  if relaobj
					  newvch.relatoinname = relaobj.skf_dependent
					  newvch.aadhaarno    = relaobj.skf_pannumber
					  newvch.doblist      = relaobj.skf_datebirth					
				  end
  
				  seapprovedobj = get_global_users(newvch.ama_approvedby)
				  if seapprovedobj
					  membercode  = seapprovedobj.ecmember
					  ldsobj      = get_member_listed(membercode)
					  if ldsobj
						  newvch.approvedby  = ldsobj.lds_name
						  newvch.lds_profile = ldsobj.lds_profile
					  end
					  
				  end
				  kycobj    =  global_sewadar_kyc_information(newvch.ama_sewadarcode)  
				  if kycobj
					  newvch.selfadhar = kycobj.sk_adharno
				  end
				 
  
			end

			arrobj.push newvch

		end
	 end

	 return arrobj


 end


end
