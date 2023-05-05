class MstIndividualHead < ApplicationRecord
    def self.to_generate_individual_head
        attributes = %w{Code Name Country State District City Pincode Phone Mobile Email Address DispatchMode DispatchType Status}
        attributes1 = %w{ih_code ih_name ih_country ih_state ih_city ih_pincode ih_phone ih_mobile ih_email ih_address ih_dispatch_mode ih_dispatch_type ih_status}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            all.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
    end
  end
  