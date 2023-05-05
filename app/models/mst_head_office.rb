class MstHeadOffice < ApplicationRecord
  def self.to_generate_headoffice
      attributes = %w{Description}
      attributes1 = %w{hof_description}
      CSV.generate(:headers=> true) do |csv|
        csv << attributes
          all.each do |user|
             csv << attributes1.map{ |attr| user.send(attr) }
          end
      end
  end
end
