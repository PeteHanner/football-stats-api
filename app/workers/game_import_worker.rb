require "httparty"

class GameImportWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform(season = nil, week = nil)
    @season, @week = season, week
    check_current_and_next_weeks

    query_string = "https://api.collegefootballdata.com/games?year=#{@season}&week=#{@week}"
    response = HTTParty.get(query_string)

    unless response.code == 200
      Rails.logger.error "Game data request for #{@season} season week #{@week} returned response code #{response.code}"
      return false
    end

    games_data = JSON.parse(response.body)
    games_data.each do |game_data|
      GameCreateWorker.perform_async(game_data)
    end
  end

  private

  def check_current_and_next_weeks
    # Unless specified, continue getting new games from same week as last successfully imported game
    # Also begin checking for new games from week following last successfully imported game
    # Also check if new season has begun and begin importing from there if applicable
    if @season.nil? || @week.nil?
      last_game = Game.last
      @season, @week = last_game.season, last_game.week
      GameImportWorker.perform_async(@season, @week + 1)
      GameImportWorker.perform_async(@season + 1, 1)
    end
  end
end
