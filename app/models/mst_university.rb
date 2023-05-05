class MstUniversity < ApplicationRecord
  def self.to_generate_unversity
      attributes = %w{Description Qualification}
      attributes1 = %w{un_description un_qltype}
      CSV.generate(:headers=> true) do |csv|
        csv << attributes
          all.each do |user|
             csv << attributes1.map{ |attr| user.send(attr) }
          end
      end
  end
end
