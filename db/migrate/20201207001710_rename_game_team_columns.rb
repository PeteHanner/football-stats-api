class RenameGameTeamColumns < ActiveRecord::Migration[6.0]
  def change
    rename_column :games, :home_team, :home_team_name
    rename_column :games, :away_team, :away_team_name
  end
end
