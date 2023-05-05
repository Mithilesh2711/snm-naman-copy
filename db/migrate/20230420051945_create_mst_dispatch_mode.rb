class CreateMstDispatchMode < ActiveRecord::Migration[5.1]
  def change
    create_table :mst_dispatch_modes do |t|
        t.string :dm_name, null: false, :limit => 60
        t.string :dm_compcode, null: false, :limit => 30
        t.string :dm_code, null: false, :limit => 30
        t.string :dm_status, default: "Y", :limit => 1, null: false
        
        t.timestamps
    end
  end
end
