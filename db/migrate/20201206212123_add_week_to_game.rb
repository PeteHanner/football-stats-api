class AddWeekToGame < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :week, :integer
  end
end
