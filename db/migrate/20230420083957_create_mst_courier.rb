class CreateMstCourier < ActiveRecord::Migration[5.1]
  def change
    create_table :mst_couriers do |t|
        t.string :cr_name, null: false, :limit => 60
        t.string :cr_compcode, null: false, :limit => 30
        t.string :cr_code, null: false, :limit => 30
        t.string :cr_status, default: "Y", :limit => 1, null: false
        
        t.timestamps
    end
  end
end
