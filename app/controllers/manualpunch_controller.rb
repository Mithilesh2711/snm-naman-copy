class ManualpunchController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  skip_before_action :verify_authenticity_token
  helper_method :get_mysewdar_list_details,:currency_formatted,:formatted_date,:year_month_days_formatted,:format_oblig_date
  def index
          @authorizedId  =   session[:autherizedUserId]
          @compCodes     =   session[:loggedUserCompCode]
          @empDetail     =   MstSewadar.where("sw_compcode =?",@compCodes).order("sw_sewadar_name ASC")
          @MstLeave      =   MstLeave.where("attend_compcode=?",@compCodes)
          month_numbers =  Time.now.month
          month_begins  =  Date.new(Date.today.year, month_numbers)
          begdates      =  Date.parse(month_begins.to_s)
          @nbegindates  =  Date.today.strftime('%d-%b-%Y') #begdates.strftime('%d-%b-%Y')
          month_endings =  month_begins.end_of_month
          endingdates   =  Date.parse(month_endings.to_s)
          @enddates     =  Date.today.strftime('%d-%b-%Y') #endingdates.strftime('%d-%b-%Y')
          @ListAllDepart   =  Department.where("compCode = ? AND subdepartment=''",@compCodes).order("departDescription ASC")
          @MannualListed = TrnGeoLocation.where("gc_compcode =? AND gc_punchtype ='M' AND DATE(gc_date) =DATE(NOW())",@compCodes).order("gc_user_id ASC")
          
          if params[:save_manual_detail]!=nil && params[:save_manual_detail]!='' && params[:save_manual_detail]=='Y'
          save_manual_detail
          return
          elsif params[:save_manual_detail]!=nil && params[:save_manual_detail]!='' && params[:save_manual_detail]=='MNL'
          save_geo_manual_punch
          return
          elsif params[:machine_punch_detail]!=nil && params[:machine_punch_detail]!='' && params[:machine_punch_detail]=='Y'
            get_all_rawpunch_detail
          return
          elsif params[:machine_emp_detail]!=nil && params[:machine_emp_detail]!='' && params[:machine_emp_detail]=='Y'
          get_employee_card_details
          return
          elsif params[:machine_emp_detail]!=nil && params[:machine_emp_detail]!='' && params[:machine_emp_detail]=='DSB'
          get_dashboard_redirected
          return
          elsif params[:machine_emp_detail]!=nil && params[:machine_emp_detail]!='' && params[:machine_emp_detail]=='QTCUST'
          get_quoation_listing
          return
           elsif params[:machine_emp_detail]!=nil && params[:machine_emp_detail]!='' && params[:machine_emp_detail]=='QTNCUST'
          find_number_quoation
          return
          elsif params[:machine_emp_detail]!=nil && params[:machine_emp_detail]!='' && params[:machine_emp_detail]=='QTLISTDATA'
          get_all_selected_quoation
          return
          elsif params[:machine_emp_detail]!=nil && params[:machine_emp_detail]!='' && params[:machine_emp_detail]=='QTUPD'
            process_update_quotation_status
            return
          elsif params[:machine_emp_detail]!=nil && params[:machine_emp_detail]!='' && params[:machine_emp_detail]=='PILSTDATA'
            get_data_from_pi_listed
            return
          elsif params[:machine_punch_detail]!=nil && params[:machine_punch_detail]!='' && params[:machine_punch_detail]=='UPD'
            process_update_mannual_punches
            return
          elsif params[:machine_punch_detail]!=nil && params[:machine_punch_detail]!='' && params[:machine_punch_detail]=='DELIT'
            process_delete_mannual_punches_record
            return
          elsif params[:machine_punch_detail]!=nil && params[:machine_punch_detail]!='' && params[:machine_punch_detail]=='MNPNCH'
            get_all_manual_punches_detail
            return
          end



  end
