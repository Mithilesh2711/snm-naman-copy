class MstAddress < ApplicationRecord
    def self.to_generate_address
        attributes = %w{Code Member Name Mobile Email Address Status}
        attributes1 = %w{adr_code adr_membercode adr_name adr_mobile adr_email adr_fulladdress adr_status}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            all.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
    end
  end
  