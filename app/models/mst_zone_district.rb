class MstZoneDistrict < ApplicationRecord

  def self.to_generate_zone_district
      attributes = %w{DistrictCode Zone Name}
      attributes1 = %w{zd_distcode myzones zd_name}
      CSV.generate(:headers=> true) do |csv|
        csv << attributes
        if all.length >0
          if $arreitems.length >0
          $arreitems.each do |user|
             csv << attributes1.map{ |attr| user.send(attr) }
          end
          end
        end
      end
  end
end
