class MstResponsibility < ApplicationRecord
  def self.to_generate_responsib
      attributes = %w{Code Description}
      attributes1 = %w{rsp_rspcode rsp_description}
      CSV.generate(:headers=> true) do |csv|
        csv << attributes
          all.each do |user|
             csv << attributes1.map{ |attr| user.send(attr) }
          end
      end
  end
end
