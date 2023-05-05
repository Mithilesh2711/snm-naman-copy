class MaterialIssueController < ApplicationController
   before_action :require_login
   
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process]
   include ErpModule::Common
   helper_method :currency_formatted,:get_name_of_product,:year_month_days_formatted,:formatted_date
   helper_method :set_ent,:set_dct

  def index
  @compcodes            =  session[:loggedUserCompCode]
  @logedId              =  session[:autherizedUserId]
  @xLoc                 =  session[:autherizedLoc]
  @isFlags              =  false
  Time.zone             = "Kolkata"
  @billtimes            =  Time.zone.now.strftime('%I:%M%p')
  @cdate                =  Time.zone.now.strftime('%d-%b-%Y')
  params[:hd_sale_type] = 'S'
  @isusegodaam          = false
  cid                   = '99'
  month_number          =  Time.now.month
  month_begin           =  Date.new(Date.today.year, month_number)
  begdate               =  Date.parse(month_begin.to_s)
  @nbegindate           =  begdate.strftime('%d-%b-%Y')
  month_ending          =  month_begin.end_of_month
  ending_date            = Date.parse(month_ending.to_s)
  @enddate              =  ending_date.strftime('%d-%b-%Y')
  @isBankers            = []
 
  @hdBillDetail         = TrnMaterialIssue.select("mi_doc_number as hd_billnumber").where("mi_compcode=?",@compcodes).order("mi_doc_number ASC")
  @customerLocality     = ''
  @HeadDps              = nil
  @FooterDps            = nil
  @printpath            = nil
  @isSelectDate         = nil
  @isSelectShft         = nil
  @GridFooter           = nil
  @customerName         = nil
  @lastDocNo            = get_last_bill_dt
  if params[:id]!=nil && params[:id]!=nil
          dparmes  = params[:id].split("_")          
          if dparmes[1]!='mdr'              
              docnumber             = set_dct(params[:id])
              session[:docum_no]    = docnumber
              @HeadDps              = TrnMaterialIssue.where("mi_compcode=? AND mi_doc_number=?",@compcodes,docnumber).first
              @GridFooter           = TrnMaterialIssueDetail.where("mid_compcode=? AND mid_docno=?",@compcodes,docnumber).order("mid_position ASC")
              if @HeadDps
                custid = @HeadDps.mi_ship_to
                custobj = get_customer_detail(custid)
                if custobj
                  @customerName = custobj.cs_customername
                end
              end

              ############### PRINT URL DETAIL ######
              if @GridFooter && @GridFooter.length >0
                printcontroll   = "1_mdr_material_issue_report"
                @printpath      = material_issue_path(printcontroll,:format=>"pdf")
              end

          end

          if dparmes[1]=='mdr'
                  @compDetail  = MstCompany.where(["cmp_companycode = ?", @compcodes]).first
                  docnumber    = session[:docum_no]
                  prodrqs      = TrnMaterialIssue.where("mi_compcode=? AND mi_doc_number=?",@compcodes,docnumber).first
                  footers      = TrnMaterialIssueDetail.where("mid_compcode=? AND mid_docno=?",@compcodes,docnumber)
                  if prodrqs
                      custid = prodrqs.mi_ship_to
                      custobj = get_customer_detail(custid)
                      if custobj
                        @customerName = custobj.cs_customername
                      end
                   end

                  if session[:is_root_printing] == 'Y'
                    $scheduleDate = ''
                    $gShift       = ''
                    $scheduleNo   = ''
                    $sitename     = ''
                    $remarks      = ''
                    $customername = @customerName
                    $username     = session[:autherizedUserName]
                    if prodrqs
                       $scheduleDate = formatted_date(prodrqs.mi_date)
                       $gShift       = prodrqs.mi_shift
                       $sitename     = prodrqs.mi_shift_detail
                       $scheduleNo   = prodrqs.mi_doc_number
                       $remarks      = prodrqs.mi_remarks
                    end
                    ##### PRINT EXCEL #########
                    $compcodes      = @compcodes
                    $globalcompname = @compDetail.cmp_companyname.upcase
                    $globaldddres   = @compDetail.cmp_addressline1.upcase.to_s+" "+@compDetail.cmp_addressline2.upcase.to_s+" "+@compDetail.cmp_addressline3.upcase.to_s
                    send_data footers.to_materialissue, :filename=> "material-issue-#{Date.today}.csv"
                    session[:is_root_printing]=nil
                  else
                     ### PRINT PDF ############
                        respond_to do |format|
                          format.html
                            format.pdf do
                                pdf = MaterialissuePdf.new(footers,'',prodrqs,@compDetail,'',@rootUrl,'','',session,'',@customerName)
                                send_data pdf.render,:filename => "1_material_issue_report.pdf", :type => "application/pdf", :disposition => "inline"
                            end
                         end

                  end

            end ### END PRINT IF
  end


end


