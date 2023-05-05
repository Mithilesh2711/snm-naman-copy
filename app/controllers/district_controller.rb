## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for generate tickets
### FOR REST API ######
class DistrictController < ApplicationController
   before_action :require_login
   before_action :allowed_security
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
   helper_method :get_state_detail
 def index
   @compcodes      = session[:loggedUserCompCode]
   @filter_search  = nil
   @Listdistrict   = get_district_list
   printcontroll   = "1_prt_excel_district_list"
   @printpath      = district_path(printcontroll,:format=>"pdf")
   printpdf        = "1_prt_pdf_district_list"
   @printpdfpath   = district_path(printpdf,:format=>"pdf")
   
   if params[:id] != nil && params[:id] != ''
       ids = params[:id].to_s.split("_")
       if ids[1] == 'prt' && ids[2] == 'excel'
           @ExcelList = print_excel_listed
           send_data @ExcelList.to_generate_district, :filename=> "district_list-#{Date.today}.csv"
           return
       elsif  ids[1] == 'prt' && ids[2] == 'pdf'
              @rootUrl  = "#{root_url}"
               dataprint = print_excel_listed
               respond_to do |format|
                    format.html
                    format.pdf do
                       pdf = DistrictPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                       send_data pdf.render,:filename => "1_prt_district_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                end
       end
   end
   
  end
  
  def add_district
     @compcodes = session[:loggedUserCompCode]
     @ListSate = MstState.where("sts_compcode =?",@compcodes).order("sts_description ASC")
     @ListDist = nil
     if params[:id].to_i >0
       @ListDist = MstDistrict.where("dts_compcode = ? AND id = ?",@compcodes,params[:id]).first
     end
     
  end
  
  def create
     @compcodes = session[:loggedUserCompCode]
    isFlags    = true
    begin
        if params[:dts_statecode] == nil || params[:dts_statecode] == ''
           flash[:error] =  "State code is required."
           isFlags = false
        elsif params[:dts_districtcode] == nil || params[:dts_districtcode] == ''
           flash[:error] =  "District code is required."
           isFlags = false
        elsif   params[:dts_description] == nil || params[:dts_description] == ''
           flash[:error] =  "Description is required."
           isFlags = false
        else
            mid        = params[:mid]
            cdistcode  = params[:cur_dist_code].to_s.strip
            distcode   = params[:dts_districtcode].to_s.strip
            statecode  = params[:dts_statecode].to_s.strip
            
            if mid.to_i >0
                  if cdistcode.to_s.downcase != distcode.to_s.downcase

                       chkstate = MstDistrict.where("dts_compcode =? AND LOWER(dts_statecode) = ? AND LOWER(dts_districtcode) = ?",@compcodes,statecode.to_s.downcase,distcode.to_s.downcase)
                       if chkstate.length >0
                            flash[:error] =  "Entered district code is already taken."
                            isFlags = false
                       end
                  end
                  if isFlags
                     stateupobj  = MstDistrict.where("dts_compcode =? AND id = ?",@compcodes,mid).first
                      if stateupobj
                           stateupobj.update(district_params)
                           flash[:error] =  "Data updated successfully."
                            isFlags = true
                      end
                  end
            else
                      chkstate = MstDistrict.where("dts_compcode =? AND LOWER(dts_statecode) = ? AND LOWER(dts_districtcode) = ?",@compcodes,statecode.to_s.downcase,distcode.to_s.downcase)
                       if chkstate.length >0
                            flash[:error] =  "Entered district code is already taken."
                            isFlags = false
                       end
                       if isFlags
                            stsobj = MstDistrict.new(district_params)
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
      redirect_to "#{root_url}"+"district"
     else
        redirect_to "#{root_url}"+"district/add_district"
     end
      
  end
  
  def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         @ListSate =  MstDistrict.where("dts_compcode =? AND id = ?",@compcodes,params[:id]).first
         if @ListSate
             disobjsate     = MstCity.where("ct_compcode = ? AND ct_districtcode = ?",@compcodes,@ListSate.dts_districtcode)
             if disobjsate.length >0
                 flash[:error] =  "Sorry!! unable do delete this due to used in city"
                 isFlags       = true
                 session[:isErrorhandled] = 1
             else
                 @ListSate.destroy
                 flash[:error] =  "Data deleted successfully."
                 isFlags       = true
                 session[:isErrorhandled] = nil
             end
              
         end
    end
    redirect_to "#{root_url}district"
 end

  private
  def district_params
    params[:dts_compcode]         =  session[:loggedUserCompCode]
    params[:dts_statecode]        = params[:dts_statecode] !=nil && params[:dts_statecode] !='' ? params[:dts_statecode].to_s.strip : ''
    params[:dts_districtcode]     = params[:dts_districtcode] !=nil && params[:dts_districtcode] !='' ? params[:dts_districtcode].to_s.strip : ''
    params[:dts_description]      = params[:dts_description] !=nil && params[:dts_description] !='' ? params[:dts_description].to_s.strip : ''

    params.permit(:dts_compcode,:dts_statecode,:dts_districtcode,:dts_description)
  end

  private
  def get_district_list
     if params[:page].to_i >0
    pages = params[:page]
  else
     pages = 1
  end
      jons = ""
      if params[:requestserver]!=nil && params[:requestserver]!= ''
         session[:req_filters] = nil
         session[:req_filter_state] = nil
      end
      filter_search = params[:filter_search] !=nil && params[:filter_search] != '' ? params[:filter_search].to_s.strip : session[:req_filters].to_s.strip
      filter_state  = params[:filter_state] !=nil && params[:filter_state] != '' ? params[:filter_state].to_s.strip : session[:req_filter_state].to_s.strip
      iswhere = "dts_compcode ='#{@compcodes}'"
      if filter_search !=nil && filter_search !=''
          iswhere +=" AND dts_districtcode LIKE '%#{filter_search}%' OR dts_description LIKE '%#{filter_search}%'"
          @filter_search = filter_search
          session[:req_filters] = filter_search
      end
      if filter_state !=nil && filter_state !=''
           iswhere +=" AND dts_statecode LIKE '%#{filter_state}%' OR sts_description LIKE '%#{filter_state}%'"
           @filter_state              = filter_state
           session[:req_filter_state] = filter_state
           
      end
          jons  = "JOIN mst_states sts ON(sts_compcode = dts_compcode AND sts_code = dts_statecode)"
         stsobj =  MstDistrict.select("sts.id as stsId,mst_districts.*").joins(jons).where(iswhere).paginate(:page =>pages,:per_page => 10).order("sts_description ASC")
      
      return stsobj
  end

 private
 def print_excel_listed
     filter_search  = session[:req_filters]
     filter_state   =  session[:req_filter_state]
     iswhere        = "dts_compcode ='#{@compcodes}'"
     if filter_search !=nil && filter_search !=''
         iswhere +=" AND dts_districtcode LIKE '%#{filter_search}%' OR dts_description LIKE '%#{filter_search}%'"
      end
      if filter_state !=nil && filter_state !=''
             iswhere +=" AND dts_statecode LIKE '%#{filter_state}%' OR sts_description LIKE '%#{filter_state}%'"
       end
       jons   = "JOIN mst_states sts ON(sts_compcode = dts_compcode AND sts_code = dts_statecode)"
       stsobj = MstDistrict.select("sts.id as stsId,sts_description,mst_districts.*").joins(jons).where(iswhere).order("sts_description ASC")
       return stsobj
    
 end
 
end
