class MstDistrict < ApplicationRecord

  def self.to_generate_district
    attributes = %w{StateName DistrictCode DistrtctName}
    attributes1 = %w{sts_description dts_districtcode dts_description}
    CSV.generate(:headers=> true) do |csv|
      csv << attributes
        all.each do |user|
           csv << attributes1.map{ |attr| user.send(attr) }
        end
    end
end


end
