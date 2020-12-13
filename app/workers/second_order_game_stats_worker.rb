class SecondOrderGameStatsWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform(season, team_id)
    @team = Team.find_by(id: team_id)

    if @team.blank?
      Rails.logger.error("SecondOrderGameStatsWorker unable to find team of ID #{team_id}")
      return false
    end

    @team.games.each do |game|
      write_or_overwrite_stats(game)
    end
  end

  private

  def caclculate_dpr_value
    pdp = Stat.find_by(name: "pdp", game_id: game.id, team_id: @team.id).value
    opponent = set_opponent(game, team.name)
    100 * (opponent.apop / pdp)
  end

  def caclculate_opr_value
    pop = Stat.find_by(name: "pop", game_id: game.id, team_id: @team.id).value
    opponent = set_opponent(game, team.name)
    100 * (pop / opponent.apdp)
  end

  def set_dpr_object(game_id, team_id)
    Stat.find_or_initialize_by(
      game_id: game_id,
      name: "dpr",
      team_id: team_id
    )
  end

  def set_opr_object(game_id, team_id)
    Stat.find_or_initialize_by(
      game_id: game_id,
      name: "opr",
      team_id: team_id
    )
  end

  def set_opponent(game, team_name)
    name = [game.home_team_name, game.away_team_name].reject(team_name)
    Team.find_by(name: name)
  end

  def write_or_overwrite_stats(game)
    opr = set_opr_object(game.id, @team.id)
    dpr = set_dpr_object(game.id, @team.id)
    opr.value = caclculate_opr_value
    dpr.value = caclculate_dpr_value

    begin
      opr.save!
      dpr.save!
    rescue => exception
      Rails.logger.error("SecondOrderGameStatsWorker encountered error processing stats for team #{team_id} on game #{game.id}: #{exception}")
      return false
    end
  end
end
