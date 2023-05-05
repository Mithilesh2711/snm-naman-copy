class Department < ApplicationRecord
  def self.to_generate_department
      attributes = %w{DepartmentCode DepartmentName DepartmentHod Strength Type}
      attributes1 = %w{departCode departDescription departHod departNumberofemp departType}
      CSV.generate(:headers=> true) do |csv|
        csv << attributes
          all.each do |user|
             csv << attributes1.map{ |attr| user.send(attr) }
          end
      end
  end

  def self.to_generate_sub_department
      attributes  = %w{Code SubDepartment Department}
      attributes1 = %w{departCode departDescription department}
      CSV.generate(:headers=> true) do |csv|
        csv << attributes
          if all.length >0
              $allrecords.each do |user|

                 csv << attributes1.map{ |attr| user.send(attr) }
              end
          end
      end
  end

  
end
