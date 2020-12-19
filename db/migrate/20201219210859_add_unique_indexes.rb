class AddUniqueIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :stats, [:game_id, :name, :season, :team_id], unique: true
    add_index :games, [:api_ref, :away_team_name, :home_team_name, :season, :week], unique: true, name: "game_unique_index"
  end
end
