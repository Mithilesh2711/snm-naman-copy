class TrnTransaction < ApplicationRecord
    def self.to_get_transactionlist
        attributes  = %w{SewadarCode Name ReferenceCode Category Department Gender TransactionType TransactionMonth TransactionYear TransactionDate(Effect) Remarks Status}
        attributes1 = %w{sw_sewcode sw_sewadar_name sw_oldsewdarcode sw_catgeory department genders trns_type trnsmon trns_year trnsdated trns_rem trnsstatus}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            if all.length >0
             
                all.each do |user| 
                    if user.sw_gender.to_s.upcase =='M'  
                        user.genders = 'Male'
                    elsif user.genders = 'F' 
                        user.genders = 'Female'   
                    end
                    if user.trns_status == 'A'
                        user.trnsstatus = "Approved"
                    elsif user.trns_status == 'C'
                        user.trnsstatus = "Cancelled"
                    else
                        user.trnsstatus = "Pending"       
                    end
                    user.trnsdated  = mys_days_formatted(user.trns_dated)
                    user.trnsmon    = month_listed_data(user.trns_mon)
                    depobj = get_self_department($compcodes,user.trns_depcode) 
                    if depobj
                        user.department = depobj.departDescription
                    end
                      csv << attributes1.map{ |attr| user.send(attr) }
                  end
            
            end
        end
      end

      private
      def self.get_self_department(compcode,depcode)        
          disobj   =  Department.where("compCode = ? AND departCode = ? AND subdepartment=''",compcode,depcode).first
          return disobj
      end
      def self.mys_days_formatted(dates)
        newdate = ''
        if dates!=nil && dates !='' && dates.to_s != '0' 
              dts    = Date.parse(dates.to_s)
              newdate = dts.strftime("%b-%m-%Y")
        end
        return newdate
    end
    def self.month_listed_data(months)
        monthsstr = ""
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
    def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
        when ".csv" then Roo::CSV.new(file.path, :packed=> nil, :file_warning=> :ignore)
        when ".xls" then Roo::Excel.new(file.path, :packed=> nil, :file_warning=> :ignore)
        when ".xlsx" then Roo::Excelx.new(file.path, :packed=> nil, :file_warning=> :ignore)
        else raise "Unknown file type: #{file.original_filename}"
        end
    end

end
