require "httparty"

class GameImportWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

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
      GameCreateWorker.perform_async(game_data)
    end
  end
end
