class Game < ApplicationRecord
  has_many :stats
  has_many :teams, through: :stats

  validates_presence_of :api_id

  # 401240218
  def self.load_new_game(last_game_api_id)
    last_game_api_id ||= Game.last.api_id
    # request = https://api.collegefootballdata.com/games?id=401110722
    # return unless response code == 200
    # game = Game.new(...)
    # game.get_drive_data(season: response.season, week: response.week, team: response.home_team)
    # game.generate_stats
    # Game.load_new_game(game.api_id) if game.save
  end

  def get_drive_data(season:, week:, team:)
    # https://api.collegefootballdata.com/drives?year=2019&week=1&team=Auburn
    # Count up offensive drives per team
  end
end
