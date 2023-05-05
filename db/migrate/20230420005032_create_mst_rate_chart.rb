class CreateMstRateChart < ActiveRecord::Migration[5.1]
  def change
    create_table :mst_rate_charts do |t|
        t.string :rc_name, null: false, :limit => 60
        t.string :rc_compcode, null: false, :limit => 30
        t.string :rc_code, null: false, :limit => 30
        t.string :rc_status, default: "Y", :limit => 1
        t.integer :rc_amount, null: false
        t.string :rc_subtyp, null: false, :limit => 30
        t.string :rc_currency, null: false, :limit => 30
        
        t.timestamps
    end
  end
end
