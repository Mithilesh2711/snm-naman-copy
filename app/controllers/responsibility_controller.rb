class ResponsibilityController < ApplicationController
   before_action :require_login
   before_action :allowed_security
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
  def index
     @compCodes       = session[:loggedUserCompCode]
     @ListResponsib   = get_responsib_list
     printcontroll    = "1_prt_excel_responsibility_list"
     @printpath       = responsibility_path(printcontroll,:format=>"pdf")
     printpdf         = "1_prt_pdf_responsibility_list"
     @printpdfpath    = responsibility_path(printpdf,:format=>"pdf")

     if params[:id] != nil && params[:id] != ''
           ids = params[:id].to_s.split("_")
           if ids[1] == 'prt' && ids[2] == 'excel'
               @ExcelList = print_excel_listed
               send_data @ExcelList.to_generate_responsib, :filename=> "responsibility_list_#{Date.today}.csv"
               return
           elsif ids[1] == 'prt' && ids[2] == 'pdf'
               @rootUrl  = "#{root_url}"
               dataprint = print_excel_listed
               respond_to do |format|
                    format.html
                    format.pdf do
                       pdf = ResponsibilityPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                       send_data pdf.render,:filename => "1_prt_responsibility_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                end
           end
     end

  end

  def add_responsibility
    @compCodes  =  session[:loggedUserCompCode]
    @lastcodes  =  generate_responsibility_series
    @ListRespns = nil
    if params[:id].to_i >0
        @ListRespns  = MstResponsibility.where("rsp_compcode = ? AND id = ?",@compCodes,params[:id]).first
    end

  end

  def create
  @compCodes  =  session[:loggedUserCompCode]
  isFlags     = true
  begin
  if params[:rsp_rspcode] == '' || params[:rsp_rspcode] == nil
     flash[:error] =  "Responsibilty code is required."
     isFlags = false
  elsif params[:rsp_description] == '' || params[:rsp_description] == nil
     flash[:error] =  "Description is required."
     isFlags = false

  else

    curdcode = params[:curdesicode].to_s.strip
    codes    = params[:desicode].to_s.strip
    mid           = params[:mid]
    if mid.to_i >0

          if curdcode.to_s.downcase != codes.to_s.downcase
              @chekDepart   = MstResponsibility.where("rsp_compcode = ? AND LOWER(rsp_rspcode) = ?",@compCodes,codes.to_s.downcase)
              if @chekDepart.length >0
                    flash[:error] = "This responsibility code is already taken!"
                    isFlags       = false
              end

          end
            if isFlags
                chkdeprtobj   = MstResponsibility.where("rsp_compcode = ? AND id = ?",@compCodes,mid).first
                if chkdeprtobj
                  chkdeprtobj.update(responsibility_params)
                      flash[:error] = "Data updated successfully"
                      isFlags       = true
                end
            end

    else
              @chekDepart   = MstResponsibility.where("rsp_compcode = ? AND LOWER(rsp_rspcode) = ?",@compCodes,codes.to_s.downcase)
              if @chekDepart.length >0
                    flash[:error] = "This responsibility code is already taken!"
                    isFlags       = false
              end
             if isFlags
                   deprtsvobj = MstResponsibility.new(responsibility_params)
                   if deprtsvobj.save
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
      redirect_to  "#{root_url}responsibility"
    else
      redirect_to  "#{root_url}responsibility/add_responsibility"
    end

end

 def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         @ListSate =  MstResponsibility.where("rsp_compcode =? AND id = ?",@compcodes,params[:id]).first
         if @ListSate

             chkoobj = check_existing_respon(@compcodes,@ListSate.rsp_rspcode)
              if chkoobj
                     flash[:error] =  "Sorry !! Data could not be deleted due to somewhere used."
                     isFlags       =  true
                     session[:isErrorhandled] = 1
              else
                   @ListSate.destroy
                   flash[:error] =  "Data deleted successfully."
                   isFlags       =  true
                   session[:isErrorhandled] = nil

              end
                
         end
    end
    redirect_to "#{root_url}responsibility"
 end


private
def responsibility_params
    params[:rsp_compcode]        = session[:loggedUserCompCode]
    params[:rsp_rspcode]         = params[:rsp_rspcode] !=nil && params[:rsp_rspcode] !='' ? params[:rsp_rspcode].to_s.delete(' ').upcase : ''
    params[:rsp_description]     = params[:rsp_description]!=nil && params[:rsp_description] !='' ? params[:rsp_description].to_s.strip : ''
    params.permit(:rsp_compcode,:rsp_rspcode,:rsp_description)
end

private
  def get_responsib_list
       if params[:page].to_i >0
         pages = params[:page]
      else
         pages = 1
      end
     if params[:requestserver] !=nil && params[:requestserver] != ''
        session[:req_search_responsibility] = nil
     end
      search_departcode = params[:search_departcode] !=nil && params[:search_departcode] != '' ? params[:search_departcode].to_s.strip : session[:req_search_responsibility]
      iswhere = "rsp_compcode ='#{@compCodes}'"
      if search_departcode !=nil && search_departcode !=''
        iswhere += " AND ( rsp_rspcode LIKE '%#{search_departcode}%' OR rsp_description LIKE '%#{search_departcode}%' ) "
        @search_departcode = search_departcode
        session[:req_search_responsibility] = search_departcode
      end
      stsobj =  MstResponsibility.where(iswhere).paginate(:page =>pages,:per_page => 10).order("rsp_description ASC")
      return stsobj
  end

  private
  def print_excel_listed
        search_departcode =  session[:req_search_responsibility]
        iswhere = "rsp_compcode ='#{@compCodes}'"
        if search_departcode !=nil && search_departcode !=''
          iswhere += " AND ( rsp_rspcode LIKE '%#{search_departcode}%' OR rsp_description LIKE '%#{search_departcode}%' ) "
          
        end
        stsobj =  MstResponsibility.where(iswhere).order("rsp_description ASC")
        return stsobj
  end

 private
def generate_responsibility_series
  prefixobj    = get_common_prefix('Responsibility')
  @Startx      = prefixobj ? prefixobj.sn_length : ''
  @isCode      = 0
  @recCodes    = MstResponsibility.select("rsp_rspcode").where(["rsp_compcode = ? AND rsp_rspcode<>''", @compCodes]).last
  if @recCodes
     @isCode1    = @recCodes.rsp_rspcode.to_s.gsub(/[^\d]/, '')
     @isCode     = @isCode1.to_i

  end
  @sumXOfCode    = @isCode.to_i + 1
  newlength      = @sumXOfCode.to_s.length
  genleth        = @Startx.to_i-newlength.to_i
  zeroseires     = serial_global_number(genleth)
  @sumXOfCode    = zeroseires.to_s+@sumXOfCode.to_s  
  myprefix  = ""
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
  private
  def check_existing_respon(compcodes,dptcodes)
     istruefalse = false
      sewobj     = MstSewadarOfficeInfo.select("so_compcode").where("so_compcode = ? AND so_respcode =?",compcodes,dptcodes)
       if sewobj.length >0
         istruefalse = true
       end
       return istruefalse
  end

end
