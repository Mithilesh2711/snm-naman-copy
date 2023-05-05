class AssignTicketIssueController < ApplicationController
   before_action :require_login
   before_action :allowed_security
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
   include ErpModule::Common
   helper_method :get_sel_brand,:currency_formatted,:year_month_days_formatted,:formatted_date,:set_ent,:set_dct
   helper_method :user_detail,:get_mysewdar_list_details,:format_oblig_date

  def index
     @compCodes     = session[:loggedUserCompCode]
     @ListDepart    = Department.where("compCode = ? ",@compCodes).order("departDescription ASC")
     @TicketsListed = get_ticket_list

  end



def create

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
        session[:reqsa_ticket_number]     = nil
        session[:ticketsa_department]     = nil
        session[:reqsa_ticket_status]     = nil
        session[:reqsa_ticket_from_date]  = nil
        session[:reqsa_ticket_upto_dated] = nil
     end
          ticket_number     = params[:ticket_number] !=nil && params[:ticket_number] != '' ? params[:ticket_number].to_s.strip : session[:reqsa_ticket_number]
          ticket_department = params[:ticket_department] !=nil && params[:ticket_department] != '' ? params[:ticket_department].to_s.strip : session[:ticketsa_department]
          ticket_status     = params[:ticket_status] !=nil && params[:ticket_status] != '' ? params[:ticket_status].to_s.strip : session[:reqsa_ticket_status]

          from_date         = params[:from_date] !=nil && params[:from_date] != '' ? params[:from_date].to_s.strip : session[:reqsa_ticket_from_date]
          upto_date         = params[:upto_dated] !=nil && params[:upto_dated] != '' ? params[:upto_dated].to_s.strip : session[:reqsa_ticket_upto_dated]

      iswhere = "rt_compcode ='#{@compCodes}' AND rt_assignedsewacode ='#{sewacode}'"
      iswhere += " AND rt_status = '#{ticket_status}'"
      @ticket_status                = ticket_status
      session[:reqsa_ticket_status] = ticket_status
      
      if ticket_number !=nil && ticket_number !=''
          iswhere += " AND rt_ticketno LIKE '%#{ticket_number}%'"
          @ticket_number              = ticket_number
          session[:reqsa_ticket_number] = ticket_number
      end
      if ticket_department !=nil && ticket_department !=''
          iswhere += " AND rt_department='#{ticket_department}'"
          @ticket_department              = ticket_department
           session[:ticketsa_department]    = ticket_department
      end    
            
     
      if from_date !=nil && from_date !=''
            iswhere += " AND rt_ticketdate >= '#{year_month_days_formatted(from_date)}'"
            @from_dated                    = from_date
            session[:reqsa_ticket_from_date] = from_date
      end
      if upto_date !=nil && upto_date !=''
            iswhere += " AND rt_ticketdate <= '#{year_month_days_formatted(upto_date)}'"
            @upto_dated                     = upto_date
            session[:reqsa_ticket_upto_dated] = upto_date
      end
      stsobj =  TrnRaiseTicket.where(iswhere).paginate(:page =>pages,:per_page => 20).order("rt_ticketno ASC")
      return stsobj

  end
end
