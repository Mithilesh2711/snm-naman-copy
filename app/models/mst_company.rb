class MstCompany < ApplicationRecord
  def self.to_company
  ## Import all columns
   CSV.generate do |csv|
      csv << column_names
        all.each do |row|
          csv << row.attributes.values_at(*column_names)
        end
    end
end
end
