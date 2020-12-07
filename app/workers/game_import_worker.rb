require "httparty"

class GameImportWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform(season = nil, week = nil)
    # Unless specified, get any new games from same + next week as last successfully imported game
    # Also check if new season has begun and begin importing from there if applicable
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
