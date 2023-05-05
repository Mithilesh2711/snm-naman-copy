## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for voucher
### FOR REST API ######
class VouchersController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_mysewdar_list_details,:get_all_department_detail
  helper_method :get_sewdar_designation_detail,:format_oblig_date,:get_dob_calculate,:set_ent,:set_dct
  
def index
    @compcodes         = session[:loggedUserCompCode]
    @LoanListReqest    = nil
    @printPath         = "vouchers/1_prt_pending_voucher_report.pdf"
    @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment=''",@compcodes).order("departDescription ASC")
    @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compcodes).order("sc_position ASC")
    sewadar_loantype   = params[:sewadar_loantype] !=nil && params[:sewadar_loantype] !='' ? params[:sewadar_loantype] : session[:req_sewadar_loantype]
    if session[:requestuser_loggedintp] && ( session[:requestuser_loggedintp].to_s == 'eds' || session[:requestuser_loggedintp].to_s == 'mrg' )
        
        if sewadar_loantype.to_s == 'ED'
             @LoanListReqest    = get_education_voucher 
        elsif sewadar_loantype.to_s == 'MARRIAGE'
             @LoanListReqest    = get_marriage_voucher  
        else
             if session[:req_sewadar_loantype] == nil || session[:req_sewadar_loantype] == ''
                session[:req_sewadar_loantype] = 'ED'
                @sewadar_loantype   ='ED'
             end
             @LoanListReqest    = get_education_voucher    
        end
     elsif session[:requestuser_loggedintp] && ( session[:requestuser_loggedintp].to_s == 'advs' )   
          if sewadar_loantype.to_s == 'Loan' || sewadar_loantype.to_s == 'HR Advance' || sewadar_loantype.to_s == 'Advance' || sewadar_loantype.to_s == 'Advance Above 60k' || sewadar_loantype.to_s == 'Ex-gratia' || sewadar_loantype.to_s == 'Special Advance' || sewadar_loantype.to_s == 'Wheat Advance'
            @LoanListReqest    = get_sewadar_loan_request

          else

                params[:sewadar_loantype] = 'Loan'
                if session[:req_sewadar_loantype] == nil || session[:req_sewadar_loantype] == ''
                  session[:req_sewadar_loantype] = 'Loan'
                end
                @LoanListReqest    = get_sewadar_loan_request
          end

    else

      if sewadar_loantype.to_s == 'Loan' || sewadar_loantype.to_s == 'HR Advance' || sewadar_loantype.to_s == 'Advance' || sewadar_loantype.to_s == 'Advance Above 60k' || sewadar_loantype.to_s == 'Ex-gratia' || sewadar_loantype.to_s == 'Special Advance' || sewadar_loantype.to_s == 'Wheat Advance'
            @LoanListReqest    = get_sewadar_loan_request
      elsif sewadar_loantype.to_s == 'ED'
            @LoanListReqest    = get_education_voucher 
     elsif sewadar_loantype.to_s == 'MARRIAGE'
            @LoanListReqest     = get_marriage_voucher       
      else
          params[:sewadar_loantype] = 'Loan'
          if session[:req_sewadar_loantype] == nil || session[:req_sewadar_loantype] == ''
            session[:req_sewadar_loantype] = 'Loan'
          end
          @LoanListReqest    = get_sewadar_loan_request
      end

    end
    if params[:id] !=nil && params[:id] !=''
          docs  = params[:id].to_s.split("_")        
          
          if docs[1] == 'prt'
                  username     = ""
                  inchargename = ""
                  reqid        = session[:request_vouchers]
                  
                  # if session[:req_sewadar_loantype].to_s == 'ED'
                  #   voucherdata  =  print_education_voucher_report(reqid)
                  # else
                  #    voucherdata  = voucher_report_detail(reqid)

                  #    #voucherdata  =  print_education_voucher_report(reqid)

                  # end
                    if docs[2] != 'pending'
                        myusercode = ""
                        voucherdata  = voucher_report_detail(reqid)
                        if voucherdata                      
                            userobj = user_detail(voucherdata.vd_userid)
                            if userobj
                              #username  =  userobj.username
                              mysewacode = userobj.sewadarcode
                              myusercode  = mysewacode
                              sewdobjs   = get_mysewdar_list_details(mysewacode)
                                if sewdobjs
                                  username  = sewdobjs.sw_sewadar_name
                                end

                            end
                            depobj = get_all_department_detail(voucherdata.vd_sewadarcode)
                            if depobj                            
                                hodcode     = depobj.departHod
                                sewnmaesobj = get_first_my_sewadar(hodcode)
                                if sewnmaesobj
                                    inchargename = sewnmaesobj.lds_name
                                end
                            end                    

                        end

                     end

                   @compDetail  = MstCompany.where(["cmp_companycode = ?", @compcodes]).first
                   rooturl      = "#{root_url}"
                   if docs[2] == 'voucher'
                        respond_to do |format|
                          format.html
                          format.pdf do
                            pdf = VoucherPdf.new(voucherdata,@compDetail,rooturl,username,inchargename,myusercode)
                            send_data pdf.render,:filename => "1_voucher_report.pdf", :type => "application/pdf", :disposition => "inline"
                          end
                        end
                    elsif docs[2] == 'pending'
                        
                        if sewadar_loantype.to_s == 'Loan' || sewadar_loantype.to_s == 'Advance'
                             voucherdata  =  pending_print_advance_voucher_report(reqid)
                              respond_to do |format|
                                format.html
                                format.pdf do
                                  pdf = AdvancevoucherPdf.new(voucherdata,@compDetail,rooturl,username,inchargename)
                                  send_data pdf.render,:filename => "1_pending_vouchers_report.pdf", :type => "application/pdf", :disposition => "inline"
                                end
                              end
                          elsif sewadar_loantype.to_s == 'ED'   
                                voucherdata  =  pending_print_education_voucher_report(reqid)
                                respond_to do |format|
                                  format.html
                                  format.pdf do
                                    pdf = EducationvoucherPdf.new(voucherdata,@compDetail,rooturl,username,inchargename)
                                    send_data pdf.render,:filename => "1_pending_vouchers_report.pdf", :type => "application/pdf", :disposition => "inline"
                                  end
                                end
                          elsif sewadar_loantype.to_s == 'MARRIAGE'   
                                voucherdata  =  pending_print_marriage_voucher_report(reqid)
                                respond_to do |format|
                                  format.html
                                  format.pdf do
                                    pdf = MarriagevoucherPdf.new(voucherdata,@compDetail,rooturl,username,inchargename)
                                    send_data pdf.render,:filename => "1_pending_vouchers_report.pdf", :type => "application/pdf", :disposition => "inline"
                                  end
                                end
                          end
                    end
                  
          end
    end
    
