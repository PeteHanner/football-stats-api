require 'rails_helper'
RSpec.describe SecondOrderGameStatsWorker, type: :worker do
  describe "#perform" do
    it "logs error and returns safely if team not found"
  end
end
