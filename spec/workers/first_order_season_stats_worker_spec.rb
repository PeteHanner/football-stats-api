require "rails_helper"

RSpec.describe FirstOrderSeasonStatsWorker, type: :worker do
  describe "#perform" do
    it "recalculates APOP and APDP for each team passed" do
      team1 = create(:team)
      team2 = create(:team)
      allow_any_instance_of(Team).to receive(:calculate_apdp).and_return(2)
      allow_any_instance_of(Team).to receive(:calculate_apop).and_return(3)

      FirstOrderSeasonStatsWorker.new.perform(2000, team1.id, team2.id)

      expect(team1.apdp(season: 2000)).to eq(2)
      expect(team1.apop(season: 2000)).to eq(3)
      expect(team2.apdp(season: 2000)).to eq(2)
      expect(team2.apop(season: 2000)).to eq(3)
    end

    it "safely continues if non-ID integer passed" do
      team1 = create(:team)
      allow_any_instance_of(Team).to receive(:calculate_apdp).and_return(2)
      allow_any_instance_of(Team).to receive(:calculate_apop).and_return(3)

      expect { FirstOrderSeasonStatsWorker.new.perform(2000, team1.id, "string") }.not_to raise_error
      expect(team1.apdp(season: 2000)).to eq(2)
      expect(team1.apop(season: 2000)).to eq(3)
    end

    it "safely continues if invalid ID passed" do
      team1 = create(:team)
      allow_any_instance_of(Team).to receive(:calculate_apdp).and_return(2)
      allow_any_instance_of(Team).to receive(:calculate_apop).and_return(3)
      bad_id = Team.all.count + 1

      expect { FirstOrderSeasonStatsWorker.new.perform(2000, team1.id, bad_id) }.not_to raise_error
      expect(team1.apdp(season: 2000)).to eq(2)
      expect(team1.apop(season: 2000)).to eq(3)
    end

    it "calls SecondOrderGameStatsWorker async on each team when complete" do
      team1 = create(:team)
      team2 = create(:team)
      2.times { create(:stat, season: 2000, team: team1) }
      2.times { create(:stat, season: 2000, team: team2) }
      allow_any_instance_of(Team).to receive(:calculate_apdp).and_return(2)
      allow_any_instance_of(Team).to receive(:calculate_apop).and_return(3)

      expect(SecondOrderGameStatsWorker).to receive(:perform_async).exactly(4).times

      FirstOrderSeasonStatsWorker.new.perform(2000, team1.id, team2.id)
    end

    it "logs and raises error if encountered" do
      team1 = create(:team)
      team2 = create(:team)
      2.times { create(:stat, season: 2000, team: team1) }
      2.times { create(:stat, season: 2000, team: team2) }
      allow_any_instance_of(Team).to receive(:calculate_apdp).and_return(2)
      allow_any_instance_of(Team).to receive(:calculate_apop).and_raise(StandardError, "ERROR MESSAGE")
      error_msg = "#{described_class.name} encountered error on season 2000 with team IDs #{[team1.id, team2.id]}: ERROR MESSAGE"

      expect(Rails.logger).to receive(:error).with(error_msg)
      expect { FirstOrderSeasonStatsWorker.new.perform(2000, team1.id, team2.id) }.to raise_error(StandardError)
    end
  end
end
