class HrParametersController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:search,:ledger_list,:ajax_process]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted
  helper_method :format_oblig_date,:get_month_listed_data

  def index
    @compcodes   =  session[:loggedUserCompCode]
    @hrRange     =  MstHrParameterRange.where("hpr_compcode =? ",@compcodes).order("hpr_rangefrom ASC")
    @hraccmtype  =  MstAccomodationType.where("at_compcode =?",@compcodes).order("at_description ASC")
    @HeadHrp     =  MstHrParameterHead.where("hph_compcode = ?",@compcodes).first
    month_number =  Time.now
    begdate      =  Date.parse(month_number.to_s)
    @nbegindate  =  2021
    nedatas      = []
    @CurrentYear  = Time.now.strftime("%Y")
    @CurrentMonth = Time.now.strftime("%m")
    #process_update_advance_cbs()
    if @HeadHrp

    end
    nsdobj       = MstHrParameterAccomodation.select("mst_hr_parameter_accomodations.*,'' as hracctype").where("hpa_compcode = ?",@compcodes).order("id desc")
     if nsdobj.length >0
           nsdobj.each do |newds|
              hrstype =    get_accomodation_type(@compcodes,newds.hpa_types)
              if hrstype
                newds.hracctype = hrstype.at_description
              end
              nedatas.push newds
           end
     end
     @neDatas = nedatas
  end
  
  def create

  end
  def ajax_process
      @compcodes = session[:loggedUserCompCode]
      if params[:identity]!=nil && params[:identity]!= '' && params[:identity] == 'Y'
          process_range_data();
          return;
      elsif params[:identity]!=nil && params[:identity]!= '' && params[:identity] == 'DELT'
          process_common_delete();
          return;
      elsif params[:identity]!=nil && params[:identity]!= '' && params[:identity] == 'HVL'
          process_add_hrparameter_values();
          return;
      elsif params[:identity]!=nil && params[:identity]!= '' && params[:identity] == 'HRHD'
          process_hrparameter_head();
          return;
      end



  end

  private
  def process_range_data
    hpr_rangefrom = params[:hpr_rangefrom] !=nil && params[:hpr_rangefrom] !='' ? params[:hpr_rangefrom] : 0
    hpr_rangeto   = params[:hpr_rangeto] !=nil && params[:hpr_rangeto] !='' ? params[:hpr_rangeto] : 0
    hpr_rate1     = params[:hpr_rate1] !=nil && params[:hpr_rate1] !='' ? params[:hpr_rate1] : 0
    hpr_rate2     = params[:hpr_rate2] !=nil && params[:hpr_rate2] !='' ? params[:hpr_rate2] : 0
    mid           = params[:mid]
    message = ""
    isfalgs = false
    if mid.to_i >0
      uhrobj = MstHrParameterRange.where("hpr_compcode =? AND id = ?",@compcodes,mid).first
       if uhrobj
         uhrobj.update(:hpr_rangefrom=>hpr_rangefrom,:hpr_rangeto=>hpr_rangeto,:hpr_rate1=>hpr_rate1,:hpr_rate2=>hpr_rate2)
         message = "Data updated successfully."
         isfalgs = true
       end
    else
         svsobj  =  MstHrParameterRange.new(:hpr_compcode=>@compcodes,:hpr_rangefrom=>hpr_rangefrom,:hpr_rangeto=>hpr_rangeto,:hpr_rate1=>hpr_rate1,:hpr_rate2=>hpr_rate2)
         if svsobj.save
           message = "Data saved successfully."
            isfalgs = true
         end
    end
    hrpobj  = MstHrParameterRange.where("hpr_compcode =? ",@compcodes).order("id DESC")
    respond_to do |format|
        format.json { render :json => { 'data'=>hrpobj, "message"=>message,:status=>isfalgs} }
     end
  end
  
