class SubscriptionLogs < ApplicationRecord
    def self.to_generate_city
        attributes = %w{Type Title Description}
        attributes1 = %w{sl_type sl_title sl_description}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            all.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
    end
  
  end
  