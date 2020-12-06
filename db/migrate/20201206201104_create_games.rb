class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.integer :season
      t.string :team1
      t.string :team2
      t.integer :team1_drives
      t.integer :team2_drives
      t.integer :team1_score
      t.integer :team2_score
      t.integer :api_id

      t.timestamps
    end
  end
end
