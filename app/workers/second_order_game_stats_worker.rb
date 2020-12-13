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
      opr = set_opr(game.id, team_id)
      dpr = set_dpr(game.id, team_id)
      opponent = set_opponent(game, team.name)
    end
  end

  private

  def set_opr(game_id, team_id)
    Stat.find_or_create_by(
      game_id: game_id,
      name: "opr",
      team_id: team_id
    )
  end

  def set_dpr(game_id, team_id)
    Stat.find_or_create_by(
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
