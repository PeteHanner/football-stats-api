require "httparty"

class GameImportWorker
  include Sidekiq::GameImportWorker
  sidekiq_options retry: false

  # 401265703
  # GameImportWorker.new.perform
  def perform(season = nil, week = nil)
    if season.nil? || week.nil?
      last_game = Game.last
      season = last_game.id
    end
    # response = HTTParty.get("https://api.collegefootballdata.com/games?id=#{last_game_api_id}")

    return unless response.code == 200

    # data = JSON.parse(response.body)[0]
    # binding.pry

    # return unless data["home_points"].present?

    game = Game.new(
      api_id: data["id"],
      season: data["season"],
      home_team: data["home_team"],
      home_team_score: data["home_points"],
      away_team: data["away_team"],
      away_team_score: data["away_points"],
    )
    # game.get_drive_data(season: data.season, week: data.week, team: data.home_team)
    # game.generate_stats
    # Game.load_new_game(game.api_id) if game.save
  end

  private

  def get_drive_data(season:, week:, team:)
    # https://api.collegefootballdata.com/drives?year=2019&week=1&team=Auburn
    # Count up offensive drives per team
  end
end
