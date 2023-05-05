class MstDispatchMode < ApplicationRecord
    def self.to_generate_dispatch_mode
        attributes = %w{Code Name Status}
        attributes1 = %w{dm_code dm_name dm_status}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            all.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
    end
  end
  