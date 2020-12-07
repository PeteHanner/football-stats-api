class ChangeStatValueToFloat < ActiveRecord::Migration[6.0]
  def change
    change_column :stats, :value, :float
  end
end
