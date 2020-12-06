class AddValueToStat < ActiveRecord::Migration[6.0]
  def change
    add_column :stats, :value, :integer
  end
end