def ajax_process
    @compcodes = session[:loggedUserCompCode]
    if params[:indedntity]!=nil  && params[:indedntity]!='' && params[:indedntity]=='SITE'
       get_site_details
       return
    elsif params[:indedntity]!=nil  && params[:indedntity]!='' && params[:indedntity]=='MAT'
       search_material_products
       return
   elsif params[:indedntity]!=nil  && params[:indedntity]!='' && params[:indedntity]=='EXP'
       search_expense_products
       return
   elsif params[:indedntity]!=nil  && params[:indedntity]!='' && params[:indedntity]=='TLDTEXP'
       find_total_expense_tilldate
       return
    elsif params[:indedntity]!=nil  && params[:indedntity]!='' && params[:indedntity]=='MRN'
       get_all_mrn_selected_vendor
       return
   elsif params[:indedntity]!=nil  && params[:indedntity]!='' && params[:indedntity]=='PRT'
      istatus = true
      if params[:ischecked]!=nil && params[:ischecked]!='' && params[:ischecked] == 'Y'
        session[:is_root_printing] ='Y'
      else
        session[:is_root_printing] =nil
      end
       respond_to do |format|
        format.json { render :json => { :status=>istatus } }
       end
       return
  elsif params[:indedntity] !=nil  && params[:indedntity] !='' && params[:indedntity] == 'SITECONTR'
       get_contractor_sitewise_details
       return
  elsif params[:indedntity] !=nil  && params[:indedntity] !='' && params[:indedntity] == 'OTPNUMB'
       find_and_send_otp_number
       return
  elsif params[:indedntity] !=nil  && params[:indedntity] !='' && params[:indedntity] == 'MYSERIAL'
       update_sort_position_process_prt
       return
  elsif params[:indedntity]!=nil  && params[:indedntity]!='' && params[:indedntity]=='SCHDL'
       get_payment_scheduled_detail
       return
  elsif params[:indedntity] !=nil  && params[:indedntity] !='' && params[:indedntity] == 'CHKCRD'
       check_user_credential_data
       return
  elsif params[:indedntity] !=nil  && params[:indedntity] !='' && params[:indedntity] == 'ACTIVE'
        session[:idle_timelineout] = 'Y'
       return
  elsif params[:indedntity] !=nil  && params[:indedntity] !='' && params[:indedntity] == 'CLRDBG'
        clean_all_session_credential_data()
       return
  end



  
end

def show
  @compcodes    = session[:loggedUserCompCode]
  @rootUrl      = "#{root_url}"

end

def destroy
  @compcodes    = session[:loggedUserCompCode]
  if params[:id]!=nil && params[:id]!=''
           docnumber = params[:id]
           prodrqs      = TrnMaterialIssue.where("mi_compcode=? AND mi_doc_number=?",@compcodes,docnumber).first
           @smaount  = 0
           if prodrqs
               customers = prodrqs.mi_ship_to
                 if prodrqs.destroy
                       @TrdObj  = TrnMaterialIssueDetail.where("mid_compcode=? AND mid_docno=?",@compcodes,docnumber)
                       ###############################################################################
                        if @TrdObj
                              @TrdObj.each do |invs|
                                @smaount += invs.mid_value
                                compcodes = invs.mid_compcode.to_s
                                mrn       = invs.mid_mrno.to_s
                                itemcode  = invs.mid_itemcode
                                qty       = invs.mid_actualqty
                                reverse_new_update_mrn(compcodes,mrn,itemcode,qty)
                              end
                          end
                         @TrdObj.destroy_all
                         @customerXId = customers
                         @custInvbal  = @smaount
                         @slaetype    = 'S'
                         if @customerXId.to_i >0
                            reverse_customer_stock_balances
                         end
                 end
               isFlags                   = true
               flash[:error]             = "Data deleted successfully."
           end
  end
  redirect_to "#{root_url}material_issue"
end

def material_issue_refresh
   session[:generatecustid]    = nil
   session[:generateshipid]    = nil
   session[:isErrorhandled]    = nil
   session[:canceldeletebill]  = nil
   session[:mybillnumbers]     = nil
   session[:day_prod_date]     = nil
   session[:day_prod_shft]     = nil
   session[:is_root_printing]  = nil
   redirect_to "#{root_url}material_issue"

end
def create
  @compcodes  =  session[:loggedUserCompCode]
  @xLoc       =  session[:autherizedLoc]
  isFlags     =  true
  @crdate     =  Time.now.strftime('%d-%b-%Y')
