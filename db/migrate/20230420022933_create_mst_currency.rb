class CreateMstCurrency < ActiveRecord::Migration[5.1]
  def change
    create_table :mst_currencies do |t|
        t.string :cur_name, null: false, :limit => 60
        t.string :cur_compcode, null: false, :limit => 30
        t.string :cur_code, null: false, :limit => 30
        t.string :cur_status, default: "Y", :limit => 1, null: false
        
        t.timestamps
    end
  end
end
