require 'rails_helper'
RSpec.describe SecondOrderGameStatsWorker, type: :worker do
  describe "#perform" do
    it "logs error and returns safely if team not found" do
      bad_id = Team.all.count + 1

      expect(Rails.logger).to receive(:error).with("SecondOrderGameStatsWorker unable to find team of ID #{bad_id}")

      SecondOrderGameStatsWorker.new.perform(2000, bad_id)
    end

    it "calls SecondOrderGameStatsCalculateWorker async for each game in a team's season" do
      team = create(:team)
      create_list(:stat, 3, team: team, game: create(:game, season: 2000))
      create(:stat, team: team, game: create(:game, season: 2001))

      expect(SecondOrderGameStatsCalculateWorker).to receive(:perform_async).exactly(3).times

      SecondOrderGameStatsWorker.new.perform(2000, team.id)
    end
  end
end
