class RenameApiIdToApiRef < ActiveRecord::Migration[6.0]
  def change
    rename_column :games, :api_id, :api_ref
  end
end
