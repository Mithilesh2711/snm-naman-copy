class HolidayController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_emp_attached_file,:get_employee_types,:format_oblig_date
  def index
        @authorizedId  =   session[:autherizedUserId]
        @compCodes     =   session[:loggedUserCompCode]
          if params[:page].to_i >0
            pages = params[:page]
          else
             pages = 1
          end
         iswheres      =  "compCode ='#{@compCodes}'"
        if params[:year_filter] !=nil && params[:year_filter] !=''
          iswheres += " AND YEAR(dateYear) = '#{params[:year_filter]}'"
          @year_filter = params[:year_filter]
        end
        @Holiday       =   Holiday.where(iswheres).paginate(:page =>pages,:per_page => 10).order("dateYear ASC")
        if @Holiday.length >0
             @printControll = "1_"+@compCode.to_s+"_holiday"+"_"+"#{Time.now}"
        else
             @printControll = ''
        end
         

  end

 def add_holiday
    @compCodes     =   session[:loggedUserCompCode]
  @selecHoliday = nil
    if params[:id].to_i >0
        @selecHoliday  =   Holiday.where("compCode = ? AND id = ?",@compCodes,params[:id].to_i).first
    end

end



def destroy
 isFlags = false
 begin
  @Holiday = Holiday.find(params[:id])
  if @Holiday.destroy
     flash[:error] =  "Data deleted successfully!!"
     isFlags = true
  end
 ############# THREAD MESSAGE & HANDLING ##########
  if !isFlags
    session[:isErrorhandled] = 1
    session[:postedpamams]   = params
  else
    session[:isErrorhandled] = nil
    session[:postedpamams]   = nil
    isFlags = true
  end
 rescue Exception => exc
     flash[:error] =  "ERROR: #{exc.message}"
     session[:isErrorhandled] = 1
     session[:postedpamams]   = params
     isFlags = false
 end
 ############# END THREAD MESSAGE & HANDLING ##########
redirect_to :action=>:index
end

def create
  isFlags = true
  @authorizedId       =   session[:autherizedUserId]
  @compcodes          =   session[:loggedUserCompCode]
  begin
  if params[:dateYear] == '' || params[:dateYear] == nil
     flash[:error] =  "Please enter date!"
     isFlags = false
  elsif params[:description] == '' || params[:description] == nil
     flash[:error] =  "Please enter description!"
     isFlags = false
  elsif  @compcodes == '' || @compcodes == nil
     flash[:error] =  "Undefine company code!"
     isFlags = false
  else
      params[:compCode] = @compcodes
      dateyear          = params[:dateYear].to_s.strip !=nil && params[:dateYear].to_s.strip != '' ?  year_month_days_formatted(params[:dateYear]).to_s.strip : ''
      currdates         = params[:curdateyear].to_s.strip
      mid               = params[:mid]
      if mid.to_i >0
           if currdates !=nil && currdates !='' && dateyear !=nil && dateyear !='' && currdates != dateyear
                checkobj          = Holiday.where("compCode =? AND dateYear =?",@compcodes,dateyear)
                if checkobj.length >0
                     flash[:error] =  " This date ( #{formatted_date(dateyear)} ) holiday is already added ."
                     isFlags = false
                end
           end
            if isFlags
                 suobjups          = Holiday.where("compCode =? AND id =?",@compcodes,mid).first
                 if suobjups
                    suobjups.update(holiday_params)
                     flash[:error] =  "Data updated successfully!!"
                     isFlags = true
                 end
            end
      else
             checkobj          = Holiday.where("compCode =? AND dateYear =?",@compcodes,dateyear)
              if checkobj.length >0
                   flash[:error] =  " This date ( #{formatted_date(dateyear)} ) holiday is already added ."
                   isFlags = false
              end
               if isFlags
                     @Holiday = Holiday.new(holiday_params)
                     if @Holiday.save
                          flash[:error] =  "Data saved successfully!!"
                          isFlags = true
                     end
               end
      end
  end
  ############# THREAD MESSAGE & HANDLING ##########
  
   rescue Exception => exc
       flash[:error] =  "ERROR: #{exc.message}"
       session[:isErrorhandled] = 1
       session[:postedpamams]   = params
       isFlags = false
   end
   if !isFlags
    session[:isErrorhandled] = 1
    session[:postedpamams]   = params
  else
    session[:isErrorhandled] = nil
    session[:postedpamams]   = nil
    isFlags = true
  end
 ############# END THREAD MESSAGE & HANDLING ##########
 if !isFlags
   redirect_to  "#{root_url}/holiday/add_holiday/"+params[:mid].to_s
 else
   redirect_to  "#{root_url}/holiday"
 end
  
end

private
def holiday_params
  if params[:holidaytype]!=nil
    params[:holidaytype] = params[:holidaytype].upcase
  end
  dt = 0
  if params[:dateYear]!=nil && params[:dateYear] !=''
    dt = year_month_days_formatted(params[:dateYear])
  end
  params[:dateYear] = dt
  params.permit(:dateYear,:compCode,:description,:holidaytype)
end

end
