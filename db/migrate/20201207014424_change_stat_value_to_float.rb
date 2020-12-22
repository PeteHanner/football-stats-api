class ChangeStatValueToFloat < ActiveRecord::Migration[6.0]
  def up
    change_column :stats, :value, :float
  end

  def down
    change_column :stats, :value, :integer
  end
end
