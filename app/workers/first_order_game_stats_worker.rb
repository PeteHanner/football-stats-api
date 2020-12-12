class FirstOrderGameStatsWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform(game_id)
    @game = Game.find_by(id: game_id)

    if @game.nil?
      Rails.logger.error("FirstOrderGameStatsWorker unable to find Game ID #{game_id}")
      return false
    end

    home_team = set_home_team
    away_team = set_away_team

    set_pop(team: home_team, is_home_team: true)
    set_pdp(team: home_team, is_home_team: true)
    set_pop(team: away_team, is_home_team: false)
    set_pdp(team: away_team, is_home_team: false)

    FirstOrderSeasonStatsWorker.perform_async(@game.season, home_team.id, away_team.id)
  end

  private

  # Points per Offensive Possession
  def set_pop(team:, is_home_team:)
    pop = if is_home_team
      @game.home_team_score.to_f / @game.home_team_drives.to_f
    else
      @game.away_team_score.to_f / @game.away_team_drives.to_f
    end

    Stat.create(
      game: @game,
      season: @game.season,
      name: "pop",
      team: team,
      value: pop
    )
  end

  # Points per Defensive Possession
  def set_pdp(team:, is_home_team:)
    pdp = if is_home_team
      @game.away_team_score.to_f / @game.away_team_drives.to_f
    else
      @game.home_team_score.to_f / @game.home_team_drives.to_f
    end

    Stat.create(
      game: @game,
      season: @game.season,
      name: "pdp",
      team: team,
      value: pdp
    )
  end

  def set_home_team
    Team.find_or_create_by(name: @game.home_team_name)
  end

  def set_away_team
    Team.find_or_create_by(name: @game.away_team_name)
  end
end
