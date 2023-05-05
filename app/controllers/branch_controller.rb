## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process zonal branches
### FOR REST API ######
class BranchController < ApplicationController
	 before_action :require_login
   before_action :allowed_security
   skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
   helper_method :get_zone_district_listed,:get_zone_name_detail
def index
   @compcodes      = session[:loggedUserCompCode]
   @filter_search  = nil
   @Listbranch     = get_branch_list
   printcontroll   = "1_prt_excel_branch_list"
   @printpath      = branch_path(printcontroll,:format=>"pdf")
   printpdf        = "1_prt_pdf_branch_list"
   @printpdfpath   = branch_path(printpdf,:format=>"pdf")
   @ExcelList      = nil
   if params[:id] != nil && params[:id] != ''
       ids = params[:id].to_s.split("_")
       if ids[1] == 'prt' && ids[2] == 'excel'
           $arreitems = print_excel_listed
           send_data @ExcelList.to_generate_branch, :filename=> "branch_list-#{Date.today}.csv"
           return
       elsif  ids[1] == 'prt' && ids[2] == 'pdf'
              @rootUrl  = "#{root_url}"
               dataprint = print_excel_listed
               respond_to do |format|
                    format.html
                    format.pdf do
                       pdf = BranchPdf.new(dataprint,@compDetail,@stkHead,@rootUrl)
                       send_data pdf.render,:filename => "1_prt_branch_report.pdf", :type => "application/pdf", :disposition => "inline"
                    end
                end
       end
   end

  end
  
  def add_branch
     @compcodes  = session[:loggedUserCompCode]
     @ListZone   = MstZone.where("zn_compcode = ?",@compcodes).order("zn_name ASC")
     @DistZone   = nil
     @lastNumber = generate_branch_series()
     @ListDepart   = nil
     if params[:id].to_i >0
         @ListDepart = MstBranch.where("bch_compcode = ? AND id = ?",@compcodes,params[:id]).first
         if @ListDepart
           @DistZone   = MstZoneDistrict.where("zd_compcode = ? AND zd_zonecode = ?",@compcodes,@ListDepart.bch_zonecode).order("zd_name ASC")
         end
         
     end


