class FirstOrderGameStatsWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform(game_id)
    @game = Game.find_by(id: game_id)

    if @game.nil?
      Rails.logger.error("FirstOrderGameStatsWorker unable to find Game ID #{game_id}")
      return false
    end

    @home_team = Team.find_or_create_by(name: @game.home_team_name)
    @away_team = Team.find_or_create_by(name: @game.away_team_name)

    set_pop_and_pdp

    FirstOrderSeasonStatsWorker.perform_async(@game.season, @home_team.id, @away_team.id)
  end

  private

  def set_pop_and_pdp
    home_team_pop = @game.home_team_score.to_f / @game.home_team_drives.to_f
    away_team_pop = @game.away_team_score.to_f / @game.away_team_drives.to_f

    # Points per Offensive Possession
    # How many points did you get on average every time you had the ball?
    Stat.create(
      game: @game,
      season: @game.season,
      name: "pop",
      team: @home_team,
      value: home_team_pop
    )

    Stat.create(
      game: @game,
      season: @game.season,
      name: "pop",
      team: @away_team,
      value: away_team_pop
    )

    # Points per Defensive Possession
    # How many points did you allow on average every time your opponent had the ball?
    # Same as opponent's POP
    Stat.create(
      game: @game,
      season: @game.season,
      name: "pdp",
      team: @away_team,
      value: home_team_pop
    )

    Stat.create(
      game: @game,
      season: @game.season,
      name: "pdp",
      team: @home_team,
      value: away_team_pop
    )
  end
end
