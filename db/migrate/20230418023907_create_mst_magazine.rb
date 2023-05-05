class CreateMstMagazine < ActiveRecord::Migration[5.1]
  def change
    create_table :mst_magazines do |t|
        t.string :mag_name, null: false, :limit => 60
        t.string :mag_compcode, null: false, :limit => 30
        t.string :mag_code, null: false, :limit => 30
        
        t.timestamps
    end
  end
end
