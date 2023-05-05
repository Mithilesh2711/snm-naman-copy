class MstSewadar < ApplicationRecord
  def self.to_generate_sewadar_list
    attributes = %w{Comp_code Year Month SewadarCode Sewadar_Name WD EL CL WO}
    attributes1 = %w{sw_compcode myear mymonth sw_sewcode sw_sewadar_name Present EL CL WO}
    CSV.generate(:headers=> true) do |csv|
      csv << attributes
        if all.length >0
              all.each do |user|
                   yrsobj = get_month_years(user.sw_compcode);
                   if yrsobj
                     user.myear   = yrsobj.hph_years
                     user.mymonth = get_month_detail(yrsobj)
                   end
                   csv << attributes1.map{ |attr| user.send(attr) }
              end
        end
    end
end

def self.to_get_birthday_listed
  attributes = %w{SewadarCode 	Name 	Department 	DateofBirth 	Location 	SubLocation}
  attributes1 = %w{sw_sewcode sw_sewadar_name department birthdays location sublocation}
  CSV.generate(:headers=> true) do |csv|
    csv << attributes
      if all.length >0
        if $voucherdata.length >0
              $voucherdata.each do |user|                 
                 csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
      end
  end
end

################SEWADAR CARD LISTED ##################
def self.to_get_sewacard_listed
  attributes = %w{SewadarCode 	Name 	Department }
  attributes1 = %w{sw_sewcode sw_sewadar_name department}
  headers    = ["Sewsara Card List","","","",""]
  headers2    = ["Category : "+$categiry_name,"","","",""]
  CSV.generate(:headers=> true) do |csv|
    csv << headers
    csv << headers2
    csv << attributes
      if all.length >0
        if $voucherdata.length >0
              $voucherdata.each do |user|                 
                 csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
      end
  end
end


########### END SEWDARA CARD LISTED ###############

def self.get_month_detail(months)
     monthsstr = ""
     months   = months.hph_months
     if  months.to_i == 1
          monthsstr = "January"
     elsif  months.to_i == 2
          monthsstr = "February"
     elsif  months.to_i == 3
          monthsstr = "March"
     elsif  months.to_i == 4
          monthsstr = "April"
     elsif  months.to_i == 5
          monthsstr = "May"
     elsif  months.to_i == 6
          monthsstr = "June"
     elsif  months.to_i == 7
          monthsstr = "July"
     elsif  months.to_i == 8
          monthsstr = "August"
     elsif  months.to_i == 9
          monthsstr = "September"
     elsif  months.to_i == 10
          monthsstr = "October"
     elsif  months.to_i == 11
          monthsstr = "November"
     elsif  months.to_i == 12
          monthsstr = "December"
     end
     return monthsstr

end
def self.get_month_years(compcodes)
    headparmobj  =  MstHrParameterHead.select("hph_years,hph_months").where("hph_compcode = ?",compcodes).first
    return headparmobj
