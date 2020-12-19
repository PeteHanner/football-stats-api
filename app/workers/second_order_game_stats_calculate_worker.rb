class SecondOrderGameStatsCalculateWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform(team_id, game_id)
    @team = Team.find_by(id: team_id)
    @game = Game.find_by(id: game_id)
    @opponent = set_opponent
    write_or_overwrite_stats
    SecondOrderGameStatsWorker.perform_async(@game.season, @opponent.id)
  end

  private

  def caclculate_dpr_value
    # Defensive Performance Ratio
    # By what percentage was your defense better/worse than the others your opponent has faced on the season?
    pdp = Stat.find_by(name: "pdp", game_id: @game.id, team_id: @team.id).value
    100 * (@opponent.apop(season: @game.season) / pdp)
  end

  def caclculate_opr_value
    # Offensive Performance Ratio
    # By what percentage was your offense better/worse than the others your opponent has faced on the season?
    pop = Stat.find_by(name: "pop", game_id: @game.id, team_id: @team.id).value
    100 * (pop / @opponent.apdp(season: @game.season))
  end

  def set_dpr_object
    Stat.find_or_initialize_by(
      game_id: @game.id,
      name: "dpr",
      team_id: @team.id
    )
  end

  def set_opr_object
    Stat.find_or_initialize_by(
      game_id: @game.id,
      name: "opr",
      team_id: @team.id
    )
  end

  def set_opponent
    name = ([@game.home_team_name, @game.away_team_name] - [@team.name]).first
    Team.find_by(name: name)
  end

  def write_or_overwrite_stats
    opr = set_opr_object
    dpr = set_dpr_object
    opr.value = caclculate_opr_value
    dpr.value = caclculate_dpr_value

    begin
      opr.save!
      dpr.save!
    rescue => exception
      Rails.logger.error("SecondOrderGameStatsWorker encountered error processing stats for team #{@team.id} on game #{@game.id}: #{exception}")
    end
  end
end
