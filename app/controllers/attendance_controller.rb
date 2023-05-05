class AttendanceController < ApplicationController
  before_action :require_login
  before_action :allowed_security
  include ErpModule::Common
  helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_emp_attached_file,:get_employee_types
  helper_method :formatted_times
  def index
    @authorizedId  =   session[:autherizedUserId]
    @compCodes     =   session[:loggedUserCompCode]
    @sewadarCategory   = MstSewadarCategory.where("sc_compcode =?",@compCodes).order("sc_position ASC")
    session[:allowed_prints] ='L'
    @selecMstLeave           = nil   
     
     if params[:id] != nil && params[:id] != ''
      
           ids = params[:id].to_s.split("_")
           if ids[1] == 'prt' && ids[2] == 'excel'
             
               @ExcelList = get_leave_listed
               send_data @ExcelList.to_leave_master, :filename=> "1_prt_excel_leave_list#{Date.today}.csv"
               return
           elsif ids[1] == 'prt' && ids[2] == 'pdf'

              @rootUrl = "#{root_url}"
               dataprint = get_leave_listed
               respond_to do |format|
                  format.html
                  format.pdf do
                    pdf = LeavePdf.new(dataprint,@compdetail)    #line_items
                    send_data pdf.render,:filename => "1_prt_pdf_leave_list", :type => "application/pdf", :disposition => "inline"
                  end
               end
           end
     end
      if params[:id].to_i >0
        @selecMstLeave      =   MstLeave.where("attend_compcode=? AND id=?",@compCodes,params[:id]).first
      end

  end
  
  def show
    @authorizedId       =   session[:autherizedUserId]
    @compCodes          =   session[:loggedUserCompCode]
    @compdetail         =   nil
    @selecMstLeave      =   MstLeave.where("attend_compcode=? AND id=?",@compCodes,params[:id]).first
    @MstLeave           =   MstLeave.where("attend_compcode=?",@compCodes)
    @paths              = ''
    if @selecMstLeave
        session[:allowed_prints] ='L'
        if @MstLeave.count >0
          @printControll = "1_"+@compCodes.to_s+"_leave"+"_"+"#{Time.now}"
          @paths = attendance_path(@printControll,:format=>"pdf")
        end
    end
    
    if session[:allowed_prints] && session[:allowed_prints] =='S'
      @MstShift = MstShift.where("attend_compcode=?",@compCodes)
       respond_to do |format|
          format.html
          format.pdf do
            pdf = ShiftPdf.new(@MstShift,@compdetail)    #line_items
            send_data pdf.render,:filename => "1_"+@compCodes.to_s+"_shift"+"_"+"#{Date.today}", :type => "application/pdf", :disposition => "inline"
          end
       end
    elsif session[:allowed_prints] && session[:allowed_prints] =='L'
        respond_to do |format|
          format.html
          format.pdf do
            pdf = LeavePdf.new(@MstLeave,@compdetail)    #line_items
            send_data pdf.render,:filename => "1_"+@compCodes.to_s+"_leave"+"_"+"#{Time.now}", :type => "application/pdf", :disposition => "inline"
          end
       end
    end
    
  end
  def shift_edit
    @authorizedId            =   session[:autherizedUserId]
    @compCodes               =   session[:loggedUserCompCode]
    @selecMstShift           =   MstShift.find(params[:id])
    @MstShift                =   MstShift.where("attend_compcode=?",@compCodes)
    session[:allowed_prints] =   'S'
  end
  def shift
    @authorizedId  =   session[:autherizedUserId]
    @compCodes     =   session[:loggedUserCompCode]
    @selecMstShift =   nil
    @MstShift      =   MstShift.where("attend_compcode=?",@compCodes)
    if params[:id].to_i >0
      @selecMstShift =   MstShift.find(params[:id])
    end
    
    session[:allowed_prints] = 'S'
    if @MstShift.count >0
      @printControll = "1_"+@compCodes.to_s+"_shift"+"_"+"#{Date.today}"
     @paths  = attendance_path(@printControll,:format=>"pdf")
    else
      @paths  = ''
    end
    if params[:attendpst]!=nil &&  params[:attendpst]!=''
    save_master_shift_leave()
    end
    if params[:attendEdits]!=nil &&  params[:attendEdits]!=''
      edit_shifting()
    end
  end
  def shift_list
      @authorizedId  =   session[:autherizedUserId]
    @compCodes     =   session[:loggedUserCompCode]
    @selecMstShift =   nil
    @MstShift      =   MstShift.where("attend_compcode=?",@compCodes)
    if params[:id].to_i >0
      @selecMstShift =   MstShift.find(params[:id])
    end
    
    session[:allowed_prints] = 'S'
    if @MstShift.count >0
      @printControll = "1_"+@compCodes.to_s+"_shift"+"_"+"#{Date.today}"
     @paths  = attendance_path(@printControll,:format=>"pdf")
    else
      @paths  = ''
    end
    if params[:attendpst]!=nil &&  params[:attendpst]!=''
    save_master_shift_leave()
    end
    if params[:attendEdits]!=nil &&  params[:attendEdits]!=''
      edit_shifting()
    end
  end

  def get_leave_listed
    @compCodes    =   session[:loggedUserCompCode]
    leavsobj      =   MstLeave.where("attend_compcode = ?",@compCodes).order("attend_category ASC,attend_leavetype ASC")
    return leavsobj
  end
  
  def leave_list
      @authorizedId   =   session[:autherizedUserId]
      @compCodes      =   session[:loggedUserCompCode]
      @MstLeave       =   get_leave_listed
      session[:allowed_prints] ='L'
      @selecMstLeave           = nil
      printcontroll     = "1_prt_excel_leave_list"
      @printpath        = attendance_path(printcontroll,:format=>"pdf")
      printpdf          = "1_prt_pdf_leave_list"
      @printpdfpath     = attendance_path(printpdf,:format=>"pdf")

  end
  
  def destroy    
   isFlags = false
    begin
    @MstLeave = MstLeave.find(params[:id])

  if @MstLeave
    leavecode = @MstLeave.attend_leaveCode
    chkedelob =  apply_checks_used(leavecode)
    if chkedelob
        flash[:error] =  "Could not be deleted due to used in apply leave"
        isFlags = false
        session[:isErrorhandled] = 1
    else
      if @MstLeave.destroy
        flash[:error] =  "Data deleted successfully!!"
        isFlags = true
        session[:isErrorhandled] = nil
       end

    end


  end
    ############# THREAD MESSAGE & HANDLING ##########
  if !isFlags
    session[:isErrorhandled] = 1
    session[:postedpamams]   = params
  else
    session[:isErrorhandled] = nil
    session[:postedpamams]   = nil
    isFlags = true
  end
   rescue Exception => exc
       flash[:error] =  "ERROR: #{exc.message}"
       session[:isErrorhandled] = 1
       session[:postedpamams]   = params
       isFlags = false
   end
 ############# END THREAD MESSAGE & HANDLING ##########
    redirect_to "#{root_url}attendance/leave_list"
  end
  def deletes
    @rsRoot = "#{root_url}attendance/shift_list"
    @MstShift = MstShift.find(params[:id])
    if @MstShift
       leavecode   = @MstShift.attend_shiftcode
       chkdekobj =  delete_checks_used(leavecode)
       if chkdekobj
           flash[:error] =  "Could not be deleted due to used in apply leave."
       else
         if @MstShift.destroy
          flash[:error] =  "Data deleted successfully."
         end

       end
        
    end
    redirect_to @rsRoot
  end
  
  def save_master_leave
    @compCodes     = session[:loggedUserCompCode]
     isFlags       = true
      mid               = params[:mid]
    begin
      if params[:attend_category] == '' || params[:attend_category] == nil
       flash[:error] = "Category is required"
    elsif params[:attend_leaveCode] == '' || params[:attend_leaveCode] == nil
       flash[:error] = "Leave code is required"
       isFlags       = false
    elsif params[:attend_leavetype] == '' || params[:attend_leavetype] == nil
      flash[:error] =  "Leave type is required"
      isFlags       =  false    
    else
        attendleavecode   = params[:attend_leaveCode].to_s.delete(' ').downcase
        cuurentleavecode  = params[:cuurentleavecode].to_s.delete(' ').downcase
        category          = params[:attend_category].to_s.delete(' ').downcase
       
        if mid.to_i >0
              if attendleavecode != cuurentleavecode && category !=nil && category !=''
               
                   @chekMstLeave = MstLeave.where("attend_compcode =? AND LOWER(attend_leaveCode) =? AND LOWER(attend_category) =?",@compCodes,attendleavecode,category);
                   if @chekMstLeave.length >0
                           flash[:error] =  "This leave code is already taken."
                           isFlags = false
                   end
              end
              if isFlags
                   leaveupdsobj  = MstLeave.where("attend_compcode =? AND id =?",@compCodes,mid).first
                   if leaveupdsobj
                     leaveupdsobj.update(params_leave)
                      flash[:error] =  "Data updated successfully."
                      isFlags = true
                   end
              end
        else
                  @chekMstLeave = MstLeave.where("attend_compcode =? AND LOWER(attend_leaveCode) =? AND LOWER(attend_category) =?",@compCodes,attendleavecode,category);
                   if @chekMstLeave.length >0
                           flash[:error] =  "This leave code is already taken."
                           isFlags = false
                   end
                   if isFlags
                          @MstLeave = MstLeave.new(params_leave)
                          if @MstLeave.save
                            flash[:error] =  "Data saved successfully."
                            isFlags = true
                          end
                     end

        end        
        
    end
    rescue Exception => exc
       flash[:error] =  "ERROR: #{exc.message}"
       session[:isErrorhandled] = 1
       
       isFlags = false
   end
    ############# THREAD MESSAGE & HANDLING ##########
    if !isFlags
      session[:isErrorhandled] = 1
      session[:req_attend_category]   = params[:attend_category]
       session[:req_attend_leaveCode]  = params[:attend_leaveCode]
       session[:req_attend_leavetype]  = params[:attend_leavetype]
       session[:req_attend_paidleave]  = params[:attend_paidleave]
       session[:req_attend_balancesleave]  = params[:attend_balancesleave]
       session[:req_attend_runworking]     = params[:attend_runworking]
       session[:req_attend_enchash]    = params[:attend_enchash]
    else
      session[:isErrorhandled] = nil
      session[:postedpamams]   = nil
       session[:req_attend_category]   = nil
       session[:req_attend_leaveCode]  = nil
       session[:req_attend_leavetype]  = nil
       session[:req_attend_paidleave]      = nil
       session[:req_attend_balancesleave]  = nil
       session[:req_attend_runworking]     = nil
       session[:req_attend_enchash]        = nil
      isFlags = true
    end
   
 ############# END THREAD MESSAGE & HANDLING ##########
    

    if mid.to_i >0
        if !isFlags
           redirect_to  "#{root_url}attendance/leave/"+mid.to_s
        else
          redirect_to  "#{root_url}attendance/leave_list"
        end
    else
          if !isFlags
             redirect_to  "#{root_url}attendance/leave"
          else
            redirect_to  "#{root_url}attendance/leave_list"
          end
    end

  end

  private
  def params_leave
    
    params[:attend_compcode]           = session[:loggedUserCompCode]
    params[:attend_leaveCode]          = params[:attend_leaveCode].to_s.delete(' ').upcase
    params[:attend_runworking]         = params[:attend_runworking]!=nil && params[:attend_runworking]!='' ? params[:attend_runworking]: 'B'
    params[:attend_enchash]            = params[:attend_enchash]!=nil && params[:attend_enchash]!='' ? params[:attend_enchash]: 'B'
    params[:attend_balanceforprevious] = params[:attend_balanceforprevious]!=nil && params[:attend_balanceforprevious]!='' ? params[:attend_balanceforprevious]: 'B'
    params[:attend_annualquota]        = params[:attend_annualquota]!=nil && params[:attend_annualquota]!='' ? params[:attend_annualquota]: 0
    params[:attend_accumulationleave]  = params[:attend_accumulationleave]!=nil && params[:attend_accumulationleave]!='' ? params[:attend_accumulationleave]: 0
    params[:attend_category]           = params[:attend_category] !=nil && params[:attend_category] !='' ? params[:attend_category] : ''
    
    params[:attend_creditrule]         = params[:attend_creditrule] !=nil && params[:attend_creditrule] !='' ? params[:attend_creditrule] : ''
    params[:attend_creditruledays]     = params[:attend_creditruledays] !=nil && params[:attend_creditruledays] !='' ? params[:attend_creditruledays] : 0
    params[:attend_mergeleave]         = params[:attend_mergeleave] !=nil && params[:attend_mergeleave] !='' ? params[:attend_mergeleave] : 'N'
    params[:attend_sundayleave]        = params[:attend_sundayleave] !=nil && params[:attend_sundayleave] !='' ? params[:attend_sundayleave] : 'N'

    params[:attend_leaveavailby]       = params[:attend_leaveavailby] !=nil && params[:attend_leaveavailby] !='' ? params[:attend_leaveavailby] : ''
    params[:attend_periodapply]        = params[:attend_periodapply] !=nil && params[:attend_periodapply] !='' ? params[:attend_periodapply] : ''
    params[:attend_totalsewarequired]  = params[:attend_totalsewarequired] !=nil && params[:attend_totalsewarequired] !='' ? params[:attend_totalsewarequired] : 0
    params[:attend_halfpermisable]     = params[:attend_halfpermisable] !=nil && params[:attend_halfpermisable] !='' ? params[:attend_halfpermisable] : 'N'
    params[:attend_leavetakenrow]      = params[:attend_leavetakenrow] !=nil && params[:attend_leavetakenrow] !='' ? params[:attend_leavetakenrow] : 0
    params[:attend_monthlyleave]       = params[:attend_monthlyleave] !=nil &&  params[:attend_monthlyleave] !='' ?  params[:attend_monthlyleave] : 0
    params[:attend_leavereqst]         = params[:attend_leavereqst] !=nil &&  params[:attend_leavereqst] !='' ?  params[:attend_leavereqst] : 'N'
    params[:attend_forefeitdays]       = params[:attend_forefeitdays] !=nil &&  params[:attend_forefeitdays] !='' ?  params[:attend_forefeitdays] : 0

   lsaply = ""
    if params[:attend_whocanapply] != nil && params[:attend_whocanapply] != ''
        params[:attend_whocanapply].each do |newfrms|
            lsaply += newfrms.to_s+","
        end
        if lsaply !=nil && lsaply !=''
          lsaply = lsaply.to_s.chop
        end
    end
    params[:attend_whocanapply] = lsaply
    params.permit(:attend_compcode,:attend_leavereqst,:attend_forefeitdays,:attend_monthlyleave,:attend_leaveavailby,:attend_creditrule,:attend_creditruledays,:attend_mergeleave,:attend_sundayleave,:attend_whocanapply,:attend_periodapply,:attend_totalsewarequired,:attend_halfpermisable,:attend_leavetakenrow,:attend_category,:attend_leaveCode,:attend_leavetype,:attend_paidleave,:attend_balancesleave,:attend_runworking,:attend_enchash,:attend_balanceforprevious,:attend_annualquota,:attend_accumulationleave)
  end

  def save_master_shift_leave
    @rxRoot = "#{root_url}attendance/shift"
    @compCodes     =   session[:loggedUserCompCode]
    isFlags = true
    begin
    if params[:attend_shiftcode] == ''
      flash[:error] =  "Please enter shift code!"
      isFlags = false
    elsif  @compCodes == ''
      flash[:error] =  "Undefine company code!"
      isFlags = false
    else
        
        if params[:attend_shfintime]!=nil && params[:attend_shfintime]!=''
            shfintime = params[:attend_shfintime].split(':')
            if shfintime[0].to_i <= 0
              flash[:error] =  "Shift In Time should be greater than zero"
              isFlags = false
            end
        elsif params[:attend_shfout]!=nil && params[:attend_shfout]!=''
            shfout = params[:attend_shfout].split(':')
            if shfout[0].to_i <= 0
              flash[:error] =  "Shift Out Time should be greater than zero"
              isFlags = false
            end
        end
        
        if isFlags
          if params[:attend_shfintime]!=nil && params[:attend_shfintime]!='' && params[:attend_shfout]!=nil && params[:attend_shfout]!=''
             if params[:attend_shfout].to_time < params[:attend_shfintime].to_time
               flash[:error] =  "Shift Out Time should be greater than In Time"
              isFlags = false
             end
          end
          
        end

       if isFlags
            if params[:attend_shfhrs] ==nil ||  params[:attend_shfhrs] == ''                
                shfhrs  = params[:attend_shfhrs].split(':')
                if shfhrs[0].to_i <= 0
                  flash[:error] =  "Please provide shift hours."
                  isFlags = false
                end

            end
       end
        cuurentcode      = params[:cuurentcode].to_s.delete(' ').upcase
        @attendshiftcode = params[:attend_shiftcode].to_s.delete(' ').upcase
        mid              = params[:mid]
        if mid.to_i >0
          if isFlags
                if @attendshiftcode!=cuurentcode
                    @chekMstShift    = MstShift.find_by_attend_shiftcode_and_attend_compcode(@attendshiftcode,@compCodes);
                    if  @chekMstShift
                        if @chekMstShift.attend_shiftcode.to_s == @attendshiftcode.to_s
                             flash[:error] =  "This shift code is already taken!"
                             isFlags = false
                        end
                     end
                end
                if isFlags
                  objup =  MstShift.where("attend_compcode=? AND id=? ",@compCodes,mid).first
                  if objup
                    objup.update(params_shift)
                    flash[:error] =  "Data updated successfully."
                     isFlags = true
                  end
                end
           end
        else
             if isFlags
                
                @chekMstShift    = MstShift.find_by_attend_shiftcode_and_attend_compcode(@attendshiftcode,@compCodes);
                 if  @chekMstShift
                    if @chekMstShift.attend_shiftcode.to_s == @attendshiftcode.to_s
                         flash[:error] =  "This shift code is already taken!"
                         isFlags       = false
                    end
                 end
             end
             if isFlags
                @MstShift = MstShift.new(params_shift)
                if @MstShift.save
                  flash[:error] =  "Data saved successfully."
                  isFlags       = true
                end

             end
        end
    end
    ############# THREAD MESSAGE & HANDLING ##########
  
   rescue Exception => exc
       flash[:error] =  "ERROR: #{exc.message}"
       session[:isErrorhandled] = 1
       session[:postedpamams]   = params
       isFlags = false
   end
   if !isFlags
    session[:isErrorhandled] = 1
    session[:postedpamams]   = params
  else
    session[:isErrorhandled] = nil
    session[:postedpamams]   = nil
    isFlags = true
  end
 ############# END THREAD MESSAGE & HANDLING ##########
   if !isFlags
     redirect_to  @rxRoot
   else
     redirect_to "#{root_url}/attendance/shift_list"
   end
    
  end

  private
  def params_shift
    @compCodes                =   session[:loggedUserCompCode]
    params[:attend_compcode]  =   @compCodes
    params[:attend_shiftcode] = params[:attend_shiftcode].to_s.delete(' ').upcase
    
    if params[:attend_nightshift]== nil || params[:attend_nightshift]==''
      params[:attend_nightshift] ='B'
    end
    
    if params[:attend_shfintime]==nil || params[:attend_shfintime]==''
      params[:attend_shfintime] = '0'
    end
    if params[:attend_shfout]== nil || params[:attend_shfout]==''
      params[:attend_shfout] ='0'
    end
    if params[:attend_shfhrs]== nil || params[:attend_shfhrs]==''
      params[:attend_shfhrs] =0
    end
    if params[:attend_starttime]== nil || params[:attend_starttime]==''
      params[:attend_starttime] ='0'
    end
    if params[:attend_endtime]== nil || params[:attend_endtime]==''
      params[:attend_endtime] ='0'
    end
    if params[:attend_endhours]== nil || params[:attend_endhours]==''
      params[:attend_endhours] ='0'
    end
    if params[:attend_absentforworking]== nil || params[:attend_absentforworking]==''
      params[:attend_absentforworking] =0
    end
    if params[:attend_presentforwork]== nil || params[:attend_presentforwork]==''
      params[:attend_presentforwork] =0
    end
    if params[:attend_othhrsallowed]== nil || params[:attend_othhrsallowed]==''
      params[:attend_othhrsallowed] =0
    end
    if params[:attend_otdeductafterhrs]== nil || params[:attend_otdeductafterhrs]==''
      params[:attend_otdeductafterhrs] =0
    end
     if params[:attend_otdeducthrs]== nil || params[:attend_otdeducthrs]==''
      params[:attend_otdeducthrs] =0
     end
     if params[:attend_outtime]== nil || params[:attend_outtime]==''
       params[:attend_outtime] ='00:00:00'
     end
     if params[:attend_intime]== nil || params[:attend_intime]==''
       params[:attend_intime] ='00:00:00'
     end
     if params[:attend_runworking]== nil || params[:attend_runworking]==''
       params[:attend_runworking] ='00:00:00'
     end
    
     params[:attend_ist]         = params[:attend_ist]!=nil && params[:attend_ist]!='' ? params[:attend_ist] : 'B'
     params[:attend_2nd]         = params[:attend_2nd]!=nil && params[:attend_2nd]!='' ? params[:attend_2nd] : 'B'
    params.permit(:attend_compcode,:attend_shiftcode,:attend_nightshift,:attend_shfintime,:attend_shfout,:attend_shfhrs,:attend_outtime,:attend_intime,:attend_runworking,:attend_starttime,:attend_endtime,:attend_endhours,:attend_absentforworking,:attend_presentforwork,:attend_othhrsallowed,:attend_otdeductafterhrs,:attend_otdeducthrs,:attend_ist,:attend_2nd,:attend_sat1st,:attend_sat2nd,:attend_sat3rd,:attend_sat4th,:attend_sat5th,:attend_sathaf1st,:attend_sathaf2nd,:attend_sathaf3rd,:attend_sathaf4th,:attend_sathaf5th)
  end
  def edit_shifting
    @edRoot = "#{root_url}attendance/shift"
    @compCodes       =   session[:loggedUserCompCode]    
    isFlags = true
    begin
    if params[:attend_shiftcode] == ''
      flash[:error] =  "Please enter shift code!"
      isFlags = false
    elsif  @compCodes == ''
      flash[:error] =  "Undefine company code!"
      isFlags = false
    else

        @attendshiftcode =  params[:attend_shiftcode].delete(' ').upcase
        @currentCodes    =  params[:currentCode].delete(' ').upcase
        @chekMstShift    =  MstShift.find_by_attend_shiftcode_and_attend_compcode(@attendshiftcode,@compCodes);        
        if @currentCodes != @attendshiftcode
            if @chekMstShift
                if @chekMstShift.attend_shiftcode.to_s == @ShiftCode.to_s
                  flash[:error] =  "This leave code is already taken!"
                  isFlags = false
                end
            end
        end
        if isFlags
          MstShift.find(params[:id]).update(params_shift)
          flash[:error] =  "Data updated successfully!!"
           isFlags = true
        end
    end
    ############# THREAD MESSAGE & HANDLING ##########
  if !isFlags
    session[:isErrorhandled] = 1
    session[:postedpamams]   = params
  else
    session[:isErrorhandled] = nil
    session[:postedpamams]   = nil
    isFlags = true
  end
   rescue Exception => exc
       flash[:error] =  "ERROR: #{exc.message}"
       session[:isErrorhandled] = 1
       session[:postedpamams]   = params
       isFlags = false
   end
 ############# END THREAD MESSAGE & HANDLING ##########
  redirect_to @edRoot
  end

  private
  def delete_checks_used(leavecode)
      compcodes = session[:loggedUserCompCode]
      mystatus = false
      trncheckdelt  = TrnLeave.where("ls_compcode=? AND ls_leave_code =?",compcodes,leavecode)
      if trncheckdelt.length >0
          #mystatus = true
      end
      return mystatus
  end

   private
  def apply_checks_used(leavecode)
      compcodes = session[:loggedUserCompCode]
      mystatus = false
      trncheckdelt  = TrnLeave.where("ls_compcode=? AND ls_leave_code =?",compcodes,leavecode)
      if trncheckdelt.length >0
          mystatus = true
      end
      return mystatus
  end
  
end