end
def self.import(file)
     
     $xcount = 0
    if $isimport == 'sewadarrevsied'
      spreadsheet = open_spreadsheet(file)
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
            row = Hash[[header, spreadsheet.row(i)].transpose]
            sewoldcode    =  (row["oldcode"].to_s.length >0 )? row["oldcode"] : ''
            revisedcode   =  (row["revisedcode"].to_s.length >0 )? row["revisedcode"] : ''            
            dob           =  (row["dob"].to_s.length >0 )? row["dob"] : 0
            datejoining   =  (row["datejoining"].to_s.length >0 )? row["datejoining"] : 0
            dateregul     =  (row["dateregul"].to_s.length >0 )? row["dateregul"] : 0
            daresupanum   =  (row["daresupanum"].to_s.length >0 )? row["daresupanum"] : 0
            department    =  (row["department"].to_s.length >0 )? row["department"] : ''
            location      =  (row["location"].to_s.length >0 )? row["location"] : ''
            accomodation  =  (row["accomodation"].to_s.length >0 )? row["accomodation"] : ''
            gender        =  (row["gender"].to_s.length >0 )? row["gender"] : ''
            category      =  (row["category"].to_s.length >0 )? row["category"] : ''
            names         =  (row["swname"].to_s.length >0 )? row["swname"] : ''
            departcode    =  (row["departcode"].to_s.length >0 )? row["departcode"] : ''
            catcode       =  (row["catcode"].to_s.length >0 )? row["catcode"] : ''
            obs           =  (row["obs"].to_s.length >0 )? row["obs"] : 0 
            installmt     =  (row["installment"].to_s.length >0 )? row["installment"] : 0 

            #######LEAVE OPENING BALANCES ####################################
            obalance      =  (row["obalance"].to_s.length >0 )? row["obalance"] : 0 
            elcredited    =  (row["elcredited"].to_s.length >0 )? row["elcredited"] : 0 
            eltotal       =  (row["eltotal"].to_s.length >0 )? row["eltotal"] : 0 
            clcredited    =  (row["clcredited"].to_s.length >0 )? row["clcredited"] : 0 
            eltype        =  row["eltype"]
            cltype        =  row["cltype"]
           ############## END LEAVE OPENING BALANCES ############################

           #sewdobj   = process_credited_leave_listed($compcodes,'EL',revisedcode,elcredited)
           sewdobj    = process_credited_leave_listed($compcodes,'CL',revisedcode,clcredited)
           #sewdobj   = process_leave_balances_CL($compcodes,revisedcode,obalance,elcredited,eltotal,clcredited,cltype)
           #sewdobj   = process_leave_balances_EL($compcodes,revisedcode,obalance,elcredited,eltotal,clcredited,eltype)
            #sewdobj  = process_monthly_advance_data($compcodes,revisedcode,obs,installmt)
            #sewdobj  =  new_update_sewadar($compcodes,revisedcode,names,category,dob,datejoining,dateregul,gender,daresupanum,department,location,accomodation)
            #sewdobj   =  update_category_department($compcodes,revisedcode,category,departcode,catcode,accomodation)
            if sewdobj
              $xcount +=1
            end
    end
  end

end

def self.process_leave_balances_EL(compcode,revisedcode,obalance,elcredited,eltotal,clcredited,eltype)
      trnobj = TrnLeaveBalance.where("lb_compcode =? AND lb_empcode =? AND lb_leavecode =?",compcode,revisedcode,eltype).first
      if trnobj
         ## EXECUTE IF REQUIRED
      else
        newcbs = obalance.to_f+elcredited.to_f
          svsobj = TrnLeaveBalance.new(:lb_compcode=>compcode,:lb_empcode=>revisedcode,:lb_leavecode=>eltype,:lb_openbal=>obalance,:lb_closingbal=>newcbs,:lb_year=>0)
          svsobj.save
      end
end

def self.process_leave_balances_CL(compcode,revisedcode,obalance,elcredited,eltotal,clcredited,cltype)
  trnobj = TrnLeaveBalance.where("lb_compcode =? AND lb_empcode =? AND lb_leavecode =?",compcode,revisedcode,cltype).first
  if trnobj
     ## EXECUTE IF REQUIRED
  else
    newcbs   = clcredited
    obalance = 0
      svsobj = TrnLeaveBalance.new(:lb_compcode=>compcode,:lb_empcode=>revisedcode,:lb_leavecode=>cltype,:lb_openbal=>obalance,:lb_closingbal=>newcbs,:lb_year=>0)
      svsobj.save
  end
end

def self.process_credited_leave_listed(compcode,leavecode,sewcode,credays)
  dateds = '2022-01-01'
   crdlvobj =  TrnCreditLeave.where("cl_compcode =? AND cl_leavecode =? AND cl_sewacode =?",compcode,leavecode,sewcode).first
    if crdlvobj
        ### execute if required
    else
        svsobj = TrnCreditLeave.new(:cl_compcode=>compcode,:cl_leavecode=>leavecode,:cl_sewacode=>sewcode,:cl_creditdays=>credays,:cl_creditdate=>dateds)
        svsobj.save
    end
