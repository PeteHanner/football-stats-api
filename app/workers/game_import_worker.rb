require "httparty"

class GameImportWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  # 401265703
  # GameImportWorker.new.perform(2019, 1)
  def perform(season = nil, week = nil)
    if season.nil? || week.nil?
      last_game = Game.last
      season, week = last_game.season, last_game.week
    end

    query_string = "https://api.collegefootballdata.com/games?year=#{season}&week=#{week}"
    response = HTTParty.get(query_string)

    return unless response.code == 200

    games_data = JSON.parse(response.body)
    games_data.each do |game_data|
      create_game(game_data)
    end
  end

  private

  def build_game_object(game_data)
    Game.new(
      api_ref: game_data["id"],
      away_team: game_data["away_team"],
      away_team_score: game_data["away_points"],
      home_team: game_data["home_team"],
      home_team_score: game_data["home_points"],
      season: game_data["season"],
      week: game_data["week"]
    )
  end

  def create_game(game_data)
    return unless game_data["home_points"].present?
    return if Game.find_by(api_ref: game_data["id"]).present?

    query_string = "https://api.collegefootballdata.com/drives?year=#{game_data["season"]}&week=#{game_data["week"]}&team=#{CGI.escape(game_data["home_team"])}"
    response = HTTParty.get(query_string)

    return unless response.code == 200

    game = build_game_object(game_data)

    drives = JSON.parse(response.body)
    game.home_team_drives, game.away_team_drives = get_drive_breakdown(drive_data: drives, home_team: game_data["home_team"])

    game.save
  end

  def get_drive_breakdown(drive_data:, home_team:)
    home_team_drives = drive_data.pluck("offense").count(home_team)
    away_team_drives = drive_data.count - home_team_drives
    [home_team_drives, away_team_drives]
  end
end
