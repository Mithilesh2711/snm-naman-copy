class PostalController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_leavemaster_detail
  helper_method :get_all_department_detail,:get_link_image,:get_mysewdar_list_details,:get_sewdar_designation_detail,:format_oblig_date,:get_sewa_all_department
  def index
    @compCodes         = session[:loggedUserCompCode]
    @HeadHrp           = MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
    @sewDepart         = Department.select("compCode,departDescription,departCode").where("compCode = ? AND subdepartment =''",@compCodes).order("departDescription ASC")
    @DispatchList      = get_postal_dispatched
  end

  def create
   @compCodes  =  session[:loggedUserCompCode]
   isFlags     = true
   begin
   if params[:dps_postedby] == '' || params[:dps_postedby] == nil
      flash[:error] =  "Posted by is required."
      isFlags = false
   elsif params[:dps_department] == '' || params[:dps_department] == nil
      flash[:error] =  "Department is required"
      isFlags = false   
   elsif params[:dps_name] == '' || params[:dps_name] == nil
      flash[:error] =  "Name is required"
      isFlags = false   		
   elsif params[:dps_subject] == '' || params[:dps_subject] == nil
      flash[:error] =  "Subject is required"
      isFlags = false
   else    
     
     mid    = params[:mid]
     if mid.to_i >0
  
           if isFlags
              chkdeprtobj   = TrnDispatchPostal.where("dps_compcode = ? AND id = ?",@compCodes,mid).first
              if chkdeprtobj
               chkdeprtobj.update(postal_params)
                  flash[:error] = "Data updated successfully"
                  isFlags       = true
              end
           end
  
     else
         
           if isFlags
              deprtsvobj = TrnDispatchPostal.new(postal_params)
               if deprtsvobj.save
                 flash[:error] = "Data saved successfully"
                 isFlags       = true
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
      redirect_to  "#{root_url}postal/dispatch_entry"
    else
      redirect_to  "#{root_url}postal"
    end

  end

  def dispatch_entry
      @compCodes       = session[:loggedUserCompCode]
      @lastEntryNo     = last_entry_no
      @ListDispFirst   = nil 
      @BrachListed     = MstBranchList.where("bl_compcode =?",@compCodes).order("bl_branchname ASC")
      @HeadOffices     = MstHeadOffice.where("hof_compcode =?",@compCodes).order("hof_description ASC")
      @ListZone        = MstZone.where("zn_compcode = ?",@compCodes).order("zn_name ASC")
      @ZonalBranch     = nil
      if params[:id].to_i >0
        @ListDispFirst =   TrnDispatchPostal.where(["dps_compcode =? AND id = ? ",@compCodes,params[:id].to_i]).first
        if @ListDispFirst
          @ZonalBranch   =   MstBranch.where("bch_compcode = ? AND bch_zonecode = ?",@compCodes,@ListDispFirst.dps_zone).order("bch_branchname ASC")
        end
        
      end
  end
    
  def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         @ListDispobj =  TrnDispatchPostal.where("dps_compcode =? AND id = ?",@compcodes,params[:id]).first
         if @ListDispobj
                @ListDispobj.destroy
                 flash[:error] =  "Data deleted successfully."
                 isFlags       =  true
                 session[:isErrorhandled] = nil
         end
    end
    redirect_to "#{root_url}postal"
 end 

