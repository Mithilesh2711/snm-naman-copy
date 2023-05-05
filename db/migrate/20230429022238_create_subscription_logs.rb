class CreateSubscriptionLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :subscription_logs do |t|
        t.string :sl_title, null: false, :limit => 200
        t.string :sl_compcode, null: false, :limit => 30
        t.string :sl_membercode, null: false, :limit => 30
        t.string :sl_subcode, null: false, :limit => 30
        t.string :sl_description, :limit => 500, null: false
        t.string :sl_type, null: false, :limit => 100
        
        t.timestamps
    end
  end
end
