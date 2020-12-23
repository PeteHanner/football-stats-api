require "rails_helper"

RSpec.describe Stat, type: :model do
  describe "Stat#current_season" do
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
    let(:cache) { Rails.cache }

    before do
      allow(Rails).to receive(:cache).and_return(memory_store)
      Rails.cache.clear
    end

    it "returns the latest season for which games are available" do
      create(:game, season: 2000)
      create(:game, season: 2001)

      expect(Stat.current_season).to eq(2001)
    end

    it "returns a cached value if not force overwritten" do
      create(:game, season: 2000)
      create(:game, season: 2001)

      expect(Rails.cache.read("seasons/current")).to eq(nil)

      Stat.current_season
      expect(Rails.cache.read("seasons/current")).to eq(2001)
      expect(Stat.current_season).to eq(2001)

      create(:game, season: 2002)
      Stat.current_season
      expect(Rails.cache.read("seasons/current")).to eq(2001)

      Stat.current_season(overwrite: true)
      expect(Rails.cache.read("seasons/current")).to eq(2002)
      expect(Stat.current_season).to eq(2002)
    end
  end
end
