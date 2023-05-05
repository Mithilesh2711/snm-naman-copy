## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for designation
### FOR REST API ######
class EscalationMatrixController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
   def index
      @compCodes       = session[:loggedUserCompCode]
      @ListEscalationMatrices = get_escalation_matrix_list
      printcontroll    = "1_prt_excel_escalation_matrix_list"
      @printpath       = escalation_matrix_path(printcontroll,:format=>"pdf")
      printpdf         = "1_prt_pdf_escalation_matrix_list"
      @printpdfpath    = escalation_matrix_path(printpdf,:format=>"pdf")
      
      if params[:id] != nil && params[:id] != ''
            ids = params[:id].to_s.split("_")
            if ids[1] == 'prt' && ids[2] == 'excel'
                @ExcelList = print_excel_listed
                send_data @ExcelList.to_generate_escalation_matrix, :filename=> "escalation_matrix_list_#{Date.today}.csv"
                return
            elsif ids[1] == 'prt' && ids[2] == 'pdf'
                @rootUrl  = "#{root_url}"
                dataprint = print_excel_listed
                respond_to do |format|
                     format.html
                     format.pdf do
                        pdf = EscalationMatrixPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                        send_data pdf.render,:filename => "1_prt_escalation_matrix_report.pdf", :type => "application/pdf", :disposition => "inline"
                     end
                 end
            end
      end
 
   end
 
   def add_escalation_matrix
     @compCodes  =  session[:loggedUserCompCode]
     @lastcodes  =  generate_escalation_matrix_series
     @ListEscalationMatrix = nil
     if params[:id].to_i >0
         @ListEscalationMatrix  = MstEscalationMatrix.where("em_compcode = ? AND id = ?",@compCodes,params[:id]).first
     end
 
   end
 
   def create
   @compCodes  =  session[:loggedUserCompCode]
   isFlags     = true
   begin
   if params[:em_code] == '' || params[:em_code] == nil
      flash[:error] =  "EscalationMatrix code is required."
      isFlags = false
   elsif params[:em_name] == '' || params[:em_name] == nil
      flash[:error] =  "EscalationMatrix name is required."
      isFlags = false
 
   else
     curcode = params[:curemcode].to_s.strip
     codes    = params[:em_code].to_s.strip
     mid           = params[:mid]
     if mid.to_i >0
 
           if curcode.to_s.downcase != codes.to_s.downcase
               @chekCur   = MstEscalationMatrix.where("em_compcode = ? AND LOWER(em_code) = ?",@compCodes,codes.to_s.downcase)
               if @chekCur.length >0
                     flash[:error] = "This EscalationMatrix code is already taken!"
                     isFlags       = false
               end
 
           end
             if isFlags
                 chkobj   = MstEscalationMatrix.where("em_compcode = ? AND id = ?",@compCodes,mid).first
                 if chkobj
                   chkobj.update(em_params)
                       flash[:error] = "Data updated successfully"
                       isFlags       = true
                 end
             end
 
     else
               @chekCur   = MstEscalationMatrix.where("em_compcode = ? AND LOWER(em_code) = ?",@compCodes,codes.to_s.downcase)
               if @chekCur.length >0
                     flash[:error] = "This EscalationMatrix code is already taken!"
                     isFlags       = false
               end
              if isFlags
                    obj = MstEscalationMatrix.new(em_params)
                    if obj.save
                       flash[:error] = "Data saved successfully"
                       isFlags       = true
                    end
              end
     end
 
   end
 
   if !isFlags
     session[:isErrorhandled] = 1
     
   else
     session[:isErrorhandled] = nil
     session[:postedpamams]   = nil
     isFlags = true
   end
    rescue Exception => exc
        flash[:error] =  "ERROR: #{exc.message}"
        session[:isErrorhandled] = 1
      
        isFlags = false
    end
     if isFlags
       redirect_to  "#{root_url}escalation_matrix"
     else
       redirect_to  "#{root_url}escalation_matrix/add_escalation_matrix"
     end
   
 end
 
  def destroy
     @compcodes = session[:loggedUserCompCode]
     if params[:id].to_i >0
          @Obj =  MstEscalationMatrix.where("em_compcode =? AND id = ?",@compcodes,params[:id]).first
          if @Obj
 
            @Obj.destroy
            flash[:error] =  "Data deleted successfully."
            isFlags       = true
            session[:isErrorhandled] = nil
                  
          end
     end
     redirect_to "#{root_url}escalation_matrix"
  end
 
 
 private
 def em_params
     params[:em_compcode]         = session[:loggedUserCompCode]
     params[:em_code]         = params[:em_code] !=nil && params[:em_code] !='' ? params[:em_code].to_s.delete(' ').upcase : ''
     params[:em_name]   = params[:em_name]!=nil && params[:em_name] !='' ? params[:em_name].to_s.strip : ''
     params[:em_status]   = params[:em_status]!=nil && params[:em_status] !='' ? params[:em_status].to_s.strip : ''
     params.permit(:em_compcode,:em_code,:em_name,:em_status)
 end
 
 private
   def get_escalation_matrix_list
        if params[:page].to_i >0
          pages = params[:page]
       else
          pages = 1
       end
      if params[:requestserver] !=nil && params[:requestserver] != ''
         session[:req_search_design] = nil
      end
       search_escalation_matrix = params[:search_escalation_matrix] !=nil && params[:search_escalation_matrix] != '' ? params[:search_escalation_matrix].to_s.strip : session[:req_search_design]
       iswhere = "em_compcode ='#{@compCodes}'"
       if search_escalation_matrix !=nil && search_escalation_matrix !=''
         iswhere += " AND ( em_code LIKE '%#{search_escalation_matrix}%' OR  em_name LIKE '%#{search_escalation_matrix}%' ) "
         @search_escalation_matrix = search_escalation_matrix
         session[:req_search_design] = search_escalation_matrix
       end
       stsobj =  MstEscalationMatrix.where(iswhere).paginate(:page =>pages,:per_page => 10).order("em_name ASC")
       return stsobj
   end
 
   private
   def print_excel_listed
        search_escalation_matrix =  session[:req_search_design]
         iswhere = "em_compcode ='#{@compCodes}'"
         if search_escalation_matrix !=nil && search_escalation_matrix !=''
           iswhere += " AND ( em_code LIKE '%#{search_escalation_matrix}%' OR  em_name LIKE '%#{search_escalation_matrix}%' ) "
           @search_escalation_matrix = search_escalation_matrix
           session[:req_search_design] = search_escalation_matrix
         end
         stsobj =  MstEscalationMatrix.where(iswhere).order("em_name ASC")
         return stsobj
   end
   
  private
 def generate_escalation_matrix_series
   prefixobj    = get_common_prefix('EscalationMatrix')
   @Startx      = prefixobj ? prefixobj.sn_length : ''
   @isCode      = 0
   @recCodes    = MstEscalationMatrix.select("em_code").where(["em_compcode = ? AND em_code<>''", @compCodes]).last
   if @recCodes
      @isCode1    = @recCodes.em_code.to_s.gsub(/[^\d]/, '')
      @isCode     = @isCode1.to_i
 
   end
   @sumXOfCode    = @isCode.to_i + 1
   newlength      = @sumXOfCode.to_s.length
   genleth        = @Startx.to_i-newlength.to_i
   zeroseires     = serial_global_number(genleth)
   @sumXOfCode    = zeroseires.to_s+@sumXOfCode.to_s
   myprefix        = ""
   if prefixobj
       myprefix = prefixobj.sn_prefix
   end
   if myprefix !=nil && myprefix !=''
     myprefix = myprefix.to_s+@sumXOfCode.to_s
   else
     myprefix = @sumXOfCode
   end
   return myprefix
 
 end
   
 end
 