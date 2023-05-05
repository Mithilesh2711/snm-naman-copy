class MagazineController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
   def index
     @compcodes     = session[:loggedUserCompCode]
     @ListMagazine     = get_magazine_list
     printcontroll  = "1_prt_excel_magazine_list"
     @printpath     = magazine_path(printcontroll,:format=>"pdf")
     printpdf       = "1_prt_pdf_magazine_list"
     @printpdfpath  = magazine_path(printpdf,:format=>"pdf")
     
    if params[:id] != nil && params[:id] != ''
        ids = params[:id].to_s.split("_")
        if ids[1] == 'prt' && ids[2] == 'excel'
            @ExcelList = get_excel_list
            send_data @ExcelList.to_generate_magazine, :filename=> "magazine_list-#{Date.today}.csv"
            return
        elsif ids[1] == 'prt' && ids[2] == 'pdf'
                @rootUrl  = "#{root_url}"
                dataprint = get_excel_list
                respond_to do |format|
                     format.html
                     format.pdf do
                        pdf = MagazinePdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                        send_data pdf.render,:filename => "1_prt_magazine_list_report.pdf", :type => "application/pdf", :disposition => "inline"
                     end
                 end
        end
    end
 
   end
   
   def create
      @compcodes = session[:loggedUserCompCode]
     isFlags    = true
     begin
         if params[:mag_code] == nil || params[:mag_code] == ''
            flash[:error] =  "Magazine code is required."
            isFlags = false
         elsif   params[:mag_name] == nil || params[:mag_name] == ''
            flash[:error] =  "Magazine name is required."
            isFlags = false
        elsif   params[:mag_language] == nil || params[:mag_language] == ''
            flash[:error] =  "Magazine language is required."
            isFlags = false
        elsif   params[:mag_frequency] == nil || params[:mag_frequency] == ''
            flash[:error] =  "Magazine frequency per year is required."
            isFlags = false
         else
             mid    = params[:mid]
             cmagazine = params[:cur_mag_code].to_s.strip
             magcode  = params[:mag_code].to_s.strip
             if mid.to_i >0
                   if cmagazine.to_s.downcase != params[:mag_code].to_s.downcase
                  
                        chkstate = MstMagazine.where("mag_compcode =? AND mag_code = ?",@compcodes,magcode)
                        if chkstate.length >0
                             flash[:error] =  "Entered magazine code is already taken."
                             isFlags = false
                        end
                   end
                   if isFlags
                      stateupobj  = MstMagazine.where("mag_compcode =? AND id = ?",@compcodes,mid).first
                       if stateupobj
                         stateupobj.update(mag_params)
                            flash[:error] =  "Data updated successfully."
                             isFlags = true
                       end
                   end
             else
                        chkstate = MstMagazine.where("mag_compcode =? AND mag_code = ?",@compcodes,magcode)
                        if chkstate.length >0
                            flash[:error] =  "Entered magazine code is already taken."
                            isFlags = false
                        end
                        if isFlags
                             stsobj = MstMagazine.new(mag_params)
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
        redirect_to "#{root_url}"+"magazine"
      else
        redirect_to "#{root_url}"+"magazine/add_magazine"
      end
       
   end
   
   def add_magazine
     @compcodes = session[:loggedUserCompCode]
     @ListMagazine  = nil
     @ListLang = MstLanguage.where("lang_compcode =?",@compcodes).order("lang_name ASC")
     if params[:id].to_i >0
          @ListMagazine =  MstMagazine.where("mag_compcode =? AND id = ?",@compcodes,params[:id]).first
         
     end
     
   end
   
  def destroy
     @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
 
          @ListMagazine =  MstMagazine.where("mag_compcode =? AND id = ?",@compcodes,params[:id]).first
          @ListMagazine.destroy
          flash[:error] =  "Data deleted successfully."
          isFlags = true
          session[:isErrorhandled] = nil
     end
     redirect_to "#{root_url}magazine"
  end
  
   private
   def mag_params
     params[:mag_compcode]         =  session[:loggedUserCompCode]
     params[:status]   = params[:status]!=nil && params[:status] !='' ? params[:status].to_s.strip : ''
     params[:mag_language] = params[:mag_language]!=nil && params[:mag_language] !='' ? params[:mag_language].to_s.strip : ''
     params[:mag_frequency] = params[:mag_frequency]!=nil && params[:mag_frequency] !='' ? params[:mag_frequency].to_s.strip : ''
     params.permit(:mag_compcode,:mag_code,:mag_name,params[:status],:mag_language,:mag_frequency)
   end
 
   private
   def get_magazine_list
       if params[:page].to_i >0
       pages = params[:page]
       else
       pages = 1
       end
       stsobj =  MstMagazine.where("mag_compcode =?",@compcodes).paginate(:page =>pages,:per_page => 10).order("mag_name ASC")
       return stsobj
   end
 
   private
   def get_excel_list
        stsobj =  MstMagazine.where("mag_compcode =?",@compcodes).order("mag_name ASC")
       return stsobj
   end
   
 end
 