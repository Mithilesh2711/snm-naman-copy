class TrnPayMonthly < ApplicationRecord
  def self.import(file)
    $xcount = 0
    if $isimport == 'monthly'
      accessible_attributes=["pm_compcode","pm_sewacode","pm_paymonth","pm_payyear","pm_workingday","pm_paidleave","pm_wo"]
      spreadsheet = open_spreadsheet(file)
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
          row = Hash[[header, spreadsheet.row(i)].transpose]
          if  row["pm_compcode"].to_s == '' || row["pm_compcode"].to_s == nil
              row["pm_compcode"] = $compcodes
          end
           row["pm_sewacode"]           =  (row["SewadarCode"].to_s.length >0 )? row["SewadarCode"].to_s.strip : ''
           row["pm_paymonth"]           =  (row["Month"].to_s.length >0 )? row["Month"].to_s.strip : ''
           row["pm_payyear"]            =  (row["Year"].to_s.length >0 )? row["Year"].to_s.strip : ''
           row["pm_workingday"]         =  (row["WD"].to_s.length >0 )? row["WD"].to_s.strip : 0
           row["pm_wo"]                 =  (row["WO"].to_s.length >0 )? row["WO"].to_s.strip : 0
           cl                           =  (row["CL"].to_s.length >0 )? row["CL"].to_s.strip : 0
           el                           =  (row["EL"].to_s.length >0 )? row["EL"].to_s.strip : 0
           paidleaves                   =  cl.to_i+el.to_i
           row["pm_paidleave"]          =  paidleaves          
           
          if process_update_importedsewa(row["pm_compcode"],row["pm_sewacode"] , row["pm_paymonth"], row["pm_payyear"] ,row["pm_workingday"],row["pm_paidleave"],row["pm_wo"])
               product = find_by_id(row["id"]) || new
               product.attributes = row.to_hash.slice(*accessible_attributes)
               product.save!
               $xcount +=1
          end
     end
  end

end

def self.process_update_importedsewa(pm_compcode,pm_sewacode,pm_paymonth,pm_payyear,pm_workingday,pm_paidleave,pm_wo)
       isfalse   = true
       trnsseobj = TrnPayMonthly.where("pm_compcode = ? AND pm_sewacode =? AND pm_paymonth =? AND pm_payyear =?",pm_compcode,pm_sewacode,pm_paymonth,pm_payyear).first
       if trnsseobj
              trnsseobj.update(:pm_paymonth=>pm_paymonth,:pm_payyear=>pm_payyear,:pm_workingday=>pm_workingday,:pm_paidleave=>pm_paidleave,:pm_wo=>pm_wo)
              isfalse = false
       end
       return isfalse
end

