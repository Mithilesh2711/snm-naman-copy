class MstMedicalHistory < ApplicationRecord
  def self.to_generate_medicalhistory
      attributes = %w{Type Description AnswerType}
      attributes1 = %w{mh_other mh_description mh_answertype}
      CSV.generate(:headers=> true) do |csv|
        csv << attributes
          all.each do |user|
             csv << attributes1.map{ |attr| user.send(attr) }
          end
      end
  end
end
