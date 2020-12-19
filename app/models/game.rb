class Game < ApplicationRecord
  has_many :stats
  has_many :teams, -> { distinct }, through: :stats

  validates_presence_of :api_ref

  def generate_first_order_stats
    FirstOrderGameStatsWorker.perform_async(id)
  end
end
