class MstDispatchType < ApplicationRecord
    def self.to_generate_dispatch_type
        attributes = %w{Code Name Status}
        attributes1 = %w{dt_code dt_name dt_status}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            all.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
    end
  end
  