private
  def last_entry_no
    @isCode     = 0
    @Startx     = '0000'
    @recCodes   = TrnDispatchPostal.where(["dps_compcode =? AND dps_entryno >0 ",@compCodes]).order('dps_entryno DESC').first
    if @recCodes
    @isCode    = @recCodes.dps_entryno.to_i
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
 def postal_params
    @isCode     = 0
    @Startx     = '0000'
	  @recCodes   = TrnDispatchPostal.where(["dps_compcode =? AND dps_entryno >0 ",@compCodes]).order('dps_entryno DESC').first
	  if @recCodes
	  @isCode    = @recCodes.dps_entryno.to_i
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
		   
		rqdated  = 0
    if params[:dps_entrydate] !=nil && params[:dps_entrydate] !=''
        rqdated = year_month_days_formatted(params[:dps_entrydate])
    end
  params[:dps_compcode]        = session[:loggedUserCompCode]
  params[:dps_entryno]         = @sumXOfCode 
  params[:dps_entrydate]       = rqdated  
  params[:dps_department]      = params[:dps_department] !=nil && params[:dps_department] !='' ? params[:dps_department] : ''
  params[:dps_postedby]        = params[:dps_postedby]  !=nil && params[:dps_postedby]  !='' ? params[:dps_postedby]  : ''
  params[:dps_name]            = params[:dps_name] !=nil && params[:dps_name] !='' ? params[:dps_name] : ''
  params[:dps_subject]         = params[:dps_subject] !=nil && params[:dps_subject] !='' ? params[:dps_subject] : ''
  params[:dps_type]            = params[:dps_type] !=nil && params[:dps_type] !='' ? params[:dps_type] : ''
  params[:dps_charges]         = params[:dps_charges] !=nil && params[:dps_charges] !='' ? params[:dps_charges] : 0
  params[:dps_zone]            = params[:dps_zone] !=nil && params[:dps_zone] !='' ? params[:dps_zone] : ''
  params[:dps_docno]           = params[:dps_docno] !=nil && params[:dps_docno] !='' ? params[:dps_docno] : ''
  params[:dps_trackingno]      = params[:dps_trackingno] !=nil && params[:dps_trackingno] !='' ? params[:dps_trackingno] : ''
  params[:dps_stampbalance]    = params[:dps_stampbalance] !=nil && params[:dps_stampbalance] !='' ? params[:dps_stampbalance] : 0
  params.permit(:dps_compcode,:dps_entryno,:dps_entrydate,:dps_postedby,:dps_department,:dps_name,:dps_subject,:dps_type,:dps_charges,:dps_zone,:dps_branch,:dps_stampbalance,:dps_reamark,:dps_branchaddress,:dps_docno,:dps_trackingno)
 end

 private
 def get_postal_dispatched
   if params[:requestserver] !=nil && params[:requestserver] != ''
    session[:postal_department]     = nil
    session[:postal_fromdated]      = nil
    session[:postal_uptodated]      = nil
    session[:postal_dpspostedby]    = nil
    session[:postal_chargesentered] = nil
   end
   voucher_department = params[:voucher_department] !=nil && params[:voucher_department] !='' ? params[:voucher_department] : session[:postal_department]
   search_fromdated   = params[:search_fromdated] !=nil && params[:search_fromdated] !='' ? params[:search_fromdated] : session[:postal_fromdated]
   search_uptodated   = params[:search_uptodated] !=nil && params[:search_uptodated] !='' ? params[:search_uptodated] : session[:postal_uptodated]
   dpspostedby        = params[:dpspostedby] !=nil && params[:dpspostedby] !='' ? params[:dpspostedby] : session[:postal_dpspostedby]
   chargesentered     = params[:chargesentered] !=nil && params[:chargesentered] !='' ? params[:chargesentered] : session[:postal_chargesentered]

  iswhere  = "dps_compcode='#{@compCodes}'"
   if voucher_department !=nil && voucher_department !='' 
    iswhere  += " AND  dps_department ='#{voucher_department}'"
    session[:postal_department] = voucher_department
    @voucher_department = voucher_department
   end
   if search_fromdated !=nil && search_fromdated !='' 
    iswhere  += " AND  dps_entrydate >='#{year_month_days_formatted(search_fromdated)}'"
    @search_fromdated = search_fromdated
    session[:postal_fromdated] = search_fromdated
   end
   if search_uptodated !=nil && search_uptodated !='' 
    iswhere  += " AND  dps_entrydate <='#{year_month_days_formatted(search_uptodated)}'"
    @search_uptodated = search_uptodated
    session[:postal_uptodated] = search_uptodated
   end
   if dpspostedby !=nil && dpspostedby !='' 
    iswhere  += " AND  dps_postedby LIKE '%#{dpspostedby}%'"
    session[:postal_dpspostedby] = dpspostedby
    @dpspostedby = dpspostedby
   end
   if chargesentered !=nil && chargesentered !='' 
    iswhere  += " AND  dps_charges >0"
    @chargesentered = chargesentered
    session[:postal_chargesentered] = chargesentered
   end
  itemlist  = TrnDispatchPostal.where(iswhere).order('dps_entryno DESC')
  return itemlist
 end

end
