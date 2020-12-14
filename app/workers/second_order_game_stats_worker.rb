class SecondOrderGameStatsWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform(season, team_id)
    team = Team.find_by(id: team_id)

    if team.blank?
      Rails.logger.error("SecondOrderGameStatsWorker unable to find team of ID #{team_id}")
      return false
    end

    team.games.where(season: season).each do |game|
      SecondOrderGameStatsCalculateWorker.perform_async(team_id, game.id)
    end
  end
end
