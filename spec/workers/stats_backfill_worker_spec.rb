require "rails_helper"
# require "sidekiq/testing"
# Sidekiq::Testing.inline!

RSpec.describe StatsBackfillWorker, type: :worker do
  describe "#perform" do
    it "calls FirstOrderGameStatsWorker on any games missing 1.o. stats" do
      team1 = create(:team)
      team2 = create(:team)
      game = create(
        :game,
        season: 2000,
        home_team_name: team1.name,
        away_team_name: team2.name
      )
      create(:stat, season: 2000, name: "pop", game: game, team: team1)
      create(:stat, season: 2000, name: "pop", game: game, team: team2)
      create(:stat, season: 2000, name: "pdp", game: game, team: team1)

      expect(FirstOrderGameStatsWorker).to receive(:perform_async).with(game.id)

      StatsBackfillWorker.new.perform(2000)
    end

    it "calls SecondOrderGameStatsWorker on any games missing 2.o. stats as long as 1.o. stats exist" do
      team1 = create(:team)
      team2 = create(:team)
      game = create(
        :game,
        season: 2000,
        home_team_name: team1.name,
        away_team_name: team2.name
      )
      create(:stat, season: 2000, name: "pop", game: game, team: team1)
      create(:stat, season: 2000, name: "pop", game: game, team: team2)
      create(:stat, season: 2000, name: "pdp", game: game, team: team1)
      create(:stat, season: 2000, name: "pdp", game: game, team: team2)
      create(:stat, season: 2000, name: "opr", game: game, team: team1)
      create(:stat, season: 2000, name: "opr", game: game, team: team2)
      create(:stat, season: 2000, name: "dpr", game: game, team: team1)

      expect(SecondOrderGameStatsWorker).to receive(:perform_async).with(team1.id, game.id)
      expect(SecondOrderGameStatsWorker).to receive(:perform_async).with(team2.id, game.id)

      StatsBackfillWorker.new.perform(2000)
    end

    it "recalculates season stats for any team missing them" do
      team = create(:team)

      expect(team.adpr(season: 2000)).to eq(0)

      create(:stat, team: team, name: "dpr", value: 5, season: 2000)
      create(:stat, team: team, name: "dpr", value: 3, season: 2000)
      StatsBackfillWorker.new.perform(2000)

      expect(team.adpr(season: 2000)).to eq(4)
    end

    it "defaults to the current season if none provided" do
      allow(Stat).to receive(:current_season).and_return(2001)
      team1 = create(:team)
      game = create(
        :game,
        season: 2001,
        home_team_name: team1.name,
      )
      create(:stat, season: 2001, name: "pop", game: game, team: team1)

      expect(FirstOrderGameStatsWorker).to receive(:perform_async).with(game.id)

      StatsBackfillWorker.new.perform
    end
  end
end
