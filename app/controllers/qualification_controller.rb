## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for generate tickets
### FOR REST API ######
class QualificationController < ApplicationController
   before_action :require_login
   before_action :allowed_security
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]

  def index
     @compCodes        = session[:loggedUserCompCode]
     @ListQualifcation = get_qualification_list
     printcontroll     = "1_prt_excel_qualification_list"
     @printpath        = qualification_path(printcontroll,:format=>"pdf")
     printpdf          = "1_prt_pdf_qualification_list"
     @printpdfpath     = qualification_path(printpdf,:format=>"pdf")
     if params[:id] != nil && params[:id] != ''
           ids = params[:id].to_s.split("_")
           if ids[1] == 'prt' && ids[2] == 'excel'
            
               @ExcelList = print_excel_listed
               send_data @ExcelList.to_generate_qualification, :filename=> "qualification_list_#{Date.today}.csv"
               return
           elsif ids[1] == 'prt' && ids[2] == 'pdf'
             
              @rootUrl = "#{root_url}"
               dataprint = print_excel_listed
               respond_to do |format|
                    format.html
                    format.pdf do
                       pdf = QualificationPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                       send_data pdf.render,:filename => "1_prt_qualification_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                end
           end
     end

  end

  def add_qualification
    @compCodes   =  session[:loggedUserCompCode]
    @lastcodes   = generate_qualification_series
    @ListQualifc =  nil
    if params[:id].to_i >0
        @ListQualifc  = MstQualification.where("ql_compcode = ? AND id = ?",@compCodes,params[:id]).first
    end

  end

  def create
  @compCodes  =  session[:loggedUserCompCode]
  isFlags     = true
  begin
  if params[:ql_qualifcode] == '' || params[:ql_qualifcode] == nil
     flash[:error] =  "Qualification code is required."
     isFlags = false
  elsif params[:ql_qualification] == '' || params[:ql_qualification] == nil
     flash[:error] =  "Qualification is required."
     isFlags = false

  else

    curdcode          = params[:cur_qualif_code].to_s.strip
    codes             = params[:ql_qualifcode].to_s.strip
    mid               = params[:mid]
    qualification     = params[:ql_qualification].to_s.strip
    qualdescription   = params[:ql_qualdescription].to_s.strip
    cqualification    = params[:cqualification].to_s.strip
    cqualdescription  = params[:cqualdescription].to_s.strip
    
    if mid.to_i >0

          if cqualification.to_s.downcase!=cqualification.to_s.downcase && qualdescription.to_s.downcase !=cqualdescription.to_s.downcase
              @chekDepart   = MstQualification.where("ql_compcode = ? AND LOWER(ql_qualification) = ? AND LOWER(ql_qualdescription)=?",@compCodes,qualification.to_s.downcase,qualdescription.to_s.downcase)
              if @chekDepart.length >0
                    flash[:error] = "This qualification is already taken!"
                    isFlags       = false
              end

          end
            if isFlags
                chkdeprtobj   = MstQualification.where("ql_compcode = ? AND id = ?",@compCodes,mid).first
                if chkdeprtobj
                  chkdeprtobj.update(qualific_params)
                      flash[:error] = "Data updated successfully"
                      isFlags       = true
                end
            end

    else
             @chekDepart   = MstQualification.where("ql_compcode = ? AND LOWER(ql_qualification) = ? AND LOWER(ql_qualdescription)=?",@compCodes,qualification.to_s.downcase,qualdescription.to_s.downcase)
              if @chekDepart.length >0
                    flash[:error] = "This qualification is already taken!"
                    isFlags       = false
              end
             if isFlags
                   deprtsvobj = MstQualification.new(qualific_params)
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
      redirect_to  "#{root_url}qualification"
    else
      redirect_to  "#{root_url}qualification/add_qualification"
    end

end

 def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         @ListQualif =  MstQualification.where("ql_compcode =? AND id = ?",@compcodes,params[:id]).first
         if @ListQualif

             listobj = check_existing_qulif(@compcodes,@ListQualif.ql_qualifcode)
             if listobj
                 flash[:error] =  "Sorry !! Data could not be deleted due to somewhere used."
                 isFlags       =  true
                 session[:isErrorhandled] = 1
             else
                 @ListQualif.destroy
                 flash[:error] =  "Data deleted successfully."
                 isFlags       =  true
                 session[:isErrorhandled] = nil
             end
            
         end
    end
    redirect_to "#{root_url}qualification"
 end


private
def qualific_params
    params[:ql_compcode]         = session[:loggedUserCompCode]
    params[:ql_qualifcode]       = params[:ql_qualifcode] !=nil && params[:ql_qualifcode] !='' ? params[:ql_qualifcode].to_s.delete(' ').upcase : ''
    params[:ql_qualdescription]  = params[:ql_qualdescription]!=nil && params[:ql_qualdescription] !='' ? params[:ql_qualdescription].to_s.strip : ''
    params[:ql_duration]         = params[:ql_duration] !=nil && params[:ql_duration] !='' ?  params[:ql_duration] : 0
    params.permit(:ql_compcode,:ql_qualifcode,:ql_qualdescription,:ql_type,:ql_qualification,:ql_duration,:ql_isprofessional,:ql_isinternational)
end

private
  def get_qualification_list
       if params[:page].to_i >0
         pages = params[:page]
      else
         pages = 1
      end
     if params[:requestserver] !=nil && params[:requestserver] != ''
        session[:req_search_qualific] = nil
     end
      search_departcode = params[:search_departcode] !=nil && params[:search_departcode] != '' ? params[:search_departcode].to_s.strip : session[:req_search_qualific]
      iswhere = "ql_compcode ='#{@compCodes}'"
      if search_departcode !=nil && search_departcode !=''
        iswhere += " AND ( ql_qualifcode LIKE '%#{search_departcode}%' OR  ql_qualdescription LIKE '%#{search_departcode}%' OR ql_qualification LIKE '%#{search_departcode}%') "
        @search_departcode          = search_departcode
        session[:req_search_qualific] = search_departcode
      end
      stsobj =  MstQualification.where(iswhere).paginate(:page =>pages,:per_page => 10).order("ql_qualification ASC,ql_qualdescription ASC")
      return stsobj
  end

  private
  def print_excel_listed
        search_departcode =  session[:req_search_qualific]
        iswhere = "ql_compcode ='#{@compCodes}'"
        if search_departcode !=nil && search_departcode !=''
          iswhere += " AND ( ql_qualifcode LIKE '%#{search_departcode}%' OR  ql_qualdescription LIKE '%#{search_departcode}%' OR ql_qualification LIKE '%#{search_departcode}%') "
          @search_departcode          = search_departcode
          session[:req_search_design] = search_departcode
        end
        stsobj =  MstQualification.where(iswhere).order("ql_qualification ASC,ql_qualdescription ASC")
        return stsobj
  end

  private
def generate_qualification_series
  prefixobj    = get_common_prefix('Qualification')
  @Startx      = prefixobj ? prefixobj.sn_length : ''
  @isCode      = 0
  @recCodes    = MstQualification.select("ql_qualifcode").where(["ql_compcode = ? AND ql_qualifcode<>''", @compCodes]).last
  if @recCodes
     @isCode1    = @recCodes.ql_qualifcode.to_s.gsub(/[^\d]/, '')
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
  def check_existing_qulif(compcodes,dptcodes)
     istruefalse = false
      sewobj     = MstSewadarOfficeInfo.select("so_compcode").where("so_compcode = ? AND so_qualifcode =?",compcodes,dptcodes)
       if sewobj.length >0
         istruefalse = true
       end
       return istruefalse
  end

end