end

def generate_vouchers
  @compcodes      = session[:loggedUserCompCode]
  @lastVoucherNo = get_last_voucher_no
  @cDated        = formatted_date(Date.today)
  @ListReqst     = nil
  @HeadVouers    = nil
  @sewadarname    = "" 
  @printVourcher  = false
  @printPath      =  "vouchers/1_prt_voucher_report.pdf"
  if params[:id] !=nil && params[:id] !=''
      myvoch       = set_dct(params[:id])
      myvochs      = myvoch.to_s.split("_")
      
      if myvochs[0] == 'VCH'
      
            @HeadVouers  = voucher_report_detail(myvochs[1])
            if @HeadVouers
                sewdarobj = get_mysewdar_list_details(@HeadVouers.vd_sewadarcode)
                if sewdarobj
                    @sewadarname = sewdarobj.sw_sewadar_name
                end
                session[:request_vouchers] = myvochs[1]
                @printVourcher = true
            end
      else
        
           
            sewadar_loantype = session[:req_sewadar_loantype]
            if session[:req_sewadar_loantype].to_s == 'Loan' || session[:req_sewadar_loantype].to_s == 'HR Advance' || session[:req_sewadar_loantype].to_s =='Advance' || sewadar_loantype.to_s == 'Advance Above 60k' || sewadar_loantype.to_s == 'Ex-gratia' || sewadar_loantype.to_s == 'Special Advance' || sewadar_loantype.to_s == 'Wheat Advance'
                @ListReqst = get_request_detail(params[:id])
            elsif session[:req_sewadar_loantype].to_s == 'ED'  
                @ListReqst = view_education_request_list(params[:id])    
            elsif session[:req_sewadar_loantype].to_s == 'MARRIAGE'  
                @ListReqst = view_marriage_request_list(params[:id])    
            end
            if @ListReqst
                sewdarobj = get_mysewdar_list_details(@ListReqst.al_sewadarcode)
                if sewdarobj
                    @sewadarname = sewdarobj.sw_sewadar_name
                end
            end

      end
  end

