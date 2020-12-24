require "rails_helper"

RSpec.describe Game, type: :model do
  describe "#home_team" do
    it "returns the team object corresponding to home_team_name" do
      team1 = create(:team)
      team2 = create(:team)
      game = create(:game, home_team_name: team1.name, away_team_name: team2.name)

      expect(game.home_team).to eq(team1)
    end
  end

  describe "#away_team" do
    it "returns the team object corresponding to home_team_name" do
      team1 = create(:team)
      team2 = create(:team)
      game = create(:game, home_team_name: team1.name, away_team_name: team2.name)

      expect(game.away_team).to eq(team2)
    end
  end

  describe "#missing_first_order_stats?" do
    it "returns true if first-order game stats are missing for either team" do
      game = create(:game)
      2.times { create(:stat, game: game, name: "pop") }
      create(:stat, game: game, name: "pdp")

      expect(game.missing_first_order_stats?).to eq(true)
    end

    it "returns false if first-order game stats are present for both teams" do
      game = create(:game)
      2.times { create(:stat, game: game, name: "pop") }
      2.times { create(:stat, game: game, name: "pdp") }

      expect(game.missing_first_order_stats?).to eq(false)
    end
  end

  describe "#missing_second_order_stats?" do
    it "returns true if second-order game stats are missing for either team" do
      game = create(:game)
      2.times { create(:stat, game: game, name: "opr") }
      create(:stat, game: game, name: "dpr")

      expect(game.missing_second_order_stats?).to eq(true)
    end

    it "returns false if second-order game stats are present for both teams" do
      game = create(:game)
      2.times { create(:stat, game: game, name: "opr") }
      2.times { create(:stat, game: game, name: "dpr") }

      expect(game.missing_second_order_stats?).to eq(false)
    end
  end
end