end
def ajax_process
      @compcodes = session[:loggedUserCompCode]
     if params[:identity] !=nil && params[:identity] !='' && params[:identity] == 'Y'
          get_zone_district
          return false
     elsif params[:identity] !=nil && params[:identity] !='' && params[:identity] == 'BRCH'
          get_zone_branch
          return false
     elsif params[:identity] !=nil && params[:identity] !='' && params[:identity] == 'ADRS'
          get_zone_branch_address
          return false
     end
     
  end
  

  def create
     @compcodes = session[:loggedUserCompCode]
    isFlags    = true
    begin
        if params[:bch_branchcode] == nil || params[:bch_branchcode] == ''
           flash[:error] =  "Branch code is required."
           isFlags = false
        elsif params[:bch_branchnumber] == nil || params[:bch_branchnumber] == ''
           flash[:error] =  "Branch number is required."
           isFlags = false
        elsif   params[:bch_zonecode] == nil || params[:bch_zonecode] == ''
           flash[:error] =  "Zone code is required."
           isFlags = false
       elsif   params[:bch_districtcode] == nil || params[:bch_districtcode] == ''
           flash[:error] =  "District code is required."
           isFlags = false
        else
            mid        = params[:mid]
            curbranch  = params[:cur_description].to_s.strip
            zonecode   = params[:bch_zonecode].to_s.strip
            distcode   = params[:bch_districtcode].to_s.strip
            branchname = params[:bch_branchname].to_s.strip
            if mid.to_i >0
                  if curbranch.to_s.downcase != branchname.to_s.downcase
                       chkstate = MstBranch.where("bch_compcode =? AND LOWER(bch_zonecode) = ? AND LOWER(bch_districtcode) = ? AND LOWER(bch_branchname) = ?",@compcodes,zonecode.to_s.downcase,distcode.to_s.downcase,branchname.to_s.downcase)
                       if chkstate.length >0
                            flash[:error] = "This Branch name is already taken."
                            isFlags       = false
                       end
                  end
                  if isFlags
                     stateupobj  = MstBranch.where("bch_compcode =? AND id = ?",@compcodes,mid).first
                      if stateupobj
                           stateupobj.update(branch_params)
                           flash[:error] =  "Data updated successfully."
                            isFlags = true
                      end
                  end
            else
                       chkstate = MstBranch.where("bch_compcode =? AND LOWER(bch_zonecode) = ? AND LOWER(bch_districtcode) = ? AND LOWER(bch_branchname) = ?",@compcodes,zonecode.to_s.downcase,distcode.to_s.downcase,branchname.to_s.downcase)
                       if chkstate.length >0
                            flash[:error] = "This Branch name is already taken."
                            isFlags       = false
                       end
                       
                       if isFlags
                            stsobj = MstBranch.new(branch_params)
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
      redirect_to "#{root_url}"+"branch"
     else
        redirect_to "#{root_url}"+"branch/add_branch"
     end

  end

  def destroy
    @compcodes = session[:loggedUserCompCode]
    if params[:id].to_i >0
         branchobj =  MstBranch.where("bch_compcode =? AND id = ?",@compcodes,params[:id]).first
         if branchobj
               branchobj.destroy
               flash[:error]            =  "Data deleted successfully."
               isFlags                  =  true
               session[:isErrorhandled] =  nil

         end
    end
    redirect_to "#{root_url}branch"
 end

  private
  def branch_params
    params[:bch_compcode]         = session[:loggedUserCompCode]
    params[:zd_zonecode]          = params[:zd_zonecode] !=nil && params[:zd_zonecode] !='' ? params[:zd_zonecode].to_s.strip : ''
    params[:bch_branchnumber]     = params[:bch_branchnumber] !=nil && params[:bch_branchnumber] !='' ? params[:bch_branchnumber].to_s.strip : ''
    params[:bch_branchname]       = params[:bch_branchname] !=nil && params[:bch_branchname] !='' ? params[:bch_branchname].to_s.strip : ''
    params[:bch_bhawan]           = params[:bch_bhawan] !=nil && params[:bch_bhawan] !='' ? params[:bch_bhawan].to_s.strip : ''
    if params[:mid].to_i >0
       params[:bch_branchcode]    = params[:bch_branchcode] !=nil && params[:bch_branchcode] !='' ? params[:bch_branchcode].to_s.strip : ''
    else
       params[:bch_branchcode]    = generate_branch_series
    end
    params.permit(:bch_compcode,:bch_branchcode,:bch_branchnumber,:bch_zonecode,:bch_districtcode,:bch_branchname,:bch_address,:bch_bhawan)
    
  end

  private
  def get_branch_list
        if params[:page].to_i >0
        pages = params[:page]
        else
        pages = 1
        end
      if params[:requestserver]!=nil && params[:requestserver]!= ''
         session[:req_branch_list] = nil
      end
      filter_search     = params[:zone_branch_search] !=nil && params[:zone_branch_search] != '' ? params[:zone_branch_search].to_s.strip : session[:req_branch_list].to_s.strip
      #zone_branch_name  = params[:zone_branch_name] !=nil && params[:zone_branch_name] != '' ? params[:zone_branch_name].to_s.strip : session[:req_zone_branch_name].to_s.strip
      iswhere       = "bch_compcode ='#{@compcodes}'"
      if filter_search !=nil && filter_search !=''
        iswhere +=" AND ( bch_branchcode LIKE '%#{filter_search}%' OR bch_branchname LIKE '%#{filter_search}%')"
        @zone_branch_search       = filter_search
        session[:req_branch_list] = filter_search
      end      

      stsobj =  MstBranch.where(iswhere).paginate(:page =>pages,:per_page => 10).order("bch_branchcode ASC")
      return stsobj
  end

 private
 def print_excel_listed
    filter_search = session[:req_branch_list].to_s.strip   
    iswhere       = "bch_compcode ='#{@compcodes}'"
    if filter_search !=nil && filter_search !=''
      iswhere +=" AND ( bch_branchcode LIKE '%#{filter_search}%' OR bch_branchname LIKE '%#{filter_search}%' )"
    end    
    arrprod = []
    stsobj =  MstBranch.select("mst_branches.*,'' as myzones,'' as myzonedistrict").where(iswhere).order("bch_branchcode ASC")
    if stsobj.length >0
      @ExcelList = stsobj
          stsobj.each do |newdist|
             zoneobj = get_zone_name_detail(newdist.bch_zonecode)
              if zoneobj
                 newdist.myzones         = zoneobj.zn_name

              end
              distobj = get_zone_district_listed(newdist.bch_districtcode)
              if distobj
                 newdist.myzonedistrict  = distobj.zd_name
              end
              
            arrprod.push newdist
          end

     end
    return arrprod
 end
 
private
def generate_branch_series
  prefixobj    = get_common_prefix('Branch')
  @Startx      = prefixobj ? prefixobj.sn_length : ''
  @isCode      = 0
  @recCodes    = MstBranch.select("bch_branchcode").where(["bch_compcode = ? AND bch_branchcode<>''", @compcodes]).last
  if @recCodes
     @isCode1    = @recCodes.bch_branchcode.to_s.gsub(/[^\d]/, '')
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
def get_zone_district
  isfalgs   = false
   zonecode = params[:zonecode]
   distpbj =  MstZoneDistrict.select("zd_distcode,zd_name").where(["zd_compcode = ? AND zd_zonecode = ?", @compcodes,zonecode]).order("zd_name ASC")
   if distpbj.length >0
      isfalgs = true
   end
    respond_to do |format|
        format.json { render :json => { 'data'=>distpbj, "message"=>'',:status=>isfalgs} }
     end
end

private
def get_zone_branch
  isfalgs   = false
   zonecode = params[:zonecode]
   distpbj =  MstBranch.select("bch_branchcode,bch_branchname").where(["bch_compcode = ? AND bch_zonecode = ?", @compcodes,zonecode]).order("bch_branchname ASC")
   if distpbj.length >0
      isfalgs = true
   end
    respond_to do |format|
        format.json { render :json => { 'data'=>distpbj, "message"=>'',:status=>isfalgs} }
     end
end

private
def get_zone_branch_address
   isfalgs  =  false
   zonecode =  params[:zonecode]
   distpbj  =  MstBranch.select("bch_branchcode,bch_branchname,bch_address").where(["bch_compcode = ? AND bch_branchcode = ?", @compcodes,zonecode]).first
   if distpbj
      isfalgs = true
   end
    respond_to do |format|
        format.json { render :json => { 'data'=>distpbj, "message"=>'',:status=>isfalgs} }
    end
end

end
