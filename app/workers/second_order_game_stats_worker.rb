class SecondOrderGameStatsWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform(team_id, game_id)
    @team = Team.find_by(id: team_id)
    raise "#{self.class.name} unable to find team ID #{team_id}" if @team.blank?

    @game = Game.find_by(id: game_id)
    raise "#{self.class.name} unable to find game ID #{game_id}" if @game.blank?
    @season = @game.season

    @opponent = set_opponent
    raise "#{self.class.name} unable to set opponent of team ID #{team_id} on game ID #{game_id}" if @opponent.blank?

    # Team of `team_id` just had APOP/APDP recalculated
    # These stats needed to (re)calculate *opponent's* 2.o. game stats
    write_or_overwrite_opponent_stats
  end

  private

  def calculate_dpr_value
    pdp = Stat.find_by(name: "pdp", game_id: @game.id, season: @season, team_id: @opponent.id).value
    return 1000.0 if pdp == 0
    100 * (@team.apop(season: @season) / pdp)
  end

  def calculate_opr_value
    pop = Stat.find_by(name: "pop", game_id: @game.id, season: @season, team_id: @opponent.id).value
    return 1000.0 if (team_apdp = @team.apdp(season: @season)) == 0
    100 * (pop / team_apdp)
  end

  def set_opponent
    name = ([@game.home_team_name, @game.away_team_name] - [@team.name]).first
    Team.find_by(name: name)
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

  def write_or_overwrite_opponent_stats
    opr = set_opr_object
    dpr = set_dpr_object
    opr.value = calculate_opr_value
    dpr.value = calculate_dpr_value

    begin
      opr.save!
      dpr.save!

      @opponent.aopr(season: @season, overwrite: true)
      @opponent.adpr(season: @season, overwrite: true)
      @opponent.cpr(season: @season, overwrite: true)
    rescue => exception
      raise "#{self.class.name} encountered error processing stats for teams #{@team.id} & #{@opponent.id} on game #{@game.id}: #{exception}"
    end
  end
end
