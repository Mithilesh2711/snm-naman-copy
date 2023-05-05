class MstProducts < ApplicationRecord
   def self.to_generate_products
      attributes = %w{ProductCode ProductName OB CB Image}
      attributes1 = %w{pr_code pr_name pr_ob pr_cb pr_img}
      CSV.generate(:headers=> true) do |csv|
        csv << attributes
          all.each do |user|
             csv << attributes1.map{ |attr| user.send(attr) }
          end
      end
  end
end
