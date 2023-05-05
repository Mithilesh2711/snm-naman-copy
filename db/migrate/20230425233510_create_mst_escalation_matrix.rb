class CreateMstEscalationMatrix < ActiveRecord::Migration[5.1]
  def change
    create_table :mst_escalation_matrices do |t|
        t.string :em_name, null: false, :limit => 60
        t.string :em_compcode, null: false, :limit => 30
        t.string :em_code, null: false, :limit => 30
        t.string :em_status, default: "Y", :limit => 1, null: false
        
        t.timestamps
    end
  end
end
