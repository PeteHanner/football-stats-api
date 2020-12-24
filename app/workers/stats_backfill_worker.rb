class StatsBackfillWorker
  include Sidekiq::Worker

  def perform(season = Stat.current_season)
    @season = season
    backfill_games
    backfill_teams
  end

  private

  def backfill_games
    Game.where(season: @season).each do |game|
      if game.missing_first_order_stats?
        FirstOrderGameStatsWorker.perform_async(game.id)
      elsif game.missing_second_order_stats?
        SecondOrderGameStatsWorker.perform_async(game.home_team.id, game.id)
        SecondOrderGameStatsWorker.perform_async(game.away_team.id, game.id)
      end
    end
  end

  def backfill_teams
    Team.all_with_games_in_season(@season).each do |team|
      team.adpr(season: @season, overwrite: true) if [nil, 0].include? team.adpr(season: @season)
      team.aopr(season: @season, overwrite: true) if [nil, 0].include? team.aopr(season: @season)
      team.apdp(season: @season, overwrite: true) if [nil, 0].include? team.apdp(season: @season)
      team.apop(season: @season, overwrite: true) if [nil, 0].include? team.apop(season: @season)
      team.appd(season: @season, overwrite: true) if [nil, 0].include? team.appd(season: @season)
      team.cpr(season: @season, overwrite: true) if [nil, 0].include? team.cpr(season: @season)
    end
  end
end
