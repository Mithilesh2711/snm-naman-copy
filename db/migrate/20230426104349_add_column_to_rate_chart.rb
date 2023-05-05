class AddColumnToRateChart < ActiveRecord::Migration[5.1]
  def change
    add_column :mst_rate_charts, :rc_magazine, :string, :limit => 30, null: false
  end
end
