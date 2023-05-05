class CreateSubscription < ActiveRecord::Migration[5.1]
  def change
    create_table :subscriptions do |t|
        t.string :sub_code, null: false, :limit => 30
        t.string :sub_name, null: false, :limit => 60
        t.string :sub_compcode, null: false, :limit => 30
        t.string :sub_amount, null: false, :limit => 30
        t.string :sub_amountrcv, null: false, :limit => 30
        t.string :sub_bankname, null: false, :limit => 30
        t.string :sub_branch, null: false, :limit => 30
        t.string :sub_currency, null: false, :limit => 30
        t.string :sub_dispatchmode, null: false, :limit => 30
        t.string :sub_dispatchtype, null: false, :limit => 30
        t.string :sub_dispatchto, null: false, :limit => 30
        t.date :sub_docdate, null: false
        t.string :sub_docnum, null: false, :limit => 30
        t.date :sub_enddate, null: false
        t.string :sub_inramount, null: false, :limit => 30
        t.string :sub_magazine, null: false, :limit => 30
        t.string :sub_member, null: false, :limit => 30
        t.string :sub_paymentmode, null: false, :limit => 30
        t.string :sub_quantity, null: false, :limit => 30
        t.string :sub_reason_change, null: false, :limit => 200
        t.date :sub_receiptdate, null: false
        t.string :sub_receiptno, null: false, :limit => 30
        t.string :sub_remarks, null: false, :limit => 200
        t.string :sub_roe, null: false, :limit => 30
        t.date :sub_startdate, null: false
        t.string :sub_status, default: "Y", :limit => 1, null: false
        t.string :sub_subtyp, null: false, :limit => 30
    end
  end
end
