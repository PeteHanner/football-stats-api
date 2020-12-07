require "httparty"

class GameCreateWorker
  include Sidekiq::Worker
  sidekiq_options retry: true

  def perform(game_data)
    return unless game_data["home_points"].present?
    return if Game.find_by(api_ref: game_data["id"]).present?

    query_string = "https://api.collegefootballdata.com/drives?year=#{game_data["season"]}&week=#{game_data["week"]}&team=#{CGI.escape(game_data["home_team"])}"
    response = HTTParty.get(query_string)
    return unless response.code == 200

    game = build_game_object(game_data)
    drives = JSON.parse(response.body)
    game.home_team_drives, game.away_team_drives = get_drive_breakdown(drive_data: drives, home_team_name: game_data["home_team"])
    game.save
    game.generate_first_order_stats
  end

  private

  def build_game_object(game_data)
    Game.new(
      api_ref: game_data["id"],
      away_team_name: game_data["away_team"],
      away_team_score: game_data["away_points"],
      home_team_name: game_data["home_team"],
      home_team_score: game_data["home_points"],
      season: game_data["season"],
      week: game_data["week"]
    )
  end

  def get_drive_breakdown(drive_data:, home_team_name:)
    home_team_drives = drive_data.pluck("offense").count(home_team_name)
    away_team_drives = drive_data.count - home_team_drives
    [home_team_drives, away_team_drives]
  end
end
