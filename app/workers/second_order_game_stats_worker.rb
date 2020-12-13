class SecondOrderGameStatsWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform(season, team_id)
    team = Team.find_by(id: team_id)

    if team.blank?
      Rails.logger.error("SecondOrderGameStatsWorker unable to find team of ID #{team_id}")
      return false
    end

    team.games.each do |game|
      opr = set_opr_object(game.id, team_id)
      dpr = set_dpr_object(game.id, team_id)
      pop = Stat.find_by(name: "pop", game_id: game.id, team_id: team_id).value
      pdp = Stat.find_by(name: "pdp", game_id: game.id, team_id: team_id).value
      opponent = set_opponent(game, team.name)

      opr_value = 100 * (pop / opponent.apdp)
      dpr_value = 100 * (opponent.apop / pdp)
    end
  end

  private

  def set_opr_object(game_id, team_id)
    Stat.find_or_initialize_by(
      game_id: game_id,
      name: "opr",
      team_id: team_id
    )
  end

  def set_dpr_object(game_id, team_id)
    Stat.find_or_initialize_by(
      game_id: game_id,
      name: "dpr",
      team_id: team_id
    )
  end

  def set_opponent(game, team_name)
    name = [game.home_team_name, game.away_team_name].reject(team_name)
    Team.find_by(name: name)
  end
end
