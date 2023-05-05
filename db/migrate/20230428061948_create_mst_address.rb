class CreateMstAddress < ActiveRecord::Migration[5.1]
  def change
    create_table :mst_addresses do |t|
        t.string :adr_code, null: false, :limit => 30
        t.string :adr_name, null: false, :limit => 60
        t.string :adr_compcode, null: false, :limit => 30
        t.string :adr_membercode, null: false, :limit => 30
        t.string :adr_state, null: false, :limit => 30
        t.string :adr_country, null: false, :limit => 60
        t.string :adr_status, default: "Y", :limit => 1, null: false
        t.string :adr_city, null: false, :limit => 30
        t.string :adr_district, null: false, :limit => 30
        t.string :adr_email, null: false, :limit => 30
        t.string :adr_fulladdress, null: false, :limit => 400
        t.string :adr_mobile, null: false, :limit => 30
        t.string :adr_pincode, null: false, :limit => 30
        t.string :adr_line1, null: false, :limit => 200
        t.string :adr_line2, :limit => 200
    end
  end
end
