## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for allotment an address to SEWADATRA
### FOR REST API ######
class AccomodationAllotmentController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_mysewdar_list_details,:format_oblig_date
    helper_method :get_accomodation_addresslisted,:get_address_item_listed
  def index
     @compcodes         = session[:loggedUserCompCode]
     @sewDepart         = nil
     @Allsewobj         = nil
     @cdate             = Date.today
     @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compcodes).order("departDescription ASC")
     @HeadBranch        = MstAccomodationDetail.select("id,ad_address").where("ad_compcode =? AND ad_belongs = 'H' AND ad_allotmentno=''",@compcodes).group("ad_address").order("ad_address ASC")
     @lastAllotno       = last_allotment_no
     @AllotmentAdd      = nil
     if params[:id].to_i >0
        @AllotmentAdd        = MstAccomodationAllotment.where("aa_compcode =? AND id = ?",@compcodes,params[:id]).first
        if @AllotmentAdd         
          @Allsewobj         = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode =? AND sw_depcode =?",@compcodes,@AllotmentAdd.aa_depcode).order("sw_sewadar_name ASC")
        end
        
     end
     if params[:id] != nil && params[:id] != ''
           ids = params[:id].to_s.split("_")
           if ids[1] == 'prt' && ids[2] == 'excel'
            $exceldata  =  excel_common_list
             send_data @newExcelVisit.to_generate_allotment, :filename=> "city-list-#{Date.today}.csv"
             return
           end
     end
    
  end

  def allotment_list
     @compcodes         = session[:loggedUserCompCode]
     @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode =? AND subdepartment =''",@compcodes).order("departDescription ASC")
     @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compcodes).order("sc_position ASC")
      @hraccmtype       = MstAccomodationType.where("at_compcode =?",@compcodes).order("at_description ASC")
     @ListSewdar        = MstSewadar.select("sw_sewcode,sw_sewadar_name").where("sw_compcode =?",@compcodes).order("sw_sewadar_name ASC")
     printcontroll      = "1_prt_excel_allotment_list"
     @printpath         = accomodation_allotment_path(printcontroll,:format=>"pdf")
     if params[:page].to_i >0
       pages = params[:page]
    else
       pages = 1
    end
    if params[:server_request] !=nil && params[:server_request] !=''
        session[:req_search_codesewa]   = nil
        session[:req_search_headbranch] = nil
        session[:req_search_acctypes]   = nil
        session[:req_search_allotno]    = nil
        
    end
    sewadar_search_code = params[:sewadar_search_code] !=nil && params[:sewadar_search_code] !='' ? params[:sewadar_search_code] : session[:req_search_codesewa]
    sewadar_branches    = params[:sewadar_branches] !=nil && params[:sewadar_branches] !='' ? params[:sewadar_branches] : session[:req_search_headbranch]
    search_allotno      = params[:sewdar_alloment] !=nil && params[:sewdar_alloment] !='' ? params[:sewdar_alloment] : session[:req_search_allotno]
    
    iswhere = "aa_compcode ='#{@compcodes}'"
    if sewadar_search_code != nil && sewadar_search_code != ''
      iswhere += " AND aa_sewadarcode ='#{sewadar_search_code}'"
      @sewadar_search_code = sewadar_search_code
      session[:req_search_codesewa] = sewadar_search_code
    end
     if sewadar_branches != nil && sewadar_branches != ''
      iswhere += " AND aa_addtype ='#{sewadar_branches}'"
      @sewadar_branches = sewadar_branches
      session[:req_search_headbranch] = sewadar_branches
    end
    if search_allotno != nil && search_allotno != ''
       iswhere += " AND aa_alotmentno LIKE '%#{search_allotno}%'"
       session[:req_search_allotno]  = search_allotno
       @search_allotno               = search_allotno
    end
    
    @AllotmentList    = MstAccomodationAllotment.where(iswhere).paginate(:page =>pages,:per_page => 10).order("aa_alotmentno ASC")
    
  end
  
  def create
    @compcodes = session[:loggedUserCompCode]
    isFlags    = true
    ApplicationRecord.transaction do
          begin
              if params[:aa_alotmentno] == nil || params[:aa_alotmentno] == ''
                 flash[:error] =  "Allotment no is required."
                 isFlags = false
              elsif params[:aa_alotmentdate] == nil || params[:aa_alotmentdate] == ''
                 flash[:error] =  "Allotment date is required."
                 isFlags = false
              elsif params[:aa_address] == nil || params[:aa_address] == ''
                 flash[:error] =  "Allotment address is required."
                 isFlags = false
             elsif params[:aa_depcode] == nil || params[:aa_depcode] == ''
                 flash[:error] =  "department is required."
                 isFlags = false
            elsif params[:aa_sewadarcode] == nil || params[:aa_sewadarcode] == ''
                 flash[:error] =  "Sewadar code is required."
                 isFlags = false
            elsif params[:sewdarname] == nil || params[:sewdarname] == ''
                 flash[:error] =  "Sewadar name is required."
                 isFlags = false
              else
                  mid           = params[:mid]
                  sewcode       = params[:aa_sewadarcode]
                  cursewcode    = params[:prevaccomod]


                  if mid.to_i >0
                        if sewcode.to_i != cursewcode.to_i

                             chekaccomtype = MstAccomodationAllotment.where("aa_compcode =? AND aa_sewadarcode = ? AND aa_status<>'C' ",@compcodes,params[:aa_sewadarcode])
                             if chekaccomtype.length >0
                                 flash[:error]  =  "Accomodation is already alloted against Allotment No : "+chekaccomtype[0].aa_alotmentno.to_s
                                  isFlags       =  false
                             end
                        end
                        if isFlags
                           stateupobj  = MstAccomodationAllotment.where("aa_compcode =? AND id = ?",@compcodes,mid).first
                            if stateupobj
                                 stateupobj.update(accomo_params)
                                  reverse_allotment_series(@compcodes,params[:aa_address])
                                  add_allotment_series(@compcodes,params[:aa_address],params[:aa_alotmentno])
                                  flash[:error] = "Data updated successfully."
                                  isFlags       = true
                            end
                        end
                  else
                           chekaccomtype = MstAccomodationAllotment.where("aa_compcode =? AND aa_sewadarcode = ? AND aa_status<>'C' ",@compcodes,params[:aa_sewadarcode])
                           if chekaccomtype.length >0
                                  flash[:error] =  "Accomodation is already alloted against Allotment No : "+chekaccomtype[0].aa_alotmentno.to_s
                                  isFlags       =  false
                            end
                             if isFlags
                                  stsobj = MstAccomodationAllotment.new(accomo_params)
                                  if stsobj.save
                                     alomentno = @sumXOfCode
                                     add_allotment_series(@compcodes,params[:aa_address],alomentno)
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
     if isFlags
       redirect_to "#{root_url}"+"accomodation_allotment/allotment_list"
     else
       redirect_to "#{root_url}"+"accomodation_allotment"
     end
  end

  def cancel
       @compcodes  = session[:loggedUserCompCode]
       if params[:id].to_i >0
          cancelobj  = MstAccomodationAllotment.where("aa_compcode =? AND id = ?",@compcodes,params[:id].to_i).first
          if cancelobj
              addressx = cancelobj.aa_address
              if cancelobj.update(:aa_status=>'C')
                 reverse_allotment_series(@compcodes,addressx)
                 flash[:error] = "Data cancelled successfully."
                 isFlags       = true
                 session[:isErrorhandled] = nil
              end
             
          end
       end
      redirect_to "#{root_url}"+"accomodation_allotment/allotment_list"
  end
  
  def ajax_process
     @compcodes       = session[:loggedUserCompCode]
         if params[:identity] != nil && params[:identity] != '' && params[:identity] == 'Y'
            get_accomodation_address_list();
            return
         elsif params[:identity] != nil && params[:identity] != '' && params[:identity] == 'DDLIST'
            get_address_list_detail();
            return
         end

  end
