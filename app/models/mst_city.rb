class MstCity < ApplicationRecord
  def self.to_generate_city
      attributes = %w{StateCode DistrictCode CityCode CityName}
      attributes1 = %w{ct_statecode ct_districtcode ct_citycode ct_description}
      CSV.generate(:headers=> true) do |csv|
        csv << attributes
          all.each do |user|
             csv << attributes1.map{ |attr| user.send(attr) }
          end
      end
  end

end
