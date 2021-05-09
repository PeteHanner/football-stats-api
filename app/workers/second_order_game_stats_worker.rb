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

    # Team of `team_id` just had APOP/APDP recalculated
    # These stats needed to (re)calculate *opponent's* 2.o. game stats
    write_or_overwrite_opponent_game_stats
    recalculate_opponent_season_stats
  rescue => error
    Rails.logger.error("#{self.class.name} encountered error on game ID #{game_id} for team ID #{team_id}: #{error.message}")
    raise error # force re-queue
  end

  private

  def calculate_dpr_value
    opponent_apop = @opponent.apop(season: @season)
    team_pdp = @game.stats.find_by(name: "pdp", team_id: @team.id).value
    return 0.0 if opponent_apop == 0 && team_pdp == 0
    return (4 * opponent_apop) if team_pdp == 0
    (100 * (opponent_apop / team_pdp)) - 100
  end

  def calculate_opr_value
    team_pop = @game.stats.find_by(name: "pop", team_id: @team.id).value
    opponent_apdp = @opponent.apdp(season: @season)
    return 0.0 if team_pop == 0 && opponent_apdp == 0
    return (4 * team_pop) if opponent_apdp == 0
    (100 * (team_pop / opponent_apdp)) - 100
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
    opr = set_opr_object
    opr.value = calculate_opr_value
    opr.save!

    dpr = set_dpr_object
    dpr.value = calculate_dpr_value
    dpr.save!
  end
end
