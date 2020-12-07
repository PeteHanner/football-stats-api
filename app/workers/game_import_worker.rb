require "httparty"

# GameImportWorker.perform_async(2019, 1)
class GameImportWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, unique: :until_executed

  def perform(season = nil, week = nil)
    if season.nil? || week.nil?
      last_game = Game.last
      season, week = last_game.season, last_game.week
      GameImportWorker.perform_async(season, week + 1)
      GameImportWorker.perform_async(season + 1, 1)
    end

    query_string = "https://api.collegefootballdata.com/games?year=#{season}&week=#{week}"
    response = HTTParty.get(query_string)

    return unless response.code == 200

    games_data = JSON.parse(response.body)
    games_data.each do |game_data|
      GameCreateWorker.perform_async(game_data)
    end
  end
end
