class RenameTypeToName < ActiveRecord::Migration[6.0]
  def change
    rename_column :stats, :type, :name
  end
end