begin
   if @compcodes == nil || @compcodes == ''
        flash[:error] =  "Invalid company."
        isFlags       =  false
        session[:isErrorhandled]  =  1
   elsif params[:mi_doc_number] == nil || params[:mi_doc_number] == ''
         flash[:error] = "Please enter doc number."
         isFlags       = false
         session[:isErrorhandled]  =  1
   elsif params[:mi_date] == nil || params[:mi_date] == ''
         flash[:error] = "Please enter date."
         isFlags       = false
         session[:isErrorhandled]  =  1
   elsif params[:mi_shift_detail] == nil || params[:mi_shift_detail] == ''
         flash[:error] = "Please select site name"
         isFlags       = false
         session[:isErrorhandled]  =  1
   elsif params[:mi_ship_to_name] == nil || params[:mi_ship_to_name] == ''
         flash[:error] = "Please enter ship to"
         isFlags       = false
         session[:isErrorhandled]  =  1
   else

               if params[:mid_itemcode]!='' && params[:mid_itemcode]!=nil
                        i = 0
                        params[:mid_itemcode].each do |qty|
                            if params[:mid_itemcode][i]==nil || params[:mid_itemcode][i]==''
                                      isFlags       = false
                                      flash[:error] =  "Material name is required."
                                      session[:isErrorhandled]  =  1
                            elsif params[:mid_mrno][i]==nil || params[:mid_mrno][i]==''
                                     isFlags  = false
                                     flash[:error] =  "MRN is required."
                                     session[:isErrorhandled]  =  1
                            elsif params[:mid_actualqty][i]==nil || params[:mid_actualqty][i]==''
                                     isFlags  = false
                                     flash[:error] =  "Issue qty is required."
                                     session[:isErrorhandled]  =  1
                           end

                      end
                           i +=1
                end
                if params[:mid_itemcode].to_s.length <=0
                  isFlags  = false
                   flash[:error]            =  "Please enter an item in grid."
                   session[:isErrorhandled]  =  1
                end
                 
                 headerid     = params[:headerid].to_i >0 ? params[:headerid].to_i : 0
                 @customerXId = params[:mi_ship_to]
                 @custInvbal  = params[:mi_total_value]
                 old_total    = params[:old_total]
                 @slaetype    = 'S'
                if isFlags
                    if headerid.to_i >0
                              isupdatehd    = TrnMaterialIssue.where("mi_compcode=? AND id=?",@compcodes,headerid.to_i).first
                              mi_doc_number = params[:mi_doc_number]!=nil && params[:mi_doc_number]!='' ? params[:mi_doc_number] : ''
                              if isupdatehd
                                  pnbobj =   isupdatehd.update(mat_process_header)                                  
                                  mat_details_params(mi_doc_number)
                                  @custInvbal = old_total
                                  reverse_customer_stock_balances()
                                  @custInvbal = @custInvbal
                                  save_customer_stock_balances()
                                  isFlags                   = true
                                  flash[:error]             = "Data updated successfully."
                                  session[:isErrorhandled]  =  nil
                              end
                        else

                            pnbobj =   TrnMaterialIssue.new(mat_process_header)
                             if pnbobj.save
                                    if params[:isprocessedupdated]!=nil && params[:isprocessedupdated]!='' && params[:isprocessedupdated] =='Y'
                                       mi_doc_number     = params[:mi_doc_number]!=nil && params[:mi_doc_number]!='' ? params[:mi_doc_number] : ''
                                    else
                                       mi_doc_number     = @sumXOfCode
                                    end
                                    mat_details_params(mi_doc_number)
                                    save_customer_stock_balances()                                  
                                    isFlags                   = true
                                    flash[:error]             = "Data saved successfully."
                                    session[:isErrorhandled]  =  nil
                             end
                      end
                 end
                 if isFlags
                    session[:isErrorhandled]  = nil
                 else
                    session[:isErrorhandled]  = 1
                 end
       end
     rescue Exception => exc
          flash[:error]                  = "#{exc.message}"
          session[:isErrorhandled]       = 1
          session[:canceldeletebill]     = nil
          docnom                         = params[:mi_doc_number]
          if params[:isprocessedupdated]!='Y'
            rollback_billing_if_not_acl(@compcodes,docnom)
          end

     end
     redirect_to "#{root_url}"+"material_issue"
end


private
def new_update_mrn(compcodes,mrn,itemcode,qty)
  ismatobj = TrnMaterialReceiveNoteDetail.where("mcnd_compcode=? AND mcnd_number=? AND mcnd_itemcode=?",compcodes,mrn,itemcode).first
  if ismatobj
    eqty = ismatobj.mcnd_total_bal_qty
    nqty = eqty.to_f-qty.to_f
    ismatobj.update(:mcnd_total_bal_qty=>nqty)
  end
end
private
def reverse_new_update_mrn(compcodes,mrn,itemcode,qty)
  ismatobj = TrnMaterialReceiveNoteDetail.where("mcnd_compcode=? AND mcnd_number=? AND mcnd_itemcode=?",compcodes,mrn,itemcode).first
  if ismatobj
    eqty = ismatobj.mcnd_total_bal_qty
    nqty = eqty.to_f+qty.to_f
    ismatobj.update(:mcnd_total_bal_qty=>nqty)
  end
end


private
def sitetwo_updated(compcodes,siteno,itemcode,qty)
  ismatobj = TrnSiteClosingBal.where("scb_compcode=? AND scb_stiteno=? AND scb_productcode=?",compcodes,siteno,itemcode).first
  if ismatobj
      eqty = ismatobj.scb_closing_bal
      nqty = eqty.to_f+qty.to_f
      ismatobj.update(:scb_closing_bal=>nqty)
  else
      issvobj = TrnSiteClosingBal.new(:scb_compcode=>compcodes,:scb_stiteno=>siteno,:scb_productcode=>itemcode,:scb_closing_bal=>qty)
      if issvobj.save
        ## EXECUTE IF REQUIRED
      end
  end
end
private
def reverse_sitetwo_updated(compcodes,siteno,itemcode,qty)
  ismatobj = TrnSiteClosingBal.where("scb_compcode=? AND scb_stiteno=? AND scb_productcode=?",compcodes,siteno,itemcode).first
  if ismatobj
    eqty = ismatobj.scb_closing_bal
    nqty = eqty.to_f-qty.to_f
    ismatobj.update(:scb_closing_bal=>nqty)
  end
end

private
def site_first_updated(compcodes,siteno,itemcode,qty)
  ismatobj = TrnSiteClosingBal.where("scb_compcode=? AND scb_stiteno=? AND scb_productcode=?",compcodes,siteno,itemcode).first
  if ismatobj
      eqty = ismatobj.scb_closing_bal
      nqty = eqty.to_f-qty.to_f
      ismatobj.update(:scb_closing_bal=>nqty)
  else
      issvobj = TrnSiteClosingBal.new(:scb_compcode=>compcodes,:scb_stiteno=>siteno,:scb_productcode=>itemcode,:scb_closing_bal=>qty)
      if issvobj.save
        ## EXECUTE IF REQUIRED
      end
  end