def add_manual_punch
          @authorizedId  =   session[:autherizedUserId]
          @compCodes     =   session[:loggedUserCompCode]
          @empDetail     =   MstSewadar.where("sw_compcode =?",@compCodes).order("sw_sewadar_name ASC")
          @MstLeave      =   MstLeave.where("attend_compcode=?",@compCodes)
          month_numbers =  Time.now.month
          month_begins  =  Date.new(Date.today.year, month_numbers)
          begdates      =  Date.parse(month_begins.to_s)
          @nbegindates  =  Date.today.strftime('%d-%b-%Y') 
          month_endings =  month_begins.end_of_month
          endingdates   =  Date.parse(month_endings.to_s)
          @enddates     =  Date.today.strftime('%d-%b-%Y')
          @selectedPunches = nil
          if params[:id].to_i >0
            @selectedPunches = TrnGeoLocation.where("gc_compcode =? AND id =? ",@compCodes,params[:id]).first
          end
          
 end

  private
  def save_geo_manual_punch
    message = ''
    isflag = true
    if params[:mp_empcode]=='' || params[:mp_empcode]==nil
       message = 'Please select employee code'
       isflag = false
    elsif params[:mp_date]=='' || params[:mp_date]==nil
       message = 'Please enter date'
       isflag = false
    elsif params[:mp_time]=='' || params[:mp_time]==nil
       message = 'Please enter time'
       isflag = false
    end
     if isflag
       @isManualObj = TrnGeoLocation.new(geo_manual_params)
       if @isManualObj.save
         message = 'Data saved successfully'
         isflag  = true
       end
     end
     empcode = params[:mp_empcode]!='' ? params[:mp_empcode] : ''
     arr   = []
     isselect = " sw_sewadar_name as empnames,trn_geo_locations.id as punchid,emp.id as empId,gc_date as mp_date,gc_local_time as mp_time,gc_user_id as mp_empcode,'' as indate,'' as intimes"
     jons     = " LEFT JOIN mst_sewadars emp ON(sw_compcode = gc_compcode AND gc_user_id = emp.sw_sewcode)"
     @isManualData = TrnGeoLocation.select(isselect).joins(jons).where("gc_compcode =? AND gc_user_id =? AND gc_punchtype ='M'",@compCodes,empcode)
     if @isManualData.length >0
         @isManualData.each do |mns|
           arr.push mns
         end
     end
     if arr.length >0
        arr.each do |tmns|
         if  tmns.mp_date!='' && tmns.mp_date!=nil
            nds    = Date.parse(tmns.mp_date.to_s)
            nedate = nds.strftime("%d-%b-%Y")
            tmns.indate = nedate
         end
         if tmns.mp_time!='' && tmns.mp_time!=nil
            #nds1        = Time.parse(tmns.mp_time.to_s)
            netime       = tmns.mp_time #nds1.strftime("%I:%M")
            tmns.intimes = netime
         end
       end

     end
     respond_to do |format|
      format.json { render :json => { 'data'=>arr, "message"=>message,:status=>isflag } }
     end
  end

  private
  def geo_manual_params
    Time.zone = "Kolkata"
    params[:gc_punchtype]   = 'M'
    params[:gc_compcode]    = @compCodes
    params[:gc_user_id]     = params[:mp_empcode]!='' ? params[:mp_empcode] : ''    
    params[:gc_date]        = params[:mp_date]!='' ? params[:mp_date] : 0
    params[:gc_local_time]  = params[:mp_time]!='' ? params[:mp_time] : 0
    params[:gc_time]         = Time.zone.now.to_time
    params[:gc_latitude]     = ''
    params[:gc_longitude]    = ''
    params[:gc_address]      = ''
    params[:gc_visit_number] = ''
    params.permit(:gc_compcode,:gc_punchtype,:gc_user_id,:gc_date,:gc_local_time,:gc_time,:gc_latitude,:gc_longitude,:gc_address)
  end

  
  
  private
  def get_all_rawpunch_detail
      empcode  = params[:empcode]!='' && params[:empcode]!= nil ? params[:empcode] : ''
      fromdate = params[:from_date]!='' && params[:from_date]!=nil ? params[:from_date] : ''
      uptodate = params[:upto_time]!='' && params[:upto_time]!=nil ? params[:upto_time] : ''
      deptcode = params[:depcode]!='' && params[:depcode]!=nil ? params[:depcode] : ''
      arr      = []
      message  = ''
      isflag   = false      
      iswhere  = "gc_compcode ='#{@compCodes}' AND gc_punchtype <>'M' "
      if empcode !=nil && empcode !=''
        iswhere += " AND gc_user_id ='#{empcode}'"
      end
      if fromdate!=nil && fromdate !=''
        iswhere += " AND gc_date >='#{year_month_days_formatted(fromdate)}'"
      end
      if uptodate !=nil && uptodate !=''
         iswhere += " AND gc_date <='#{year_month_days_formatted(uptodate)}'"
      end
      if deptcode !=nil && deptcode !=''
         iswhere += " AND sw_depcode ='#{deptcode}'"
      end
      # isselect = " emp.id as empId,gc_date as mp_date,gc_local_time as mp_time,gc_user_id as mp_empcode,'' as indate,'' as intimes,sw_sewadar_name as myempname"
      isselect = " emp.id as empId,trn_geo_locations.id as punchid,gc_date as mp_date,gc_local_time as mp_time,gc_user_id as mp_empcode,'' as indate,'' as intimes,sw_sewadar_name as myempname,gc_punchtype"
      jons     = " LEFT JOIN mst_sewadars emp ON(sw_compcode = gc_compcode AND gc_user_id = emp.sw_sewcode)"
      machdataobj = TrnGeoLocation.select(isselect).joins(jons).where(iswhere).order("gc_date ASC,gc_local_time ASC,sw_sewadar_name ASC")
     if machdataobj.length >0
       message = "success"
       isflag  = true
         machdataobj.each do |mns|
           arr.push mns
         end
     else
       message = "No Record(s) found."
     end
     
     if arr.length >0
        arr.each do |tmns|
         if  tmns.mp_date!='' && tmns.mp_date!=nil
             tmns.indate = formatted_date(tmns.mp_date)
         end
         if tmns.mp_time!='' && tmns.mp_time!=nil
            #nds1    = Time.parse(tmns.mp_time.to_s)
            netime   = tmns.mp_time #nds1.strftime("%I:%M")
            tmns.intimes= netime
         end
       end

     end
     #objmanual = get_manual_punches_detail()
     respond_to do |format|
      format.json { render :json => { 'data'=>arr, "message"=>message,:status=>isflag } }
     end
  end

  private
  def get_all_manual_punches_detail
      empcode  = params[:empcode]!='' && params[:empcode]!= nil ? params[:empcode] : ''
      fromdate = params[:from_date]!='' && params[:from_date]!=nil ? params[:from_date] : ''
      uptodate = params[:upto_time]!='' && params[:upto_time]!=nil ? params[:upto_time] : ''
      deptcode = params[:depcode]!='' && params[:depcode]!=nil ? params[:depcode] : ''
      arr      = []
      message  = ''
      isflag   = false      
      iswhere  = "gc_compcode ='#{@compCodes}' AND UPPER(gc_punchtype) ='M' "
      if empcode !=nil && empcode !=''
        iswhere += " AND gc_user_id ='#{empcode}'"
      end
      if fromdate!=nil && fromdate !=''
        iswhere += " AND gc_date >='#{year_month_days_formatted(fromdate)}'"
      end
      if uptodate !=nil && uptodate !=''
         iswhere += " AND gc_date <='#{year_month_days_formatted(uptodate)}'"
      end
      if deptcode !=nil && deptcode !=''
         iswhere += " AND sw_depcode ='#{deptcode}'"
      end
      # isselect = " emp.id as empId,gc_date as mp_date,gc_local_time as mp_time,gc_user_id as mp_empcode,'' as indate,'' as intimes,sw_sewadar_name as myempname"
      isselect = " emp.id as empId,trn_geo_locations.id as punchid,gc_date as mp_date,gc_local_time as mp_time,gc_user_id as mp_empcode,'' as indate,'' as intimes,sw_sewadar_name as myempname,gc_punchtype"
      jons     = " LEFT JOIN mst_sewadars emp ON(sw_compcode = gc_compcode AND gc_user_id = emp.sw_sewcode)"
      machdataobj = TrnGeoLocation.select(isselect).joins(jons).where(iswhere).order("gc_date ASC,gc_local_time ASC,sw_sewadar_name ASC")
     if machdataobj.length >0
       message = "success"
       isflag  = true
         machdataobj.each do |mns|
           arr.push mns
         end
     else
       message = "No Record(s) found."
     end
     
     if arr.length >0
        arr.each do |tmns|
         if  tmns.mp_date!='' && tmns.mp_date!=nil
             tmns.indate = formatted_date(tmns.mp_date)
         end
         if tmns.mp_time!='' && tmns.mp_time!=nil
            netime   = tmns.mp_time #nds1.strftime("%I:%M")
            tmns.intimes= netime
         end
       end

     end
     respond_to do |format|
      format.json { render :json => { 'data'=>arr, "message"=>message,:status=>isflag } }
     end
  end



