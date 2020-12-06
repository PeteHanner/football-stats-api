class RenameApiIdToApiRef < ActiveRecord::Migration[6.0]
  def change
    rename_column :games, :api_ref, :api_ref
  end
end