end
private
def reverse_site_first_updated(compcodes,siteno,itemcode,qty)
  ismatobj = TrnSiteClosingBal.where("scb_compcode=? AND scb_stiteno=? AND scb_productcode=?",compcodes,siteno,itemcode).first
  if ismatobj
    eqty = ismatobj.scb_closing_bal
    nqty = eqty.to_f+qty.to_f
    ismatobj.update(:scb_closing_bal=>nqty)
  end
end



private
def mat_process_header
      @compCodes  = session[:loggedUserCompCode]
      @xLoc       = session[:autherizedLoc]
      @isCode     = 0
      @Startx    = '0000'
      @recCodes  = TrnMaterialIssue.select("mi_doc_number").where(["mi_compcode = ? AND mi_doc_number >0", @compcodes]).order('mi_doc_number DESC').first
      if @recCodes
        @isCode    = @recCodes.mi_doc_number.to_i
      end
      @sumXOfCode    = @isCode.to_i + 1
      if @sumXOfCode.to_i < 10
        @sumXOfCode = p @Startx.to_s + @sumXOfCode.to_s
      elsif @sumXOfCode.to_s.length < 3
        @sumXOfCode = p "000" + @sumXOfCode.to_s
      elsif @sumXOfCode.to_s.length < 4
        @sumXOfCode = p "00" + @sumXOfCode.to_s
      elsif @sumXOfCode.to_s.length < 5
        @sumXOfCode = p "0" + @sumXOfCode.to_s
      elsif @sumXOfCode.to_s.length >5
        @sumXOfCode =  @sumXOfCode.to_i
      end
      dates       = 0
      if params[:mi_date]!='' && params[:mi_date]!=nil
        dates = year_month_days_formatted(params[:mi_date])
      end
      if params[:isprocessedupdated]!=nil && params[:isprocessedupdated]!='' && params[:isprocessedupdated] =='Y'
         params[:mi_doc_number]     = params[:mi_doc_number]!=nil && params[:mi_doc_number]!='' ? params[:mi_doc_number] : ''
      else
         params[:mi_doc_number]     = @sumXOfCode
      end
      
      params[:mi_shift]          = params[:mi_shift]!=nil && params[:mi_shift]!='' ? params[:mi_shift] : ''
      params[:mi_shift_detail]   = params[:mi_shift_detail]!=nil && params[:mi_shift_detail]!='' ? params[:mi_shift_detail] : ''     
      params[:mi_date]           = dates
      params[:mi_compcode]       = @compCodes
      params[:mi_sitetwo_name]   = params[:mi_ship_to_name]!=nil && params[:mi_ship_to_name]!='' ? params[:mi_ship_to_name] : ''
      params[:mi_ship_to]        = params[:mi_ship_to]!=nil && params[:mi_ship_to]!='' ? params[:mi_ship_to] : ''

      params[:mi_remarks]        = params[:mi_remarks]!=nil && params[:mi_remarks]!='' ? params[:mi_remarks] : ''     
      params[:mi_total_qty]      = params[:mi_total_qty]!=nil && params[:mi_total_qty]!='' ? params[:mi_total_qty] : 0
      params[:mi_total_value]    = params[:mi_total_value]!=nil && params[:mi_total_value]!='' ? params[:mi_total_value] : 0 
      params.permit(:mi_compcode,:mi_sitetwo_name,:mi_doc_number,:mi_date,:mi_shift,:mi_shift_detail,:mi_remarks,:mi_ship_to,:mi_total_qty,:mi_total_value)

end

private
def mat_details_params(mid_docno)
@compcodes     = session[:loggedUserCompCode]
mid_compcode   = @compcodes
isnewprocess   = 0
mid_siteno     = params[:mi_shift]!=nil && params[:mi_shift]!='' ? params[:mi_shift] : ''
mid_sitetwo    = params[:mi_ship_to]!=nil && params[:mi_ship_to]!='' ? params[:mi_ship_to] : ''

if params[:mid_itemcode]!='' && params[:mid_itemcode]!=nil
      i = 0
      params[:mid_itemcode].each do |tnd|
             if params[:mid_itemcode][i]!=nil && params[:mid_itemcode][i]!=''
               mid_itemcode = params[:mid_itemcode][i]
             else
               mid_itemcode = ''
            end
            if params[:mid_itemname][i]!=nil && params[:mid_itemname][i]!=''
               mid_itemname = params[:mid_itemname][i]
            else
              mid_itemname  = ''
            end
            if params[:mid_mrno][i]!=nil && params[:mid_mrno][i]!=''
                mid_mrno = params[:mid_mrno][i]
            else
                mid_mrno = ''
            end

            if params[:mid_balqty][i]!=nil && params[:mid_balqty][i]!=''
              mid_balqty = params[:mid_balqty][i]
            else
              mid_balqty = 0
            end

            if params[:mid_actualqty][i]!=nil && params[:mid_actualqty][i]!=''
              mid_actualqty = params[:mid_actualqty][i]
            else
              mid_actualqty = 0
            end

            if params[:mid_rate][i]!=nil && params[:mid_rate][i]!=''
               mid_rate = params[:mid_rate][i]
            else
               mid_rate = 0
            end
            if params[:mid_value][i]!=nil && params[:mid_value][i]!=''
               mid_value = params[:mid_value][i]
            else
               mid_value = 0
            end


            if params[:mid_remarks][i]!=nil && params[:mid_remarks][i]!=''
               mid_remarks = params[:mid_remarks][i]
            else
               mid_remarks = ''
            end
            if params[:mid_position][i]!=nil && params[:mid_position][i]!=''
               mid_position = params[:mid_position][i]
            else
               mid_position = 0
            end
            if params[:mid_old_qty][i]!=nil && params[:mid_old_qty][i]!=''
               mid_old_qty = params[:mid_old_qty][i]
            else
               mid_old_qty = 0
            end

            if params[:bill_id][i]!=nil && params[:bill_id][i]!=''
               bill_id = params[:bill_id][i]
            else
               bill_id = 0
            end

            if mid_value.to_f >0 && mid_mrno!=nil && mid_mrno!=''
               material_save_params_details(mid_compcode,mid_docno,mid_siteno,mid_itemcode,mid_itemname,mid_mrno,mid_balqty,mid_actualqty,mid_rate,mid_value,mid_remarks,mid_position,mid_old_qty,mid_sitetwo,bill_id)
               isnewprocess = 1
            end
          i += 1
      end
 end
  return isnewprocess
