## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common attend process according dated

class ProcessMachineDataController < ApplicationController
    before_action :require_login
    before_action :allowed_security
    skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
    include ErpModule::Common
    helper_method :currency_formatted,:formatted_date,:year_month_days_formatted,:get_leavemaster_detail

    def index
        @compCodes         = session[:loggedUserCompCode]
       
    end

    def create 
        @compCodes         = session[:loggedUserCompCode]
        if params[:requestserver]!=nil && params[:requestserver]!=''
            newdated   = params[:from_date]
            @from_date = newdated
           
            process_live_attendance_machine_data(@compCodes,newdated)
        end       
        redirect_to "#{root_url}process_machine_data"
    end
########## PROCESS LIVE MACHINE DATA #########################  
    private
    def process_live_attendance_machine_data(compcode,newselectdated)
        mysave       = 0 
        #Attandance_SPCETRA.csv
        dateobj = lastupdate_process_raw_data(compcode)
        if newselectdated !=nil && newselectdated!='' ###selected date wise process
             gcnowdate = year_month_days_formatted(newselectdated)
             
        else  ### NO DATE SELECTION IS REQUIRED
                if dateobj != '' && dateobj != nil
                    gcnowdate = year_month_days_formatted(dateobj)
                else
                    gcnowdate = year_month_days_formatted(Date.today)   
                end
       end
        if gcnowdate !=nil && gcnowdate!=''

                if newselectdated !=nil && newselectdated!=''    ### IF DATE IS SELECTED THEN   
                           
                        gcnowdates   = Date.parse(newselectdated)-1.days
                        gcnowdate    = year_month_days_formatted(gcnowdates) 
                        enddated     = year_month_days_formatted(newselectdated)
                        process_delete_last_records(compcode,enddated,gcnowdate)    
                else   ### WITHOUT DATE SELECTION
                        process_delete_last_records(compcode,gcnowdate)
                        #gcnowdate  = Date.parse(gcnowdate)-1.days
                        gcnowdate   = year_month_days_formatted(gcnowdate) 
                        enddated     = year_month_days_formatted(Date.today)    
                end
        end        
           
        newstartdate = Date.parse(gcnowdate.to_s)
        newenddate   = Date.parse(enddated.to_s)
        (newstartdate).upto(newenddate).each do |newlpdated|
            newdateds = Date.parse(newlpdated.to_s).strftime('%d%m%Y')    
            filename  = Rails.root.to_s+ '/attendance/'+newdateds.to_s+'.csv'     
            if File.exist?(filename)
                CSV.foreach(filename, headers: true) do |row|
                        usersid    = row["Code"] 
                        inpunch    = row["In Out"] !=nil && row["In Out"] !='' ? row["In Out"].to_s.strip : '' 
                        gcdate     = year_month_days_formatted(row["Punch Date"])
                        cvgcdate   = year_month_days_formatted(row["Punch Date Time"])
                        gctime     = row["Punch Time"]
                        if inpunch.to_s.upcase == 'IN'
                            if usersid !=nil && usersid !='' #&& cvgcdate >=gcnowdate #cvgcdate >='2022-09-19' && cvgcdate <='2022-09-20' #cvgcdate >=gcnowdate                
                                process_raw_data(compcode,cvgcdate,gctime,usersid)
                                mysave +=1
                            end
                        end    
                end
            end
    end
        if mysave.to_i >0
            flash[:error] =  "Data saved successfully."
            isFlags       =  true
            session[:isErrorhandled] = nil
        end
    end

    private
    def process_raw_data(compcode,gcdate,gctime,usersid)
      rawobjs =   TrnGeoLocation.new(:gc_compcode=>compcode,:gc_date=>gcdate,:gc_time=>gctime,:gc_user_id=>usersid,:gc_local_time=>gctime,:gc_punchtype=>'R',:gc_customer_id=>0)
      rawobjs.save
    end

    private
    def lastupdate_process_raw_data(compcode)
        dates   = ''
        rawobjs =   TrnGeoLocation.where("gc_compcode = ?",compcode).order("gc_date DESC").first
        if rawobjs
        dates = rawobjs.gc_date
        end
        return dates
    end
    private
    def process_delete_last_records(compcode,lastdated,fromdated="")
        needated = year_month_days_formatted(lastdated)
        if( fromdated !=nil && fromdated!='')
            rawobjs = TrnGeoLocation.where("gc_compcode = ? AND gc_date>=? AND gc_date<=?",compcode,year_month_days_formatted(fromdated),needated)
        else
            rawobjs = TrnGeoLocation.where("gc_compcode = ? AND gc_date=?",compcode,needated)
        end
        
        if rawobjs.length >0
            rawobjs.destroy_all
        end
    end


end