private
def get_employee_card_details
     empcode    = params[:empcode]!='' ? params[:empcode] : ''
     isflag     = false
     @isCardObj = MstEmployee.select('id as ecd_card_number').where("emp_compcode=? AND id=?",@compCodes,empcode).first #MstEmpCardDetail.select('ecd_card_number').where("ecd_compcode=? AND ecd_empcode=?",@compCodes,empcode).first
     if @isCardObj
      isflag = true
     end
     respond_to do |format|
      format.json { render :json => { 'data'=>@isCardObj, "message"=>'',:status=>isflag } }
     end
 end

private
def get_dashboard_redirected
     startdate    = params[:evstdt]!='' && params[:evstdt] !=nil ? params[:evstdt] : ''
     type         = params[:type] !=nil && params[:type]!='' ? params[:type] : ''
     isflag       = false
     if startdate !=nil && startdate !=''
        isflag = true
        session[:req_dashquotrsch] = startdate
        session[:view_request_flp] = nil
     end
     respond_to do |format|
      format.json { render :json => { 'data'=>'', "message"=>'',:status=>isflag } }
     end
 end


private
def get_quoation_listing
     iscustomers  = params[:customers]!='' && params[:customers] !=nil ? params[:customers] : 0
     type         = params[:type] !=nil && params[:type]!='' ? params[:type] : ''
     isflag       = false
     jons       = " JOIN trn_quotation_details pod ON(pod.qdt_compcode=qt_compcode AND pod.qdt_quotno=qt_quotno)"
     iswhere    = " qt_compcode='#{@compCodes}' AND qt_customers='#{iscustomers}' AND qt_status='AP' AND qt_pistatus<>'Y'"
     isselect   = " COUNT(*) as totalprod,SUM(qdt_netamount) as totalamount,SUM(qdt_quantity) as tqty"
     isselect   +=" ,DATE_FORMAT(qt_quotdate,'%d-%b-%Y') as qtdated,qt_quotno as quotno,qt_customers"
     sqtsobj    =  TrnQuotation.select(isselect).joins(jons).where(iswhere).group("qt_quotno").order('qt_quotno ASC')
       if sqtsobj.length >0
        isflag =true
       end
       respond_to do |format|
        format.json { render :json => { 'data'=>sqtsobj, "message"=>'',:status=>isflag } }
       end
   end

   private
   def process_update_quotation_status
       qtnumber  = params[:qtnumber]
       remarks   = params[:remarks]
       mystatus  = params[:mystatus]
       isflag = false
       qtsobj    = TrnQuotation.where("qt_compcode = ? AND qt_quotno = ?",@compCodes,qtnumber).first
       if qtsobj
         qtsobj.update(:qt_processstatus=>mystatus,:qt_remark=>remarks)
         isflag = true
       end
       respond_to do |format|
        format.json { render :json => { 'data'=>'', "message"=>'',:status=>isflag } }
       end

   end

   private
