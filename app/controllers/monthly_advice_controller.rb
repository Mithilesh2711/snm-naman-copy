class MonthlyAdviceController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_mysewdar_list_details,:get_month_listed_data
    def index
       @compcodes   = session[:loggedUserCompCode]
       @Allsewobj   = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode =?",@compcodes)
       @sewDepart   = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment=''",@compcodes).order("departDescription ASC")
       @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compcodes).order("sc_name ASC")
       #@weeks       = week_of_month(31,2021,12)
        @nbegindate  =  2021
        @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compcodes).first
        @HrMonths          = nil
        @Hryears           = nil
        if @HeadHrp
          @HrMonths = @HeadHrp.hph_months
          @Hryears  = @HeadHrp.hph_years
        end
    end
    
    def create
    @compCodes  =  session[:loggedUserCompCode]
    isFlags     = true
    begin
    if params[:pm_sewacode] == '' || params[:pm_sewacode] == nil
       flash[:error] =  "Sewa code is required"
       isFlags       = false
    elsif params[:pm_workingday] == '' || params[:pm_workingday] == nil
       flash[:error] =  "Working days is required"
       isFlags = false


    else
      @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
      mymonths           = ""
      myyears            = ""
      genfinalyear       = ""
      if @HeadHrp
          mymonths = @HeadHrp.hph_months
          myyears  = @HeadHrp.hph_years
          if mymonths.to_i >=4 
            genfinalyear = myyears.to_s+"-"+(myyears.to_i+1).to_s
          else
            genfinalyear = (myyears.to_i-1).to_s+"-"+myyears.to_s
          end 

      end
          
            sewacode  = params[:pm_sewacode].to_s.strip
            @Globalobjs = nil
            swslobj   = TrnPayMonthly.where("pm_compcode = ? AND pm_sewacode = ? AND pm_paymonth =? AND pm_payyear =? AND pm_financialyear =?",@compCodes,sewacode,mymonths,myyears,genfinalyear)
              if swslobj.length >0
                    useewobj = TrnPayMonthly.where("pm_compcode = ? AND pm_sewacode = ? AND pm_paymonth =? AND pm_payyear =? AND pm_financialyear =?",@compCodes,sewacode,mymonths,myyears,genfinalyear).first
                    if useewobj
                      @Globalobjs = useewobj
                      useewobj.update(salary_params)
                        flash[:error] = "Data updated successfully."
                        isFlags       = true
                    end
              else
                  seewobjs = TrnPayMonthly.new(salary_params)
                  if seewobjs.save
                        flash[:error] = "Data saved successfully."
                        isFlags       = true
                  end
              end

    

  end

  
   rescue Exception => exc
       flash[:error] =  "ERROR: #{exc.message}"
       session[:isErrorhandled] = 1      
       isFlags = false
   end
  if !isFlags
     session[:isErrorhandled] = 1
  else
      session[:isErrorhandled] = nil
      session[:postedpamams]   = nil
      isFlags = true
  end
     redirect_to  "#{root_url}monthly_advice"
  
 end
 
 def ajax_process
      @compcodes = session[:loggedUserCompCode]
      if params[:identity]!=nil && params[:identity]!= '' && params[:identity] == 'Y'
        get_salary_list_detail_by_sewdar()
        return

      end
 end

 private
 def salary_params
   compcodes                      = session[:loggedUserCompCode]
   params[:pm_compcode]           = compcodes
   params[:pm_sewacode]           = params[:pm_sewacode] !=nil && params[:pm_sewacode] !='' ? params[:pm_sewacode] : ''
   params[:pm_monthday]           = params[:pm_monthday] !=nil && params[:pm_monthday] !='' ? params[:pm_monthday] : 0
   params[:pm_paidleave]          = params[:pm_paidleave] !=nil && params[:pm_paidleave] !='' ? params[:pm_paidleave] : 0
   params[:pm_absent]             = params[:pm_absent] !=nil && params[:pm_absent] !='' ? params[:pm_absent] : 0
   params[:pm_wo]                 = params[:pm_wo] !=nil && params[:pm_wo] !='' ? params[:pm_wo] : 0
   params[:pm_hl]                 = params[:pm_hl] !=nil && params[:pm_hl] !='' ? params[:pm_hl] : 0
   params[:pm_workingday]         = params[:pm_workingday] !=nil && params[:pm_workingday] !='' ? params[:pm_workingday] : 0
   params[:pm_paydays]            = params[:pm_paydays] !=nil && params[:pm_paydays] !='' ? params[:pm_paydays] : 0
   params[:pm_fixarear]           = fixareas = params[:pm_fixarear] !=nil && params[:pm_fixarear] !='' ? params[:pm_fixarear] : 0
   params[:pm_areardays]          = params[:pm_areardays] !=nil && params[:pm_areardays] !='' ? params[:pm_areardays] : 0
   params[:pm_ded_repaidadvance]  = params[:pm_ded_repaidadvance] !=nil && params[:pm_ded_repaidadvance] !='' ? params[:pm_ded_repaidadvance] : 0
   params[:pm_ded_repaidloan]     = params[:pm_ded_repaidloan] !=nil && params[:pm_ded_repaidloan] !='' ? params[:pm_ded_repaidloan] : 0    
   params[:pm_areaprvmonths]      = params[:pm_prvmonths] !=nil && params[:pm_prvmonths] !='' ? params[:pm_prvmonths] : 0
   params[:pm_areaprvyears]       = params[:pm_prvyears] !=nil && params[:pm_prvyears] !='' ? params[:pm_prvyears] : 0

   params[:pm_allowancefirst]   = pm_allowancefirst    = params[:pm_allowancefirst] !=nil && params[:pm_allowancefirst] !='' ? params[:pm_allowancefirst] : 0
   params[:pm_allowancesecond]  = pm_allowancesecond   = params[:pm_allowancesecond] !=nil && params[:pm_allowancesecond] !='' ? params[:pm_allowancesecond] : 0
   params[:pm_dedfirst]         = pm_dedfirst          = params[:pm_dedfirst] !=nil && params[:pm_dedfirst] !='' ? params[:pm_dedfirst] : 0
   params[:pm_dedsecond]        = pm_dedsecond          = params[:pm_dedsecond] !=nil && params[:pm_dedsecond] !='' ? params[:pm_dedsecond] : 0

   params[:pm_allowanremarkfirst]  = params[:pm_allowanremarkfirst] !=nil && params[:pm_allowanremarkfirst] !='' ? params[:pm_allowanremarkfirst] : ''
   params[:pm_allowanceremksecond] = params[:pm_allowanceremksecond] !=nil && params[:pm_allowanceremksecond] !='' ? params[:pm_allowanceremksecond] : ''
   params[:pm_dedremarkfirst]      = params[:pm_dedremarkfirst] !=nil && params[:pm_dedremarkfirst] !='' ? params[:pm_dedremarkfirst] : ''
   params[:pm_dedremarksecond]     = params[:pm_dedremarksecond] !=nil && params[:pm_dedremarksecond] !='' ? params[:pm_dedremarksecond] : ''
   params[:pm_hold]                = params[:pm_hold] !=nil && params[:pm_hold] !='' ? params[:pm_hold] : 'N'
   params[:pm_arearremarks]        = params[:pm_arearremarks] !=nil && params[:pm_arearremarks] !='' ? params[:pm_arearremarks] : ''
   
   netamounts = 0
    if @Globalobjs
      netamounts = (@Globalobjs.pm_netpay.to_f+pm_allowancefirst.to_f+pm_allowancesecond.to_f+fixareas.to_f).to_f-(pm_dedfirst.to_f+pm_dedsecond.to_f).to_f
    else
      netamounts = (pm_allowancefirst.to_f+pm_allowancesecond.to_f+fixareas.to_f).to_f-(pm_dedfirst.to_f+pm_dedsecond.to_f).to_f
    end
    params[:pm_netpay] = netamounts
    params.permit(:pm_compcode,:pm_arearremarks,:pm_hold,:pm_netpay,:pm_allowancefirst,:pm_allowancesecond,:pm_dedfirst,:pm_dedsecond,:pm_allowanremarkfirst,:pm_allowanceremksecond,:pm_dedremarkfirst,:pm_dedremarksecond,:pm_areaprvmonths,:pm_areaprvyears,:pm_sewacode,:pm_monthday,:pm_paidleave,:pm_absent,:pm_wo,:pm_hl,:pm_workingday,:pm_paydays,:pm_fixarear,:pm_areardays,:pm_ded_repaidadvance,:pm_ded_repaidloan)
 end

 private
 def get_salary_list_detail_by_sewdar
   message  = ""
   isfalgs  = false
   sewacode = params[:sewcode]
   iswhere  = "pm_compcode ='#{@compcodes}' AND pm_sewacode ='#{sewacode}'"
   mobjs    = TrnPayMonthly.where(iswhere).first
   if mobjs
      message = "Success"
      isfalgs = true
   end
       respond_to do |format|
        format.json { render :json => { 'data'=>mobjs, "message"=>message,:status=>isfalgs} }
      end
 end
 
end
