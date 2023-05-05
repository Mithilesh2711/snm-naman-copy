class MstMagazine < ApplicationRecord
    def self.to_generate_magazine
      attributes = %w{MagazineCode MagazineName Language Frequency}
      attributes1 = %w{mag_code mag_name mag_language mag_frequency}
      CSV.generate(:headers=> true) do |csv|
        csv << attributes
          all.each do |user|
             csv << attributes1.map{ |attr| user.send(attr) }
          end
      end
  end
  
  end
  