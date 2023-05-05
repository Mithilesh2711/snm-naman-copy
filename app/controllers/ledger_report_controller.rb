class LedgerReportController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:year_month_days_formatted,:formatted_date,:set_ent,:set_dct,:format_oblig_date

    def index
        @compCodes     = session[:loggedUserCompCode]
        mydeprtcode    = ""
        @mydepartcode  = ""
        @newsewdarList = nil
        if session[:sec_sewdar_code]
            sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
            if sewobjs          
                mydeprtcode   = sewobjs.sw_depcode
                category      = sewobjs.sw_catcode
                @mydepartcode = mydeprtcode
            end
       end
        if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf' 
           @sewDepart       = Department.where("compCode = ? AND subdepartment = '' AND departCode = ? ",@compCodes,mydeprtcode).order("departDescription ASC")
           @newsewdarList   = MstSewadar.where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")
        else	
                @sewDepart     = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compCodes).order("departDescription ASC")		   		  
        end
        
        @MstLeave     = MstLeave.where("attend_compcode=?",@compCodes).group("attend_leaveCode").order("attend_leaveCode ASC")
        month_number  =  Time.now.month
        month_begin   =  Date.new(Date.today.year, month_number)
        begdate       =  Date.parse(month_begin.to_s)
        @nbegindate   =  begdate.strftime('%d-%b-%Y')
        month_ending  =  month_begin.end_of_month
        endingDate    =  Date.parse(month_ending.to_s)
        @enddate      =  endingDate.strftime('%d-%b-%Y')
        @printPdfPath = "ledger_report/1_prt_ledger_report.pdf"
    end

    def ajax_process
        @compCodes     = session[:loggedUserCompCode]
      if params[:identity] !=nil && params[:identity] !='' && params[:identity] == 'Y'        
        check_balances();
        return false;
      end

    end
    def show
         obalances = get_all_opening_balance()
        printpts   = print_sewdar_leave_balances()
        @compcodes     = session[:loggedUserCompCode]
        @compDetail    = MstCompany.where(["cmp_companycode = ?", @compcodes]).first
         rooturl       = "#{root_url}"
         if params[:id] != nil && params[:id] != ''
           docsid       = params[:id].to_s.split("_")
           mysewobj     = get_mysewdar_list_details(session[:leave_sewcode])
           mysewdarname = ""
           mysewdarcode = ""
           desiname     = ""
           department   = ""
           leavecodes   = ""
           leavename    = ""
           category     = ""
           if mysewobj
              mysewdarname = mysewobj.sw_sewadar_name
              mysewdarcode = mysewobj.sw_sewcode
              category     = mysewobj.sw_catgeory
              deprtobj = get_all_department_detail(mysewobj.sw_depcode)
                if deprtobj
                   department = deprtobj.departDescription
                end                
                sewdedesobj = get_sewdar_designation_detail(mysewobj.sw_desigcode)
                if sewdedesobj
                   desiname = sewdedesobj.ds_description
                end
               leavetpobj =  get_leavemaster_detail(session[:leave_type])
               if leavetpobj
                leavecodes = leavetpobj.attend_leaveCode
                leavename  = leavetpobj.attend_leavetype
               end
           end
           if docsid[2] == 'ledger'
               
               respond_to do |format|
                   format.html
                   format.pdf do
                      pdf = LedgersPdf.new(printpts,@compDetail,rooturl,obalances,session,mysewdarname,mysewdarcode,desiname,department,leavecodes,leavename,category)
                      send_data pdf.render,:filename => "1_leave_ledger_report.pdf", :type => "application/pdf", :disposition => "inline"
                   end
                end
            end  
        end      
    end

    def check_balances
        compcode                  = @compCodes
        session[:leave_fromdated] = nil
        session[:leave_uptodated] = nil
        session[:leave_sewcode]   = nil 
        session[:leave_type]      = nil 

        sewacode   =  params[:sewacode].to_s.strip 
        from_date  =  params[:from_date] !=nil && params[:from_date] !='' ? year_month_days_formatted(params[:from_date]) : ''
        upto_date  =  params[:upto_date] !=nil && params[:upto_date] != '' ? year_month_days_formatted(params[:upto_date]) : ''
        leavecode  =  params[:leavecode].to_s.strip 
        
        if sewacode !=nil && sewacode !=''           
            session[:leave_sewcode] = sewacode
        end
        if from_date !=nil && from_date !=''
            session[:leave_fromdated] = from_date
        end
        if upto_date !=nil && upto_date !=''
            session[:leave_uptodated] = upto_date
        end
        if leavecode !=nil && leavecode !=''
            session[:leave_type]  = leavecode
        end
        itemsselected = get_avail_leave_listed(compcode,sewacode,from_date,upto_date,leavecode)
        if itemsselected.length <=0
            itemsselected = get_credited_leave_listed(compcode,sewacode,from_date,upto_date,leavecode)
        end
        if itemsselected.length <=0
            itemsselected = get_cood_leave_listed(compcode,sewacode,from_date,upto_date,leavecode)
        end
        
        isflags = false
        if itemsselected.length >0
            isflags = true
        end
        if itemsselected.length <=0
            @obalnces  = get_all_opening_balance()
            @obalncess = @obalnces #.to_s.delete("-")
            if @obalncess.to_f >0
                isflags = true
            end
        end
       
        
          respond_to do |format|
            format.json { render :json => { 'data'=>'',:status=>isflags} }
          end
    end

    def print_sewdar_leave_balances
        compcode   =  session[:loggedUserCompCode]
        fromdated  =  session[:leave_fromdated]
        uptodated  =  session[:leave_uptodated]
        leavecode  =  session[:leave_type]
        sewcode    =  session[:leave_sewcode]        
        itemsarra  =  []

        availobj   =  get_avail_leave_listed(compcode,sewcode,fromdated,uptodated,leavecode)
        if availobj.length >0
            availobj.each do |newob|
                itemsarra.push  newob
            end
        end
        crediobj   = get_credited_leave_listed(compcode,sewcode,fromdated,uptodated,leavecode)
        if crediobj.length >0
            crediobj.each do |newbls|
                itemsarra.push newbls
            end

        end
        codreqobj =  get_cood_leave_listed(compcode,sewcode,fromdated,uptodated,leavecode)
        if codreqobj.length >0
            codreqobj.each do |newob|
                itemsarra.push  newob
            end
        end
        arr = []
        if itemsarra.length >0
            arr =  itemsarra.sort_by{ |t| t.datefirst }
        end         
        return arr

    end


    def get_avail_leave_listed(compcode,sewacode,fromdated,uptodated,leavecode)
        
        iswhere   = "ls_compcode ='#{compcode}' AND ls_status NOT IN('C','R','D') "
        if leavecode !=nil && leavecode !='' && leavecode !='All'
            iswhere  += " AND ls_leave_code ='#{leavecode}'"
        end
        if fromdated !=nil && fromdated !='' 
            iswhere  += " AND ls_fromdate >='#{fromdated}'"
        end 
        if uptodated !=nil && uptodated !='' 
            iswhere  += " AND ls_todate <='#{uptodated}'"
        end 
        if sewacode !=nil && sewacode !='' 
            iswhere  += " AND ls_empcode = '#{sewacode}'"
        end
        arritem   = []        
        isselect  = "ls_nodays as tleave,id as transactno,ls_leave_code as leavecode,ls_empcode  as sewacode,'dbt' as mytpe,ls_fromdate as datefirst,ls_todate as datesecond,ls_period as periodtype"
        leaveobj  = TrnLeave.select(isselect).where(iswhere).order("ls_fromdate ASC") #.group("ls_leave_code")
        if leaveobj.length >0
            leaveobj.each do |newlvs|
                arritem.push  newlvs   
            end
        end
        return arritem
    end

    def get_credited_leave_listed(compcode,sewacode,fromdated,uptodated,leavecode)
       
            iswhere = "cl_compcode ='#{compcode}'"
            if leavecode !=nil && leavecode !='' && leavecode !='All'
                iswhere  += " AND cl_leavecode ='#{leavecode}'"
            end
            if fromdated !=nil && fromdated !='' 
                iswhere  += " AND cl_creditdate >='#{fromdated}'"
            end 
            if uptodated !=nil && uptodated !='' 
                iswhere  += " AND cl_creditdate <='#{uptodated}'"
            end 
            if sewacode !=nil && sewacode !='' 
                iswhere  += " AND cl_sewacode ='#{sewacode}'"
            end 
            arritems = []
            isselect  = "cl_creditdays as tleave,id as transactno,cl_leavecode as leavecode,cl_sewacode  as sewacode,'cdt' as mytpe,cl_creditdate as datefirst,cl_creditdate  as datesecond,'' as periodtype"
            lvsobj  = TrnCreditLeave.select(isselect).where(iswhere).order("cl_creditdate ASC")
            if lvsobj.length >0
                lvsobj.each do |newd|
                    arritems.push newd 

                end
            end
            return arritems
    end
    def get_cood_leave_listed(compcode,sewacode,fromdated,uptodated,leavecode)
        
        iswhere   = "ls_compcode ='#{compcode}' AND ls_status='A' " #AND ls_status NOT IN('C','R','D')
        if leavecode !=nil && leavecode !='' && leavecode !='All'
            iswhere  += " AND ls_leave_code ='#{leavecode}'"
        end
        if fromdated !=nil && fromdated !='' 
            iswhere  += " AND ls_fromdate >='#{fromdated}'"
        end 
        if uptodated !=nil && uptodated !='' 
            iswhere  += " AND ls_todate <='#{uptodated}'"
        end 
        if sewacode !=nil && sewacode !='' 
            iswhere  += " AND ls_empcode = '#{sewacode}'"
        end
        arritem   = []        
        isselect  = "ls_nodays as tleave,id as transactno,ls_leave_code as leavecode,ls_empcode  as sewacode,'cdt' as mytpe,ls_fromdate as datefirst,ls_todate as datesecond,ls_period as periodtype"
        leaveobj  = TrnRequestCoOd.select(isselect).where(iswhere).order("ls_fromdate ASC") #.group("ls_leave_code")
        if leaveobj.length >0
            leaveobj.each do |newlvs|
                arritem.push  newlvs   
            end
        end
        return arritem
    end
    private
    def get_all_opening_balance
        compcode   =  session[:loggedUserCompCode]
        fromdated  =  session[:leave_fromdated]
        uptodated  =  session[:leave_uptodated]
        leavecode  =  session[:leave_type]
        sewcode    =  session[:leave_sewcode]
        availleave =  get_avail_leave_ob(compcode,sewcode,fromdated,uptodated,leavecode)
        creditedlv =  get_credited_leave_ob(compcode,sewcode,fromdated,uptodated,leavecode)
        mywhere    = "lb_compcode='#{compcode}'"
        if sewcode != nil && sewcode !=''
            mywhere    += " AND lb_empcode ='#{sewcode}'"
        end
        if leavecode !=nil && leavecode !=''
            mywhere    += " AND lb_leavecode ='#{leavecode}'"
        end 
        newobs     = 0       
         oblsobj   = TrnLeaveBalance.select("SUM(lb_openbal) as tleavs").where(mywhere).first
         if oblsobj
            newobs = oblsobj.tleavs
         end
         fobalance  = (newobs.to_f+creditedlv.to_f).to_f-availleave.to_f
         return fobalance
    end

    def get_avail_leave_ob(compcode,sewacode,fromdated,uptodated,leavecode)
        tcounts = 0
        iswhere   = "ls_compcode ='#{compcode}' AND ls_status NOT IN('C','R','D')"
        if leavecode !=nil && leavecode !='' && leavecode !='All'
            iswhere  += " AND ls_leave_code ='#{leavecode}'"
        end
        if fromdated !=nil && fromdated !='' 
            iswhere  += " AND ls_fromdate <'#{fromdated}'"
        end 
        if sewacode !=nil && sewacode !='' 
            iswhere  += " AND ls_empcode = '#{sewacode}'"
        end        
        isselect  = "SUM(ls_nodays) as tleave"
        leaveobj  = TrnLeave.select(isselect).where(iswhere).first
        if leaveobj
            tcounts = leaveobj.tleave
        end
        return tcounts
    end
    def get_credited_leave_ob(compcode,sewacode,fromdated,uptodated,leavecode)
        tcounts = 0
            iswhere = "cl_compcode ='#{compcode}'"
            if leavecode !=nil && leavecode !='' && leavecode !='All'
                iswhere  += " AND cl_leavecode ='#{leavecode}'"
            end
            if fromdated !=nil && fromdated !='' 
                iswhere  += " AND cl_creditdate <'#{fromdated}'"
            end 
            if sewacode !=nil && sewacode !='' 
                iswhere  += " AND cl_sewacode ='#{sewacode}'"
            end 
            isselect  = "SUM(cl_creditdays) as tleave"
            lvsobj  = TrnCreditLeave.select(isselect).where(iswhere).first
            if lvsobj
                tcounts = lvsobj.tleave
            end
            return tcounts
    end
end
