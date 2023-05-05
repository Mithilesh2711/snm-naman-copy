class MstState < ApplicationRecord
  def self.to_generate_sate
    attributes = %w{StateCode StateName}
    attributes1 = %w{sts_code sts_description}
    CSV.generate(:headers=> true) do |csv|
      csv << attributes
        all.each do |user|
           csv << attributes1.map{ |attr| user.send(attr) }
        end
    end
end

end
