class MstQualification < ApplicationRecord
  def self.to_generate_qualification
    attributes  = %w{Code QualificationIn Qualification  Duration IsProfessionalQualification IsInternationalQualification}
    attributes1 = %w{ql_qualifcode ql_qualdescription ql_qualification  ql_duration ql_isprofessional ql_isinternational}
    CSV.generate(:headers=> true) do |csv|
      csv << attributes
        all.each do |user|
           csv << attributes1.map{ |attr| user.send(attr) }
        end
    end
end
end