end ## END METHED

private
def material_save_params_details(mid_compcode,mid_docno,mid_siteno,mid_itemcode,mid_itemname,mid_mrno,mid_balqty,mid_actualqty,mid_rate,mid_value,mid_remarks,mid_position,mid_old_qty,mid_sitetwo,bill_id)
     ############     
     isupdate  = TrnMaterialIssueDetail.where("mid_compcode=? AND id=?",mid_compcode,bill_id.to_i).first
     if isupdate
            isupdate.update(:mid_compcode=>mid_compcode,:mid_sitetwo=>mid_sitetwo,:mid_position=>mid_position,:mid_docno=>mid_docno,:mid_siteno=>mid_siteno,:mid_itemcode=>mid_itemcode,:mid_itemname=>mid_itemname,:mid_mrno=>mid_mrno,:mid_balqty=>mid_balqty,:mid_actualqty=>mid_actualqty,:mid_rate=>mid_rate,:mid_value=>mid_value,:mid_remarks=>mid_remarks)
            ######### FOR MRN SITEWISE STOCK ################### */
             reverse_new_update_mrn(mid_compcode,mid_mrno,mid_itemcode,mid_old_qty)
             new_update_mrn(mid_compcode,mid_mrno,mid_itemcode,mid_actualqty)
            ######### FOR PRODUCT STOCK ################### */
             reverse_material_issue_return_balances(mid_compcode,mid_itemcode,mid_old_qty)
             save_material_issue_return_balances(mid_compcode,mid_itemcode,mid_actualqty)
             ## DEDUCT BAL FROM SITE ONE
             reverse_site_first_updated(mid_compcode,mid_siteno,mid_itemcode,mid_old_qty)
             site_first_updated(mid_compcode,mid_siteno,mid_itemcode,mid_actualqty)
             ##### ADD BAL INTO SITE 2
             reverse_sitetwo_updated(mid_compcode,mid_sitetwo,mid_itemcode,mid_old_qty)
             sitetwo_updated(mid_compcode,mid_sitetwo,mid_itemcode,mid_actualqty)
            
            ######## END PRODUCT STOCK #############
     else
         isaveobj =  TrnMaterialIssueDetail.new(:mid_compcode=>mid_compcode,:mid_sitetwo=>mid_sitetwo,:mid_position=>mid_position,:mid_docno=>mid_docno,:mid_siteno=>mid_siteno,:mid_itemcode=>mid_itemcode,:mid_itemname=>mid_itemname,:mid_mrno=>mid_mrno,:mid_balqty=>mid_balqty,:mid_actualqty=>mid_actualqty,:mid_rate=>mid_rate,:mid_value=>mid_value,:mid_remarks=>mid_remarks)
         if isaveobj.save
           ######### FOR MRN SITEWISE STOCK ################### */
           new_update_mrn(mid_compcode,mid_mrno,mid_itemcode,mid_actualqty)
           ######### FOR PRODUCT STOCK ################### */
           save_material_issue_return_balances(mid_compcode,mid_itemcode,mid_actualqty)
            ## DEDUCT BAL FROM SITE ONE
           site_first_updated(mid_compcode,mid_siteno,mid_itemcode,mid_actualqty)
           ##### ADD BAL INTO SITE 2
           sitetwo_updated(mid_compcode,mid_sitetwo,mid_itemcode,mid_actualqty)
           ## EXECUTE IF REQUIRED
         end
     end
end

def rollback_billing_if_not_acl(compcode,docsno)
 @qtdelete  = TrnMaterialIssue.joins("JOIN trn_material_issue_details ON(mid_compcode=mi_compcode AND mi_doc_number=mid_docno)").where("mi_compcode=? AND mi_doc_number=?",compcode,docsno)
 if @qtdelete.length <=0
     @qtalldelete  = TrnMaterialIssue.where("mi_compcode=? AND mi_doc_number=?",compcode,docsno)
     @qtalldelete.destroy_all
 end

end


private
def find_and_send_otp_number
  istatus    = false
  mobileno   = "9999905301" #"8076372788" #
  types      = params[:types]
  otpnumber  = generate_common_numbers(6)
  if otpnumber.to_s.length >0
      if types == 'UPD'
           messages = "Your OTP is  :  #{otpnumber}"
         #messages   = " Update MRN OTP Number is : #{otpnumber}"
      elsif types == 'CLD'
        messages   = "Your OTP is  :  #{otpnumber}"
      end
      istatus = true
      UserMailMailer.send_common_message(mobileno,messages).deliver
      
  end
   respond_to do |format|
    format.json { render :json => { :status=>istatus,'otpnumber'=>otpnumber } }
  end
  
