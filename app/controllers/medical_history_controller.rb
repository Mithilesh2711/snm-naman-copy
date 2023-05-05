## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process medical history master

class MedicalHistoryController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted
  def index
     @compCodes  =  session[:loggedUserCompCode]
     printcontroll   = "1_prt_excel_medicalhistory_list"
     @printpath      = medical_history_path(printcontroll,:format=>"pdf")
     printpdf        = "1_prt_pdf_medicalhistory_list"
     @printpdfpath   = medical_history_path(printpdf,:format=>"pdf")
     @medicalListed   = get_medicalhst_list
     if params[:id] != nil && params[:id] != ''
           ids = params[:id].to_s.split("_")
           if ids[1] == 'prt' && ids[2] == 'excel'
               @ExcelList = print_excel_listed
               send_data @ExcelList.to_generate_medicalhistory, :filename=> "medical_list_#{Date.today}.csv"
               return
           elsif ids[1] == 'prt' && ids[2] == 'pdf'

              @rootUrl = "#{root_url}"
               dataprint = print_excel_listed
               respond_to do |format|
                    format.html
                    format.pdf do
                       pdf = MedicalhistoryPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                       send_data pdf.render,:filename => "1_prt_medical_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                end
           end
     end
  end
  def medical_list
      @compCodes     =  session[:loggedUserCompCode]
     @Lastcode       =  generate_medical_series
     @ListMedical    = nil
      if params[:id].to_i >0
          @ListMedical  = MstMedicalHistory.where("mh_compcode = ? AND id = ?",@compCodes,params[:id]).first
      end
  end
  def create
  @compCodes  =  session[:loggedUserCompCode]
  isFlags     = true
  begin
  if params[:mh_other] == '' || params[:mh_other] == nil
     flash[:error] =  "other is required!"
     isFlags = false
  elsif params[:mh_answertype] == '' || params[:mh_answertype] == nil
     flash[:error] =  "Answer type is required"
     isFlags = false

  else

#    curbank      = params[:cur_bank].to_s.strip
#    bank         = params[:bl_name].to_s.strip
    mid          = params[:mid]
    if mid.to_i >0

         
            if isFlags
                chkdeprtobj   = MstMedicalHistory.where("mh_compcode = ? AND id = ?",@compCodes,mid).first
                if chkdeprtobj
                  chkdeprtobj.update(medical_params)
                      flash[:error] = "Data updated successfully"
                      isFlags       = true
                end
            end

    else
             
            if isFlags
                deprtsvobj = MstMedicalHistory.new(medical_params)
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
     redirect_to  "#{root_url}medical_history"
   else
     redirect_to  "#{root_url}medical_history/medical_list"
   end

end

 def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         @ListSate =  MstMedicalHistory.where("mh_compcode =? AND id = ?",@compcodes,params[:id]).first
         if @ListSate
                 @ListSate.destroy
                 flash[:error] =  "Data deleted successfully."
                 isFlags       =  true
                 session[:isErrorhandled] = nil
         end
    end
    redirect_to "#{root_url}medical_history"
 end


private
def medical_params
    params[:mh_compcode]          = session[:loggedUserCompCode]
    params[:mh_code]              = params[:mh_code] !=nil && params[:mh_code] !='' ? params[:mh_code].to_s.strip : ''
    params[:mh_other]             = params[:mh_other]!=nil && params[:mh_other] !='' ? params[:mh_other].to_s.strip : ''
    params[:mh_answertype]        = params[:mh_answertype]!=nil && params[:mh_answertype] !='' ? params[:mh_answertype].to_s.strip : ''
    params[:mh_description]       = params[:mh_description]!=nil && params[:mh_description] !='' ? params[:mh_description].to_s.strip : ''
    params.permit(:mh_compcode,:mh_code,:mh_other,:mh_answertype,:mh_description)
end

private
  def get_medicalhst_list
       if params[:page].to_i >0
         pages = params[:page]
      else
         pages = 1
      end
     if params[:requestserver] !=nil && params[:requestserver] != ''
        session[:req_search_bank] = nil
     end
      search_bank = params[:search_bank] !=nil && params[:search_bank] != '' ? params[:search_bank].to_s.strip : session[:req_search_bank]
      iswhere = "mh_compcode ='#{@compCodes}'"
      if search_bank !=nil && search_bank !=''
#          iswhere += " AND bl_name LIKE '%#{search_bank}%'"
#          @search_bank              = search_bank
#          session[:req_search_bank] = search_bank
      end
      stsobj =  MstMedicalHistory.where(iswhere).paginate(:page =>pages,:per_page => 10).order("mh_other ASC,mh_description ASC")
      return stsobj
  end

  private
  def print_excel_listed
      search_bank =  session[:req_search_bank]
      iswhere = "mh_compcode ='#{@compCodes}'"
      if search_bank !=nil && search_bank !=''
        #  iswhere += " AND bl_name LIKE '%#{search_bank}%'"
      end
      stsobj =  MstMedicalHistory.where(iswhere).order("mh_other ASC,mh_description ASC")
      return stsobj
  end


 private
def generate_medical_series
  prefixobj    = get_common_prefix('Bank')
  @Startx      = prefixobj ? prefixobj.sn_length : ''
  @isCode      = 0
  @recCodes    = MstBankList.select("bl_code").where(["bl_compcode = ? AND bl_code<>''", @compCodes]).last
  if @recCodes
     @isCode1    = @recCodes.bl_code.to_s.gsub(/[^\d]/, '')
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
end