private
  def accomo_params
    cdirect    = "allotment"
    @isCode     = 0
    @Startx     = '0000'
    @recCodes   = MstAccomodationAllotment.where(["aa_compcode =? AND aa_alotmentno >0 ",@compcodes]).order('aa_alotmentno DESC').first
    if @recCodes
    @isCode    = @recCodes.aa_alotmentno.to_i
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
      params[:aa_alotmentno] =  params[:aa_alotmentno]
    else
      params[:aa_alotmentno] =  @sumXOfCode
    end
     params[:aa_compcode]      = session[:loggedUserCompCode]
     params[:aa_alotmentdate]  = params[:aa_alotmentdate]  !=nil && params[:aa_alotmentdate]  !='' ? year_month_days_formatted(params[:aa_alotmentdate])  : 0
     params[:aa_depcode]       = params[:aa_depcode]  !=nil && params[:aa_depcode]  !='' ? params[:aa_depcode]  : ''
     params[:aa_sewadarcode]   = params[:aa_sewadarcode]  !=nil && params[:aa_sewadarcode]  !='' ? params[:aa_sewadarcode]  : ''
     params[:aa_addtype]       = params[:aa_addtype]  !=nil && params[:aa_addtype]  !='' ? params[:aa_addtype]  : ''
     currenyimage              = params[:currenyimage]  !=nil && params[:currenyimage]  !='' ? params[:currenyimage]  : ''
     attimage = ""
     if params[:aa_attachment] !=nil && params[:aa_attachment] !=''
       attimage = process_files(params[:aa_attachment],currenyimage,cdirect)
     end
     if attimage == nil  || attimage == ''
        if currenyimage !=nil && currenyimage !=''
          attimage = currenyimage
        end
     end
      params[:aa_attachment] = attimage
     params.permit(:aa_compcode,:aa_alotmentno,:aa_alotmentdate,:aa_depcode,:aa_sewadarcode,:aa_addtype,:aa_address,:aa_declaretaking,:aa_attachment)
  end
  private
  def last_allotment_no
    @isCode     = 0
    @Startx     = '0000'
    @recCodes   = MstAccomodationAllotment.where(["aa_compcode =? AND aa_alotmentno >0 ",@compcodes]).order('aa_alotmentno DESC').first
    if @recCodes
    @isCode    = @recCodes.aa_alotmentno.to_i
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
  def get_accomodation_address_list
      adtype  = params[:types]
      isflags = false
      listobj =  MstAccomodationDetail.select("id,ad_address").where("ad_compcode =? AND ad_belongs = ? AND ad_allotmentno=''",@compcodes,adtype).group("ad_address").order("ad_address ASC")
      if listobj.length >0
        message = "Success"
        isflags = true
      end
      respond_to do |format|
        format.json { render :json => { 'data'=>listobj, "message"=>message,:status=>isflags} }
       end
  end

  private
  def get_address_list_detail
     arrs     = []
     adid     = params[:adid]
     isflags  = false
     isselect = "'' as states,'' as cities,'' as districts,'' as accomotype,mst_accomodation_details.*"
      listobj =  MstAccomodationDetail.select(isselect).where("ad_compcode =? AND id = ?",@compcodes,adid).first
      if listobj
            newadd  = listobj
            stoibj  = get_state_detail(newadd.ad_state)
            if stoibj
              newadd.states = stoibj.sts_description
            end
            distobj = get_district_detail(newadd.ad_district)
            if distobj
              newadd.districts = distobj.dts_description
            end
            acotpobj = get_accomodation_types(newadd.ad_accomodtype)
            if acotpobj
               newadd.accomotype = acotpobj.at_description
            end
            arrs.push newadd
           message = "Success"
           isflags = true
      end
      respond_to do |format|
        format.json { render :json => { 'data'=>arrs, "message"=>message,:status=>isflags} }
       end
  end

  private
  def add_allotment_series(compcode,adid,alomentno)
      alotmeobj = MstAccomodationDetail.select("id,ad_address").where("ad_compcode =? AND id = ?",compcode,adid).first
      if alotmeobj
        alotmeobj.update(:ad_allotmentno=>alomentno)
      end
  end

  private
  def reverse_allotment_series(compcode,adid)
    alotmeobj = MstAccomodationDetail.select("id,ad_address").where("ad_compcode =? AND id = ?",compcode,adid).first
      if alotmeobj
        alotmeobj.update(:ad_allotmentno=>'')
      end

  end

  private
  def get_address_item_listed(adid)
     arrs     = []
     compcode =  session[:loggedUserCompCode]
     isselect = "'' as states,'' as cities,'' as districts,'' as accomotype,mst_accomodation_details.*"
      listobj =  MstAccomodationDetail.select(isselect).where("ad_compcode =? AND id = ?",compcode,adid).first
      if listobj
            newadd  = listobj
            stoibj  = get_state_detail(newadd.ad_state)
            if stoibj
              newadd.states = stoibj.sts_description
            end
            distobj = get_district_detail(newadd.ad_district)
            if distobj
              newadd.districts = distobj.dts_description
            end
            acotpobj = get_accomodation_types(newadd.ad_accomodtype)
            if acotpobj
               newadd.accomotype = acotpobj.at_description
            end
            arrs.push newadd
          
      end
     return arrs
  end
  private
  def excel_common_list
     @co
     mpcodes         = session[:loggedUserCompCode]
    sewadar_search_code = session[:req_search_codesewa]
    sewadar_branches    = session[:req_search_headbranch]
    search_allotno      = session[:req_search_allotno]

    iswhere = "aa_compcode ='#{@compcodes}'"
    if sewadar_search_code != nil && sewadar_search_code != ''
        iswhere += " AND aa_sewadarcode ='#{sewadar_search_code}'"
       
    end
     if sewadar_branches != nil && sewadar_branches != ''
        iswhere += " AND aa_addtype ='#{sewadar_branches}'"
        
    end
    if search_allotno != nil && search_allotno != ''
         iswhere += " AND aa_alotmentno LIKE '%#{search_allotno}%'"
        
    end
    arrs        = []
    isselect    = "mst_accomodation_allotments.*,'' as address,'' as sewdarname,'' as belogsto,DATE_FORMAT(aa_alotmentdate,'%d-%b-%Y') as accomodated"
    excelobj    = MstAccomodationAllotment.select(isselect).where(iswhere).order("aa_alotmentno ASC")
    if excelobj.length >0
          @newExcelVisit = excelobj
          excelobj.each do |newalt|
              addrsobj      = get_accomodation_addresslisted(newalt.aa_address)
             if addrsobj
               newalt.address = addrsobj.ad_address
             end
             seobj      = get_mysewdar_list_details(newalt.aa_sewadarcode)
             if seobj
               newalt.sewdarname = seobj.sw_sewadar_name
             end
             
            if newalt.aa_addtype == 'H'
              newalt.belogsto ="Head"
            elsif newalt.aa_addtype == 'B'
              newalt.belogsto ="Branch"
            end
            arrs.push newalt
          end
    end
     return arrs
  end
  
end
