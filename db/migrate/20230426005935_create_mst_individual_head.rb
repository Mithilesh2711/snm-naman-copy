class CreateMstIndividualHead < ActiveRecord::Migration[5.1]
  def change
    create_table :mst_individual_heads do |t|
        t.string :ih_code, null: false, :limit => 30
        t.string :ih_name, null: false, :limit => 60
        t.string :ih_compcode, null: false, :limit => 30
        t.string :ih_state, null: false, :limit => 30
        t.string :ih_status, default: "Y", :limit => 1, null: false
        t.string :ih_city, null: false, :limit => 30
        t.string :ih_district, null: false, :limit => 30
        t.string :ih_phone, null: false, :limit => 30
        t.string :ih_email, null: false, :limit => 30
        t.string :ih_address, null: false, :limit => 200
        t.string :ih_mobile, null: false, :limit => 30
        t.string :ih_dispatch_mode, null: false, :limit => 30
        t.string :ih_dispatch_type, null: false, :limit => 30
        t.string :ih_country, null: false, :limit => 30
        t.string :ih_pincode, null: false, :limit => 30
        
        t.timestamps
    end
  end
end