def find_number_quoation
     iscustomers  = params[:customers]!='' && params[:customers] !=nil ? params[:customers] : 0
     type         = params[:type] !=nil && params[:type]!='' ? params[:type] : ''
     isflag       = false
     jons       = " JOIN trn_quotation_details pod ON(pod.qdt_compcode=qt_compcode AND pod.qdt_quotno=qt_quotno)"
     iswhere    = " qt_compcode='#{@compCodes}' AND qt_oano='' AND qt_customers='#{iscustomers}' AND qt_status='AP' AND qt_pistatus<>'Y'"
     isselect   = " COUNT(*) as totalprod,SUM(qdt_netamount) as totalamount,SUM(qdt_quantity) as tqty"
     isselect   +=" ,DATE_FORMAT(qt_quotdate,'%d-%b-%Y') as qtdated,qt_quotno as quotno,qt_customers"
     sqtsobj    =  TrnQuotation.select(isselect).joins(jons).where(iswhere).group("qt_quotno").order('qt_quotno ASC')
       if sqtsobj.length >0
        isflag =true
       end
       respond_to do |format|
        format.json { render :json => { 'data'=>sqtsobj, "message"=>'',:status=>isflag } }
       end
   end

private
def get_all_selected_quoation
     iscustomers  =  params[:customers]!='' && params[:customers] !=nil ? params[:customers] : 0
     qutono       =  params[:qutono] !=nil && params[:qutono]!='' ? params[:qutono] : ''
     isflag       =  false
     jons         =  " JOIN trn_quotation_details pod ON(pod.qdt_compcode=qt_compcode AND pod.qdt_quotno=qt_quotno)"
     iswhere      =  " qt_compcode='#{@compCodes}' AND qt_oano='' AND qt_quotno ='#{qutono}' AND qt_customers='#{iscustomers}' AND qt_status='AP' AND qt_pistatus<>'Y'"
     isselect     =  " pod.*"
     isselect     += " ,DATE_FORMAT(qt_quotdate,'%d-%b-%Y') as qtdated,qt_quotno as quotno"
     sqtsobj      =  TrnQuotation.select(isselect).joins(jons).where(iswhere).order('qt_quotno ASC')
     if sqtsobj.length >0
         isflag =true
     end
      respond_to do |format|
        format.json { render :json => { 'data'=>sqtsobj, "message"=>'',:status=>isflag } }
      end
   end

