class FirstOrderSeasonStatsWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform(season, *team_ids)
    team_ids.each do |id|
      unless id.instance_of?(Integer)
        Rails.logger.error("#{self.class.name} passed non-integer argument for team_id: #{id}")
        next
      end

      team = Team.find_by(id: id)

      if team.blank?
        Rails.logger.error("#{self.class.name} unable to find team of ID #{team_id}")
        next
      end

      team.apdp(season: season, overwrite: true)
      team.apop(season: season, overwrite: true)
      team.appd(season: season, overwrite: true)

      team.games.where(season: season).each do |game|
        SecondOrderGameStatsWorker.perform_async(team.id, game.id)
      end
    end
  end
end
