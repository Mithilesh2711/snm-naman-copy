## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for designation
### FOR REST API ######
class CourierController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
   def index
      @compCodes       = session[:loggedUserCompCode]
      @ListCouriers = get_courier_list
      printcontroll    = "1_prt_excel_courier_list"
      @printpath       = courier_path(printcontroll,:format=>"pdf")
      printpdf         = "1_prt_pdf_courier_list"
      @printpdfpath    = courier_path(printpdf,:format=>"pdf")
      
      if params[:id] != nil && params[:id] != ''
            ids = params[:id].to_s.split("_")
            if ids[1] == 'prt' && ids[2] == 'excel'
                @ExcelList = print_excel_listed
                send_data @ExcelList.to_generate_courier, :filename=> "courier_list_#{Date.today}.csv"
                return
            elsif ids[1] == 'prt' && ids[2] == 'pdf'
                @rootUrl  = "#{root_url}"
                dataprint = print_excel_listed
                respond_to do |format|
                     format.html
                     format.pdf do
                        pdf = CourierPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                        send_data pdf.render,:filename => "1_prt_courier_report.pdf", :type => "application/pdf", :disposition => "inline"
                     end
                 end
            end
      end
 
   end
 
   def add_courier
     @compCodes  =  session[:loggedUserCompCode]
     @lastcodes  =  generate_courier_series
     @ListCourier = nil
     if params[:id].to_i >0
         @ListCourier  = MstCourier.where("cr_compcode = ? AND id = ?",@compCodes,params[:id]).first
     end
 
   end
 
   def create
   @compCodes  =  session[:loggedUserCompCode]
   isFlags     = true
   begin
   if params[:cr_code] == '' || params[:cr_code] == nil
      flash[:error] =  "Courier code is required."
      isFlags = false
   elsif params[:cr_name] == '' || params[:cr_name] == nil
      flash[:error] =  "Courier name is required."
      isFlags = false
 
   else
     curcode = params[:curcrcode].to_s.strip
     codes    = params[:cr_code].to_s.strip
     mid           = params[:mid]
     if mid.to_i >0
 
           if curcode.to_s.downcase != codes.to_s.downcase
               @chekCur   = MstCourier.where("cr_compcode = ? AND LOWER(cr_code) = ?",@compCodes,codes.to_s.downcase)
               if @chekCur.length >0
                     flash[:error] = "This courier code is already taken!"
                     isFlags       = false
               end
 
           end
             if isFlags
                 chkobj   = MstCourier.where("cr_compcode = ? AND id = ?",@compCodes,mid).first
                 if chkobj
                   chkobj.update(cr_params)
                       flash[:error] = "Data updated successfully"
                       isFlags       = true
                 end
             end
 
     else
               @chekCur   = MstCourier.where("cr_compcode = ? AND LOWER(cr_code) = ?",@compCodes,codes.to_s.downcase)
               if @chekCur.length >0
                     flash[:error] = "This courier code is already taken!"
                     isFlags       = false
               end
              if isFlags
                    obj = MstCourier.new(cr_params)
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
       redirect_to  "#{root_url}courier"
     else
       redirect_to  "#{root_url}courier/add_courier"
     end
   
 end
 
  def destroy
     @compcodes = session[:loggedUserCompCode]
     if params[:id].to_i >0
          @Cur =  MstCourier.where("cr_compcode =? AND id = ?",@compcodes,params[:id]).first
          if @Cur

            @Cur.destroy
            flash[:error] =  "Data deleted successfully."
            isFlags       = true
            session[:isErrorhandled] = nil
                  
          end
     end
     redirect_to "#{root_url}courier"
  end
 
 
 private
 def cr_params
     params[:cr_compcode]         = session[:loggedUserCompCode]
     params[:cr_code]         = params[:cr_code] !=nil && params[:cr_code] !='' ? params[:cr_code].to_s.delete(' ').upcase : ''
     params[:cr_name]   = params[:cr_name]!=nil && params[:cr_name] !='' ? params[:cr_name].to_s.strip : ''
     params[:cr_status]   = params[:cr_status]!=nil && params[:cr_status] !='' ? params[:cr_status].to_s.strip : ''
     params.permit(:cr_compcode,:cr_code,:cr_name,:cr_status)
 end
 
 private
   def get_courier_list
        if params[:page].to_i >0
          pages = params[:page]
       else
          pages = 1
       end
      if params[:requestserver] !=nil && params[:requestserver] != ''
         session[:req_search_design] = nil
      end
       search_courier = params[:search_courier] !=nil && params[:search_courier] != '' ? params[:search_courier].to_s.strip : session[:req_search_design]
       iswhere = "cr_compcode ='#{@compCodes}'"
       if search_courier !=nil && search_courier !=''
         iswhere += " AND ( cr_code LIKE '%#{search_courier}%' OR  cr_name LIKE '%#{search_courier}%' ) "
         @search_courier = search_courier
         session[:req_search_design] = search_courier
       end
       stsobj =  MstCourier.where(iswhere).paginate(:page =>pages,:per_page => 10).order("cr_name ASC")
       return stsobj
   end
 
   private
   def print_excel_listed
        search_courier =  session[:req_search_design]
         iswhere = "cr_compcode ='#{@compCodes}'"
         if search_courier !=nil && search_courier !=''
           iswhere += " AND ( cr_code LIKE '%#{search_courier}%' OR  cr_name LIKE '%#{search_courier}%' ) "
           @search_courier = search_courier
           session[:req_search_design] = search_courier
         end
         stsobj =  MstCourier.where(iswhere).order("cr_name ASC")
         return stsobj
   end
   
  private
 def generate_courier_series
   prefixobj    = get_common_prefix('Courier')
   @Startx      = prefixobj ? prefixobj.sn_length : ''
   @isCode      = 0
   @recCodes    = MstCourier.select("cr_code").where(["cr_compcode = ? AND cr_code<>''", @compCodes]).last
   if @recCodes
      @isCode1    = @recCodes.cr_code.to_s.gsub(/[^\d]/, '')
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
 