class SecondOrderGameStatsWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, unique: :until_executed

  def perform(team_id, game_id)
    @team = Team.find_by(id: team_id)
    @game = Game.find_by(id: game_id)
    @opponent = set_opponent

    if @team.blank? || @game.blank? || @opponent.blank?
      raise "#{self.class.name} encountered error with arguments team_id #{team_id}, game_id #{game_id}"
    end

    write_or_overwrite_opponent_stats
  end

  private

  def set_opponent
    name = ([@game.home_team_name, @game.away_team_name] - [@team.name]).first
    Team.find_by(name: name)
  end

  def write_or_overwrite_opponent_stats
    # Team of `team_id` just had APOP/APDP recalculated
    # These stats needed to (re)calculate *opponent's* 2.o. game stats
    opr = set_opr_object
    dpr = set_dpr_object
    opr.value = calculate_opr_value
    dpr.value = calculate_dpr_value

    begin
      opr.save!
      dpr.save!

      @opponent.aopr(season: @game.season, overwrite: true)
      @opponent.adpr(season: @game.season, overwrite: true)
      @opponent.cpr(season: @game.season, overwrite: true)
    rescue => exception
      Rails.logger.error("#{self.class.name} encountered error processing stats for teams #{@team.id} & #{@opponent.id} on game #{@game.id}: #{exception}")
    end
  end
end