end

  def create
   @compcodes = session[:loggedUserCompCode]
   isFlags    = true
    ApplicationRecord.transaction do
    begin
        if params[:vd_voucherno] == nil || params[:vd_voucherno] == ''
           flash[:error] =  "Voucher no is required."
           isFlags = false
        elsif params[:vd_voucherdate] == nil || params[:vd_voucherdate] == ''
           flash[:error] =  "Voucher date is required."
           isFlags = false
       elsif params[:vd_sewadarcode] == nil || params[:vd_sewadarcode] == ''
           flash[:error] =  "Sewadar code is required."
           isFlags = false
        elsif params[:vd_requestno] == nil || params[:vd_requestno] == ''
           flash[:error] =  "Request no is required."
           isFlags = false
         elsif   params[:vd_requestdate] == nil || params[:vd_requestdate] == ''
           flash[:error] =  "Request date is required."
           isFlags = false
         elsif   params[:vd_requestfor] == nil || params[:vd_requestfor] == ''
           flash[:error] =  "Request for is required."
           isFlags = false
        elsif   params[:vd_reqamount] == nil || params[:vd_reqamount] == ''
           flash[:error] =  "Request amount is required."
           isFlags = false
        else
            mid       = params[:mid]
            sewdarcode = params[:vd_sewadarcode]
            amounts    = params[:vd_reqamount]                     
            
            if mid.to_i >0

                  if isFlags
                     stateupobj  = TrnVoucherDetail.where("vd_compcode =? AND id = ?",@compcodes,mid).first
                      if stateupobj
                           
                          #  loantypes  = stateupobj.al_requesttype
                          #  if loantypes == 'Loan'
                          #    oldamounts = stateupobj.al_advanceamt
                          #  elsif loantypes == 'Advance'
                          #    oldamounts = stateupobj.al_advanceamt
                          #  end
                          #  stateupobj.update(voucher_params)
                           # reverse_process_sewdar_cb(@compcodes,sewdarcode,oldamounts,loantypes)
                           # process_sewdar_cb(@compcodes,sewdarcode,amounts,params[:vd_requestfor])
                            flash[:error] =  "Data updated successfully."
                            isFlags = true
                      end
                  end
            else

                       if isFlags
                            stsobj = TrnVoucherDetail.new(voucher_params)
                            if stsobj.save
                                @myVouchersNo  = @sumXOfCode
                                process_update_request(params[:vd_requestno],@myVouchersNo,params[:vd_requestfor])
                               # process_sewdar_cb(@compcodes,sewdarcode,amounts,params[:vd_requestfor])
                                flash[:error] =  "Data saved successfully."
                                isFlags = true
                            end

                       end
            end
        end
          rescue Exception => exc
          flash[:error] =   "#{exc.message}"
          session[:isErrorhandled] = 1
          raise ActiveRecord::Rollback
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
     if !isFlags
       redirect_to "#{root_url}"+"vouchers/generate_vouchers/"+params[:reqid].to_s
     else
       vouchers = "VCH_"+@myVouchersNo.to_s
       redirect_to "#{root_url}"+"vouchers/generate_vouchers/"+set_ent(vouchers).to_s
     end
  end


  def cancel
   @compcodes = session[:loggedUserCompCode]
   if params[:id].to_i >0
        canncelobj  = TrnVoucherDetail.where("vd_compcode =? AND id = ?",@compcodes,params[:id].to_i).first
        if canncelobj
              sewdarcode = canncelobj.vd_sewadarcode
              amounts    = canncelobj.vd_reqamount
              requestfor = canncelobj.vd_requestfor
              reqid      = canncelobj.vd_requestno
              if canncelobj.update(:vd_status=>'C')
                  #reverse_process_sewdar_cb(@compcodes,sewdarcode,amounts,requestfor)
                  reverse_process_update_request(reqid,requestfor)
                  flash[:error]            = "Data Cancelled successfully."
                  isFlags                  = true
                  session[:isErrorhandled] = nil
              end
        end
   end
  redirect_to "#{root_url}"+"vouchers"
  end

  private
   def get_sewadar_loan_request
     
     if params[:server_request] !=nil && params[:server_request] !=''
        session[:req_voucher_department] = nil
        session[:req_voucher_category]   = nil
        session[:req_voucher_number]     = nil
        session[:req_sewadar_loantype]   = nil
        session[:req_show_voucher]       = nil
     end
     voucher_department = params[:voucher_department] !=nil && params[:voucher_department] !='' ? params[:voucher_department] : session[:req_voucher_department]
     voucher_category   = params[:voucher_category] !=nil && params[:voucher_category] !='' ? params[:voucher_category] : session[:req_voucher_category]
     voucher_number     = params[:voucher_number] !=nil && params[:voucher_number] !='' ? params[:voucher_number] : session[:req_voucher_number]
     sewadar_loantype   = params[:sewadar_loantype] !=nil && params[:sewadar_loantype] !='' ? params[:sewadar_loantype] : session[:req_sewadar_loantype]
     show_voucher       = params[:show_voucher] !=nil && params[:show_voucher] !='' ? params[:show_voucher] : session[:req_show_voucher]
     isfalgs = false
     iswhere   = "al_compcode ='#{@compcodes}' AND al_approvestatus='A'"
     if voucher_department !=nil && voucher_department !=''
         session[:req_voucher_department] = voucher_department
         @voucher_department              = voucher_department
          iswhere     += " AND al_depcode ='#{voucher_department}'"
     end
     if voucher_category !=nil && voucher_category !=''
         session[:req_voucher_category] = voucher_category
         @voucher_category = voucher_category
         isfalgs = true
         iswhere     += " AND sw_catgeory ='#{voucher_category}'"
     end
     if voucher_number !=nil && voucher_number !=''
         session[:req_voucher_number] = voucher_number
         @voucher_number = voucher_number
         iswhere     += " AND al_broucherno ='#{voucher_number}'"
     end
     if sewadar_loantype !=nil && sewadar_loantype !=''
         session[:req_sewadar_loantype] = sewadar_loantype
         @sewadar_loantype  = sewadar_loantype
         iswhere           += " AND al_requesttype ='#{sewadar_loantype}'"

     end
     if show_voucher !=nil && show_voucher != ''
        session[:req_show_voucher] = show_voucher
        @show_voucher              = show_voucher
     else
         if voucher_number !=nil && voucher_number !=''
            ## EXECUTE MESSAGE IF REQUIRED
         else
           iswhere     += " AND al_broucherno =''"
         end
        
     end
     if isfalgs
       jons    = "LEFT JOIN mst_sewadars sewb ON(sw_compcode = al_compcode AND sw_sewcode = al_sewadarcode)"
       loansobj = TrnAdvanceLoan.select("trn_advance_loans.*,sewb.id as sewID").joins(jons).where(iswhere).order("al_sewadarcode asc")
     else        
        loansobj = TrnAdvanceLoan.where(iswhere).order("al_sewadarcode asc")
     end
     
     return loansobj
   end

 private
