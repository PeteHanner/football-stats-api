class Game < ApplicationRecord
  has_many :stats, dependent: :destroy
  has_many :teams, through: :stats, dependent: :destroy

  validates_presence_of :api_ref

  def generate_first_order_stats
    FirstOrderGameStatsWorker.perform_async(id)
  end
end
