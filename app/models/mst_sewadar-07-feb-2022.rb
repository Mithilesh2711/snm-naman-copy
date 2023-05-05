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
end
