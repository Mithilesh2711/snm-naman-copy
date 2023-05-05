class MemberLogs < ApplicationRecord
    def self.to_generate_city
        attributes = %w{Title Description}
        attributes1 = %w{ml_title ml_description}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            all.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
    end
  
  end
  