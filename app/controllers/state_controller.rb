class StateController < ApplicationController
   before_action :require_login
   before_action :allowed_security
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  def index
    @compcodes     = session[:loggedUserCompCode]
    @ListSates     = get_state_list
    printcontroll  = "1_prt_excel_state_list"
    @printpath     = state_path(printcontroll,:format=>"pdf")
    printpdf       = "1_prt_pdf_state_list"
    @printpdfpath  = state_path(printpdf,:format=>"pdf")
    
   if params[:id] != nil && params[:id] != ''
       ids = params[:id].to_s.split("_")
       if ids[1] == 'prt' && ids[2] == 'excel'
           @ExcelList = get_excel_list
           send_data @ExcelList.to_generate_sate, :filename=> "state_list-#{Date.today}.csv"
           return
       elsif ids[1] == 'prt' && ids[2] == 'pdf'
               @rootUrl  = "#{root_url}"
               dataprint = get_excel_list
               respond_to do |format|
                    format.html
                    format.pdf do
                       pdf = StatePdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                       send_data pdf.render,:filename => "1_prt_state_list_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                end
       end
   end

  end
  
  def create
     @compcodes = session[:loggedUserCompCode]
    isFlags    = true
    begin
        if params[:sts_code] == nil || params[:sts_code] == ''
           flash[:error] =  "State code is required."
           isFlags = false
        elsif   params[:sts_description] == nil || params[:sts_description] == ''
           flash[:error] =  "Description is required."
           isFlags = false
        else
            mid    = params[:mid]
            cstate = params[:cur_sts_code].to_s.strip
            state  = params[:sts_code].to_s.strip
            if mid.to_i >0
                  if cstate.to_s.downcase != state.to_s.downcase
                 
                       chkstate = MstState.where("sts_compcode =? AND sts_code = ?",@compcodes,state)
                       if chkstate.length >0
                            flash[:error] =  "Entered state code is already taken."
                            isFlags = false
                       end
                  end
                  if isFlags
                     stateupobj  = MstState.where("sts_compcode =? AND id = ?",@compcodes,mid).first
                      if stateupobj
                        stateupobj.update(state_params)
                           flash[:error] =  "Data updated successfully."
                            isFlags = true
                      end
                  end
            else
                      chkstate = MstState.where("sts_compcode =? AND sts_code = ?",@compcodes,state)
                       if chkstate.length >0
                            flash[:error] =  "Entered State Code is already taken."
                            isFlags = false
                       end
                       if isFlags
                            stsobj = MstState.new(state_params)
                            if stsobj.save
                               flash[:error] =  "Data saved successfully."
                               isFlags = true
                            end

                       end
            end
        end
          rescue Exception => exc
          flash[:error] =   "#{exc.message}"
          session[:isErrorhandled] = 1
          isFlags = false
      end

     if !isFlags
         session[:request_params] = params
         session[:isErrorhandled] = 1
         isFlags = false
     else
         session[:request_params] = nil
         session[:isErrorhandled] = nil
         session.delete(:request_params)
     end
     if isFlags
       redirect_to "#{root_url}"+"state"
     else
       redirect_to "#{root_url}"+"state/add_state"
     end
      
  end
  
  def add_state
    @compcodes = session[:loggedUserCompCode]
    @ListSate  = nil
    if params[:id].to_i >0
         @ListSate =  MstState.where("sts_compcode =? AND id = ?",@compcodes,params[:id]).first
        
    end
    
  end
  
 def destroy
    @compcodes = session[:loggedUserCompCode]
   if params[:id].to_i >0

         @ListSate =  MstState.where("sts_compcode =? AND id = ?",@compcodes,params[:id]).first
         if @ListSate
             stscode       = @ListSate.sts_code
             @destobj      =  MstDistrict.where("dts_compcode =? AND dts_statecode = ?",@compcodes,stscode)
             if @destobj.length >0
                  flash[:error] =  "Sorry!! Unable to deleted this due to used in district."
                  isFlags       = false
                  session[:isErrorhandled] = 1
             else
                  @ListSate.destroy
                  flash[:error] =  "Data deleted successfully."
                  isFlags = true
                  session[:isErrorhandled] = nil
             end
         end
    end
    redirect_to "#{root_url}state"
 end
 
  private
  def state_params
    params[:sts_compcode]         =  session[:loggedUserCompCode]
    params[:sts_welfare]          = params[:sts_welfare] !=nil && params[:sts_welfare] !='' ? params[:sts_welfare] : 0
    params[:sts_welfare_employer] = params[:sts_welfare_employer] !=nil && params[:sts_welfare_employer] !='' ? params[:sts_welfare_employer] : 0
    params.permit(:sts_compcode,:sts_code,:sts_description,:sts_welfare,:sts_welfare_employer)
  end

  private
  def get_state_list
      if params[:page].to_i >0
      pages = params[:page]
      else
      pages = 1
      end
      stsobj =  MstState.where("sts_compcode =?",@compcodes).paginate(:page =>pages,:per_page => 10).order("sts_description ASC")
      return stsobj
  end

  private
  def get_excel_list
       stsobj =  MstState.where("sts_compcode =?",@compcodes).order("sts_description ASC")
      return stsobj
  end
  
end
