class MstLanguage < ApplicationRecord
    def self.to_generate_language
        attributes = %w{LanguageCode Name Status}
        attributes1 = %w{lang_code lang_name status}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            all.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
    end
  end
  