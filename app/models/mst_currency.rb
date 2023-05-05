class MstCurrency < ApplicationRecord
    def self.to_generate_currency
        attributes = %w{Code Name Status}
        attributes1 = %w{cur_code cur_name cur_status}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            all.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
    end
  end
  