private
 def process_common_delete
   mid           = params[:mid]
   types         = params[:types]
   delobj        = []
   message       = ""
   isfalgs = false
    if types == 'RNG'
        hrpobj  = MstHrParameterRange.where("hpr_compcode =?  AND id =?",@compcodes,mid).first
        if hrpobj
           hrpobj.destroy
           message = "Data deleted sucessfully."
        else
           message = "No record(s) match for delete."
        end
        isfalgs = true
        delobj  = MstHrParameterRange.where("hpr_compcode =? ",@compcodes).order("id DESC")
    elsif types == 'AVL'
        hrpobj  = MstHrParameterAccomodation.where("hpa_compcode = ? AND id = ?",@compcodes,mid).first
        if hrpobj
           hrpobj.destroy
           message = "Data deleted sucessfully."
        else
           message = "No record(s) match for delete."
        end
        isfalgs = true
         nedatas = []
         nsdobj  = MstHrParameterAccomodation.select("mst_hr_parameter_accomodations.*,'' as hracctype").where("hpa_compcode = ?",@compcodes).order("id desc")
         if nsdobj.length >0
             nsdobj.each do |newds|
              hrstype =    get_accomodation_type(@compcodes,newds.hpa_types)
              if hrstype
                newds.hracctype = hrstype.at_description
              end
              nedatas.push newds
             end
         end
         delobj = nedatas
    end

     respond_to do |format|
        format.json { render :json => { 'data'=>delobj, "message"=>message,:status=>isfalgs} }
     end

 end


 private
 def process_add_hrparameter_values
     mid       = params[:mid]
     hpa_types = params[:hpa_types] !=nil && params[:hpa_types] !='' ? params[:hpa_types] : 0
     hpa_value = params[:hpa_value] !=nil && params[:hpa_value] !='' ? params[:hpa_value] : 0
     hpa_rates = params[:hpa_rates] !=nil && params[:hpa_rates] !='' ? params[:hpa_rates] : 0
     isfalgs   = false
     message   = ""
     if mid.to_i >0
         svoubj =  MstHrParameterAccomodation.where("hpa_compcode = ? AND id = ?",@compcodes,mid).first
           if svoubj
             svoubj.update(:hpa_types=>hpa_types,:hpa_value=>hpa_value,:hpa_rates=>hpa_rates)
             message = "Data updated successfully."
             isfalgs = true
           end
     else
          svobj =  MstHrParameterAccomodation.new(:hpa_compcode=>@compcodes,:hpa_types=>hpa_types,:hpa_value=>hpa_value,:hpa_rates=>hpa_rates)
          if svobj.save
            message = "Data saved successfully."
            isfalgs = true
          end
     end
     nedatas = []
     nsdobj  = MstHrParameterAccomodation.select("mst_hr_parameter_accomodations.*,'' as hracctype").where("hpa_compcode = ?",@compcodes).order("id desc")
     if nsdobj.length >0
         nsdobj.each do |newds|
          hrstype =    get_accomodation_type(@compcodes,newds.hpa_types)
          if hrstype
            newds.hracctype = hrstype.at_description
          end
          nedatas.push newds
         end
     end
     respond_to do |format|
        format.json { render :json => { 'data'=>nedatas, "message"=>message,:status=>isfalgs} }
     end
     
 end

 private
 def get_accomodation_type(compcode,id)
     acobj = MstAccomodationType.where("at_compcode =? AND id = ?",compcode,id).first
     return acobj
 end

