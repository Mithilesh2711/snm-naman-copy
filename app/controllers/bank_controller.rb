## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process banking master
### FOR REST API ######
class BankController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted
  def index
    @compCodes  =  session[:loggedUserCompCode]
     printcontroll   = "1_prt_excel_bank_list"
     @printpath      = bank_path(printcontroll,:format=>"pdf")
     printpdf        = "1_prt_pdf_bank_list"
     @printpdfpath  = bank_path(printpdf,:format=>"pdf")
     @bankListed   = get_bank_list
     if params[:id] != nil && params[:id] != ''
           ids = params[:id].to_s.split("_")
           if ids[1] == 'prt' && ids[2] == 'excel'
               @ExcelList = print_excel_listed
               send_data @ExcelList.to_generate_bank, :filename=> "bank_list_#{Date.today}.csv"
               return
           elsif ids[1] == 'prt' && ids[2] == 'pdf'

              @rootUrl = "#{root_url}"
               dataprint = print_excel_listed
               respond_to do |format|
                    format.html
                    format.pdf do
                       pdf = BankPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                       send_data pdf.render,:filename => "1_prt_bank_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                end
           end
     end
  end
  def add_bank

     @compCodes      =  session[:loggedUserCompCode]
     @Lastcode       =  generate_bank_series
     @ListBank = nil
      if params[:id].to_i >0
          @ListBank  = MstBankList.where("bl_compcode = ? AND id = ?",@compCodes,params[:id]).first
      end
  end

  def create
  @compCodes  =  session[:loggedUserCompCode]
  isFlags     = true
  begin
  if params[:bl_code] == '' || params[:bl_code] == nil
     flash[:error] =  "Bank code is required!"
     isFlags = false
  elsif params[:bl_name] == '' || params[:bl_name] == nil
     flash[:error] =  "Bank name is required"
     isFlags = false

  else

    curbank      = params[:cur_bank].to_s.strip
    bank         = params[:bl_name].to_s.strip
    mid          = params[:mid]
    if mid.to_i >0

          if bank.to_s.downcase != curbank.to_s.downcase
              chkbank   = MstBankList.where("bl_compcode = ? AND LOWER(bl_name) = ? ",@compCodes,bank.to_s.downcase)
              if chkbank.length >0
                    flash[:error] = "This bank name is already taken!"
                    isFlags       = false
              end

          end
            if isFlags
                chkdeprtobj   = MstBankList.where("bl_compcode = ? AND id = ?",@compCodes,mid).first
                if chkdeprtobj
                  chkdeprtobj.update(bank_params)
                      flash[:error] = "Data updated successfully"
                      isFlags       = true
                end
            end

    else
             chkbank   = MstBankList.where("bl_compcode = ? AND LOWER(bl_name) = ? ",@compCodes,bank.to_s.downcase)
              if chkbank.length >0
                    flash[:error] = "This bank name is already taken!"
                    isFlags       = false
              end
            if isFlags
                deprtsvobj = MstBankList.new(bank_params)
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
     redirect_to  "#{root_url}bank"
   else
     redirect_to  "#{root_url}bank/add_bank"
   end

end

 def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         @ListSate =  MstBankList.where("bl_compcode =? AND id = ?",@compcodes,params[:id]).first
         if @ListSate
                 @ListSate.destroy
                 flash[:error] =  "Data deleted successfully."
                 isFlags       =  true
                 session[:isErrorhandled] = nil
         end
    end
    redirect_to "#{root_url}bank"
 end


private
def bank_params
    params[:bl_compcode]          = session[:loggedUserCompCode]
    params[:bl_name]              = params[:bl_name] !=nil && params[:bl_name] !='' ? params[:bl_name].to_s.strip : ''
    params[:bl_code]              = params[:bl_code]!=nil && params[:bl_code] !='' ? params[:bl_code].to_s.strip : ''
    params[:bl_address]           = params[:bl_address]!=nil && params[:bl_address] !='' ? params[:bl_address].to_s.strip : ''    
    params.permit(:bl_compcode,:bl_name,:bl_code,:bl_address,:bl_ifsccode)
end

private
  def get_bank_list
       if params[:page].to_i >0
         pages = params[:page]
      else
         pages = 1
      end
     if params[:requestserver] !=nil && params[:requestserver] != ''
        session[:req_search_bank] = nil
     end
      search_bank = params[:search_bank] !=nil && params[:search_bank] != '' ? params[:search_bank].to_s.strip : session[:req_search_bank]
      iswhere = "bl_compcode ='#{@compCodes}'"
      if search_bank !=nil && search_bank !=''
          iswhere += " AND bl_name LIKE '%#{search_bank}%'"
          @search_bank              = search_bank
          session[:req_search_bank] = search_bank
      end
      stsobj =  MstBankList.where(iswhere).paginate(:page =>pages,:per_page => 10).order("bl_name ASC")
      return stsobj
  end

  private
  def print_excel_listed
      search_bank =  session[:req_search_bank]      
      iswhere = "bl_compcode ='#{@compCodes}'"
      if search_bank !=nil && search_bank !=''
          iswhere += " AND bl_name LIKE '%#{search_bank}%'"
      end
      stsobj =  MstBankList.where(iswhere).order("bl_name ASC")
      return stsobj
  end


 private
def generate_bank_series
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
