class CreateMagazineReceipt < ActiveRecord::Migration[5.1]
  def change
    create_table :magazine_receipts do |t|
        t.string :mr_code, null: false, :limit => 30
        t.string :mr_compcode, null: false, :limit => 30
        t.string :mr_amount, null: false, :limit => 30
        t.string :mr_currencyamount, null: false, :limit => 30
        t.string :mr_bankname, null: false, :limit => 30
        t.string :mr_magazine, null: false, :limit => 30
        t.string :mr_member, null: false, :limit => 30
        t.string :mr_subscription, null: false, :limit => 30
        t.string :mr_paymentmode, null: false, :limit => 30
        t.string :mr_manualrectnum, null: false, :limit => 30
        t.date :mr_manualrectdate, null: false
        t.string :mr_accountrectnum, null: false, :limit => 30
        t.date :mr_accountrectdate, null: false
        t.string :mr_documentnum, null: false, :limit => 30
        t.string :mr_modifiedby, null: false, :limit => 60
        t.string :mr_createdby, null: false, :limit => 60
        t.string :mr_status, default: "Y", :limit => 1, null: false

        t.timestamps
    end
  end
end