private
def process_hrparameter_head
  hph_compcode             =  @compcodes
  hph_licpay               =  params[:hph_licpay] !=nil && params[:hph_licpay]  !='' ? params[:hph_licpay]  : 0
  hph_mandalpay            =  params[:hph_mandalpay] !=nil && params[:hph_mandalpay]  !='' ? params[:hph_mandalpay]  : 0
  hph_sewapay              =  params[:hph_sewapay] !=nil && params[:hph_sewapay]  !='' ? params[:hph_sewapay]  : 0
  hph_suminsured           =  params[:hph_suminsured] !=nil && params[:hph_suminsured]  !='' ? params[:hph_suminsured]  : 0
  hph_monthly_amt          =  params[:hph_monthly_amt] !=nil && params[:hph_monthly_amt]  !='' ? params[:hph_monthly_amt]  : 0
  hph_policymandalpay      =  params[:hph_policymandalpay] !=nil && params[:hph_policymandalpay]  !='' ? params[:hph_policymandalpay]  : 0
  hph_policysewapay        =  params[:hph_policysewapay] !=nil && params[:hph_policysewapay]  !='' ? params[:hph_policysewapay]  : 0

  hph_policyslabtwo_sumins  =  params[:hph_policyslabtwo_sumins] !=nil && params[:hph_policyslabtwo_sumins]  !='' ? params[:hph_policyslabtwo_sumins]  : 0
  hph_policytwo_monthlyamt  =  params[:hph_policytwo_monthlyamt] !=nil && params[:hph_policytwo_monthlyamt]  !='' ? params[:hph_policytwo_monthlyamt]  : 0
  hph_policytwo_mandalpay   =  params[:hph_policytwo_mandalpay] !=nil && params[:hph_policytwo_mandalpay]  !='' ? params[:hph_policytwo_mandalpay]  : 0
  hph_policytwo_sewapay     =  params[:hph_policytwo_sewapay] !=nil && params[:hph_policytwo_sewapay]  !='' ? params[:hph_policytwo_sewapay]  : 0
  hph_policythree_sumins    =  params[:hph_policythree_sumins] !=nil && params[:hph_policythree_sumins]  !='' ? params[:hph_policythree_sumins]  : 0
  hph_policythree_monthly   =  params[:hph_policythree_monthly] !=nil && params[:hph_policythree_monthly]  !='' ? params[:hph_policythree_monthly]  : 0
  hph_policythree_mandalpay =  params[:hph_policythree_mandalpay] !=nil && params[:hph_policythree_mandalpay]  !='' ? params[:hph_policythree_mandalpay]  : 0
  hph_policythree_sewpay    =  params[:hph_policythree_sewpay] !=nil && params[:hph_policythree_sewpay]  !='' ? params[:hph_policythree_sewpay]  : 0
  hph_incometaxpercent      =  params[:hph_incometaxpercent] !=nil && params[:hph_incometaxpercent]  !='' ? params[:hph_incometaxpercent]  : 0
  hph_deductedlimited       =  params[:hph_deductedlimited] !=nil && params[:hph_deductedlimited]  !='' ? params[:hph_deductedlimited]  : 0
  hph_consumption           =  params[:hph_consumption] !=nil && params[:hph_consumption]  !='' ? params[:hph_consumption]  : 0
  hph_months                =  params[:hph_months] !=nil && params[:hph_months]  !='' ? params[:hph_months]  : 0
  hph_years                 =  params[:hph_years] !=nil && params[:hph_years]  !='' ? params[:hph_years]  : 0
  hph_aplicablema           =  params[:hph_aplicablema] !=nil && params[:hph_aplicablema]  !='' ? params[:hph_aplicablema]  : 0
  hph_dependent             =  params[:hph_dependent] !=nil && params[:hph_dependent]  !='' ? params[:hph_dependent]  : 0
  hph_parent                =  params[:hph_parent] !=nil && params[:hph_parent]  !='' ? params[:hph_parent]  : 0
  hph_dependentsec          =  params[:hph_dependentsec] !=nil && params[:hph_dependentsec]  !='' ? params[:hph_dependentsec]  : 0
  hph_parenetsec            =  params[:hph_parenetsec] !=nil && params[:hph_parenetsec]  !='' ? params[:hph_parenetsec]  : 0
  hph_dependentthird        =  params[:hph_dependentthird] !=nil && params[:hph_dependentthird]  !='' ? params[:hph_dependentthird]  : 0
  hph_parenthird            =  params[:hph_parenthird] !=nil && params[:hph_parenthird]  !='' ? params[:hph_parenthird]  : 0
 

  message = ""
 heobj    = MstHrParameterHead.where("hph_compcode = ?",@compcodes).first
 if heobj
       heobj.update(:hph_aplicablema=>hph_aplicablema,:hph_dependent=>hph_dependent,:hph_parent=>hph_parent,:hph_dependentsec=>hph_dependentsec,:hph_parenetsec=>hph_parenetsec,:hph_dependentthird=>hph_dependentthird,:hph_parenthird=>hph_parenthird,:hph_licpay=>hph_licpay,:hph_consumption=>hph_consumption,:hph_deductedlimited=>hph_deductedlimited,:hph_policysewapay=>hph_policysewapay,:hph_mandalpay=>hph_mandalpay,:hph_sewapay=>hph_sewapay,:hph_suminsured=>hph_suminsured,:hph_monthly_amt=>hph_monthly_amt,:hph_policymandalpay=>hph_policymandalpay,:hph_policyslabtwo_sumins=>hph_policyslabtwo_sumins,:hph_policytwo_monthlyamt=>hph_policytwo_monthlyamt,:hph_policytwo_mandalpay=>hph_policytwo_mandalpay,:hph_policytwo_sewapay=>hph_policytwo_sewapay,:hph_policythree_sumins=>hph_policythree_sumins,:hph_policythree_monthly=>hph_policythree_monthly,:hph_policythree_monthly=>hph_policythree_monthly,:hph_policythree_monthly=>hph_policythree_monthly,:hph_policythree_mandalpay=>hph_policythree_mandalpay,:hph_policythree_monthly=>hph_policythree_monthly,:hph_policythree_mandalpay=>hph_policythree_mandalpay,:hph_policythree_sewpay=>hph_policythree_sewpay,:hph_incometaxpercent=>hph_incometaxpercent)
       message = "Data updated successfully."
       isfalgs = true
  else
        svsobj = MstHrParameterHead.new(:hph_aplicablema=>hph_aplicablema,:hph_dependent=>hph_dependent,:hph_parent=>hph_parent,:hph_dependentsec=>hph_dependentsec,:hph_parenetsec=>hph_parenetsec,:hph_dependentthird=>hph_dependentthird,:hph_parenthird=>hph_parenthird,:hph_compcode=>hph_compcode,:hph_months=>hph_months,:hph_years=>hph_years,:hph_consumption=>hph_consumption,:hph_deductedlimited=>hph_deductedlimited,:hph_policysewapay=>hph_policysewapay,:hph_licpay=>hph_licpay,:hph_mandalpay=>hph_mandalpay,:hph_sewapay=>hph_sewapay,:hph_suminsured=>hph_suminsured,:hph_monthly_amt=>hph_monthly_amt,:hph_policymandalpay=>hph_policymandalpay,:hph_policyslabtwo_sumins=>hph_policyslabtwo_sumins,:hph_policytwo_monthlyamt=>hph_policytwo_monthlyamt,:hph_policytwo_mandalpay=>hph_policytwo_mandalpay,:hph_policytwo_sewapay=>hph_policytwo_sewapay,:hph_policythree_sumins=>hph_policythree_sumins,:hph_policythree_monthly=>hph_policythree_monthly,:hph_policythree_monthly=>hph_policythree_monthly,:hph_policythree_monthly=>hph_policythree_monthly,:hph_policythree_mandalpay=>hph_policythree_mandalpay,:hph_policythree_monthly=>hph_policythree_monthly,:hph_policythree_mandalpay=>hph_policythree_mandalpay,:hph_policythree_sewpay=>hph_policythree_sewpay,:hph_incometaxpercent=>hph_incometaxpercent)
        svsobj.save
        message = "Data saved successfully."
        isfalgs = true
 end
    respond_to do |format|
        format.json { render :json => { 'data'=>'', "message"=>message,:status=>isfalgs} }
    end

