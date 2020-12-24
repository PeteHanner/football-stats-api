require "httparty"

class GamesImportWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform(season = nil, week = nil)
    @season, @week = season, week
    check_current_and_next_weeks

    query_string = "https://api.collegefootballdata.com/games?year=#{@season}&week=#{@week}"
    response = HTTParty.get(query_string)

    error_msg = "ERROR: #{self.class.name} received response code #{response.code} for #{@season} season week #{@week}"
    raise error_msg unless response.code == 200

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
      GamesImportWorker.perform_async(@season, @week + 1)
      GamesImportWorker.perform_async(@season + 1, 1)
    end
  end
end
