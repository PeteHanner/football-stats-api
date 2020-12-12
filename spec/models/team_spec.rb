require 'rails_helper'

RSpec.describe Team, type: :model do
  describe "#pop_over_season" do
    it "returns an array of a team's POP for only the season provided" do
      team = create(:team)
      create(:stat, team: team, name: "pop", season: 2000)
      create(:stat, team: team, name: "pop", season: 2000)
      excluded_stat = create(:stat, team: team, name: "pop", season: 2001)

      expect(team.pop_over_season(2000).length).to eq(2)
      expect(team.pop_over_season(2000)).not_to include(excluded_stat)
    end
  end

  describe "#pdp_over_season" do
    it "returns an array of a team's PDP for only the season provided" do
      team = create(:team)
      create(:stat, team: team, name: "pdp", season: 2000)
      create(:stat, team: team, name: "pdp", season: 2000)
      excluded_stat = create(:stat, team: team, name: "pdp", season: 2001)

      expect(team.pdp_over_season(2000).length).to eq(2)
      expect(team.pdp_over_season(2000)).not_to include(excluded_stat)
    end
  end
end