def get_last_voucher_no
    @isCode     = 0
    @Startx     = '0000'
    @recCodes   = TrnVoucherDetail.where(["vd_compcode = ?  AND vd_voucherno >0 ", @compcodes]).order('vd_voucherno DESC').first
    if @recCodes
    @isCode    = @recCodes.vd_voucherno.to_i
    end
    @sumXOfCode    = @isCode.to_i + 1
    if @sumXOfCode.to_s.length   < 2
    @sumXOfCode = p "0000" + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length < 3
    @sumXOfCode = p "000" + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length < 4
    @sumXOfCode = p "00" + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length < 5
    @sumXOfCode = p "0" + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length >=5
    @sumXOfCode =  @sumXOfCode.to_i
    end
    return @sumXOfCode
end
private
   def get_request_detail(reqid)
     newreqid = set_dct(reqid)
     iswhere = "al_compcode='#{@compcodes}' AND al_requestno ='#{newreqid}'"
     loansobj = TrnAdvanceLoan.where(iswhere).first
     return loansobj
   end

   private
   def voucher_params
        @compcodes = session[:loggedUserCompCode]
        @isCode     = 0
        @Startx     = '0000'
        @recCodes   = TrnVoucherDetail.where(["vd_compcode = ?  AND vd_voucherno >0 ", @compcodes]).order('vd_voucherno DESC').first
        if @recCodes
        @isCode    = @recCodes.vd_voucherno.to_i
        end
        @sumXOfCode    = @isCode.to_i + 1
        if @sumXOfCode.to_s.length   < 2
        @sumXOfCode = p "0000" + @sumXOfCode.to_s
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
          params[:vd_voucherno] = params[:vd_voucherno]
        else
           params[:vd_voucherno] = @sumXOfCode
        end
         params[:vd_compcode]    = @compcodes
         params[:vd_remark]      = params[:vd_remark]  !=nil && params[:vd_remark]  !='' ? params[:vd_remark]  : ''
         params[:vd_voucherdate] = params[:vd_voucherdate] !=nil && params[:vd_voucherdate] !='' ? year_month_days_formatted(params[:vd_voucherdate]) : 0
         params[:vd_requestdate] = params[:vd_requestdate] !=nil && params[:vd_requestdate] !='' ? year_month_days_formatted(params[:vd_requestdate]) : 0
         params[:vd_reqamount]   = params[:vd_reqamount] !=nil && params[:vd_reqamount] !='' ? currency_formatted(params[:vd_reqamount]) : 0
         params[:vd_userid]      = session[:autherizedUserId]
         params.permit(:vd_compcode,:vd_userid,:vd_voucherno,:vd_voucherdate,:vd_sewadarcode,:vd_requestno,:vd_requestdate,:vd_requestfor,:vd_reqamount,:vd_remark)
   end

   private
 def process_sewdar_cb(compcode,sewdarcode,amounts,requestfor)
        amounts = amounts !=nil && amounts !='' ? amounts : 0
        iswhere = "sw_compcode ='#{compcode}' AND sw_sewcode ='#{sewdarcode}'"
        sewobj  =  MstSewadar.where(iswhere).first
        if sewobj
                tamounts  = sewobj.sw_outstandingamt
                loanamts  = sewobj.sw_loanamount
                if requestfor == 'Loan'
                      newlonamt = loanamts.to_f+amounts.to_f
                      sewobj.update(:sw_loanamount=>newlonamt)
                 elsif requestfor == 'Advance'
                      newamts   = tamounts.to_f+amounts.to_f
                      sewobj.update(:sw_outstandingamt=>newamts)
                end
        end
 end

 private
 def reverse_process_sewdar_cb(compcode,sewdarcode,amounts,requestfor)
        amounts = amounts !=nil && amounts !='' ? amounts : 0
        iswhere = "sw_compcode ='#{compcode}' AND sw_sewcode ='#{sewdarcode}'"
        sewobj  =  MstSewadar.where(iswhere).first
        if sewobj
                tamounts  = sewobj.sw_outstandingamt
                loanamts  = sewobj.sw_loanamount
                if requestfor == 'Loan'
                      newlonamt = loanamts.to_f-amounts.to_f
                      sewobj.update(:sw_loanamount=>newlonamt)
                 elsif requestfor == 'Advance'
                      newamts   = tamounts.to_f-amounts.to_f
                      sewobj.update(:sw_outstandingamt=>newamts)
                end
        end
 end

 private
 def process_update_request(reqid,voucherno,type="")
      newreqid = reqid
      if type.to_s.strip == 'Loan' || type.to_s == 'HR Advance' || type.to_s.strip == 'Advance' || type.to_s.strip == 'MA Advance' || type.to_s.strip == 'Advance Above 60k' || type.to_s.strip == 'Ex-gratia' || type.to_s.strip == 'Special Advance' || type.to_s.strip == 'Wheat Advance'
            iswhere  = "al_compcode ='#{@compcodes}' AND al_requestno ='#{newreqid}'"
            loansobj = TrnAdvanceLoan.where(iswhere).first
            if loansobj
              loansobj.update(:al_broucherno=>voucherno)
            end
      elsif type.to_s == 'Education' 
            iswhere  = "aea_compcode ='#{@compcodes}' AND aea_requestno ='#{newreqid}'"
            loansobj = TrnApplyEducationAid.where(iswhere).first
            if loansobj
              loansobj.update(:aea_voucherno=>voucherno)
            end
        
      elsif type.to_s == 'Marriage' 
          iswhere  = "ama_compcode ='#{@compcodes}' AND ama_requestno ='#{newreqid}'"
          loansobj = TrnApplyMarriageAid.where(iswhere).first
          if loansobj
            loansobj.update(:ama_voucherno=>voucherno)
          end 
      end  
 end

 private
 def reverse_process_update_request(reqid,type="")
      newreqid = reqid
      if type.to_s.strip == 'Loan' || type.to_s == 'HR Advance'  || type.to_s.strip == 'Advance' || type.to_s.strip == 'MA Advance' || type.to_s.strip == 'Advance Above 60k' || type.to_s.strip == 'Ex-gratia' || type.to_s.strip == 'Special Advance' || type.to_s.strip == 'Wheat Advance'
              iswhere  = "al_compcode='#{@compcodes}' AND al_requestno ='#{newreqid}'"
              loansobj = TrnAdvanceLoan.where(iswhere).first
              if loansobj
                loansobj.update(:al_broucherno=>'')
              end
      elsif type.to_s.strip == 'Education' 
              iswhere  = "aea_compcode ='#{@compcodes}' AND aea_requestno ='#{newreqid}'"
              loansobj = TrnApplyEducationAid.where(iswhere).first
              if loansobj
                loansobj.update(:aea_voucherno=>'')
              end 
      elsif type.to_s == 'Marriage' 
              iswhere  = "ama_compcode ='#{@compcodes}' AND ama_requestno ='#{newreqid}'"
              loansobj = TrnApplyMarriageAid.where(iswhere).first
              if loansobj
                loansobj.update(:ama_voucherno=>'')
              end 
      end     
 end

 private
 def get_voucher_list_detail(compcode,requestno)  
     chkdsobj = TrnApplyEducationAid.where("aea_compcode = ? AND aea_requestno = ?",compcode,requestno).first     
     return chkdsobj
 end
 private
 def get_marriage_voucher_list_detail(compcode,requestno)  
     chkdsobj = TrnApplyMarriageAid.where("ama_compcode = ? AND ama_requestno = ?",compcode,requestno).first     
     return chkdsobj
 end
