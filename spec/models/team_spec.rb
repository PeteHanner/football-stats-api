require 'rails_helper'

RSpec.describe Team, type: :model do
  describe "Team#all_with_games_in_season" do
    it "returns an array of only teams that had games in a season" do
      team1 = create(:team)
      team2 = create(:team)
      team3 = create(:team)
      create(:stat, team: team1, season: 2000, game: create(:game, season: 2000))
      create(:stat, team: team2, season: 2000, game: create(:game, season: 2000))
      create(:stat, team: team3, season: 2001, game: create(:game, season: 2001))

      expect(Team.all_with_games_in_season(2000)).to match_array([team1, team2])
      expect(Team.all_with_games_in_season(2000)).not_to include(team3)
    end
  end

  describe "#adpr" do
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
    let(:cache) { Rails.cache }

    before do
      allow(Rails).to receive(:cache).and_return(memory_store)
      Rails.cache.clear
    end

    it "returns sum of all DPR scores ÷ number of games played" do
      team = create(:team)
      create(:stat, team: team, name: "dpr", value: 5, season: 2000)
      create(:stat, team: team, name: "dpr", value: 3, season: 2000)

      expect(team.adpr(season: 2000)).to eq(4)
    end

    it "returns a cached value if no overwrite specified" do
      team = create(:team)
      create(:stat, team: team, name: "dpr", value: 5, season: 2000)
      create(:stat, team: team, name: "dpr", value: 3, season: 2000)

      expect(Rails.cache.read("#{team.name.parameterize}/adpr/2000")).to eq(nil)

      team.adpr(season: 2000)

      expect(Rails.cache.read("#{team.name.parameterize}/adpr/2000")).to eq(4)

      create(:stat, team: team, name: "dpr", value: 1, season: 2000)
      team.adpr(season: 2000)

      expect(Rails.cache.read("#{team.name.parameterize}/adpr/2000")).to eq(4)

      team.adpr(season: 2000, overwrite: true)
      expect(Rails.cache.read("#{team.name.parameterize}/adpr/2000")).to eq(3)
    end
  end

  describe "#aopr" do
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
    let(:cache) { Rails.cache }

    before do
      allow(Rails).to receive(:cache).and_return(memory_store)
      Rails.cache.clear
    end

    it "returns sum of all OPR scores ÷ number of games played" do
      team = create(:team)
      create(:stat, team: team, name: "opr", value: 5, season: 2000)
      create(:stat, team: team, name: "opr", value: 3, season: 2000)

      expect(team.aopr(season: 2000)).to eq(4)
    end

    it "returns a cached value if no overwrite specified" do
      team = create(:team)
      create(:stat, team: team, name: "opr", value: 5, season: 2000)
      create(:stat, team: team, name: "opr", value: 3, season: 2000)

      expect(Rails.cache.read("#{team.name.parameterize}/aopr/2000")).to eq(nil)

      team.aopr(season: 2000)

      expect(Rails.cache.read("#{team.name.parameterize}/aopr/2000")).to eq(4)

      create(:stat, team: team, name: "opr", value: 1, season: 2000)
      team.aopr(season: 2000)

      expect(Rails.cache.read("#{team.name.parameterize}/aopr/2000")).to eq(4)

      team.aopr(season: 2000, overwrite: true)
      expect(Rails.cache.read("#{team.name.parameterize}/aopr/2000")).to eq(3)
    end
  end

  describe "#apdp" do
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
    let(:cache) { Rails.cache }

    before do
      allow(Rails).to receive(:cache).and_return(memory_store)
      Rails.cache.clear
    end

    it "writes to the cache if overwrite is specified" do
      team = create(:team)
      create(:stat, team: team, name: "pdp", season: 2000, value: 5)
      create(:stat, team: team, name: "pdp", season: 2000, value: 3)

      team.apdp(season: 2000, overwrite: true)

      expect(Rails.cache.read("#{team.name.parameterize}/apdp/2000")).to eq(4)

      create(:stat, team: team, name: "pdp", season: 2000, value: 1)
      team.apdp(season: 2000, overwrite: true)

      expect(Rails.cache.read("#{team.name.parameterize}/apdp/2000")).to eq(3)
    end

    it "writes to the cache if no key exists" do
      team = create(:team)
      create(:stat, team: team, name: "pdp", season: 2000, value: 5)
      create(:stat, team: team, name: "pdp", season: 2000, value: 3)

      expect(Rails.cache.read("#{team.name.parameterize}/apdp/2000")).to eq(nil)

      team.apdp(season: 2000, overwrite: true)

      expect(Rails.cache.read("#{team.name.parameterize}/apdp/2000")).to eq(4)
    end

    it "does not write to the cache if the key exists & not forced" do
      team = create(:team)
      create(:stat, team: team, name: "pdp", season: 2000, value: 5)
      create(:stat, team: team, name: "pdp", season: 2000, value: 3)

      team.apdp(season: 2000, overwrite: true)

      expect(Rails.cache.read("#{team.name.parameterize}/apdp/2000")).to eq(4)

      create(:stat, team: team, name: "pdp", season: 2000, value: 1)
      team.apdp(season: 2000)

      expect(Rails.cache.read("#{team.name.parameterize}/apdp/2000")).to eq(4)
    end
  end

  describe "#apop" do
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
    let(:cache) { Rails.cache }

    before do
      allow(Rails).to receive(:cache).and_return(memory_store)
      Rails.cache.clear
    end

    it "writes to the cache if overwrite is specified" do
      team = create(:team)
      create(:stat, team: team, name: "pop", season: 2000, value: 5)
      create(:stat, team: team, name: "pop", season: 2000, value: 3)

      team.apop(season: 2000, overwrite: true)

      expect(Rails.cache.read("#{team.name.parameterize}/apop/2000")).to eq(4)

      create(:stat, team: team, name: "pop", season: 2000, value: 1)
      team.apop(season: 2000, overwrite: true)

      expect(Rails.cache.read("#{team.name.parameterize}/apop/2000")).to eq(3)
    end

    it "writes to the cache if no key exists" do
      team = create(:team)
      create(:stat, team: team, name: "pop", season: 2000, value: 5)
      create(:stat, team: team, name: "pop", season: 2000, value: 3)

      expect(Rails.cache.read("#{team.name.parameterize}/apop/2000")).to eq(nil)

      team.apop(season: 2000)

      expect(Rails.cache.read("#{team.name.parameterize}/apop/2000")).to eq(4)
    end

    it "does not write to the cache if the key exists & not forced" do
      team = create(:team)
      create(:stat, team: team, name: "pop", season: 2000, value: 5)
      create(:stat, team: team, name: "pop", season: 2000, value: 3)

      team.apop(season: 2000)

      expect(Rails.cache.read("#{team.name.parameterize}/apop/2000")).to eq(4)

      create(:stat, team: team, name: "pop", season: 2000, value: 1)
      team.apop(season: 2000)

      expect(Rails.cache.read("#{team.name.parameterize}/apop/2000")).to eq(4)

      team.apop(season: 2000, overwrite: true)

      expect(Rails.cache.read("#{team.name.parameterize}/apop/2000")).to eq(3)
    end
  end

  describe "#appd" do
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
    let(:cache) { Rails.cache }

    before do
      allow(Rails).to receive(:cache).and_return(memory_store)
      Rails.cache.clear
    end

    it "provides the difference between APOP and APDP in a given season" do
      team = create(:team)
      allow_any_instance_of(Team).to receive(:apop).and_return(5)
      allow_any_instance_of(Team).to receive(:apdp).and_return(3)

      expect(team.appd(season: 2000)).to eq(2)
    end

    it "only calculates the specified season" do
      team = create(:team)
      allow_any_instance_of(Team).to receive(:apop).with(season: 2000).and_return(5)
      allow_any_instance_of(Team).to receive(:apdp).with(season: 2000).and_return(3)
      allow_any_instance_of(Team).to receive(:apop).with(season: 2001).and_return(6)
      allow_any_instance_of(Team).to receive(:apdp).with(season: 2001).and_return(3)

      expect(team.appd(season: 2000)).to eq(2)
      expect(team.appd(season: 2001)).to eq(3)
    end

    it "provides a cached value if not overwritten/expired" do
      team = create(:team)
      create(:stat, team: team, name: "pop", season: 2000, value: 2)
      create(:stat, team: team, name: "pdp", season: 2000, value: 1)
      create(:stat, team: team, name: "pop", season: 2000, value: 3)
      create(:stat, team: team, name: "pdp", season: 2000, value: 1)

      expect(Rails.cache.read("#{team.name.parameterize}/appd/2000")).to eq(nil)

      team.appd(season: 2000)
      expect(Rails.cache.read("#{team.name.parameterize}/appd/2000")).to eq(1.5)

      create(:stat, team: team, name: "pop", season: 2000, value: 5)
      create(:stat, team: team, name: "pdp", season: 2000, value: 2)
      team.apop(season: 2000, overwrite: true)
      team.apdp(season: 2000, overwrite: true)
      team.appd(season: 2000)

      expect(Rails.cache.read("#{team.name.parameterize}/appd/2000")).to eq(1.5)

      team.apop(season: 2000, overwrite: true)
      team.apdp(season: 2000, overwrite: true)
      team.appd(season: 2000, overwrite: true)

      expect(Rails.cache.read("#{team.name.parameterize}/appd/2000")).to eq(2)
    end
  end

  describe "#calculate_adpr" do
    it "averages the team's DPR accross a season" do
      team = create(:team)
      create(:stat, team: team, name: "dpr", season: 2000, value: 120)
      create(:stat, team: team, name: "dpr", season: 2000, value: 90)

      expect(team.calculate_adpr(2000)).to eq(105)
    end

    it "returns 0 if the team hasn't played any games that season" do
      team = create(:team)

      expect(team.games.count).to eq(0)
      expect(team.calculate_adpr(2000)).to eq(0)
    end
  end

  describe "#calculate_aopr" do
    it "averages the team's OPR accross a season" do
      team = create(:team)
      create(:stat, team: team, name: "opr", season: 2000, value: 120)
      create(:stat, team: team, name: "opr", season: 2000, value: 90)

      expect(team.calculate_aopr(2000)).to eq(105)
    end

    it "returns 0 if the team hasn't played any games that season" do
      team = create(:team)

      expect(team.games.count).to eq(0)
      expect(team.calculate_aopr(2000)).to eq(0)
    end
  end

  describe "#calculate_apdp" do
    it "averages the team's PDP across a season" do
      team = create(:team)
      create(:stat, team: team, name: "pdp", season: 2000, value: 5)
      create(:stat, team: team, name: "pdp", season: 2000, value: 3)

      expect(team.calculate_apdp(2000)).to eq(4)
    end

    it "returns 0 if the team hasn't played any games that season" do
      team = create(:team)

      expect(team.games.count).to eq(0)
      expect(team.calculate_apdp(2000)).to eq(0)
    end
  end

  describe "#calculate_apop" do
    it "averages the team's POP across a season" do
      team = create(:team)
      create(:stat, team: team, name: "pop", season: 2000, value: 5)
      create(:stat, team: team, name: "pop", season: 2000, value: 3)

      expect(team.calculate_apop(2000)).to eq(4)
    end

    it "returns 0 if the team hasn't played any games that season" do
      team = create(:team)

      expect(team.games.count).to eq(0)
      expect(team.calculate_apop(2000)).to eq(0)
    end
  end

  describe "#cpr" do
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
    let(:cache) { Rails.cache }

    before do
      allow(Rails).to receive(:cache).and_return(memory_store)
      Rails.cache.clear
    end

    it "averages AOPR and ADPR for a season" do
      team = create(:team)
      create(:stat, team: team, season: 2000, name: "opr", value: 120)
      create(:stat, team: team, season: 2000, name: "dpr", value: 100)

      expect(team.cpr(season: 2000)).to eq(110)
    end

    it "returns a cached value unless missing or overwritten" do
      team = create(:team)
      create(:stat, team: team, season: 2000, name: "opr", value: 120)
      create(:stat, team: team, season: 2000, name: "dpr", value: 100)

      expect(Rails.cache.read("#{team.name.parameterize}/cpr/2000")).to eq(nil)

      team.cpr(season: 2000)

      expect(Rails.cache.read("#{team.name.parameterize}/cpr/2000")).to eq(110)

      create(:stat, team: team, season: 2000, name: "opr", value: 100)
      create(:stat, team: team, season: 2000, name: "dpr", value: 80)

      team.aopr(season: 2000, overwrite: true)
      team.adpr(season: 2000, overwrite: true)
      team.cpr(season: 2000)
      expect(Rails.cache.read("#{team.name.parameterize}/cpr/2000")).to eq(110)

      team.aopr(season: 2000, overwrite: true)
      team.adpr(season: 2000, overwrite: true)
      team.cpr(season: 2000, overwrite: true)
      expect(Rails.cache.read("#{team.name.parameterize}/cpr/2000")).to eq(100)
    end
  end

  describe "#dpr_over_season" do
    it "returns an array of a team's DPR for only the season provided" do
      team = create(:team)
      create(:stat, team: team, name: "dpr", season: 2000)
      create(:stat, team: team, name: "dpr", season: 2000)
      excluded_stat = create(:stat, team: team, name: "dpr", season: 2001)

      expect(team.dpr_over_season(2000).length).to eq(2)
      expect(team.dpr_over_season(2000)).not_to include(excluded_stat)
    end
  end

  describe "#opr_over_season" do
    it "returns an array of a team's OPR for only the season provided" do
      team = create(:team)
      create(:stat, team: team, name: "opr", season: 2000)
      create(:stat, team: team, name: "opr", season: 2000)
      excluded_stat = create(:stat, team: team, name: "opr", season: 2001)

      expect(team.opr_over_season(2000).length).to eq(2)
      expect(team.opr_over_season(2000)).not_to include(excluded_stat)
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
end
