class MstBankList < ApplicationRecord
   def self.to_generate_bank
      attributes = %w{BankCode BankName IFSCCODE Address}
      attributes1 = %w{bl_code bl_name bl_ifsccode bl_address}
      CSV.generate(:headers=> true) do |csv|
        csv << attributes
          all.each do |user|
             csv << attributes1.map{ |attr| user.send(attr) }
          end
      end
  end
end
