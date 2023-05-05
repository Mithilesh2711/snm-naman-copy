class MstPostalDirectory < ApplicationRecord
    def self.to_generate_postal_directory
        attributes = %w{Code Name Country State District Tehsil City Pincode Status}
        attributes1 = %w{pd_code pd_name pd_country pd_state pd_tehsil pd_city pd_pincode pd_status}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            all.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
    end
  end
  