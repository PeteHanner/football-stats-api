require 'rails_helper'
RSpec.describe FirstOrderGameStatsWorker, type: :worker do
  describe "#perform" do
    it "creates POP and PDP for home and away teams" do
      game = create(:game)
      home_pop = game.home_team_score.to_f / game.home_team_drives.to_f
      away_pop = game.away_team_score.to_f / game.away_team_drives.to_f
      home_pdp = away_pop
      away_pdp = home_pop

      FirstOrderGameStatsWorker.new.perform(game.id)

      home_team = Team.find_by(name: game.home_team_name)
      away_team = Team.find_by(name: game.away_team_name)

      expect(Stat.where(
        game: game,
        season: game.season,
        name: "pop",
        team: home_team,
        value: home_pop
      ).count).to eq(1)

      expect(Stat.where(
        game: game,
        season: game.season,
        name: "pdp",
        team: home_team,
        value: home_pdp
      ).count).to eq(1)

      expect(Stat.where(
        game: game,
        season: game.season,
        name: "pop",
        team: away_team,
        value: away_pop
      ).count).to eq(1)

      expect(Stat.where(
        game: game,
        season: game.season,
        name: "pdp",
        team: away_team,
        value: away_pdp
      ).count).to eq(1)
    end

    it "calls FirstOrderSeasonStatsWorker when complete" do
      home_team = create(:team)
      away_team = create(:team, :opponent)
      game = create(:game, home_team_name: home_team.name, away_team_name: away_team.name)

      expect(FirstOrderSeasonStatsWorker).to receive(:perform_async).with([home_team.id, away_team.id])

      FirstOrderGameStatsWorker.new.perform(game.id)
    end

    it "logs error and returns safely if no game found" do
      bad_id = Game.all.count + 1

      expect(Rails.logger).to receive(:error).with("FirstOrderGameStatsWorker unable to find Game ID #{bad_id}")

      FirstOrderGameStatsWorker.new.perform(bad_id)
    end
  end
end
