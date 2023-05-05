class MstRateChart < ApplicationRecord
    def self.to_generate_rate_chart
        attributes = %w{Code Name Currency SubscriptionType Amount Magazine Status}
        attributes1 = %w{rc_code rc_name rc_currency rc_subtyp rc_amount rc_magazine rc_status}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            all.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
    end
  end
  