end



def self.process_monthly_advance_data(compcode,sewacode,obalance,installment)
    departcode = get_departmentform_sewadar(compcode,sewacode)
    reqnumber  = generated_requestno(compcode)
    rqdated    = Date.today
    loantype   = "Loan" 
    trnobjsv   = TrnAdvanceLoan.new(:al_compcode=>compcode,:al_requestno=>reqnumber,:al_requestdate=>rqdated,:al_loanamount=>obalance,:al_installpermonth=>installment,:al_sewadarcode=>sewacode,:al_depcode=>departcode,:al_requesttype=>loantype)
    trnobjsv.save

end

def self.get_departmentform_sewadar(compcode,revisecode)
    departcode = ""
    seobjs = MstSewadar.where("sw_compcode = ? AND sw_sewcode = ?",compcode,revisecode).first
    if seobjs
      departcode = seobjs.sw_depcode
    end
    return departcode
end

def self.update_category_department(compcode,revisecode,category,departcode,catcode,accomodation)
  accomd = ''
  if accomodation && accomodation.to_s == 'YES'
    accomd = 'Y'
  else
    accomd = 'N'
  end
   seobjs = MstSewadar.where("sw_compcode = ? AND sw_sewcode = ?",compcode,revisecode).first
  if seobjs
      #seobjs.update(:sw_catgeory=>category,:sw_catcode=>catcode)
       seobjs.update(:sw_isaccommodation=>accomd)
    end

end


def self.new_update_sewadar(compcode,revisecode,name,category,dob,datejoining,dateregul,gender,daresupanum,department,location,accomodation)
  #  seobjs = MstSewadar.where("sw_compcode =? AND sw_sewcode = ?",compcode,cuurentcode).first
  #  if seobjs
  #    seobjs.update(:sw_revisedcode=>revisecode,:sw_revisedoldcode=>oldrevise)
  #  end
  
  name         = name !=nil && name !='' ? name.to_s.strip : ''
  dob          = dob !=nil && dob !=''? dob : 0
  datejoining  = datejoining !=nil && datejoining!='' ? mys_year_month_days_formatted(datejoining) : 0
  dateregul    = dateregul !=nil && dateregul!='' ? mys_year_month_days_formatted(dateregul) : 0
  daresupanum  = daresupanum !=nil && daresupanum !='' ? mys_year_month_days_formatted(daresupanum) : 0
  locids       = get_location_listed(compcode,location)
  sw_gender   = ''
  if gender !=nil && gender !='' && gender.to_s.downcase == 'male'
    sw_gender = 'M'
  elsif gender !=nil && gender !='' && gender.to_s.downcase == 'female'
    sw_gender = 'F'
  end

  if accomodation !=nil && accomodation !='' && accomodation.to_s.downcase == 'yes'
    sw_isaccommodation    = 'Y'
    sw_iselectricconsump  = 'Y'
  else
    sw_isaccommodation    = 'N'
    sw_iselectricconsump  = 'N' 
  end


  sewdarobj =  MstSewadarOfficeInfo.where("so_compcode =? AND so_sewcode =?",compcode,revisecode).first
  if sewdarobj
    sewdarobj.update(:so_joiningdate=>datejoining,:so_regularizationdate=>dateregul,:so_superannuationdate=>daresupanum)
  end

  #  seobjs = MstSewadar.where("sw_compcode =? AND sw_sewcode = ?",compcode,revisecode).first
  #  if seobjs
  #     seobjs.update(:sw_joiningdate=>datejoining,:sw_gender=>sw_gender,:sw_location=>locids,:sw_sewadar_name=>name,:sw_date_of_birth=>dob,:sw_isaccommodation=>sw_isaccommodation,:sw_iselectricconsump=>sw_iselectricconsump)
  #   end


  # seobjs = MstSewadar.new(:sw_compcode=>compcode,:sw_joiningdate=>0,:sw_leavingdate=>0,:sw_catgeory=>'SD-Permanent',:sw_catcode=>'SD',:sw_sewadar_name=>'',:sw_date_of_birth=>0,:sw_sewcode=>revisecode,:sw_revisedcode=>revisecode,:sw_revisedoldcode=>oldrevise)
  # seobjs.save

  #fill_kyc_2(compcode,revisecode,cuurentcode)
  # fill_bank_2(compcode,revisecode,cuurentcode)
  # fill_qualif(compcode,revisecode,cuurentcode)
  #fill_office_2(compcode,revisecode,cuurentcode)
  #fill_personal_2(compcode,revisecode,cuurentcode)
  # fill_experience(compcode,revisecode,cuurentcode)
  #fill_family(compcode,revisecode,cuurentcode)
