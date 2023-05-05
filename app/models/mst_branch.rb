class MstBranch < ApplicationRecord
  def self.to_generate_branch
    attributes = %w{BranchCode BranchNumber BranchName Zone DistrictZone Adrress Bhawan}
    attributes1 = %w{bch_branchcode bch_branchnumber bch_branchname myzones myzonedistrict bch_address bch_bhawan}
    CSV.generate(:headers=> true) do |csv|
      csv << attributes
      if all.length >0
        if $arreitems.length >0
            $arreitems.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
      end
    end
end
end
