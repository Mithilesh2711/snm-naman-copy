class AddStatusToLanguage < ActiveRecord::Migration[5.1]
  def change
    add_column :mst_languages, :status, :string, default: "Y", :limit => 1
  end
end
