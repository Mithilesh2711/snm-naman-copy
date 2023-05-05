class AddColumnToMagazine < ActiveRecord::Migration[5.1]
  def change
    add_column :mst_magazines, :mag_language, :string, :limit => 30, null: false
    add_column :mst_magazines, :mag_frequency, :integer, null: false
  end
end
