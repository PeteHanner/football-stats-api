class FirstOrderGameStatsWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform(game_id)
    @game = Game.find_by(id: game_id)

    raise "ERROR: #{self.class.name} unable to find Game ID #{game_id}" if @game.nil?

    @home_team = @game.home_team
    @away_team = @game.away_team

    set_pop_and_pdp

    FirstOrderSeasonStatsWorker.perform_async(@game.season, @home_team.id, @away_team.id)
  end

  private

  def home_team_pop_object
    Stat.find_or_create_by(
      game: @game,
      season: @game.season,
      name: "pop",
      team: @home_team
    )
  end

  def away_team_pop_object
    Stat.find_or_create_by(
      game: @game,
      season: @game.season,
      name: "pop",
      team: @away_team
    )
  end

  def home_team_pdp_object
    Stat.find_or_create_by(
      game: @game,
      season: @game.season,
      name: "pdp",
      team: @away_team
    )
  end

  def away_team_pdp_object
    Stat.find_or_create_by(
      game: @game,
      season: @game.season,
      name: "pdp",
      team: @home_team,
    )
  end

  def set_pop_and_pdp
    home_team_pop_value = @game.home_team_score.to_f / @game.home_team_drives.to_f
    away_team_pop_value = @game.away_team_score.to_f / @game.away_team_drives.to_f

    home_team_pop = home_team_pop_object
    home_team_pop.value = home_team_pop_value
    home_team_pop.save

    away_team_pop = away_team_pop_object
    away_team_pop.value = away_team_pop_value
    away_team_pop.save

    home_team_pdp = home_team_pdp_object
    home_team_pdp.value = away_team_pop_value
    home_team_pdp.save

    away_team_pdp = away_team_pdp_object
    away_team_pdp.value = home_team_pop_value
    away_team_pdp.save
  end
end
