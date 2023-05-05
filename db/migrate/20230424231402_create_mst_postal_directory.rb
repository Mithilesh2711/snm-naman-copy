class CreateMstPostalDirectory < ActiveRecord::Migration[5.1]
  def change
    create_table :mst_postal_directories do |t|
        t.string :pd_code, null: false, :limit => 30
        t.string :pd_name, null: false, :limit => 60
        t.string :pd_compcode, null: false, :limit => 30
        t.string :pd_state, null: false, :limit => 30
        t.string :pd_status, default: "Y", :limit => 1, null: false
        t.string :pd_city, null: false, :limit => 30
        t.string :pd_district, null: false, :limit => 30
        t.string :pd_tehsil, null: false, :limit => 30
        t.string :pd_country, null: false, :limit => 30
        t.string :pd_pincode, null: false, :limit => 30
        
        t.timestamps
    end
  end
end