private
 def get_sewadar_kyc_families(compcode,dependentid)
  names = ""
	  sewdarobj =  MstSewdarKycFamilyDetail.where("skf_compcode = ? AND id = ?",compcode,dependentid).first
    if sewdarobj
      names = sewdarobj.skf_dependent
    end
	  return names
 end
private
   def voucher_report_detail(reqid)
     arrobj   = []
     newreqid = reqid
     iswhere = "vd_compcode ='#{@compcodes}' AND vd_voucherno ='#{newreqid}'"
     loansobj = TrnVoucherDetail.select("trn_voucher_details.*,'' as department,'' as sewadar_name,'' as classname,'' as dependentname,'' as al_installpermonth,'' as sewoldcode").where(iswhere).first
     if loansobj
         if loansobj
              sewdarobj = get_mysewdar_list_details(loansobj.vd_sewadarcode)
              if sewdarobj
                    loansobj.sewadar_name  = sewdarobj.sw_sewadar_name
                    loansobj.sewoldcode    = sewdarobj.sw_oldsewdarcode
                    deprtobj = get_department_detail(sewdarobj.sw_depcode)
                    if deprtobj
                      loansobj.department = deprtobj.departDescription
                    end
                    adobj = get_selected_advance_listing(loansobj.vd_sewadarcode,loansobj.vd_requestno)
                    if adobj
                      loansobj.al_installpermonth = adobj.al_installpermonth
                    end
              end
              if loansobj.vd_requestfor == 'Education'
                chkdsobj = get_voucher_list_detail(@compcodes,loansobj.vd_requestno)
                  ################
                  if chkdsobj
                      if chkdsobj.aea_applyfor.to_s == 'self'
                          loansobj.dependentname = "Self"
                      elsif chkdsobj.aea_applyfor.to_s == 'dependent' 
                          loansobj.dependentname  = get_sewadar_kyc_families(@compcodes,chkdsobj.aea_dependent)
                          loansobj.classname  = get_class_series(chkdsobj.aea_forclass)
                      end
                    else
                      loansobj.dependentname  =  sewdarobj.sw_sewadar_name   
                  end
                  ###########
              elsif loansobj.vd_requestfor == 'Marriage'
                  chkdsobj = get_marriage_voucher_list_detail(@compcodes,loansobj.vd_requestno)
                  ################
                  if chkdsobj
                      if chkdsobj.ama_applyfor.to_s == 'self'
                          loansobj.dependentname = "Self"
                      elsif chkdsobj.ama_applyfor.to_s == 'dependent' 
                          loansobj.dependentname  = get_sewadar_kyc_families(@compcodes,chkdsobj.ama_dependent)
                          loansobj.classname      = ""
                      end
                    else
                      loansobj.dependentname  =  sewdarobj.sw_sewadar_name 
                  end
                  ###########
              end
              
          end
        arrobj = loansobj
     end
     return arrobj
   end
