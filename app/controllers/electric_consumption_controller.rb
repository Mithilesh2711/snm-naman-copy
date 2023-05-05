## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for allotment an address to SEWADATRA
### FOR REST API ######
class ElectricConsumptionController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search,:consumption_list]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_mysewdar_list_details,:format_oblig_date
    helper_method :get_accomodation_addresslisted,:get_address_item_listed,:get_sewdar_designation_detail,:get_all_department_detail
    def index
      @compcodes      = session[:loggedUserCompCode]
      @Allsewobj         = nil
      @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compcodes).order("departDescription ASC")
      @lastEntryNo       = last_entry_no
      @cdate             = Date.today
      @CurrentYear       = nil
      @CurrentMonth      = nil
      @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compcodes).first
      @myadminstrator    = nil
      @AllowedRequested  = false
      if @HeadHrp
        @CurrentMonth = get_month_listed_data(@HeadHrp.hph_months)
        @CurrentYear  = @HeadHrp.hph_years
      end
      if params[:id] != nil && params[:id] != ''
        @compDetail  = MstCompany.where(["cmp_companycode = ?", @compcodes]).first
        ids = params[:id].to_s.split("_")
        if ids[1] == 'prt' && ids[2] == 'excel'
            $eclectdata = print_electric_listed()
            send_data @ExcelList.to_generate_electric, :filename=> "electric-consumption-list-#{Date.today}.csv"
            return
        elsif ids[1] == 'prt' && ids[2] == 'pdf'
               @rootUrl  = "#{root_url}"
                dataprint = print_electric_listed()
                respond_to do |format|
                     format.html
                     format.pdf do
                        pdf = ElectricchargesPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                        send_data pdf.render,:filename => "1_prt_city_report.pdf", :type => "application/pdf", :disposition => "inline"
                     end
                 end
         else
             ########### EDIT CASES ONLY ##########
              if params[:id].to_i >0
                @ElectricList    = TrnElectricConsumption.where("ec_compcode =? AND id = ?",@compcodes,params[:id].to_i).first
            
                if @ElectricList
                    departobj = get_department_detail(@ElectricList.ec_department)
                    if departobj
                      @myadminstrator = departobj.departDescription
                    end
                end
            end
        end
    end


      
      @Allsewobj         = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode = ? AND sw_iselectricconsump ='Y'",@compcodes).order("sw_sewadar_name ASC")
      if session[:requested_lastid] && session[:requested_lastid].to_i >0
        @AllowedRequested = true
      end
      
    end
    def consumption_list
      @compcodes         = session[:loggedUserCompCode]
      printcontroll      = "1_prt_excel_electric_consumption_list"
      @printpath         = electric_consumption_path(printcontroll,:format=>"pdf")
      printpdf           = "1_prt_pdf_electric_consumption_list"
      @printpdfpath      = electric_consumption_path(printpdf,:format=>"pdf")
      @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compcodes).order("departDescription ASC")
      @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compcodes).order("sc_position ASC")
      @Allsewobj         = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode =? AND sw_iselectricconsump ='Y'",@compcodes).order("sw_sewadar_name ASC")
	  
      @ElectricConsump   = get_electric_listed
    end
    def refresh_electric_consumption
       session[:requested_lastid] = nil
       redirect_to "#{root_url}"+"electric_consumption"
    end

    def create
         @compcodes = session[:loggedUserCompCode]
        isFlags    = true
		lastid     = 0
		mid           = params[:mid]
        ApplicationRecord.transaction do
          begin
              if params[:ec_entryno] == nil || params[:ec_entryno] == ''
                 flash[:error] =  "Entry no is required."
                 isFlags = false
              elsif params[:ec_readingdate] == nil || params[:ec_readingdate] == ''
                 flash[:error] =  "Reading date is required."
                 isFlags = false
              elsif params[:ec_department] == nil || params[:ec_department] == ''
                 flash[:error] =  "Department is required."
                 isFlags = false             
            elsif params[:ec_sewdarcode] == nil || params[:ec_sewdarcode] == ''
                 flash[:error] =  "Sewadar code is required."
                 isFlags = false
            
              else
                  
                  hrmonths      = params[:hrmonths]
                  hryears       = params[:hryears]
                  sewcode       = params[:ec_sewdarcode]
                  if mid.to_i >0
                        
                        if isFlags
                           stateupobj  = TrnElectricConsumption.where("ec_compcode =? AND id = ?",@compcodes,mid).first
                            if stateupobj
                                 stateupobj.update(electric_params)
                                  flash[:error] = "Data updated successfully."
                                  isFlags       = true
                            end
                        end
                  else
                        swmonthsobj   = TrnElectricConsumption.select("ec_lastreading").where("ec_compcode = ? AND ec_sewdarcode = ? AND ec_readingyear = ? AND ec_readingmonth = ?",@compcodes,sewcode,hryears,hrmonths).order("ec_readingdate DESC")
                       if swmonthsobj.length >0
                                   flash[:error] = "Electric consumption is already added for selected sewadar."
                                  isFlags         = false
                       end
                           
                             if isFlags
                                  @stsobj = TrnElectricConsumption.new(electric_params)
                                  if @stsobj.save  
								                   	lastid = @stsobj.id.to_i
                                     session[:requested_lastid] = lastid
                                     flash[:error] =  "Data saved successfully."
                                     isFlags = true
                                  end

                             end
                  end
              end
                rescue Exception => exc
                flash[:error]            = "#{exc.message}"
                session[:isErrorhandled] = 1
                isFlags                  = false
                raise ActiveRecord::Rollback
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
     if mid.to_i >0
       redirect_to "#{root_url}"+"electric_consumption/"+mid.to_s
     else
       redirect_to "#{root_url}"+"electric_consumption/"+lastid.to_s
     end

    end

