class CreateMstComplaintType < ActiveRecord::Migration[5.1]
  def change
    create_table :mst_complaint_types do |t|
        t.string :ct_name, null: false, :limit => 60
        t.string :ct_compcode, null: false, :limit => 30
        t.string :ct_code, null: false, :limit => 30
        t.string :ct_status, default: "Y", :limit => 1, null: false
        
        t.timestamps
    end
  end
end
