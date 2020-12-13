class SecondOrderGameStatsWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform(season, team_id)
    # Do something
  end
end
