class MstLeave < ApplicationRecord

  def self.to_leave_master
      attributes = %w{LeaveCode LeaveType PaidLeave BalanceLeave Working Encash BalancePreviousCF AnnualQuota AccumulationLeave}
      attributes1 = %w{attend_leaveCode attend_leavetype attend_paidleave attend_balancesleave attend_runworking attend_enchash attend_balanceforprevious attend_annualquota attend_accumulationleave}
      CSV.generate(:headers=> true) do |csv|
        csv << attributes
          all.each do |user|
             csv << attributes1.map{ |attr| user.send(attr) }
          end
      end
  end
end