end


def self.mys_year_month_days_formatted(dates)
    newdate = ''
    if dates!=nil && dates !='' && dates.to_s != '0' 
          dts    = Date.parse(dates.to_s)
          newdate = dts.strftime("%Y-%m-%d")
    end
    return newdate
end
def self.get_location_listed(compcode,locname)
  locid = 0
  locname = locname !=nil && locname !='' ? locname.to_s.strip : ''
  headsobj    = MstHeadOffice.where("hof_compcode =? AND LOWER(hof_description) =?",compcode,locname.downcase).first
  if headsobj
    locid = headsobj.id
  end
  return locid
end

def self.update_sewadar(compcode,revisecode,cuurentcode,oldrevise)
  #  seobjs = MstSewadar.where("sw_compcode =? AND sw_sewcode = ?",compcode,cuurentcode).first
  #  if seobjs
  #    seobjs.update(:sw_revisedcode=>revisecode,:sw_revisedoldcode=>oldrevise)
  #  end

   seobjs = MstSewadar.where("sw_compcode =? AND sw_sewcode = ?",compcode,revisecode).first
   if seobjs
      seobjs.update(:sw_joiningdate=>0,:sw_leavingdate=>0,:sw_catgeory=>'SD-Permanent',:sw_catcode=>'SD',:sw_sewadar_name=>'',:sw_date_of_birth=>0)
    end

  # seobjs = MstSewadar.new(:sw_compcode=>compcode,:sw_joiningdate=>0,:sw_leavingdate=>0,:sw_catgeory=>'SD-Permanent',:sw_catcode=>'SD',:sw_sewadar_name=>'',:sw_date_of_birth=>0,:sw_sewcode=>revisecode,:sw_revisedcode=>revisecode,:sw_revisedoldcode=>oldrevise)
  # seobjs.save

  #fill_kyc_2(compcode,revisecode,cuurentcode)
  # fill_bank_2(compcode,revisecode,cuurentcode)
  # fill_qualif(compcode,revisecode,cuurentcode)
  #fill_office_2(compcode,revisecode,cuurentcode)
  fill_personal_2(compcode,revisecode,cuurentcode)
  # fill_experience(compcode,revisecode,cuurentcode)
  #fill_family(compcode,revisecode,cuurentcode)
end

def self.fill_kyc_2(compcode,revisecode,cuurentcode)
    kycobj = MstSewadarKyc.new(:sk_compcode=>compcode,:sk_sewcode=>revisecode,:sk_revisedcode=>revisecode)
    kycobj.save
end

def self.fill_kyc(compcode,revisecode,cuurentcode)
  kycobj = MstSewadarKyc.where("sk_compcode = ? AND sk_sewcode = ?",compcode,cuurentcode)
  if kycobj
    kycobj.update_all(:sk_revisedcode=>revisecode)
  end
