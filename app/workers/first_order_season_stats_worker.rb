class FirstOrderSeasonStatsWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform(season, *team_ids)
    team_ids.each do |id|
      next unless id.instance_of?(Integer)

      team = Team.find_by(id: id)

      next unless team.present?

      # 'true' arg forces overwrite
      team.apdp(season, true)
      team.apop(season, true)
    end
  end
end
