class MstSubscriptionType < ApplicationRecord
    def self.to_generate_subtyp
        attributes = %w{Code Name}
        attributes1 = %w{subtyp_code subtyp_name}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            all.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
    end
  end
  