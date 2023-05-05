class MstCourier < ApplicationRecord
    def self.to_generate_courier
        attributes = %w{Code Name Status}
        attributes1 = %w{cr_code cr_name cr_status}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            all.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
    end
  end
  