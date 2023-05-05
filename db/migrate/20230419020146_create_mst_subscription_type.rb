class CreateMstSubscriptionType < ActiveRecord::Migration[5.1]
  def change
    create_table :mst_subscription_types do |t|
        t.string :subtyp_name, null: false, :limit => 60
        t.string :subtyp_compcode, null: false, :limit => 30
        t.string :subtyp_code, null: false, :limit => 30
        
        t.timestamps
    end
  end
end