def self.process_excel_data
     headers5    = ["Bank Transfer Detail","","","",""]
     headers6    = [""+ $mymonths.to_s+"-"+$myyears.to_s,"","",""]   
     #,:allowance1=>allowance1,:allowance2=>allowance2,:deduction1=>deduction1,:deduction2=>deduction2  
     
     if $printdatatype.to_s == 'BK'
          # attributes   = %w{AccountNo WD PL HL WO Absent GrossMA Arrear MA LIC Building Electricity AdvanceUpto60k AdvanceAbove60k MAAdvance SpecialAdvance WheatAdvance Health IncomeTax TotalDeduction NetMA}
          # attributes1 = %w{bankaccount pm_workingday pm_paidleave pm_hl pm_wo pm_absent pmactbasic pmarear pmbasic pmdedlicemployee pmdedaccomodatamount pmdedelectricamount uptosixty abovesixty maadvance specialadvance wheatadvance pmdedhealthsewdarpay pmincometaxamount pmtotaldeduction pmnetpay}
           attributes   = %w{Name BankName AccountNo IFSCCODE NetPayable}
           attributes1  = %w{sw_sewadar_name skb_bank accountno skb_ifccocde mynetpay}
     
     elsif $printdatatype.to_s == 'CT' 
          attributes   = %w{Category WD PL HL WO Absent GrossMA Arrear Allowance1 allowance2 Deduction1 Deduction2 MA LIC Building Electricity AdvanceUpto60k AdvanceAbove60k MAAdvance SpecialAdvance WheatAdvance Health IncomeTax TotalDeduction NetMA}
          attributes1 = %w{categoryname pm_workingday pm_paidleave pm_hl pm_wo pm_absent pmactbasic pmarear allowance1  allowance2 deduction1 deduction2 pmbasic pmdedlicemployee pmdedaccomodatamount pmdedelectricamount uptosixty abovesixty maadvance specialadvance wheatadvance pmdedhealthsewdarpay pmincometaxamount pmtotaldeduction pmnetpay}
     elsif $printdatatype.to_s == 'DT' 
          attributes   = %w{Department WD PL HL WO Absent GrossMA Arrear Allowance1 allowance2 Deduction1 Deduction2 MA LIC Building Electricity AdvanceUpto60k AdvanceAbove60k MAAdvance SpecialAdvance WheatAdvance Health IncomeTax TotalDeduction NetMA}
          attributes1 = %w{department pm_workingday pm_paidleave pm_hl pm_wo pm_absent pmactbasic pmarear allowance1  allowance2 deduction1 deduction2 pmbasic pmdedlicemployee pmdedaccomodatamount pmdedelectricamount uptosixty abovesixty maadvance specialadvance wheatadvance pmdedhealthsewdarpay pmincometaxamount pmtotaldeduction pmnetpay}
             
     else
          attributes = %w{SewadarCode SewadarName category Department AccountNo  WD PL HL WO Absent GrossMA Arrear Allowance1 allowance2 Deduction1 Deduction2 MA LIC Building Electricity AdvanceUpto60k AdvanceAbove60k MAAdvance SpecialAdvance WheatAdvance Health IncomeTax TotalDeduction NetMA ArrearRemarks AllowanceRemarkFirst AllowanceRemarkSecond DeductionRemarkFirst DeductionRemarkSecond}
          attributes1 = %w{pm_sewacode sw_sewadar_name categoryname deprtment bankaccount  pm_workingday pm_paidleave pm_hl pm_wo pm_absent pmactbasic pmarear allowance1  allowance2 deduction1 deduction2 pmbasic pmdedlicemployee pmdedaccomodatamount pmdedelectricamount uptosixty abovesixty maadvance specialadvance wheatadvance pmdedhealthsewdarpay pmincometaxamount pmtotaldeduction pmnetpay pm_arearremarks pm_allowanremarkfirst pm_allowanceremksecond pm_dedremarkfirst pm_dedremarksecond}
          

     end
    
      
      
      
      pitems  = []
     isselect =  "'Total' as pm_sewacode,'' as sw_sewadar_name,'' as bankaccount,'' as deprtment,'' as pm_workingday,'' as pm_paidleave,'' as pm_hl,'' as pm_wo,'' as pm_absent"
     isselect += ", '' as pmactbasic,'' as pmarear,'' as pmbasic,'' as pmdedlicemployee,'' as pmdedaccomodatamount ,'' as pmdedelectricamount,'' as pmdedrepaidadvance,'' as pmdedrepaidloan "
     isselect += ", '' as pmdedhealthsewdarpay,'' as pmincometaxamount,'' as pmtotaldeduction,'' as pmnetpay,'' as categoryname,'' as department"
     isselect += ", '' as uptosixty,'' as abovesixty,'' as exgratia,'' as maadvance,'' as wheatadvance,'' as specialadvance,'' as pmactbasic1"
     isselect += ",'' as sw_sewadar_name,'' as  skb_bank,'' as  skb_accountno,'' as skb_ifccocde,'' as pm_netpay,'' as accountno,'' as mynetpay"
     isselect  += ",'' as allowance1,'' as allowance2,'' as deduction1,'' as deduction2,'' as pm_arearremarks,'' as pm_allowanremarkfirst,'' as pm_allowanceremksecond,'' as pm_dedremarkfirst,'' as pm_dedremarksecond"
     if all.length >0
           if $voucherdata.length
                   $voucherdata.each do |newregister|
                    if $printdatatype.to_s == 'BK'
                         newregister.accountno = "`"+newregister.skb_accountno.to_s
                    end
                    # if $printdatatype.to_s == 'SR'       
                    #         newregister.pmactbasic           = currencyformatted(newregister.pm_actbasic)
                    #         newregister.pmarear              = currencyformatted(newregister.pm_arear)
                    #         newregister.pmbasic              = currencyformatted(newregister.pm_basic)
                    #         newregister.pmdedlicemployee     = currencyformatted(newregister.pm_ded_licemployee)
                    #         newregister.pmdedaccomodatamount = currencyformatted(newregister.pm_dedaccomodatamount)
                    #         newregister.pmdedelectricamount  = currencyformatted(newregister.pm_ded_electricamount)
                    #         newregister.pmdedrepaidadvance   = currencyformatted(newregister.pm_ded_repaidadvance)
                    #         newregister.pmdedrepaidloan      = currencyformatted(newregister.pm_ded_repaidloan)

                    #         newregister.pmdedhealthsewdarpay  = currencyformatted(newregister.pm_ded_healthsewdarpay)
                    #         newregister.pmincometaxamount     = currencyformatted(newregister.pm_totaltds)
                    #         newregister.pmtotaldeduction      = currencyformatted(newregister.pm_totaldeduction)
                    #         newregister.pmnetpay              = currencyformatted(newregister.pm_netpay)
                    # end
                            pitems.push newregister
                   end
           end
     end
     subobj   = TrnPrawnTable.select(isselect).all
     if subobj.length >0
        subobj.each do |mysub|
            pitems.push mysub
        end
     end
     tworkingday = 0
     tpaidleave  = 0
     thalfleave  = 0
     tweeklyoff  = 0
     tabsent     = 0
     tgrossma    = 0
     tarears     = 0
     tmabasic    = 0
     tlicamt     = 0
     tbuldamt    = 0
     telectric   = 0
     trepaid     = 0
     thealth     = 0
     tincomtax   = 0
     tdeduction  = 0
     tnetpay     = 0
     tloans      = 0
     tuptoxisty  = 0
     tabovesixty = 0
     tmadvance   = 0
     tspecial    = 0
     twheatadv   = 0
     tnetpayment = 0
    CSV.generate(:headers=> true) do |csv|
     if $printdatatype.to_s == 'BK'
          csv << headers5
          csv << headers6
     end
          csv << attributes
           if pitems.length >0
                pitems.each do |newsalry|
                    if newsalry.pm_sewacode != 'Total'
                         if $printdatatype.to_s != 'BK'
                              tworkingday += newsalry.pm_workingday.to_f
                              tpaidleave  += newsalry.pm_paidleave.to_f
                              thalfleave  += newsalry.pm_hl.to_f
                              tweeklyoff  += newsalry.pm_wo.to_f
                              tabsent     += newsalry.pm_absent.to_f
                              tgrossma    += newsalry.pmactbasic.to_f
                              tarears     += newsalry.pmarear.to_f
                              tmabasic    += newsalry.pmbasic.to_f
                              tlicamt     += newsalry.pmdedlicemployee.to_f
                              tbuldamt    += newsalry.pmdedaccomodatamount.to_f
                              telectric   += newsalry.pmdedelectricamount.to_f
                              #trepaid    += newsalry.pmdedrepaidadvance.to_f
                              thealth     += newsalry.pmdedhealthsewdarpay.to_f
                              tincomtax   += newsalry.pmincometaxamount.to_f
                              tdeduction  += newsalry.pmtotaldeduction.to_f
                              tnetpay     += newsalry.pmnetpay.to_f
                              tuptoxisty  += newsalry.uptosixty.to_f
                              tabovesixty += newsalry.abovesixty.to_f
                              tmadvance   += newsalry.maadvance.to_f
                              tspecial    += newsalry.specialadvance.to_f
                              twheatadv   += newsalry.wheatadvance.to_f
                         else
                             tnetpayment  += newsalry.pm_netpay.to_f
                         end
                        #tloans      += newsalry.pmdedrepaidloan.to_f
                        csv << attributes1.map{ |attr| newsalry.send(attr) }
                   elsif newsalry.pm_sewacode == 'Total'
                    if $printdatatype.to_s != 'BK'
                         newsalry.pm_workingday         = tworkingday
                         newsalry.pm_paidleave          = tpaidleave
                         newsalry.pm_hl                 = thalfleave
                         newsalry.pm_wo                 = tweeklyoff
                         newsalry.pm_absent             = tabsent
                         newsalry.pmactbasic            = currencyformatted(tgrossma)
                         newsalry.pmarear               = currencyformatted(tarears)
                         newsalry.pmbasic               = currencyformatted(tmabasic)
                         newsalry.pmdedlicemployee      = currencyformatted(tlicamt)
                         newsalry.pmdedaccomodatamount  = currencyformatted(tbuldamt)
                         newsalry.pmdedelectricamount   = currencyformatted(telectric)
                         #newsalry.pmdedrepaidadvance   = currencyformatted(trepaid)
                         newsalry.pmdedhealthsewdarpay  = currencyformatted(thealth)
                         newsalry.pmincometaxamount     = currencyformatted(tincomtax)
                         newsalry.pmtotaldeduction      = currencyformatted(tdeduction)
                         newsalry.pmnetpay              = currencyformatted(tnetpay)
                         #newsalry.pmdedrepaidloan      = currencyformatted(tloans)
                         newsalry.uptosixty             = currencyformatted(tuptoxisty)
                         newsalry.abovesixty            = currencyformatted(tabovesixty)
                         newsalry.maadvance             = currencyformatted(tmadvance)
                         newsalry.specialadvance        = currencyformatted(tspecial)
                         newsalry.wheatadvance          = currencyformatted(twheatadv)  
                    else
                         newsalry.sw_sewadar_name    = 'Total'
                         newsalry.pm_netpay          = currencyformatted(tnetpayment) 
                         newsalry.mynetpay            = currencyformatted(tnetpayment) 
                         
                    end

                        csv << attributes1.map{ |attr| newsalry.send(attr) }
                   end
                end
            end
      end
end

def self.check_email(email)
    isemail = find_by_cs_emailaddress(email)
     return isemail
 end
def self.check_phone(phone)
    isemail = find_by_cs_mobilenumber(phone)
    return isemail
 end
def self.open_spreadsheet(file)
  case File.extname(file.original_filename)
  when ".csv" then Roo::CSV.new(file.path, :packed=> nil, :file_warning=> :ignore)
  when ".xls" then Roo::Excel.new(file.path, :packed=> nil, :file_warning=> :ignore)
  when ".xl" then Roo::Excel.new(file.path, :packed=> nil, :file_warning=> :ignore)
  when ".xlsx" then Roo::Excelx.new(file.path, :packed=> nil, :file_warning=> :ignore)
  else raise "Unknown file type: #{file.original_filename}"
  end
end

private
 def self.formatteddate(dates)
      newdate = ''
      if dates!=nil && dates!=''
           dts    = Date.parse(dates.to_s)
           newdate = dts.strftime("%d-%b-%Y")
      end
      return newdate
 end

 private
   def self.currencyformatted(amt)
        amts = 0
        if amt!=nil && amt!=''
          amts = amt.to_f.round(0)
        end
        return amts
   end

end
