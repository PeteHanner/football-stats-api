require "rails_helper"

RSpec.describe SecondOrderGameStatsCalculateWorker, type: :worker do
  describe "#perform" do
    it "sets a teams OPR and DPR for a given game" do
      team = create(:team)
      opponent = create(:team, :opponent)
      game = create(:game, home_team_name: team.name, away_team_name: opponent.name)
      create(:stat, name: "pop", team: team, game: game, value: 3)
      create(:stat, name: "pdp", team: team, game: game, value: 4)
      allow_any_instance_of(Team).to receive(:apdp).and_return(2.5)
      allow_any_instance_of(Team).to receive(:apop).and_return(5)

      SecondOrderGameStatsCalculateWorker.new.perform(team.id, game.id)
      opr = Stat.find_by(name: "opr", team: team)
      dpr = Stat.find_by(name: "dpr", team: team)

      expect(opr.present?).to eq(true)
      expect(opr.value).to eq(120)
      expect(dpr.present?).to eq(true)
      expect(dpr.value).to eq(125)
    end

    it "logs an error and returns safely if unable to save Stat" do
      team = create(:team)
      opponent = create(:team, :opponent)
      game = create(:game, home_team_name: team.name, away_team_name: opponent.name)
      create(:stat, name: "pop", team: team, game: game, value: 3)
      create(:stat, name: "pdp", team: team, game: game, value: 4)
      allow_any_instance_of(Team).to receive(:apdp).and_return(2.5)
      allow_any_instance_of(Team).to receive(:apop).and_return(5)
      Stat.any_instance.stub(:save!) { raise StandardError, "ERROR MESSAGE" }

      expect(Rails.logger).to receive(:error).with("SecondOrderGameStatsWorker encountered error processing stats for team #{team.id} on game #{game.id}: ERROR MESSAGE")

      SecondOrderGameStatsCalculateWorker.new.perform(team.id, game.id)
    end
  end
end