end

private
def get_site_details
  sitsid  = params[:productname]!=nil && params[:productname]!='' ? params[:productname] : ''
  iswhere = " st_compcode='#{@compcodes}'"
  if sitsid!=nil && sitsid!=''
    iswhere += " AND st_name LIKE '%#{sitsid}%'"
  end
 isobj   = MstSiteMaster.select("st_number,st_name").where(iswhere).order('st_name ASC')
 istatus = false
 if isobj
    istatus = true
 end
 respond_to do |format|
  format.json { render :json => { :status=>istatus,'data'=>isobj } }
 end
 
end


private
def get_contractor_sitewise_details
  siteno  = params[:siteno]!=nil && params[:siteno]!='' ? params[:siteno] : ''
 iswhere  = " ct_compcode = '#{@compcodes}' AND ct_siteno ='#{siteno}' "
 isobj    = TrnContract.select("ct_serviceprov_id").where(iswhere)
 acont    = ''
 istatus  = false
 allcontrobj = []
 if isobj.length >0
       isobj.each do |allcontract|
          acont +=allcontract.ct_serviceprov_id.to_s+","
       end
       if acont!='' && acont!=nil
         acont = acont.chop
          isnwhere = "cs_compcode='#{@compcodes}' AND id IN(#{acont})"
          allcontrobj  = MstCustomer.select("id,cs_customername,cs_contactpersonname,cs_contactpersonname").where(isnwhere).order("cs_customername ASC")
       end
       istatus = true
 end
 respond_to do |format|
  format.json { render :json => { :status=>istatus,'data'=>allcontrobj } }
 end

end

private
def get_last_bill_dt
  @xLoc       = (session[:autherizedLoc].to_i >0) ? session[:autherizedLoc] : 0
  @isCode     = 0
  @Startx    = '0000'
  @recCodes  = TrnMaterialIssue.select("mi_doc_number").where(["mi_compcode = ? AND mi_doc_number >0", @compcodes]).order('mi_doc_number DESC').first
   if @recCodes
    @isCode    = @recCodes.mi_doc_number.to_i
   end

    @sumXOfCode    = @isCode.to_i + 1
    if @sumXOfCode.to_i < 10
      @sumXOfCode = p @Startx.to_s + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length < 3
      @sumXOfCode = p "000" + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length < 4
      @sumXOfCode = p "00" + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length < 5
      @sumXOfCode = p "0" + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length >5
      @sumXOfCode =  @sumXOfCode.to_i
    end
    return @sumXOfCode
end

private
def get_payment_scheduled_detail
  siteno      = params[:siteno]!=nil && params[:siteno]!='' ? params[:siteno] : ''
  contractor  = params[:contractor]!=nil && params[:contractor]!='' ? params[:contractor] : ''
  
  istatus    = false
  iswhere    = "  ct_compcode ='#{@compcodes}'"
  iswhere    +=  " AND ct_siteno ='#{siteno}'"
  iswhere    +=  " AND ct_serviceprov_id ='#{contractor}'"
  jons       = "JOIN trn_contract_details cts ON(cond_compcode = ct_compcode AND cond_number = ct_number)"
 isselect   =  " cts.*,trn_contracts.id as contId,DATE_FORMAT(cond_date,'%b-%d-%Y') as conddate"
 objitems    = TrnContract.select(isselect).joins(jons).where(iswhere).order("ct_number ASC")
 if objitems.length >0
   istatus = true
 end

 respond_to do |format|
  format.json { render :json => { :status=>istatus,'data'=>objitems } }
 end

end




private
def search_material_products
  @isXProdName   = nil
  iswhere        = "pd_compcode = '#{@compcodes}' AND ( pd_type='F' OR pd_useboth='Y' )"
   if params[:productname]!='' && params[:productname]!=nil
         productname  =  params[:productname]+"%"
         iswhere     +=  " AND pd_productname LIKE '#{productname}'"
         @isXProdName =   MstProduct.select('mst_products.id as prodId,pd_refer_no,pd_productcode,pd_taxtincyesno,pd_productname,pd_productcode,pd_mrps,pd_purchaserate,pd_weight,pd_gross_weight,"" as pdclbalance').where(iswhere).order('TRIM(pd_productname) ASC')   
   else
         @isXProdName =   MstProduct.select('mst_products.id as prodId,pd_refer_no,pd_productcode,pd_productname,pd_taxtincyesno,pd_productcode,pd_mrps,pd_purchaserate,pd_weight,pd_gross_weight,"" as pdclbalance').where(iswhere).order('TRIM(pd_productname) ASC').limit('30')
   end

  arrp  = []
  if @isXProdName!=nil
      if @isXProdName.length >0
           @isXProdName.each do |arp|
               arrp.push arp
           end
       end
  end

  if arrp.length >0
      @msg = "success"
      respond_to do |format|
         format.json { render :json => { 'data'=>arrp, "message"=>@msg,:status=>200 } }
      end
  end

end

