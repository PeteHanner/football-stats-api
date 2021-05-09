class SecondOrderGameStatsWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform(team_id, game_id)
    @team = Team.find_by(id: team_id)
    raise "Unable to find team ID #{team_id}" if @team.blank?

    @game = Game.find_by(id: game_id)
    raise "Unable to find game ID #{game_id}" if @game.blank?

    @season = @game.season
    @opponent = set_opponent

    # Team of `team_id` just had APOP/APDP recalculated in FirstOrderSeasonStatsWorker
    # These stats needed to (re)calculate *opponent's* 2.o. game stats
    write_or_overwrite_opponent_game_stats
    recalculate_opponent_season_stats
  rescue => error
    Rails.logger.error("#{self.class.name} encountered error on game ID #{game_id} for team ID #{team_id}: #{error.message}")
    raise error # force re-queue
  end

  private

  def calculate_opponent_dpr_value
    opponent_pdp = @game.stats.find_by(name: "pdp", team_id: @opponent.id).value
    team_apop = @team.apop(season: @season)
    return 0.0 if opponent_pdp == 0 && team_apop == 0
    return (4 * team_apop) if opponent_pdp == 0
    (100 * (team_apop / opponent_pdp)) - 100
  end

  def calculate_opponent_opr_value
    opponent_pop = @game.stats.find_by(name: "pop", team_id: @opponent.id).value
    team_apdp = @team.apdp(season: @season)
    return 0.0 if opponent_pop == 0 && team_apdp == 0
    return (4 * opponent_pop) if team_apdp == 0
    (100 * (opponent_pop / team_apdp)) - 100
  end

  def recalculate_opponent_season_stats
    @opponent.aopr(season: @season, overwrite: true)
    @opponent.adpr(season: @season, overwrite: true)
    @opponent.cpr(season: @season, overwrite: true)
  end

  def set_opponent
    ([@game.home_team, @game.away_team] - [@team]).first
  end

  def set_dpr_object
    Stat.find_or_initialize_by(
      game_id: @game.id,
      name: "dpr",
      team_id: @opponent.id,
      season: @season
    )
  end

  def set_opr_object
    Stat.find_or_initialize_by(
      game_id: @game.id,
      name: "opr",
      team_id: @opponent.id,
      season: @season
    )
  end

  def write_or_overwrite_opponent_game_stats
    opponent_opr = set_opr_object
    opponent_opr.value = calculate_opponent_opr_value
    opponent_opr.save!

    opponent_dpr = set_dpr_object
    opponent_dpr.value = calculate_opponent_dpr_value
    opponent_dpr.save!
  end
end
