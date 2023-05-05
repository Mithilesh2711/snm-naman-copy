class Subscription < ApplicationRecord
    def self.to_generate_subscription
        attributes = %w{Code Name Member Magazine SubscriptionType Currency ROE Quantity SubsAmount DispatchMode DispatchType DispatchTo  PaymentMode BankName DocumentNo.  DocumentDate AmountReceived  INRAmount SubsStartDate SubsEndDate Remarks ManualReceiptNo. ManualReceiptDate IssuingBranch Status }
        attributes1 = %w{sub_code sub_name sub_member sub_magazine sub_subtyp sub_currency sub_roe sub_quantity sub_amount sub_dispatchmode sub_dispatchtype sub_dispatchto sub_paymentmode sub_bankname sub_docnum sub_docdate sub_amountrcv sub_inramount sub_startdate sub_enddate sub_remarks sub_receiptno sub_receiptdate sub_branch sub_status}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            all.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
    end
  end
  