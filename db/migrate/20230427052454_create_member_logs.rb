class CreateMemberLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :member_logs do |t|
        t.string :ml_title, null: false, :limit => 200
        t.string :ml_compcode, null: false, :limit => 30
        t.string :ml_member_code, null: false, :limit => 30
        t.string :ml_description, :limit => 500, null: false
        
        t.timestamps
    end
  end
end