end

def process_update_advance_cbs
  compcodes = session[:loggedUserCompCode]
  isselect = "(al_advanceamt+al_loanamount) as totals,al_requestno,al_sewadarcode"
  loansobj  = TrnAdvanceLoan.select(isselect).where("al_compcode = ? AND al_balances<=0",compcodes).order("al_requestno ASC")
  if loansobj.length >0
      loansobj.each do |newhrs|
          newtotal   = newhrs.totals
          totals     = get_all_sum_transaction(newhrs.al_sewadarcode,newhrs.al_requestno)
          finaltotal = newtotal.to_f-totals.to_f
          process_update_advance_outsatnding(compcodes,newhrs.al_requestno,finaltotal)
      end
        message = "Data saved successfully."
        isfalgs = true
  end

end

def get_all_sum_transaction(sewacode,requestno)
    compcodes = session[:loggedUserCompCode]
    totals    = 0
    iswhere   = "pma_compcode='#{compcodes}' AND pma_sewacode='#{sewacode}' AND pma_requestno='#{requestno}' AND pma_month >3"
    isselect   = "SUM(pma_installment) as totals "
    sewobj    = TrnProcessMonthlyAdvance.select(isselect).where(iswhere).first
    if sewobj
      totals = sewobj.totals    
    end
    return totals
end
  

def process_update_advance_outsatnding(compcode,reqno,oustanding)  
  loansobj  = TrnAdvanceLoan.where("al_compcode = ?  AND al_requestno = ?",compcode,reqno).first
  if loansobj
      loansobj.update(:al_balances=>oustanding)
  end

end
end
