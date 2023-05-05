## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for designation
### FOR REST API ######
class LanguageController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
   def index
      @compCodes       = session[:loggedUserCompCode]
      @ListLanguage = get_language_list
      printcontroll    = "1_prt_excel_language_list"
      @printpath       = language_path(printcontroll,:format=>"pdf")
      printpdf         = "1_prt_pdf_language_list"
      @printpdfpath    = language_path(printpdf,:format=>"pdf")
      
      if params[:id] != nil && params[:id] != ''
            ids = params[:id].to_s.split("_")
            if ids[1] == 'prt' && ids[2] == 'excel'
                @ExcelList = print_excel_listed
                send_data @ExcelList.to_generate_language, :filename=> "language_list_#{Date.today}.csv"
                return
            elsif ids[1] == 'prt' && ids[2] == 'pdf'
                @rootUrl  = "#{root_url}"
                dataprint = print_excel_listed
                respond_to do |format|
                     format.html
                     format.pdf do
                        pdf = LanguagePdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                        send_data pdf.render,:filename => "1_prt_language_report.pdf", :type => "application/pdf", :disposition => "inline"
                     end
                 end
            end
      end
 
   end
 
   def add_language
     @compCodes  =  session[:loggedUserCompCode]
     @lastcodes  =  generate_language_series
     @ListLang = nil
     if params[:id].to_i >0
         @ListLang  = MstLanguage.where("lang_compcode = ? AND id = ?",@compCodes,params[:id]).first
     end
 
   end
 
   def create
   @compCodes  =  session[:loggedUserCompCode]
   isFlags     = true
   begin
   if params[:lang_code] == '' || params[:lang_code] == nil
      flash[:error] =  "Language code is required."
      isFlags = false
   elsif params[:lang_name] == '' || params[:lang_name] == nil
      flash[:error] =  "Language name is required."
      isFlags = false
 
   else
 
     curlcode = params[:curlangcode].to_s.strip
     codes    = params[:lang_code].to_s.strip
     mid           = params[:mid]
     if mid.to_i >0
 
           if curlcode.to_s.downcase != codes.to_s.downcase
               @chekLang   = MstLanguage.where("lang_compcode = ? AND LOWER(lang_code) = ?",@compCodes,codes.to_s.downcase)
               if @chekLang.length >0
                     flash[:error] = "This language code is already taken!"
                     isFlags       = false
               end
 
           end
             if isFlags
                 chklangobj   = MstLanguage.where("lang_compcode = ? AND id = ?",@compCodes,mid).first
                 if chklangobj
                   chklangobj.update(lang_params)
                       flash[:error] = "Data updated successfully"
                       isFlags       = true
                 end
             end
 
     else
               @chekLang   = MstLanguage.where("lang_compcode = ? AND LOWER(lang_code) = ?",@compCodes,codes.to_s.downcase)
               if @chekLang.length >0
                     flash[:error] = "This language code is already taken!"
                     isFlags       = false
               end
              if isFlags
                    langvobj = MstLanguage.new(lang_params)
                    if langvobj.save
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
       redirect_to  "#{root_url}language"
     else
       redirect_to  "#{root_url}language/add_language"
     end
   
 end
 
  def destroy
     @compcodes = session[:loggedUserCompCode]
     if params[:id].to_i >0
          @Lang =  MstLanguage.where("lang_compcode =? AND id = ?",@compcodes,params[:id]).first
          if @Lang
 
            @Lang.destroy
            flash[:error] =  "Data deleted successfully."
            isFlags       =  true
            session[:isErrorhandled] = nil
                  
          end
     end
     redirect_to "#{root_url}language"
  end
 
 
 private
 def lang_params
     params[:lang_compcode]         = session[:loggedUserCompCode]
     params[:lang_code]         = params[:lang_code] !=nil && params[:lang_code] !='' ? params[:lang_code].to_s.delete(' ').upcase : ''
     params[:lang_name]   = params[:lang_name]!=nil && params[:lang_name] !='' ? params[:lang_name].to_s.strip : ''
     params[:status]   = params[:status]!=nil && params[:status] !='' ? params[:status].to_s.strip : ''
     params.permit(:lang_compcode,:lang_code,:lang_name,:status)
 end
 
 private
   def get_language_list
        if params[:page].to_i >0
          pages = params[:page]
       else
          pages = 1
       end
      if params[:requestserver] !=nil && params[:requestserver] != ''
         session[:req_search_design] = nil
      end
       search_language = params[:search_language] !=nil && params[:search_language] != '' ? params[:search_language].to_s.strip : session[:req_search_design]
       iswhere = "lang_compcode ='#{@compCodes}'"
       if search_language !=nil && search_language !=''
         iswhere += " AND ( lang_code LIKE '%#{search_language}%' OR  lang_name LIKE '%#{search_language}%' ) "
         @search_language = search_language
         session[:req_search_design] = search_language
       end
       stsobj =  MstLanguage.where(iswhere).paginate(:page =>pages,:per_page => 10).order("lang_name ASC")
       return stsobj
   end
 
   private
   def print_excel_listed
         search_language =  session[:req_search_design]
         iswhere = "lang_compcode ='#{@compCodes}'"
         if search_language !=nil && search_language !=''
           iswhere += " AND ( lang_code LIKE '%#{search_language}%' OR  lang_name LIKE '%#{search_language}%' ) "
           @search_language = search_language
           session[:req_search_design] = search_language
         end
         stsobj =  MstLanguage.where(iswhere).order("lang_name ASC")
         return stsobj
   end
   
  private
 def generate_language_series
   prefixobj    = get_common_prefix('Language')
   @Startx      = prefixobj ? prefixobj.sn_length : ''
   @isCode      = 0
   @recCodes    = MstLanguage.select("lang_code").where(["lang_compcode = ? AND lang_code<>''", @compCodes]).last
   if @recCodes
      @isCode1    = @recCodes.lang_code.to_s.gsub(/[^\d]/, '')
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
 