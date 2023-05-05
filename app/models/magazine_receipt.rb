class MagazineReceipt < ApplicationRecord
    def self.to_generate_magazine_receipt
        attributes = %w{Code Member Magazine Subscription ReceiptDate CreatedBy ModifiedBy CurrencyAmount TotalAmount PaymentMode  BankName  DocumentNo. ManualReceiptNo. ManualReceiptDate AccountReceiptNo. AccountReceiptDate  Status }
        attributes1 = %w{mr_code mr_member mr_magazine mr_subscription created_at mr_createdby mr_modifiedby mr_currencyamount mr_amount mr_paymentmode mr_bankname mr_documentnum mr_manualrectnum mr_manualrectdate mr_accountrectnum mr_accountrectdate mr_status}
        CSV.generate(:headers=> true) do |csv|
          csv << attributes
            all.each do |user|
               csv << attributes1.map{ |attr| user.send(attr) }
            end
        end
    end
  
  end
  