class RenameGameColumns < ActiveRecord::Migration[6.0]
  def change
    rename_column :games, :team1, :home_team
    rename_column :games, :team2, :away_team
    rename_column :games, :team1_drives, :home_team_drives
    rename_column :games, :team2_drives, :away_team_drives
    rename_column :games, :team1_score, :home_team_score
    rename_column :games, :team2_score, :away_team_score
  end
end
