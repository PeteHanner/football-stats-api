require "httparty"

class GameCreateWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform(game_data)
    return if game_data["home_points"].blank? # game exists in API but not played yet
    return if Game.find_by(api_ref: game_data["id"]).present? # game has already been imported

    query_string = "https://api.collegefootballdata.com/drives?year=#{game_data["season"]}&week=#{game_data["week"]}&team=#{CGI.escape(game_data["home_team"])}"
    response = HTTParty.get(query_string)
    error_msg = "ERROR: #{self.class.name} received response code #{response.code} for API game ID #{game_data["id"]}"
    raise error_msg unless response.code == 200

    drives = JSON.parse(response.body)
    game = build_game_object(game_data)
    game.home_team_drives, game.away_team_drives = get_drive_counts(drive_data: drives, home_team_name: game_data["home_team"])

    error_msg = "ERROR: #{self.class.name} unable to build game from API data:\n\n#{game_data}"
    raise error_msg unless game.save

    FirstOrderGameStatsWorker.perform_async(game.id)
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

  def get_drive_counts(drive_data:, home_team_name:)
    home_team_drives = drive_data.pluck("offense").count(home_team_name)
    away_team_drives = drive_data.count - home_team_drives
    [home_team_drives, away_team_drives]
  end
end