############## PENDING MARRIAGE VOUCHER #################
private
   def pending_print_marriage_voucher_report(reqid)
     arrobj    = []
     newreqid  = reqid
     
     voucher_department =  session[:req_voucher_department]
     voucher_category   =  session[:req_voucher_category]
     voucher_number     =  session[:req_voucher_number]
     sewadar_loantype   =  session[:req_sewadar_loantype]
     show_voucher       =  session[:req_show_voucher]
     isfalgs            =  false
     iswhere            =  "ama_compcode = '#{@compcodes}' AND ama_voucherno = '' AND ama_status='A'"
     if voucher_department !=nil && voucher_department !=''         
          iswhere  += " AND ama_departcode ='#{voucher_department}'"
     end
     if voucher_category !=nil && voucher_category !=''         
         isfalgs = true
         iswhere += " AND sw_catgeory ='#{voucher_category}'"
     end  
    
     isselect  = "trn_apply_marriage_aids.*,'' as sewdarname,'' as refercode,'' as dsicode,'' as vd_userid,'Education' as vd_requestfor"
     isselect  += ",'' as dates,'' as prevbalance,'' as department,'' as deginname,'' as totalsewa,'' as installamount"
     
     if isfalgs
        isselect += ",sewb.id as sewID"
        jons     = "LEFT JOIN mst_sewadars sewb ON(sw_compcode = ama_compcode AND sw_sewcode = ama_sewadarcode)"
        loansobj = TrnApplyMarriageAid.select(isselect).joins(jons).where(iswhere).order("ama_requestno DESC")
    else        
        loansobj = TrnApplyMarriageAid.select(isselect).where(iswhere).order("ama_requestno DESC")
    end

     if loansobj.length >0
          loansobj.each do |newvch|
            sewdobjs   = get_mysewdar_list_details(newvch.ama_sewadarcode)
            if sewdobjs
                newvch.sewdarname   = sewdobjs.sw_sewadar_name
                newvch.refercode    = sewdobjs.sw_oldsewdarcode
                newvch.dsicode      = sewdobjs.sw_desigcode
                newvch.dates        = sewdobjs.sw_joiningdate
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
            end
            
            arrobj.push newvch
          end
     end
     return arrobj

   end

################ EDUCATION AID ##################
   private
   def pending_print_education_voucher_report(reqid)
     arrobj    = []
     newreqid  = reqid
     
     voucher_department =  session[:req_voucher_department]
     voucher_category   =  session[:req_voucher_category]
     voucher_number     =  session[:req_voucher_number]
     sewadar_loantype   =  session[:req_sewadar_loantype]
     show_voucher       =  session[:req_show_voucher]
     isfalgs            =  false
     iswhere   = "aea_compcode = '#{@compcodes}' AND aea_voucherno = '' AND aea_status='A'"
     if voucher_department !=nil && voucher_department !=''         
          iswhere     += " AND aea_departcode ='#{voucher_department}'"
     end
     if voucher_category !=nil && voucher_category !=''         
         isfalgs = true
         iswhere     += " AND sw_catgeory ='#{voucher_category}'"
     end
     
    
     isselect  = "trn_apply_education_aids.*,'' as sewdarname,'' as refercode,'' as dsicode,'' as vd_userid,'Education' as vd_requestfor"
     isselect  += ",'' as dates,'' as prevbalance,'' as department,'' as deginname,'' as totalsewa,'' as installamount"
     
     if isfalgs
      isselect += ",sewb.id as sewID"
      jons     = "LEFT JOIN mst_sewadars sewb ON(sw_compcode = aea_compcode AND sw_sewcode = aea_sewadarcode)"
      loansobj = TrnApplyEducationAid.select(isselect).joins(jons).where(iswhere).order("aea_requestno DESC")
    else        
        loansobj = TrnApplyEducationAid.select(isselect).where(iswhere).order("aea_requestno DESC")
    end

     if loansobj.length >0
          loansobj.each do |newvch|
            sewdobjs   = get_mysewdar_list_details(newvch.aea_sewadarcode)
            if sewdobjs
                newvch.sewdarname   = sewdobjs.sw_sewadar_name
                newvch.refercode    = sewdobjs.sw_oldsewdarcode
                newvch.dsicode      = sewdobjs.sw_desigcode
                newvch.dates        = sewdobjs.sw_joiningdate
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
            end
            
            arrobj.push newvch
          end
     end
     return arrobj

   end
   private
   def pending_print_advance_voucher_report(reqid)
     arrobj    = []
     newreqid  = reqid
     voucher_department = session[:req_voucher_department]
     voucher_category   = session[:req_voucher_category]
     voucher_number     = session[:req_voucher_number]
     sewadar_loantype   = session[:req_sewadar_loantype]
     show_voucher       = session[:req_show_voucher]
     isfalgs    = false
     iswhere   = "al_compcode = '#{@compcodes}' AND al_broucherno = '' AND al_approvestatus='A'"
     if voucher_department !=nil && voucher_department !=''       
         @voucher_department              = voucher_department         
     end
     if voucher_category !=nil && voucher_category !=''         
         isfalgs = true
         iswhere     += " AND sw_catgeory ='#{voucher_category}'"
     end
     
     if sewadar_loantype !=nil && sewadar_loantype !=''         
         iswhere           += " AND al_requesttype ='#{sewadar_loantype}'"
     end
     
     isselect  = "trn_advance_loans.*,'' as sewdarname,'' as refercode,'' as dsicode,'' as vd_userid,(al_advanceamt+al_loanamount) as aea_amount"
     isselect  += ",'' as dates,'' as prevbalance,'' as department,'' as deginname,'' as totalsewa,'' as vd_requestfor"
     if isfalgs
      jons    = "LEFT JOIN mst_sewadars sewb ON(sw_compcode = al_compcode AND sw_sewcode = al_sewadarcode)"
      loansobj = TrnAdvanceLoan.select(isselect).joins(jons).where(iswhere).order("al_requestno asc")
    else        
       loansobj = TrnAdvanceLoan.select(isselect).where(iswhere).order("al_requestno asc")
    end



     if loansobj.length >0
          loansobj.each do |newvch|
            sewdobjs   = get_mysewdar_list_details(newvch.al_sewadarcode)
            if sewdobjs
                newvch.sewdarname  = sewdobjs.sw_sewadar_name
                newvch.refercode   = sewdobjs.sw_oldsewdarcode
                newvch.dsicode     = sewdobjs.sw_desigcode
                newvch.dates       = sewdobjs.sw_joiningdate
                newvch.totalsewa   = get_dob_calculate(format_oblig_date(sewdobjs.sw_joiningdate))
                newvch.prevbalance = ""
                if newvch.al_requesttype == 'Advance'
                   newvch.vd_requestfor = "MA Advance"
                elsif   newvch.al_requesttype == 'Loan'
                   newvch.vd_requestfor = "Advance"
                end
                  sewdptobj   = get_all_department_detail(sewdobjs.sw_depcode)
                  if sewdptobj
                    newvch.department = sewdptobj.departDescription
                  end
                  desobjs = get_sewdar_designation_detail(sewdobjs.sw_desigcode)
                  if desobjs
                    newvch.deginname = desobjs.ds_description
                  end
            end
           
            arrobj.push newvch
          end
     end
     return arrobj

   end
   
