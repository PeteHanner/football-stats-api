require "rails_helper"

RSpec.describe SecondOrderGameStatsWorker, type: :worker do
  describe "#perform" do
    it "sets OPR and DPR for opponent of provided team on each game" do
      team = create(:team)
      opponent = create(:team)
      game = create(:game, home_team_name: team.name, away_team_name: opponent.name)
      create(:stat, name: "pop", team: opponent, game: game, value: 3)
      create(:stat, name: "pdp", team: opponent, game: game, value: 4)
      allow_any_instance_of(Team).to receive(:apdp).and_return(2.5)
      allow_any_instance_of(Team).to receive(:apop).and_return(5)

      SecondOrderGameStatsWorker.new.perform(team.id, game.id)
      opr = Stat.find_by(name: "opr", team: opponent)
      dpr = Stat.find_by(name: "dpr", team: opponent)

      expect(opr.present?).to eq(true)
      expect(opr.value).to eq(120)
      expect(dpr.present?).to eq(true)
      expect(dpr.value).to eq(125)
    end

    it "returns an DPR of 100% if opponent PDP and team APOP are both 0" do
      team = create(:team)
      opponent = create(:team)
      game = create(:game, home_team_name: team.name, away_team_name: opponent.name)
      create(:stat, name: "pop", team: opponent, game: game, value: 3)
      create(:stat, name: "pdp", team: opponent, game: game, value: 0)
      allow_any_instance_of(Team).to receive(:apdp).and_return(2.5)
      allow_any_instance_of(Team).to receive(:apop).and_return(0)

      SecondOrderGameStatsWorker.new.perform(team.id, game.id)
      dpr = Stat.find_by(name: "dpr", team: opponent)

      expect(dpr.present?).to eq(true)
      expect(dpr.value).to eq(100)
    end

    it "returns an DPR of 1000% if just PDP is 0" do
      team = create(:team)
      opponent = create(:team)
      game = create(:game, home_team_name: team.name, away_team_name: opponent.name)
      create(:stat, name: "pop", team: opponent, game: game, value: 3)
      create(:stat, name: "pdp", team: opponent, game: game, value: 0)
      allow_any_instance_of(Team).to receive(:apdp).and_return(2.5)
      allow_any_instance_of(Team).to receive(:apop).and_return(5)

      SecondOrderGameStatsWorker.new.perform(team.id, game.id)
      dpr = Stat.find_by(name: "dpr", team: opponent)

      expect(dpr.present?).to eq(true)
      expect(dpr.value).to eq(1000)
    end

    it "returns an OPR of 100% if team POP and opponent APDP are both 0" do
      team = create(:team)
      opponent = create(:team)
      game = create(:game, home_team_name: team.name, away_team_name: opponent.name)
      create(:stat, name: "pop", team: opponent, game: game, value: 0)
      create(:stat, name: "pdp", team: opponent, game: game, value: 4)
      allow_any_instance_of(Team).to receive(:apdp).and_return(0)
      allow_any_instance_of(Team).to receive(:apop).and_return(5)

      SecondOrderGameStatsWorker.new.perform(team.id, game.id)
      opr = Stat.find_by(name: "opr", team: opponent)

      expect(opr.present?).to eq(true)
      expect(opr.value).to eq(100)
    end

    it "returns an OPR of 1000% if just opponent APDP is 0" do
      team = create(:team)
      opponent = create(:team)
      game = create(:game, home_team_name: team.name, away_team_name: opponent.name)
      create(:stat, name: "pop", team: opponent, game: game, value: 3)
      create(:stat, name: "pdp", team: opponent, game: game, value: 4)
      allow_any_instance_of(Team).to receive(:apdp).and_return(0)
      allow_any_instance_of(Team).to receive(:apop).and_return(5)

      SecondOrderGameStatsWorker.new.perform(team.id, game.id)
      opr = Stat.find_by(name: "opr", team: opponent)

      expect(opr.present?).to eq(true)
      expect(opr.value).to eq(1000)
    end

    it "raises error if team not found" do
      bad_id = Team.all.count + 1
      error_msg = "#{described_class.name} encountered error on game ID 1 for team ID #{bad_id}: Unable to find team ID #{bad_id}"

      expect(Rails.logger).to receive(:error).with(error_msg)
      expect { SecondOrderGameStatsWorker.new.perform(bad_id, 1) }.to raise_error(RuntimeError)
    end

    it "raises error if game not found" do
      team = create(:team)
      bad_id = Game.all.count + 1
      error_msg = "#{described_class.name} encountered error on game ID #{bad_id} for team ID #{team.id}: Unable to find game ID #{bad_id}"

      expect(Rails.logger).to receive(:error).with(error_msg)
      expect { SecondOrderGameStatsWorker.new.perform(team.id, bad_id) }.to raise_error(RuntimeError)
    end

    it "raises error if unable to save stats" do
      team = create(:team)
      opponent = create(:team)
      game = create(:game, home_team_name: team.name, away_team_name: opponent.name)
      create(:stat, name: "pop", team: opponent, game: game, value: 3)
      create(:stat, name: "pdp", team: opponent, game: game, value: 4)
      allow_any_instance_of(Team).to receive(:apdp).and_return(2.5)
      allow_any_instance_of(Team).to receive(:apop).and_return(5)
      allow_any_instance_of(Stat).to receive(:save!).and_raise(StandardError, "ERROR MESSAGE")
      error_msg = "#{described_class.name} encountered error on game ID #{game.id} for team ID #{team.id}: ERROR MESSAGE"

      expect(Rails.logger).to receive(:error).with(error_msg)
      expect { SecondOrderGameStatsWorker.new.perform(team.id, game.id) }.to raise_error(StandardError)
    end
  end
end
