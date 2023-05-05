class PostalReceiveController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_leavemaster_detail
    helper_method :get_all_department_detail,:get_link_image,:get_mysewdar_list_details,:get_sewdar_designation_detail,:format_oblig_date,:get_sewa_all_department
    def index
      @compCodes     =  session[:loggedUserCompCode]
      month_number   =  Time.now.month
      month_begin    =  Date.new(Date.today.year, month_number)
      begdate        =  Date.parse(month_begin.to_s)
      @nbegindate    =  begdate.strftime('%d-%b-%Y')
      month_ending   =  month_begin.end_of_month
      endingDate     =  Date.parse(month_ending.to_s)
      @enddate       =  endingDate.strftime('%d-%b-%Y')
      @CurDated      =  Date.today
      @HeadHrp       =  MstHrParameterHead.where("hph_compcode = ?",@compCodes).first
      @sewDepart     =  Department.select("compCode,departDescription,departCode").where("compCode = ? AND subdepartment =''",@compCodes).order("departDescription ASC")
      @DispatchList  =  get_postal_dispatched
    end
  
    def create
     @compCodes  =  session[:loggedUserCompCode]
     isFlags     = true
     begin
     if params[:dps_postedby] == '' || params[:dps_postedby] == nil
        flash[:error] =  "Received from is required."
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
                chkdeprtobj   = TrnPostalReceive.where("prs_compcode = ? AND id = ?",@compCodes,mid).first
                if chkdeprtobj
                 chkdeprtobj.update(receive_params)
                    flash[:error] = "Data updated successfully"
                    isFlags       = true
                end
             end
    
       else
           
             if isFlags
                deprtsvobj = TrnPostalReceive.new(receive_params)
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
       session[:rcpostal_department]     = nil
       session[:rcpostal_fromdated]      = nil
       session[:rcpostal_uptodated]      = nil
       session[:rcpostal_dpspostedby]    = nil
       session[:rcpostal_chargesentered] = nil
       isFlags = true
     end
      rescue Exception => exc
         flash[:error] =  "ERROR: #{exc.message}"
         session[:isErrorhandled] = 1
        # session[:postedpamams]   = params
         isFlags = false
      end
      if !isFlags
        redirect_to  "#{root_url}postal_receive/postal_receive_entry"
      else
        redirect_to  "#{root_url}postal_receive"
      end
  
    end
  
    def postal_receive_entry
        @compCodes       = session[:loggedUserCompCode]
        @lastEntryNo     = last_entry_no
        @ListDispFirst   = nil 
        @BrachListed     = MstBranchList.where("bl_compcode =?",@compCodes).order("bl_branchname ASC")
        @HeadOffices     = MstHeadOffice.where("hof_compcode =?",@compCodes).order("hof_description ASC")
        @ListZone        = MstZone.where("zn_compcode = ?",@compCodes).order("zn_name ASC")
        @ZonalBranch     = nil
        if params[:id].to_i >0
          @ListDispFirst =   TrnPostalReceive.where(["prs_compcode =? AND id = ? ",@compCodes,params[:id].to_i]).first
          if @ListDispFirst
            @ZonalBranch   =   MstBranch.where("bch_compcode = ? AND bch_zonecode = ?",@compCodes,@ListDispFirst.prs_zone).order("bch_branchname ASC")
          end
          
        end
    end
      
    def destroy
      @compcodes = session[:loggedUserCompCode]
      if params[:id].to_i >0
           @ListDispobj =  TrnPostalReceive.where("prs_compcode =? AND id = ?",@compcodes,params[:id]).first
           if @ListDispobj
                  @ListDispobj.destroy
                   flash[:error] =  "Data deleted successfully."
                   isFlags       =  true
                   session[:isErrorhandled] = nil
           end
      end
      redirect_to "#{root_url}postal_receive"
   end 
  
  private
    def last_entry_no
      @isCode     = 0
      @Startx     = '0000'
      @recCodes   = TrnPostalReceive.where(["prs_compcode =? AND prs_entryno >0 ",@compCodes]).order('prs_entryno DESC').first
      if @recCodes
      @isCode    = @recCodes.prs_entryno.to_i
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
   def receive_params
        @isCode     = 0
        @Startx     = '0000'
        @recCodes   = TrnPostalReceive.where(["prs_compcode =? AND prs_entryno >0 ",@compCodes]).order('prs_entryno DESC').first
        if @recCodes
         @isCode    = @recCodes.prs_entryno.to_i
        end
          @sumXOfCode = @isCode.to_i + 1
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
    params[:prs_compcode]        = session[:loggedUserCompCode]
    params[:prs_entryno]         = @sumXOfCode 
    params[:prs_entrydate]       = rqdated  
    params[:prs_department]      = params[:dps_department] !=nil && params[:dps_department] !='' ? params[:dps_department] : ''
    params[:prs_postedby]        = params[:dps_postedby]  !=nil && params[:dps_postedby]  !='' ? params[:dps_postedby]  : ''
    params[:prs_name]            = params[:dps_name] !=nil && params[:dps_name] !='' ? params[:dps_name] : ''
    params[:prs_subject]         = params[:dps_subject] !=nil && params[:dps_subject] !='' ? params[:dps_subject] : ''
    params[:prs_type]            = params[:dps_type] !=nil && params[:dps_type] !='' ? params[:dps_type] : ''
    params[:prs_charges]         = params[:dps_charges] !=nil && params[:dps_charges] !='' ? params[:dps_charges] : 0
    params[:prs_zone]            = params[:dps_zone] !=nil && params[:dps_zone] !='' ? params[:dps_zone] : ''
    params[:prs_stampbalance]    = params[:dps_stampbalance] !=nil && params[:dps_stampbalance] !='' ? params[:dps_stampbalance] : 0
    params.permit(:prs_compcode,:prs_entryno,:prs_entrydate,:prs_postedby,:prs_department,:prs_name,:prs_subject,:prs_type,:prs_charges,:prs_zone,:prs_branch,:prs_stampbalance,:prs_reamark,:prs_branchaddress)
   end
  
   private
   def get_postal_dispatched
     if params[:requestserver] !=nil && params[:requestserver] != ''
      session[:rcpostal_department]     = nil
      session[:rcpostal_fromdated]      = nil
      session[:rcpostal_uptodated]      = nil
      session[:rcpostal_dpspostedby]    = nil
      session[:rcpostal_chargesentered] = nil
     else
      return false
     end
     voucher_department = params[:voucher_department] !=nil && params[:voucher_department] !='' ? params[:voucher_department] : session[:rcpostal_department]
     search_fromdated   = params[:search_fromdated] !=nil && params[:search_fromdated] !='' ? params[:search_fromdated] : session[:rcpostal_fromdated]
     search_uptodated   = params[:search_uptodated] !=nil && params[:search_uptodated] !='' ? params[:search_uptodated] : session[:rcpostal_uptodated]
     dpspostedby        = params[:dpspostedby] !=nil && params[:dpspostedby] !='' ? params[:dpspostedby] : session[:rcpostal_dpspostedby]
     chargesentered     = params[:chargesentered] !=nil && params[:chargesentered] !='' ? params[:chargesentered] : session[:rcpostal_chargesentered]
  
    iswhere  = "prs_compcode='#{@compCodes}'"
     if voucher_department !=nil && voucher_department !='' 
      iswhere  += " AND  prs_department ='#{voucher_department}'"
      session[:rcpostal_department] = voucher_department
      @voucher_department = voucher_department
     end
     if search_fromdated !=nil && search_fromdated !='' 
      iswhere  += " AND  prs_entrydate >='#{year_month_days_formatted(search_fromdated)}'"
      @search_fromdated = search_fromdated
      session[:rcpostal_fromdated] = search_fromdated
     end
     if search_uptodated !=nil && search_uptodated !='' 
      iswhere  += " AND  prs_entrydate <='#{year_month_days_formatted(search_uptodated)}'"
      @search_uptodated = search_uptodated
      session[:rcpostal_uptodated] = search_uptodated
     end
     if dpspostedby !=nil && dpspostedby !='' 
      iswhere  += " AND  prs_postedby LIKE '%#{dpspostedby}%'"
      session[:rcpostal_dpspostedby] = dpspostedby
      @dpspostedby = dpspostedby
     end
     if chargesentered !=nil && chargesentered !='' 
      iswhere  += " AND  prs_charges >0"
      @chargesentered = chargesentered
      session[:rcpostal_chargesentered] = chargesentered
     end
    itemlist  = TrnPostalReceive.where(iswhere).order('prs_entryno DESC')
    return itemlist
   end


end