######## GET EDUCATION VOUCHER ############
   private
   def get_education_voucher
     
     if params[:server_request] !=nil && params[:server_request] !=''
        session[:req_voucher_department] = nil
        session[:req_voucher_category]   = nil
        session[:req_voucher_number]     = nil
        session[:req_sewadar_loantype]   = nil
        session[:req_show_voucher]       = nil
     end
     voucher_department = params[:voucher_department] !=nil && params[:voucher_department] !='' ? params[:voucher_department] : session[:req_voucher_department]
     voucher_category   = params[:voucher_category] !=nil && params[:voucher_category] !='' ? params[:voucher_category] : session[:req_voucher_category]
     voucher_number     = params[:voucher_number] !=nil && params[:voucher_number] !='' ? params[:voucher_number] : session[:req_voucher_number]
     sewadar_loantype   = params[:sewadar_loantype] !=nil && params[:sewadar_loantype] !='' ? params[:sewadar_loantype] : session[:req_sewadar_loantype]
     show_voucher       = params[:show_voucher] !=nil && params[:show_voucher] !='' ? params[:show_voucher] : session[:req_show_voucher]
     isfalgs            = false
     iswhere            = "aea_compcode ='#{@compcodes}' AND aea_status='A'"
     if voucher_department !=nil && voucher_department !=''
         session[:req_voucher_department] = voucher_department
         @voucher_department              = voucher_department
          iswhere     += " AND aea_departcode ='#{voucher_department}'"
     end
     if voucher_category !=nil && voucher_category !=''
         session[:req_voucher_category] = voucher_category
         @voucher_category = voucher_category
         isfalgs = true
         iswhere     += " AND sw_catgeory ='#{voucher_category}'"
     end
     if voucher_number !=nil && voucher_number !=''
         session[:req_voucher_number] = voucher_number
         @voucher_number = voucher_number
         iswhere     += " AND aea_voucherno ='#{voucher_number}'"
     end
     if sewadar_loantype !=nil && sewadar_loantype !=''
         session[:req_sewadar_loantype] = sewadar_loantype
         @sewadar_loantype  = sewadar_loantype
         
     end
    
     if show_voucher !=nil && show_voucher != ''
        session[:req_show_voucher] = show_voucher
        @show_voucher              = show_voucher
     else
         if voucher_number !=nil && voucher_number !=''
            ## EXECUTE MESSAGE IF REQUIRED
         else
           iswhere     += " AND aea_voucherno =''"
         end
        
     end
     isselect = " aea_sewadarcode as al_sewadarcode,aea_requestdate as al_requestdate,'Education' as al_requesttype,aea_voucherno as al_broucherno"
     isselect += ",trn_apply_education_aids.created_at,aea_amount as al_advanceamt,'' as al_loanamount,aea_departcode as al_depcode,aea_requestdate as al_requestdate,aea_requestno as al_requestno, '' as al_installpermonth"
     
     if isfalgs
         isselect += ",sewb.id as sewID"
         jons     = "LEFT JOIN mst_sewadars sewb ON(sw_compcode = aea_compcode AND sw_sewcode = aea_sewadarcode)"
         loansobj = TrnApplyEducationAid.select(isselect).joins(jons).where(iswhere).order("aea_requestno DESC")
     else        
          loansobj = TrnApplyEducationAid.select(isselect).where(iswhere).order("aea_requestno DESC")
     end
     
     return loansobj
   end

