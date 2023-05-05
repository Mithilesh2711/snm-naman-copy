class CreateMstLanguage < ActiveRecord::Migration[5.1]
  def change
    create_table :mst_languages do |t|
        t.string :lang_name, null: false, :limit => 60
        t.string :lang_compcode, null: false, :limit => 30
        t.string :lang_code, null: false, :limit => 30
        
        t.timestamps
    end
  end
end
