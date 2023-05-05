class CreateMember < ActiveRecord::Migration[5.1]
  def change
    create_table :members do |t|
        t.string :mbr_code, null: false, :limit => 30
        t.string :mbr_name, null: false, :limit => 60
        t.string :mbr_compcode, null: false, :limit => 30
        t.string :mbr_state, null: false, :limit => 30
        t.string :mbr_status, default: "Y", :limit => 1, null: false
        t.string :mbr_city, null: false, :limit => 30
        t.string :mbr_district, null: false, :limit => 30
        t.string :mbr_email, null: false, :limit => 30
        t.string :mbr_full_address, null: false, :limit => 200
        t.string :mbr_mobile, null: false, :limit => 30
        t.string :mbr_mobile2, :limit => 30
        t.string :mbr_pincode, null: false, :limit => 30
        t.string :mbr_addr_l1, null: false, :limit => 200
        t.string :mbr_addr_l2, :limit => 200
        t.string :mbr_co_name, null: false, :limit => 30
        t.string :mbr_co_title, null: false, :limit => 30
        t.date :mbr_dob
        t.string :mbr_education, :limit => 30
        t.string :mbr_gender, :limit => 30
        t.string :mbr_occupation, :limit => 30
        t.string :mbr_pan, :limit => 200
        t.string :mbr_reason_change, :limit => 30
        t.string :mbr_title, null: false, :limit => 30

        t.timestamps
    end
  end
end
