require 'rails_helper'

RSpec.describe Team, type: :model do
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

      expect(Rails.cache.read("#{team.name}/apdp/2000")).to eq(4)

      create(:stat, team: team, name: "pdp", season: 2000, value: 1)
      team.apdp(season: 2000, overwrite: true)

      expect(Rails.cache.read("#{team.name}/apdp/2000")).to eq(3)
    end

    it "writes to the cache if no key exists" do
      team = create(:team)
      create(:stat, team: team, name: "pdp", season: 2000, value: 5)
      create(:stat, team: team, name: "pdp", season: 2000, value: 3)

      expect(Rails.cache.read("#{team.name}/apdp/2000")).to eq(nil)

      team.apdp(season: 2000, overwrite: true)

      expect(Rails.cache.read("#{team.name}/apdp/2000")).to eq(4)
    end

    it "does not write to the cache if the key exists & not forced" do
      team = create(:team)
      create(:stat, team: team, name: "pdp", season: 2000, value: 5)
      create(:stat, team: team, name: "pdp", season: 2000, value: 3)

      team.apdp(season: 2000, overwrite: true)

      expect(Rails.cache.read("#{team.name}/apdp/2000")).to eq(4)

      create(:stat, team: team, name: "pdp", season: 2000, value: 1)
      team.apdp(season: 2000)

      expect(Rails.cache.read("#{team.name}/apdp/2000")).to eq(4)
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

      team.apop(2000, overwrite: true)

      expect(Rails.cache.read("#{team.name}/apop/2000")).to eq(4)

      create(:stat, team: team, name: "pop", season: 2000, value: 1)
      team.apop(2000, overwrite: true)

      expect(Rails.cache.read("#{team.name}/apop/2000")).to eq(3)
    end

    it "writes to the cache if no key exists" do
      team = create(:team)
      create(:stat, team: team, name: "pop", season: 2000, value: 5)
      create(:stat, team: team, name: "pop", season: 2000, value: 3)

      expect(Rails.cache.read("#{team.name}/apop/2000")).to eq(nil)

      team.apop(2000, overwrite: true)

      expect(Rails.cache.read("#{team.name}/apop/2000")).to eq(4)
    end

    it "does not write to the cache if the key exists & not forced" do
      team = create(:team)
      create(:stat, team: team, name: "pop", season: 2000, value: 5)
      create(:stat, team: team, name: "pop", season: 2000, value: 3)

      team.apop(2000, overwrite: true)

      expect(Rails.cache.read("#{team.name}/apop/2000")).to eq(4)

      create(:stat, team: team, name: "pop", season: 2000, value: 1)
      team.apop(2000)

      expect(Rails.cache.read("#{team.name}/apop/2000")).to eq(4)
    end
  end

  describe "#calculate_apdp" do
    it "averages the team's PDP across a season" do
      team = create(:team)
      create(:stat, team: team, name: "pdp", season: 2000, value: 5)
      create(:stat, team: team, name: "pdp", season: 2000, value: 3)

      expect(team.calculate_apdp(2000)).to eq(4)
    end
  end

  describe "#calculate_apop" do
    it "averages the team's POP across a season" do
      team = create(:team)
      create(:stat, team: team, name: "pop", season: 2000, value: 5)
      create(:stat, team: team, name: "pop", season: 2000, value: 3)

      expect(team.calculate_apop(2000)).to eq(4)
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
