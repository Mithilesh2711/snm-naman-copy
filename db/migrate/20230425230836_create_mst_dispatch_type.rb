class CreateMstDispatchType < ActiveRecord::Migration[5.1]
  def change
    create_table :mst_dispatch_types do |t|
        t.string :dt_name, null: false, :limit => 60
        t.string :dt_compcode, null: false, :limit => 30
        t.string :dt_code, null: false, :limit => 30
        t.string :dt_status, default: "Y", :limit => 1, null: false
        
        t.timestamps
    end
  end
end
