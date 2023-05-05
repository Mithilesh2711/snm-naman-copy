class MstAccomodationAllotment < ApplicationRecord
  def self.to_generate_allotment
      attributes = %w{AllotmentNo AllotmentDate Belongs Address 	SewadarName DeclarationSigned}
      attributes1 = %w{aa_alotmentno accomodated belogsto address sewdarname aa_declaretaking}
      CSV.generate(:headers=> true) do |csv|
        csv << attributes
        if all.length >0
            if $exceldata.length >0
                $exceldata.each do |user|
                   csv << attributes1.map{ |attr| user.send(attr) }
                end
            end
        end
      end
  end
end