private
def get_all_mrn_selected_vendor
  mrncode   = params[:productname]!=nil && params[:productname]!='' ? params[:productname] : ''
  itemcode  = params[:itemcode]!=nil && params[:itemcode]!='' ? params[:itemcode] : ''
  customers = params[:customers]!=nil && params[:customers]!='' ? params[:customers] : ''
  matreturn = params[:chkInvoiceType]!=nil && params[:chkInvoiceType]!='' ? params[:chkInvoiceType] : ''
  istatus   = false  
  iswhere   = " mcnd_compcode='#{@compcodes}' AND mcnd_itemcode='#{itemcode}' AND mcnd_siteno='#{customers}'"
  if matreturn!=nil && matreturn!='' && matreturn == 'matreturn'
     iswhere +=  " AND mcnd_excess NOT IN('E','S')"
  else
     iswhere +=  " AND mcnd_total_bal_qty >0 AND mcnd_excess NOT IN('E','S')"
  end  
  if mrncode!=nil && mrncode!=''
    iswhere += " AND mcnd_number LIKE '%#{mrncode}%'"
  end 
 sselect =  " mcnd_number as mcn_number,mcnd_blance_qnty,mcnd_rate,mcnd_total_bal_qty" 
 isproduct = TrnMaterialReceiveNoteDetail.select(sselect).where(iswhere).order("mcnd_number").group("mcnd_number ASC")
 if isproduct
   istatus = true
 end

 respond_to do |format|
  format.json { render :json => { :status=>istatus,'data'=>isproduct } }
 end
 
end

private
def save_customer_stock_balances
   compcodes   = session[:loggedUserCompCode]
   csbalance   = 0
    if @customerXId.to_i >0
        @openingBal = MstCustomer.where(["cs_compcode= ? AND id= ? and cs_loc=?", compcodes,@customerXId.to_i,@isLoc]).first
        if @openingBal
          csbalance =@openingBal.cs_cbamount
        end
         @slaetype = 'P'
         if @custInvbal.to_f >0
            if @slaetype == 'S'
              csbalance = csbalance.to_f+@custInvbal.to_f
            elsif @slaetype == 'P'
              csbalance = csbalance.to_f-@custInvbal.to_f
            elsif @slaetype == 'PR'
              csbalance = csbalance.to_f+@custInvbal.to_f
            elsif @slaetype == 'SR'
              csbalance = csbalance.to_f-@custInvbal.to_f
            end
            if @openingBal
              @openingBal.update(:cs_cbamount=>csbalance)
            end
        end
    end
end

private
def reverse_customer_stock_balances ## Call only case of update,delete,cancel
   compcodes   = session[:loggedUserCompCode]
   csbalance   = 0
  if @customerXId.to_i >0
        @openingBal = MstCustomer.where(["cs_compcode= ? AND id= ? and cs_loc=?", compcodes,@customerXId.to_i,@isLoc]).first
        if @openingBal
          csbalance =@openingBal.cs_cbamount
        end
        @slaetype = 'P'
        if @custInvbal.to_f >0
            if @slaetype == 'S'
              csbalance = csbalance.to_f-@custInvbal.to_f
            elsif @slaetype == 'P'
              csbalance = csbalance.to_f+@custInvbal.to_f
            elsif @slaetype == 'PR'
              csbalance = csbalance.to_f-@custInvbal.to_f
            elsif @slaetype == 'SR'
              csbalance = csbalance.to_f+@custInvbal.to_f
            end
           if @openingBal
            @openingBal.update(:cs_cbamount=>csbalance)
           end
        end
    end
end

private
def save_material_issue_return_balances(dt_compcode,dt_itemcode,dt_quantity)  
   netbalance           = dt_quantity.to_f
   saletype             = 'S'
   csbalance            = 0  
   
    if dt_itemcode!=nil &&  dt_itemcode!=''
          @openingBal = MstClosingBalance.where(["cb_compcode= ? AND cb_pdcode= ? and cb_loc=?", dt_compcode,dt_itemcode,@isLoc]).first
          if @openingBal
               csbalance = @openingBal.cb_closing_bal
          end
          if netbalance.to_f >0
              if saletype == 'S'
                csbalance = csbalance.to_f-netbalance.to_f
              elsif saletype == 'P'
                csbalance = csbalance.to_f+netbalance.to_f
              elsif saletype == 'PR'
                csbalance = csbalance.to_f-netbalance.to_f
              elsif saletype == 'SR'
                csbalance = csbalance.to_f+netbalance.to_f
             end
          end
        
          if  csbalance >0
              if @openingBal
                   @openingBal.update(:cb_closing_bal=>csbalance)
              else
                   @saveBal= MstClosingBalance.new(:cb_compcode=>dt_compcode,:cb_pdcode=>dt_itemcode,:cb_closing_bal=>csbalance)
                   @saveBal.save
              end
          end
    end
end



private
def reverse_material_issue_return_balances(dt_compcode,dt_itemcode,dt_quantity)
   netbalance           = dt_quantity.to_f
   saletype             = 'S'
   csbalance            = 0
    if dt_itemcode!=nil &&  dt_itemcode!=''
          @openingBal = MstClosingBalance.where(["cb_compcode= ? AND cb_pdcode= ? and cb_loc=?", dt_compcode,dt_itemcode,@isLoc]).first
          if @openingBal
               csbalance = @openingBal.cb_closing_bal
          end
          if netbalance.to_f >0
              if saletype == 'S'
                csbalance = csbalance.to_f+netbalance.to_f
              elsif saletype == 'P'
                csbalance = csbalance.to_f-netbalance.to_f
              elsif saletype == 'PR'
                csbalance = csbalance.to_f+netbalance.to_f
              elsif saletype == 'SR'
                csbalance = csbalance.to_f-netbalance.to_f
             end
          end
          if  csbalance >0
              if @openingBal
                   @openingBal.update(:cb_closing_bal=>csbalance)
              end
          end
     end
