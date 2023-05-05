class AddStatusToSubtyp < ActiveRecord::Migration[5.1]
  def change
    add_column :mst_subscription_types, :status, :string, default: "Y", :limit => 1
  end
end