##########VOUCHER PRINTING ###########

########MARRIAGE VOUCHER #####################
private
   def get_marriage_voucher
     
     if params[:server_request] !=nil && params[:server_request] !=''
        session[:req_voucher_department] = nil
        session[:req_voucher_category]   = nil
        session[:req_voucher_number]     = nil
        session[:req_sewadar_loantype]   = nil
        session[:req_show_voucher]       = nil
     end
     voucher_department = params[:voucher_department] !=nil && params[:voucher_department] !='' ? params[:voucher_department] : session[:req_voucher_department]
     voucher_category   = params[:voucher_category] !=nil && params[:voucher_category] !='' ? params[:voucher_category] : session[:req_voucher_category]
     voucher_number     = params[:voucher_number] !=nil && params[:voucher_number] !='' ? params[:voucher_number] : session[:req_voucher_number]
     sewadar_loantype   = params[:sewadar_loantype] !=nil && params[:sewadar_loantype] !='' ? params[:sewadar_loantype] : session[:req_sewadar_loantype]
     show_voucher       = params[:show_voucher] !=nil && params[:show_voucher] !='' ? params[:show_voucher] : session[:req_show_voucher]
     isfalgs            = false
     iswhere            = "ama_compcode ='#{@compcodes}' AND ama_status='A'"
     if voucher_department !=nil && voucher_department !=''
         session[:req_voucher_department] = voucher_department
         @voucher_department              = voucher_department
          iswhere     += " AND ama_departcode ='#{voucher_department}'"
     end
     if voucher_category !=nil && voucher_category !=''
         session[:req_voucher_category] = voucher_category
         @voucher_category = voucher_category
         isfalgs = true
         iswhere     += " AND sw_catgeory ='#{voucher_category}'"
     end
     if voucher_number !=nil && voucher_number !=''
         session[:req_voucher_number] = voucher_number
         @voucher_number = voucher_number
         iswhere     += " AND ama_voucherno ='#{voucher_number}'"
     end
     if sewadar_loantype !=nil && sewadar_loantype !=''
         session[:req_sewadar_loantype] = sewadar_loantype
         @sewadar_loantype  = sewadar_loantype
         
     end
    
     if show_voucher !=nil && show_voucher != ''
        session[:req_show_voucher] = show_voucher
        @show_voucher              = show_voucher
     else
         if voucher_number !=nil && voucher_number !=''
            ## EXECUTE MESSAGE IF REQUIRED
         else
           iswhere     += " AND ama_voucherno =''"
         end
        
     end
     isselect = " ama_sewadarcode as al_sewadarcode,'Marriage' as al_requesttype,ama_voucherno as al_broucherno"
     isselect += ",trn_apply_marriage_aids.created_at,ama_amount as al_advanceamt,'' as al_loanamount,ama_departcode as al_depcode,ama_requestdate as al_requestdate,ama_requestno as al_requestno, '' as al_installpermonth"
     
     if isfalgs
         isselect += ",sewb.id as sewID"
         jons     = "LEFT JOIN mst_sewadars sewb ON(sw_compcode = ama_compcode AND sw_sewcode = ama_sewadarcode)"
         loansobj = TrnApplyMarriageAid.select(isselect).joins(jons).where(iswhere).order("ama_requestno DESC")
     else        
          loansobj = TrnApplyMarriageAid.select(isselect).where(iswhere).order("ama_requestno DESC")
     end
     
     return loansobj
   end

##########VOUCHER PRINTING ###########



########## END MARRIAGE VOUCHER #################


private
   def view_education_request_list(reqid)
      newreqid = set_dct(reqid)
      iswhere = "aea_compcode='#{@compcodes}' AND aea_requestno ='#{newreqid}'"
      isselect = " aea_sewadarcode as al_sewadarcode,aea_requestdate as al_requestdate,'Education' as al_requesttype,aea_voucherno as al_broucherno"
      isselect += ",aea_amount as al_advanceamt,'' as al_loanamount,aea_departcode as al_depcode,aea_requestdate as al_requestdate,aea_requestno as al_requestno, '' as al_installpermonth"
   
      loansobj = TrnApplyEducationAid.select(isselect).where(iswhere).first
      return loansobj
   end

   ### GET MARRIAGE COLLECTION ############
   private
   def view_marriage_request_list(reqid)
      newreqid = set_dct(reqid)
      iswhere  = "ama_compcode='#{@compcodes}' AND ama_requestno ='#{newreqid}'"
      isselect = " ama_sewadarcode as al_sewadarcode,'Marriage' as al_requesttype,ama_voucherno as al_broucherno"
      isselect += ",created_at,ama_amount as al_advanceamt,'' as al_loanamount,ama_departcode as al_depcode,ama_requestdate as al_requestdate,ama_requestno as al_requestno, '' as al_installpermonth"
      loansobj = TrnApplyMarriageAid.select(isselect).where(iswhere).first
      return loansobj
   end

end