end
private
def find_total_expense_tilldate
  dt       = ''
  texpense = 0
  isflag   = false
  if params[:tildates]!='' && params[:tildates]!=nil    
    dt      = year_month_days_formatted(params[:tildates])
  end
  siteno   = params[:siteno]
  pdname   = params[:productname].to_s.delete(' ').downcase
  
  iswhere  = " exp_compcode = '#{@compcodes}' AND exp_date <='#{dt}' AND REPLACE(LOWER(exd_expensename),' ','')='#{pdname}'"
  if siteno!=nil && siteno!=''
    iswhere  += "  AND exd_siteno='#{siteno}'"
  end
  isselect  = " SUM(exd_amount) as totalexpense"
  jons      = " JOIN trn_expense_entry_details ON(exp_compcode = exd_compcode and exp_number = exd_number)"
  expobj    = TrnExpenseEntry.select(isselect).joins(jons).where(iswhere)
  if expobj.length >0
    texpense = expobj[0].totalexpense
    isflag = true
  end
  
  respond_to do |format|
     format.json { render :json => { 'data'=>texpense, "message"=>'',:status=>isflag } }
  end

end

private
def search_expense_products
  @isXProdName   = nil

  iswhere        = "pd_compcode = '#{@compcodes}' AND ( pd_type='E' OR pd_useboth='Y' ) " 
  
  isselect       = 'mst_products.id as prodId,pd_refer_no,pd_productcode,pd_taxtincyesno,pd_productname,pd_productcode,pd_mrps,pd_purchaserate,pd_weight,pd_gross_weight,"" as pdclbalance'
  
   if params[:productname]!='' && params[:productname]!=nil
         productname  =  params[:productname]
         iswhere     +=  " AND pd_productname LIKE '%#{productname}%'"        
         @isXProdName =   MstProduct.select(isselect).where(iswhere).order('pd_productname ASC')
   else
         @isXProdName =   MstProduct.select(isselect).where(iswhere).order('pd_productname ASC').limit('30')
   end

  arrp  = []
  if @isXProdName!=nil
      if @isXProdName.length >0
           @isXProdName.each do |arp|
               arrp.push arp
           end
       end
  end

      @msg = "success"
      respond_to do |format|
         format.json { render :json => { 'data'=>arrp, "message"=>@msg,:status=>200 } }
      end

end

private
def clean_all_session_credential_data
session[:approveStatus]   = nil
session[:mydatefilter]    = nil
session[:myfrom_date]     = nil
session[:myupto_date]     = nil
session[:po_number]       = nil
session[:mcn_supplier_id] = nil
session[:mysuppliers]     = nil
session[:filter_mi_shift] = nil
session[:filter_shift_detail] = nil
session[:approveStatus]   = nil
session[:mydatefilter]    = nil
session[:myfrom_date]     = nil
session[:myupto_date]     = nil
session[:po_number]       = nil
session[:mcn_supplier_id] = nil
session[:mysuppliers]     = nil
session[:approveStatus]       = nil
session[:mydatefilter]        = nil
session[:myfrom_date]         = nil
session[:myupto_date]         = nil
session[:po_number]           = nil
session[:mcn_supplier_id]     = nil
session[:mysuppliers]         = nil
session[:filter_mi_shift]     = nil
session[:filter_shift_detail] = nil
session[:mybillnumbers]        = nil
session[:is_searchpono]        = nil
 respond_to do |format|
  format.json { render :json => { :status=>true,'message'=>'' } }
 end


end

private
def update_sort_position_process_prt
   srializeddata = params[:srializeddata]!=nil && params[:srializeddata]!='' ? params[:srializeddata] : ''
   spdaa = srializeddata.split(",")
   c     = 1
   isflas = true
   spdaa.each do |list|
     if list!='' && list!='0'
       spsid  = list
       postion = c
       update_orders_parameters(spsid,postion)
     end
     c +=1
   end
    respond_to do |format|
       format.json { render :json => { 'data'=>'', "message"=>'',:status=>isflas } }
    end
end
private
def update_orders_parameters(spsid,postion)
  processprobj = MstLevelMaster.where("lm_compcode=? AND id=?",@compcodes,spsid).first
  if processprobj
      processprobj.update(:lm_position=>postion)
  end

end

private
def check_user_credential_data
  @isLogedId    =  session[:autherizedUserId]
  iscompcode    =  session[:loggedUserCompCode]
  password      =  params[:password]!=nil && params[:password]!='' ? params[:password] : ''
  objuser       =  User.select('userpassword').where("usercompcode = ? AND id=?",iscompcode.to_s,@isLogedId).first
 istatus        =  false
 message        =  ""
 if password !=nil && password !=''
     if objuser
          xpassword = Digest::MD5.hexdigest(password)
         if objuser.userpassword == xpassword
             istatus                     = true
             session[:load_current_user] = 'Y'
         else
              message = "Invalid Password."
              istatus =  false
         end
     else
             message = "Invalid user."
            istatus =  false
     end
 else
        message = "Please enter password."
 end
 respond_to do |format|
  format.json { render :json => { :status=>istatus,'message'=>message } }
 end

end

end
