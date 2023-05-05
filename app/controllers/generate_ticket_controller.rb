## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for generate tickets
### FOR REST API ######
class GenerateTicketController < ApplicationController
   before_action :require_login
   before_action :allowed_security
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search,:get_ticket_list,:ticket_list]
   include ErpModule::Common
   helper_method :get_sel_brand,:currency_formatted,:year_month_days_formatted,:formatted_date,:set_ent,:set_dct
   helper_method :user_detail,:format_oblig_date,:get_mysewdar_list_details,:get_department_detail
   
  def index
     @compCodes     =  session[:loggedUserCompCode]
     @LastNo        =  get_last_ticket_no
     Time.zone      =  "Kolkata"
     @Localtimes    =  Time.zone.now.strftime('%I:%M%p')
     @cDated        =  formatted_date(Time.now.to_date)
     mydeprtcode    =  ""
     @newsewdarList =  nil
     @mydepartcode  =  nil
    if session[:sec_sewdar_code]
         sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
         if sewobjs
            mydeprtcode   = sewobjs.sw_depcode
            @mydepartcode = sewobjs.sw_depcode
         end
     end
     if @mydepartcode == nil 
           if  session[:sec_deprtmentcode]
                mydeprtcode   =  session[:sec_deprtmentcode]
                @mydepartcode =  session[:sec_deprtmentcode]
           end
     end


       @markedXAllowed = true
      @rasedAllowed    = true
	   if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf' || session[:requestuser_loggedintp].to_s == 'asd'
		    @ListDepart  = Department.where("compCode = ? AND subdepartment = '' AND departCode = ? ",@compCodes,mydeprtcode).order("departDescription ASC")
			@markedXAllowed = false
	   else		  
		   @ListDepart     = Department.where("compCode = ? AND subdepartment='' ",@compCodes).order("departDescription ASC")		   		  
	   end

	  if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
		  @markedXAllowed  =   false
		  @newsewdarList   =   MstSewadar.where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")
	  elsif session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'stf'
	      @markedXAllowed  =   false
		  @newsewdarList   =   MstSewadar.where("sw_compcode = ? AND sw_depcode = ?",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")
	  end
	 
     if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf'
         @ListAllDepart  = Department.where("compCode = ?  AND helpdesk = 'Y' ",@compCodes).order("departDescription ASC")
     else
	     @rasedAllowed = false
         @ListAllDepart  = Department.where("compCode = ?  AND helpdesk = 'Y' AND departCode = ? ",@compCodes,session[:requser_loggeddpt]).order("departDescription ASC")
     end
     
     @ListTicket  = nil
     if params[:id] != nil && params[:id] != ''
          docs = params[:id].to_s.split("_")
          if docs[1] != 'prt'
            docsno      =  params[:id]
            @ListTicket =  TrnRaiseTicket.where("rt_compcode = ? AND id = ?",@compCodes,docsno).first
          end
          
     end

  end
  def cancel
    @compCodes        =  session[:loggedUserCompCode]
    isFlags = true
     if params[:id].to_i >0
      chkdeprtobj   = TrnRaiseTicket.where("rt_compcode = ? AND id = ?",@compCodes,params[:id].to_i).first
        if chkdeprtobj
             chkdeprtobj.update(:rt_status=>'D')
             flash[:error] =  "Data cancelled sucessfully."
             isFlags        = false
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
    redirect_to "#{root_url}generate_ticket/ticket_list"
  end
  
  def ticket_list
    @compCodes        =  session[:loggedUserCompCode]
     mydeprtcode      =  ""
     @newsewdarList   =  nil
     @mydepartcode    =  nil
	 @rasedAllowed    =  true
	 @DeprtmentalExc  = false
    if session[:sec_sewdar_code]
         sewobjs =  get_mysewdar_list_details(session[:sec_sewdar_code] )
         if sewobjs
            mydeprtcode   = sewobjs.sw_depcode
            @mydepartcode = sewobjs.sw_depcode
         end
     end
     @AssignedListed = 0
     if @mydepartcode == nil
           if  session[:sec_deprtmentcode]
                mydeprtcode   =  session[:sec_deprtmentcode]
                @mydepartcode =  session[:sec_deprtmentcode]
           end
    
     end

      if session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf' || session[:requestuser_loggedintp].to_s == 'asd'
		 @ListAssigned  = MstSewadar.select("sw_sewadar_name,sw_sewcode").where("sw_compcode = ? AND sw_depcode = ?",@compCodes,@mydepartcode).order("sw_sewadar_name ASC")
	  else
		  @ListAssigned  = MstSewadar.select("sw_sewadar_name,sw_sewcode").where("sw_compcode = ? AND sw_depcode = ?",@compCodes,session[:requser_loggeddpt]).order("sw_sewadar_name ASC")
		  if session[:sec_sewdar_code] !=nil  && session[:sec_sewdar_code] !=''
			#@AssignedListed = 1
		  end
	  end
	  
	
	  
	  @markedXAllowed = true
	  if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf' 
		   @ListAllDepart  = Department.where("compCode = ?  AND helpdesk = 'Y' ",@compCodes).order("departDescription ASC")
  	elsif session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'asd' 
      @rasedAllowed   = false
		  @DeprtmentalExc = true
          @ListAllDepart  = Department.where("compCode = ?  AND helpdesk = 'Y' AND departCode = ? ",@compCodes,session[:sec_deprtmentcode]).order("departDescription ASC")
		     
     else
	      @rasedAllowed   = false
		  @DeprtmentalExc = true
          @ListAllDepart  = Department.where("compCode = ?  AND helpdesk = 'Y' AND departCode = ? ",@compCodes,session[:requser_loggeddpt]).order("departDescription ASC")
		   
     end
	 
      if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd' || session[:requestuser_loggedintp].to_s == 'stf' 
	  	    @ListDepart  = Department.where("compCode = ? AND subdepartment='' AND departCode = ? ",@compCodes,mydeprtcode).order("departDescription ASC")
		    @markedXAllowed = false      
	 else
	    @ListDepart     = Department.where("compCode = ? AND subdepartment='' ",@compCodes).order("departDescription ASC")    
	 end
	if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'	|| session[:requestuser_loggedintp].to_s == 'asd'	
		@newsewdarList =   MstSewadar.where("sw_compcode = ? AND sw_sewcode = ?",@compCodes,session[:sec_sewdar_code]).order("sw_sewadar_name ASC")
	elsif session[:requestuser_loggedintp].to_s == 'stf'	
		@newsewdarList =   MstSewadar.where("sw_compcode = ? AND sw_depcode = ?",@compCodes,mydeprtcode).order("sw_sewadar_name ASC")
	end
     @TicketsListed = get_ticket_list
  end

  def refresh_generate_ticket
    session[:reqs_ticket_number]     = nil
    session[:tickets_department]     = nil
    session[:reqs_ticket_status]     = nil
    session[:reqs_ticket_from_date]  = nil
    session[:reqs_ticket_upto_dated] = nil
    session[:req_raised_department]  = nil
    redirect_to  "#{root_url}generate_ticket/ticket_list"
  end

  def create
  @compCodes  =  session[:loggedUserCompCode]
  isFlags     = true
  begin
  if params[:rt_ticketno] == '' || params[:rt_ticketno] == nil
     flash[:error] =  "ticket no. is required."
     isFlags = false
  elsif params[:rt_ticketdate] == '' || params[:rt_ticketdate] == nil
     flash[:error] =  "Ticket date is required."
     isFlags = false
 elsif params[:rt_tickettime] == '' || params[:rt_tickettime] == nil
     flash[:error] =  "Ticket time is required."
     isFlags = false
 elsif params[:rt_department] == '' || params[:rt_department] == nil
     flash[:error] =  "Department is required."
     isFlags = false
 elsif params[:rt_queryissue] == '' || params[:rt_queryissue] == nil
     flash[:error] =  "Query/Issue is is required."
     isFlags = false
  else

    ticketno      = params[:rt_ticketno].to_s.strip
    mid           = params[:mid]
    if mid.to_i >0

            if isFlags
                chkdeprtobj   = TrnRaiseTicket.where("rt_compcode = ? AND rt_ticketno = ?",@compCodes,ticketno).first
                if chkdeprtobj
                  chkdeprtobj.update(ticket_params)
                      flash[:error] = "Data updated successfully"
                      isFlags       = true
                end
            end

    else
          deprtsvobj = TrnRaiseTicket.new(ticket_params)
           if deprtsvobj.save
              flash[:error] = "Data saved successfully"
              isFlags       = true
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
    if isFlags
      redirect_to  "#{root_url}generate_ticket"
    else
      redirect_to  "#{root_url}generate_ticket/ticket_list"
    end
  
end

 def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         @ListSate =  TrnRaiseTicket.where("compCode =? AND id = ?",@compcodes,params[:id]).first
         if @ListSate
                 @ListSate.destroy
                 flash[:error] =  "Data deleted successfully."
                 isFlags       =  true
                 session[:isErrorhandled] = nil
         end
    end
    redirect_to "#{root_url}department"
 end


private
def ticket_params
  @Startx     = '0000'
  @recCodes   = TrnRaiseTicket.select("rt_ticketno").where(["rt_compcode = ? AND rt_ticketno<>''", @compCodes]).order('rt_ticketno DESC').first
  if @recCodes
  @isCode    = @recCodes.rt_ticketno.to_i
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
  attachfile = ""
  cdirect    = "ticket"
  if params[:mid].to_i >0
    params[:rt_ticketno]   = params[:rt_ticketno]
  else
      params[:rt_ticketno] = @sumXOfCode
  end
  dt = 0
  if params[:rt_ticketdate] !=nil && params[:rt_ticketdate] !=''
      dt = year_month_days_formatted(params[:rt_ticketdate])
  end
    params[:rt_ticketdate]     = dt
    params[:rt_compcode]       = session[:loggedUserCompCode]
    params[:rt_tickettime]     = params[:rt_tickettime] !=nil && params[:rt_tickettime] !='' ? params[:rt_tickettime] : ''
    params[:rt_department]     = params[:rt_department]!=nil && params[:rt_department] !='' ? params[:rt_department] : ''
    params[:rt_sewadar]        = params[:rt_sewadar]!=nil && params[:rt_sewadar] !='' ? params[:rt_sewadar] : ''
    params[:rt_issueraisedby]  = params[:rt_issueraisedby]!=nil && params[:rt_issueraisedby] !='' ? params[:rt_issueraisedby] : ''
    params[:rt_priorty]        = params[:rt_priorty]!=nil && params[:rt_priorty] !='' ? params[:rt_priorty] : ''
    params[:rt_queryissue]     = params[:rt_queryissue]!=nil && params[:rt_queryissue] !='' ? params[:rt_queryissue] : ''
    params[:rt_status]         = params[:rt_status]!=nil && params[:rt_status] !='' ? params[:rt_status] : 'O'    
    params[:rt_raiseddep]      = params[:rt_raiseddep]!=nil && params[:rt_raiseddep] !='' ? params[:rt_raiseddep] : ''
    params[:rt_titles]         = params[:rt_titles]!=nil && params[:rt_titles] !='' ? params[:rt_titles] : ''
    params[:rt_resolveremark]  = ''
    params[:rt_feeback]        = ''
    params[:rt_rating]         = 0


    if params[:rt_attachment] != '' && params[:rt_attachment] !=nil
      attachfile      = process_files(params[:rt_attachment],params[:currfile],cdirect)
  end
  if attachfile == nil || attachfile == ''
      if params[:currfile] !=nil && params[:currfile] != ''
           attachfile = params[:currfile]
      end
  end
    params[:rt_attachment]  = attachfile
    params.permit(:rt_compcode,:rt_resolveremark,:rt_feeback,:rt_rating,:rt_titles,:rt_sewadar,:rt_raiseddep,:rt_ticketno,:rt_ticketdate,:rt_tickettime,:rt_department,:rt_issueraisedby,:rt_priorty,:rt_queryissue,:rt_status,:rt_attachment)
end

private
  def get_ticket_list
        sewacode = session[:sec_sewdar_code]
       if params[:page].to_i >0
         pages = params[:page]
      else
         pages = 1
      end
     if params[:requestserver] !=nil && params[:requestserver] != ''
        session[:reqs_ticket_number]     = nil
        session[:tickets_department]     = nil
        session[:reqs_ticket_status]     = nil
        session[:reqs_ticket_from_date]  = nil
        session[:reqs_ticket_upto_dated] = nil
        session[:req_raised_department]  = nil
     end
          ticket_number     = params[:ticket_number] !=nil && params[:ticket_number] != '' ? params[:ticket_number].to_s.strip : session[:reqs_ticket_number]
          ticket_department = params[:ticket_department] !=nil && params[:ticket_department] != '' ? params[:ticket_department].to_s.strip : session[:tickets_department]
          ticket_status     = params[:ticket_status] !=nil && params[:ticket_status] != '' ? params[:ticket_status].to_s.strip : session[:reqs_ticket_status]

          from_date         = params[:from_dated] !=nil && params[:from_dated] != '' ? params[:from_dated].to_s.strip : session[:reqs_ticket_from_date]
          upto_date         = params[:upto_dated] !=nil && params[:upto_dated] != '' ? params[:upto_dated].to_s.strip : session[:reqs_ticket_upto_dated]
          rased_department  = params[:rt_raiseddep] !=nil && params[:rt_raiseddep] != '' ? params[:rt_raiseddep].to_s.strip : session[:req_raised_department]

          if session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'swd'
             iswhere = "rt_compcode ='#{@compCodes}' AND rt_sewadar ='#{sewacode}'"  
          elsif session[:requestuser_loggedintp] && session[:requestuser_loggedintp].to_s == 'asd'
              iswhere = "rt_compcode ='#{@compCodes}' AND rt_assignedsewacode ='#{sewacode}'"                                
          else
              iswhere = "rt_compcode ='#{@compCodes}'  "
             
           end
      
      if ticket_number !=nil && ticket_number !=''
          iswhere += " AND rt_ticketno LIKE '%#{ticket_number}%'"
          @ticket_number              = ticket_number
          session[:reqs_ticket_number] = ticket_number
      end
      if session[:requestuser_loggedintp] && session[:requestuser_loggedintp] =='stf' || session[:requestuser_loggedintp] =='swd'	  
           iswhere += " AND rt_department='#{@mydepartcode}'"
           @ticket_department              = @mydepartcode
           session[:tickets_department]    = @mydepartcode
       else
            if ticket_department != nil && ticket_department != ''
			   iswhere += " AND rt_department='#{ticket_department}'"
			   @ticket_department              = ticket_department
			   session[:tickets_department]    = ticket_department
           end
      end

      if session[:requestuser_loggedintp] !='asd'	
        
				  if rased_department !=nil && rased_department !=''
					   iswhere += " AND rt_raiseddep ='#{rased_department}'"
					   @raised_department             = rased_department
					  session[:req_raised_department]  = rased_department
				  end
    elsif session[:requestuser_loggedintp] && session[:requestuser_loggedintp] =='hr'	
          iswhere += " AND rt_raiseddep   ='#{session[:requser_loggeddpt]}'"
          @raised_department              = session[:requser_loggeddpt]
         session[:req_raised_department]  = session[:requser_loggeddpt]    
		else
				  iswhere += " AND rt_raiseddep    ='#{session[:sec_deprtmentcode]}'"
				   @raised_department              = session[:sec_deprtmentcode]
				  session[:req_raised_department]  = session[:sec_deprtmentcode]
    end

       if ticket_status !=nil && ticket_status !=''
            iswhere += " AND rt_status = '#{ticket_status}'"
            @ticket_status              = ticket_status
            session[:reqs_ticket_status] = ticket_status
      end
      if from_date !=nil && from_date !=''
            iswhere += " AND rt_ticketdate >= '#{year_month_days_formatted(from_date)}'"
            @from_dated                    = from_date
            session[:reqs_ticket_from_date] = from_date
      else
            iswhere += " AND rt_ticketdate >= '#{year_month_days_formatted(Date.today)}'"
            @from_dated                    = formatted_date(Date.today)
      end
      if upto_date !=nil && upto_date !=''
            iswhere += " AND rt_ticketdate <= '#{year_month_days_formatted(upto_date)}'"
            @upto_dated                     = formatted_date(upto_date)
            session[:reqs_ticket_upto_dated] = formatted_date(upto_date)
      else
           iswhere += " AND rt_ticketdate <= '#{year_month_days_formatted(Date.today)}'"            
            session[:reqs_ticket_upto_dated] = formatted_date(Date.today)
            
      end
      stsobj =  TrnRaiseTicket.where(iswhere).paginate(:page =>pages,:per_page => 20).order("created_at DESC")
      return stsobj
      
  end

  private
  def print_excel_listed
     search_departcode =  session[:req_search_departcode]
     
      iswhere          = "compCode ='#{@compCodes}'"
      if search_departcode !=nil && search_departcode !=''
        iswhere += " AND departCode LIKE '%#{search_departcode}%' OR  departDescription LIKE '%#{search_departcode}%' OR departHod LIKE '%#{search_departcode}%'"
      end
      stsobj =  TrnRaiseTicket.where(iswhere).order("departDescription ASC")
      return stsobj
  end

  private
def get_last_ticket_no
  @Startx     = '0000'
  @isCode     = 0
  @recCodes   = TrnRaiseTicket.select("rt_ticketno").where(["rt_compcode = ? AND rt_ticketno<>''", @compCodes]).order('rt_ticketno DESC').first
  if @recCodes
  @isCode    = @recCodes.rt_ticketno.to_i
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

end
