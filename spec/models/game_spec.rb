require 'rails_helper'

RSpec.describe Game, type: :model do
  describe "#generate_first_order_stats" do
    it "calls FirstOrderGameStatsWorker on itself" do
      game = create(:game)

      expect(FirstOrderGameStatsWorker).to receive(:perform_async).with(game.id)

      game.generate_first_order_stats
    end
  end
end
