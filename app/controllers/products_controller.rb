## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process banking master
### FOR REST API ######
class ProductsController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted
  def index
    @compCodes  =  session[:loggedUserCompCode]
     printcontroll   = "1_prt_excel_bank_list"
     @printpath      = product_path(printcontroll,:format=>"pdf")
     printpdf        = "1_prt_pdf_bank_list"
     @printpdfpath  = product_path(printpdf,:format=>"pdf")
     @bankListed   = get_bank_list
     if params[:id] != nil && params[:id] != ''
           ids = params[:id].to_s.split("_")
           if ids[1] == 'prt' && ids[2] == 'excel'
               @ExcelList = print_excel_listed
               send_data @ExcelList.to_generate_products, :filename=> "products_#{Date.today}.csv"
               return
           elsif ids[1] == 'prt' && ids[2] == 'pdf'

              @rootUrl = "#{root_url}"
               dataprint = print_excel_listed
               respond_to do |format|
                    format.html
                    format.pdf do
                       pdf = ProductsPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                       send_data pdf.render,:filename => "1_prt_bank_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                end
           end
     end
  end
  def add_products

     @compCodes      =  session[:loggedUserCompCode]
     @Lastcode       =  generate_bank_series
     @ListProducts = nil
      if params[:id].to_i >0
          @ListProducts  = MstProducts.where("pr_compcode = ? AND id = ?",@compCodes,params[:id]).first
      end
  end

  def create
  @compCodes  =  session[:loggedUserCompCode]
  isFlags     = true
  begin
  if params[:pr_code] == '' || params[:pr_code] == nil
     flash[:error] =  "Product code is required!"
     isFlags = false
  elsif params[:pr_name] == '' || params[:pr_name] == nil
     flash[:error] =  "Product name is required"
     isFlags = false

  else

    curbank      = params[:cur_bank].to_s.strip
    bank         = params[:pr_name].to_s.strip
    mid          = params[:mid]
    if mid.to_i >0

          if bank.to_s.downcase != curbank.to_s.downcase
              chkbank   = MstProducts.where("pr_compcode = ? AND LOWER(pr_name) = ? ",@compCodes,bank.to_s.downcase)
              if chkbank.length >0
                    flash[:error] = "This Product name is already taken!"
                    isFlags       = false
              end

          end
            if isFlags
                chkdeprtobj   = MstProducts.where("pr_compcode = ? AND id = ?",@compCodes,mid).first
                if chkdeprtobj
                  chkdeprtobj.update(bank_params)
                      flash[:error] = "Data updated successfully"
                      isFlags       = true
                end
            end

    else
             chkbank   = MstProducts.where("pr_compcode = ? AND LOWER(pr_name) = ? ",@compCodes,bank.to_s.downcase)
              if chkbank.length >0
                    flash[:error] = "This Product name is already taken!"
                    isFlags       = false
              end
            if isFlags
                deprtsvobj = MstProducts.new(bank_params)
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
     redirect_to  "#{root_url}products"
   else
     redirect_to  "#{root_url}products/add_products"
   end

end

 def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         @ListSate =  MstProducts.where("pr_compcode =? AND id = ?",@compcodes,params[:id]).first
         if @ListSate
                 @ListSate.destroy
                 flash[:error] =  "Data deleted successfully."
                 isFlags       =  true
                 session[:isErrorhandled] = nil
         end
    end
    redirect_to "#{root_url}products"
 end


private
def bank_params
    attachfile = ""
    cdirect    = "products"
    params[:pr_compcode]          = session[:loggedUserCompCode]
    params[:pr_name]              = params[:pr_name] !=nil && params[:pr_name] !='' ? params[:pr_name].to_s.strip : ''
    params[:pr_code]              = params[:pr_code]!=nil && params[:pr_code] !='' ? params[:pr_code].to_s.strip : ''
    params[:pr_cb]           = params[:pr_cb]!=nil && params[:pr_cb] !='' ? params[:pr_cb].to_s.strip : '' 
    
    if params[:pr_img] != '' && params[:pr_img] !=nil
      attachfile      = process_files(params[:pr_img],params[:currfile],cdirect)
  end
  if attachfile == nil || attachfile == ''
      if params[:currfile] !=nil && params[:currfile] != ''
           attachfile = params[:currfile]
      end
  end
    params[:pr_img]  = attachfile
    
    params.permit(:pr_compcode,:pr_name,:pr_code,:pr_ob,:pr_cb,:pr_img)
end

private
  def get_bank_list
       if params[:page].to_i >0
         pages = params[:page]
      else
         pages = 1
      end
     if params[:requestserver] !=nil && params[:requestserver] != ''
        session[:req_search_products] = nil
     end
      search_products = params[:search_products] !=nil && params[:search_products] != '' ? params[:search_products].to_s.strip : session[:req_search_products]
      iswhere = "pr_compcode ='#{@compCodes}'"
      if search_products !=nil && search_products !=''
          iswhere += " AND pr_name LIKE '%#{search_products}%'"
          @search_products              = search_products
          session[:req_search_products] = search_products
      end
      stsobj =  MstProducts.where(iswhere).paginate(:page =>pages,:per_page => 10).order("pr_name ASC")
      return stsobj
  end

  private
  def print_excel_listed
      search_products =  session[:req_search_products]      
      iswhere = "pr_compcode ='#{@compCodes}'"
      if search_products !=nil && search_products !=''
          iswhere += " AND pr_name LIKE '%#{search_products}%'"
      end
      stsobj =  MstProducts.where(iswhere).order("pr_name ASC")
      return stsobj
  end


 private
def generate_bank_series
  prefixobj    = get_common_prefix('Bank')
  @Startx      = prefixobj ? prefixobj.sn_length : ''
  @isCode      = 0
  @recCodes    = MstProducts.select("pr_code").where(["pr_compcode = ? AND pr_code<>''", @compCodes]).last
  if @recCodes
     @isCode1    = @recCodes.pr_code.to_s.gsub(/[^\d]/, '')
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
