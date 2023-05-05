class Member < ApplicationRecord
    def self.to_generate_member
        attributes = %w{Code Name Mobile AdditionalMobile Email Address Gender DOB PAN Education Occupation Status}
        attributes1 = %w{mbr_code mbr_name mbr_mobile mbr_mobile2 mbr_email mbr_full_address mbr_gender mbr_dob mbr_pan mbr_education mbr_occupation mbr_status}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            all.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
    end
  end
  