def destroy
     @compcodes = session[:loggedUserCompCode]
      if params[:id].to_i >0
           @ListElect =  TrnElectricConsumption.where("ec_compcode =? AND id = ?",@compcodes,params[:id]).first
           if @ListElect
                @ListElect.destroy
                flash[:error] =  "Data deleted successfully."
                isFlags       = true
                session[:isErrorhandled] = nil
           end
      end
      redirect_to "#{root_url}electric_consumption/consumption_list"
end
private
  def electric_params
    
    @isCode     = 0
    @Startx     = '0000'
    @recCodes   = TrnElectricConsumption.where(["ec_compcode =? AND ec_entryno >0 ",@compcodes]).order('ec_entryno DESC').first
    if @recCodes
    @isCode    = @recCodes.ec_entryno.to_i
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
      params[:ec_entryno] =  params[:ec_entryno]
    else
      params[:ec_entryno] =  @sumXOfCode
    end
      params[:ec_compcode]      = session[:loggedUserCompCode]
      params[:ec_readingdate]   = params[:ec_readingdate]  !=nil && params[:ec_readingdate]  !='' ? year_month_days_formatted(params[:ec_readingdate])  : 0
      params[:ec_department]    = params[:ec_department]  !=nil && params[:ec_department]  !='' ? params[:ec_department]  : ''
      params[:ec_sewdarcode]    = params[:ec_sewdarcode]  !=nil && params[:ec_sewdarcode]  !='' ? params[:ec_sewdarcode]  : ''
      params[:ec_readingyear]   = params[:ec_readingyear]  !=nil && params[:ec_readingyear]  !='' ? params[:ec_readingyear]  : ''

      params[:ec_lastreading]    = params[:ec_lastreading]  !=nil && params[:ec_lastreading]  !='' ? params[:ec_lastreading]  : 0
      params[:ec_currentreading] = params[:ec_currentreading]  !=nil && params[:ec_currentreading]  !='' ? params[:ec_currentreading]  : 0
      params[:ec_totalunit]      = params[:ec_totalunit]  !=nil && params[:ec_totalunit]  !='' ? params[:ec_totalunit]  : 0
      params[:ec_reamrk]         = params[:ec_reamrk]  !=nil && params[:ec_reamrk]  !='' ? params[:ec_reamrk]  : ''
	    params[:ec_totalamount]    = params[:ec_totalamount] != nil && params[:ec_totalamount] != '' ? params[:ec_totalamount] : 0
      oldmeters = 0
      if params[:ec_newmeter] !=nil && params[:ec_newmeter] !=''
        oldmeters = params[:ec_oldreading]
      end
      params[:ec_newmeter]   = params[:ec_newmeter] !=nil && params[:ec_newmeter] !='' ? params[:ec_newmeter] : 'N'
      params[:ec_oldreading] = oldmeters
      params.permit(:ec_compcode,:ec_newmeter,:ec_oldreading,:ec_totalamount,:ec_entryno,:ec_readingdate,:ec_department,:ec_sewdarcode,:ec_readingyear,:ec_readingmonth,:ec_lastreading,:ec_currentreading,:ec_totalunit,:ec_reamrk)
  end
    
    private
  def last_entry_no
    @isCode     = 0
    @Startx     = '0000'
    @recCodes   = TrnElectricConsumption.where(["ec_compcode =? AND ec_entryno >0 ",@compcodes]).order('ec_entryno DESC').first
    if @recCodes
    @isCode    = @recCodes.ec_entryno.to_i
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
  def get_electric_listed
    if params[:page].to_i >0
       pages = params[:page]
    else
       pages = 1
    end
    if params[:server_request] !=nil && params[:server_request] !=''
        session[:reqx_search_department] = nil
        session[:reqx_search_category] = nil
        session[:reqx_search_sewdarcode] = nil
    end
      search_department = params[:search_department] !=nil && params[:search_department] !='' ? params[:search_department] : session[:reqx_search_department]
      search_category   = params[:search_category] !=nil && params[:search_category] !='' ? params[:search_category] : session[:reqx_search_category]
      search_sewdarcode = params[:search_sewdarcode] !=nil && params[:search_sewdarcode] !='' ? params[:search_sewdarcode] : session[:reqx_search_sewdarcode]
      iswhere = "ec_compcode ='#{@compcodes}'"
        if search_department !=nil && search_department !=''
           iswhere += " AND  ec_department ='#{search_department}'"
           @search_department = search_department
           session[:reqx_search_department] = search_department
        end
        isflags = false
        if search_category !=nil && search_category !=''
           iswhere += " AND  sw_catgeory LIKE '%#{search_category}%'"
           @search_category = search_category
           session[:reqx_search_category] = search_category
           isflags = true
        end
        if search_sewdarcode !=nil && search_sewdarcode !=''
           iswhere += " AND  ec_sewdarcode ='#{search_sewdarcode}'"
           @search_sewdarcode = search_sewdarcode
           session[:reqx_search_sewdarcode] = search_sewdarcode
        end
        if isflags
           jons     = " LEFT JOIN mst_sewadars swd ON(sw_compcode = ec_compcode AND sw_sewcode = ec_sewdarcode)"
           elecobjs = TrnElectricConsumption.select("trn_electric_consumptions.*,swd.id as swdId").joins(jons).where(iswhere).paginate(:page =>pages,:per_page => 10).order("ec_entryno DESC")
        else
          elecobjs =    TrnElectricConsumption.where(iswhere).paginate(:page =>pages,:per_page => 10).order("ec_entryno DESC")
        end
      
      return elecobjs
  end


  private
  def print_electric_listed
      arrelect          =  []
      search_department =  session[:reqx_search_department]
      search_category   =  session[:reqx_search_category]
      search_sewdarcode =  session[:reqx_search_sewdarcode]
      iswhere           =  "ec_compcode ='#{@compcodes}'"
        if search_department !=nil && search_department !=''
           iswhere += " AND  ec_department ='#{search_department}'"          
        end
        isflags = false
        if search_category !=nil && search_category !=''
           iswhere += " AND  sw_catgeory LIKE '%#{search_category}%'"          
           isflags = true
        end
        if search_sewdarcode !=nil && search_sewdarcode !=''
           iswhere += " AND  ec_sewdarcode ='#{search_sewdarcode}'"           
        end

        if isflags
           jons     = " LEFT JOIN mst_sewadars swd ON(sw_compcode = ec_compcode AND sw_sewcode = ec_sewdarcode)"
           isselect = "'' as sewdarname,'' as desiname,'' as department,'' as unitdiffs,trn_electric_consumptions.*,swd.id as swdId"
           elecobjs = TrnElectricConsumption.select(isselect).joins(jons).where(iswhere).order("ec_entryno ASC")
        else
          isselect = "'' as sewdarname,'' as desiname,'' as department,'' as unitdiffs,trn_electric_consumptions.*"
          elecobjs =    TrnElectricConsumption.select(isselect).where(iswhere).order("ec_entryno ASC")
        end
       if elecobjs.length >0
          @ExcelList = elecobjs
          elecobjs.each do |newelct|
            
            seobj      = get_mysewdar_list_details(newelct.ec_sewdarcode)
            if seobj
                 sewdarname         = seobj.sw_sewadar_name  
                 newelct.sewdarname = sewdarname          
                 sewdesobj          = get_sewdar_designation_detail(seobj.sw_desigcode)
                 if sewdesobj
                    desiname         = sewdesobj.ds_description
                    newelct.desiname = desiname 
                 end
                 deprtobj            = get_all_department_detail(seobj.sw_depcode)
                 if deprtobj
                    department         = deprtobj.departDescription
                    newelct.department = department 
                 end
            end
            unitdiffs         = newelct.ec_currentreading.to_f-newelct.ec_lastreading.to_f
            newelct.unitdiffs = unitdiffs
            arrelect.push newelct
          end
       end
      return arrelect
  end
  
end