end
def self.fill_bank_2(compcode,revisecode,cuurentcode)
    kycobj = MstSewadarKycBank.new(:skb_compcode=>compcode,:sbk_sewcode=>revisecode,:skb_revisedcode=>revisecode)
    kycobj.save
end

def self.fill_bank(compcode,revisecode,cuurentcode)
  kycobj = MstSewadarKycBank.where("skb_compcode = ? AND sbk_sewcode = ?",compcode,cuurentcode)
  if kycobj
    kycobj.update_all(:skb_revisedcode=>revisecode)
  end
end

def self.fill_qualif(compcode,revisecode,cuurentcode)
  kycobj = MstSewadarKycQualification.where("skq_compcode = ? AND skq_sewcode = ?",compcode,cuurentcode)
  if kycobj
    kycobj.update_all(:skq_revisedcode=>revisecode)
  end
end
def self.fill_office_2(compcode,revisecode,cuurentcode)
    kycobj = MstSewadarOfficeInfo.new(:so_compcode=>compcode,:so_sewcode=>revisecode,:so_revisedcode=>revisecode)
    kycobj.save
end

def self.fill_office(compcode,revisecode,cuurentcode)
  kycobj = MstSewadarOfficeInfo.where("so_compcode = ? AND so_sewcode = ?",compcode,cuurentcode)
  if kycobj
    kycobj.update_all(:so_revisedcode=>revisecode)
  end
end

def self.fill_personal_2(compcode,revisecode,cuurentcode)
    kycobj = MstSewadarPersonalInfo.new(:sp_compcode=>compcode,:sp_sewcode=>revisecode,:sp_revisedcode=>revisecode)
    kycobj.save
end
def self.fill_personal(compcode,revisecode,cuurentcode)
  kycobj = MstSewadarPersonalInfo.where("sp_compcode = ? AND sp_sewcode = ?",compcode,cuurentcode)
  if kycobj
    kycobj.update_all(:sp_revisedcode=>revisecode)
  end
end

def self.fill_experience(compcode,revisecode,cuurentcode)
  kycobj = MstSewadarWorkExperience.where("swe_compcode = ? AND swe_sewcode = ?",compcode,cuurentcode)
  if kycobj
     kycobj.update_all(:swe_revisedcode=>revisecode)
  end
end
def self.fill_family(compcode,revisecode,cuurentcode)
  kycobj = MstSewdarKycFamilyDetail.where("skf_compcode = ? AND skf_sewcode = ?",compcode,cuurentcode)
  if kycobj
     kycobj.update_all(:skf_revisedcode=>revisecode)
  end
end
def self.open_spreadsheet(file)
  case File.extname(file.original_filename)
  when ".csv" then Roo::CSV.new(file.path, :packed=> nil, :file_warning=> :ignore)
  when ".xls" then Roo::Excel.new(file.path, :packed=> nil, :file_warning=> :ignore)
  when ".xlsx" then Roo::Excelx.new(file.path, :packed=> nil, :file_warning=> :ignore)
  else raise "Unknown file type: #{file.original_filename}"
  end
end

def self.generated_requestno(compCodes)
    @isCode     = 0
    @Startx     = '0000'
    @recCodes   = TrnAdvanceLoan.where(["al_compcode =? AND al_requestno >0 ",compCodes]).order('al_requestno DESC').first
    if @recCodes
       @isCode   = @recCodes.al_requestno.to_i
    end
    @sumXOfCode    = @isCode.to_i + 1
    if  @sumXOfCode.to_s.length < 2
      @sumXOfCode = p @Startx.to_s + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length < 3
      @sumXOfCode = p "000" + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length < 4
      @sumXOfCode = p "00" + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length < 5
      @sumXOfCode = p "0" + @sumXOfCode.to_s
    elsif @sumXOfCode.to_s.length >=5
      @sumXOfCode =  @sumXOfCode.to_i
    end
    return @sumXOfCode
end



end
