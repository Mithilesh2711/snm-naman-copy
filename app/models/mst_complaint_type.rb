class MstComplaintType < ApplicationRecord
    def self.to_generate_complaint_type
        attributes = %w{Code Name Status}
        attributes1 = %w{ct_code ct_name ct_status}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            all.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
    end
  end
  