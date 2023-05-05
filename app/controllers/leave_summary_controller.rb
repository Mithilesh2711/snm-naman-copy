class LeaveSummaryController < ApplicationController
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
        @printPdfPath = "leave_summary/1_prt_leave_summary.pdf"
    end

    def ajax_process
        @compCodes     = session[:loggedUserCompCode]
        if params[:identity] !=nil && params[:identity] !='' && params[:identity] == 'Y'        
            check_balances();
            return false;
        end

    end
    def show        
        @compcodes     = session[:loggedUserCompCode]
        @compDetail    = MstCompany.where(["cmp_companycode = ?", @compcodes]).first
         rooturl       = "#{root_url}"
         $asondated    = formatted_date(Date.today)
         if params[:id] != nil && params[:id] != ''
            $dataitems    = nil
            $mysewobj     = print_sewdar_leave_balances
            if $dataitems !=nil && $dataitems.length >0             
                send_data $dataitems.leave_summary_data, :filename=> "leave_summary-#{Date.today}.csv"
            end
        end      
    end

    def check_balances
        compcode                        = @compCodes
        session[:leave_reqs_department] = nil
        session[:leave_reqs_sewcode]    = nil 
        session[:leave_reqs_type]       = nil 
        isflags     = false
        sewacode    =  params[:sewacode].to_s.strip 
        department  =  params[:department] !=nil && params[:department] !='' ? params[:department] : ''
        types       =  params[:types] !=nil && params[:types] != '' ? params[:types] : ''
       
        iswhere    = "sw_compcode='#{compcode}'"
        if sewacode !=nil && sewacode !=''           
            session[:leave_reqs_sewcode] = sewacode
            iswhere += " AND sw_sewcode='#{sewacode}'"
        end
        if department !=nil && department !=''
            iswhere += " AND sw_depcode='#{department}'"
            session[:leave_reqs_department] = department
        end
        
        sweobjs = MstSewadar.select("id").where(iswhere).order("sw_sewcode ASC")  
        if sweobjs.length >0
            isflags = true
        end
          respond_to do |format|
            format.json { render :json => { 'data'=>'',:status=>isflags} }
          end
    end

    def print_sewdar_leave_balances
        compcode    = session[:loggedUserCompCode]
        department  = session[:leave_reqs_department]
        sewacode    = session[:leave_reqs_sewcode] 
        types       = "" 
        itemsarra   =  []
        iswhere     = "sw_compcode='#{compcode}' AND sw_catcode<>'VI'"
        if sewacode !=nil && sewacode !=''        
            iswhere += " AND sw_sewcode='#{sewacode}'"
        end
        if department !=nil && department !=''
            iswhere += " AND sw_depcode='#{department}'"           
        end

        isselect = "sw_sewadar_name,sw_sewcode,sw_catgeory,sw_catcode,sw_desigcode,sw_depcode,sw_oldsewdarcode"
        isselect +=",sw_catgeory as categroy,'' as department,'' as elcb,'' as clcb,'' as slcb,'' as cocb,'' as odcb"

        sweobjs = MstSewadar.select(isselect).where(iswhere).order("sw_sewadar_name ASC")  
        if sweobjs.length >0
               $dataitems = TrnLeaveBalance.where("id>0").limit(2)
                sweobjs.each do |newso|
                    depobj = get_department_detail(newso.sw_depcode)
                    if depobj
                        newso.department = depobj.departDescription     
                    end
                    newso.cocb   =  get_leave_balances_summary('CO',newso.sw_sewcode)
                    newso.elcb   =  get_leave_balances_summary('EL',newso.sw_sewcode)
                    newso.slcb   =  get_leave_balances_summary('SL',newso.sw_sewcode)
                    newso.clcb   =  get_leave_balances_summary('CL',newso.sw_sewcode)
                    newso.odcb   =  get_leave_balances_summary('OD',newso.sw_sewcode)                    
                    itemsarra.push newso
                end
        end
        return itemsarra

    end

    private
    def get_leave_balances_summary(leavecode,sewdarcode)   
         compcodes  = session[:loggedUserCompCode]  
         lcounts = 0    
         leaveobj   = TrnLeaveBalance.select("lb_closingbal as totals").where("lb_compcode = ? AND lb_empcode = ? AND lb_leavecode = ?",compcodes,sewdarcode,leavecode).first
        if leaveobj
            lcounts = leaveobj.totals  
        end
        return lcounts
    end
    
end
