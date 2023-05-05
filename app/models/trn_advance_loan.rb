class TrnAdvanceLoan < ApplicationRecord
    def self.to_advance_ma_advance
        attributes = %w{RequestNo DateofRequest RequestFor sewadarCode SewadarOldCode SewadarName Category Department Designation Gender AadhaarNo DateofBirth DateOfJoining DateofSuperannuation DateofRegularization LeavingDate MAAdvance AdvanceAmount Installment SanctionNo SanctionDate CurrentOutsatnding NoOfInstallment LastInstallmentDate Purpose Remark GuarantorCode GuarantorName Status ForwardedBy(Sh./Smt.) }
        attributes1 = %w{al_requestno requestDated requestype al_sewadarcode refercode sewdarname categoryname department designation genders selfadhar dobs dateofjoing  dos dor leavingdated al_advanceamt al_loanamount al_installpermonth sanctionNo sanctionDate currentoutsatnding noinstallment lastinstallmentdate al_purpose al_remark al_guarantorname guarantorname reqstatus approvedby }
        items = []
        if all.length >0
            items = $dataitems       
        end
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
          items.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
    end
end