private
def get_data_from_pi_listed
  isflag    =  false
  cutomer   =  params[:customers]
  pino      =  params[:pino]
 jons       =  " JOIN trn_pi_details pod ON(pod.qdt_compcode = qt_compcode AND pod.qdt_quotno = qt_quotno)"
 iswhere    =  " qt_compcode = '#{@compCodes}' AND qdt_bill_number = '' AND qt_status<>'C' AND qt_quotno='#{pino}'"
 isselect   =  " pod.*,qt_quotdate,qt_quotno"
 qtobj      =  TrnPiHead.select(isselect).joins(jons).where(iswhere).order("qdt_itemcode")
 if qtobj.length >0
     isflag = true
 end
  respond_to do |format|
    format.json { render :json => { 'data'=>qtobj, "message"=>'',:status=>isflag } }
  end
  
end

private
   def process_update_mannual_punches
      empcode     = params[:empcode]
      pid         = params[:pid]
      mypunchtime = params[:mypunchtime]
      compcodes   = session[:loggedUserCompCode]
       isflag     = false
       message    = ""
       iswhere    = "gc_compcode='#{compcodes}' AND gc_user_id ='#{empcode}' AND id = '#{pid}'"
       manualobj  = TrnGeoLocation.where(iswhere).first
       if manualobj
           manualobj.update(:gc_local_time=>mypunchtime)
           isflag  = true
           message = "Data updated successfully."
        end
       respond_to do |format|
        format.json { render :json => { 'data'=>mypunchtime, "message"=>message,:status=>isflag } }
       end

   end
   def process_delete_mannual_punches_record
     empcode     = params[:empcode]
     pid         = params[:pid]
     mypunchtime = params[:mypunchtime]
     compcodes   = session[:loggedUserCompCode]
     isflag      = false
     message     = ""
     iswhere     = "gc_compcode='#{compcodes}' AND gc_user_id ='#{empcode}' AND id = '#{pid}'"
     manualobj   = TrnGeoLocation.where(iswhere).first
      if manualobj
          if manualobj.destroy
              isflag  = true
              message = "Data deleted successfully."
          end
      end

     arr        = []
     isselect   = " sw_sewadar_name as empnames,trn_geo_locations.id as punchid,emp.id as empId,gc_date as mp_date,gc_local_time as mp_time,gc_user_id as mp_empcode,'' as indate,'' as intimes"
     jons       = " LEFT JOIN mst_sewadars emp ON(sw_compcode = gc_compcode AND gc_user_id = emp.sw_sewcode)"
     newdataobj = TrnGeoLocation.select(isselect).joins(jons).where("gc_compcode =? AND gc_user_id =? AND gc_punchtype ='M'",compcodes,empcode).order("gc_local_time ASC")
     if newdataobj.length >0
         newdataobj.each do |mns|
            arr.push mns
         end
     end
    if arr.length >0
          arr.each do |tmns|
          if  tmns.mp_date!='' && tmns.mp_date!=nil
              tmns.indate = formatted_date(tmns.mp_date)
          end
          if tmns.mp_time!='' && tmns.mp_time!=nil            
              netime       = tmns.mp_time #nds1.strftime("%I:%M")
              tmns.intimes = netime
          end
        end

     end
      
     respond_to do |format|
        format.json { render :json => { 'data'=>arr, "message"=>message,:status=>isflag } }
     end

   end


  end
