class Designation < ApplicationRecord
  def self.to_generate_designation
      attributes = %w{DesignationCode Description,Type}
      attributes1 = %w{desicode ds_description ds_type}
      CSV.generate(:headers=> true) do |csv|
        csv << attributes
          all.each do |user|
             csv << attributes1.map{ |attr| user.send(attr) }
          end
      end
  end
end
