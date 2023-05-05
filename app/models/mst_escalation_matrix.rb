class MstEscalationMatrix < ApplicationRecord
    def self.to_generate_escalation_matrix
        attributes = %w{Code Name Status}
        attributes1 = %w{em_code em_name em_status}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            all.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
    end
  end
  