class Game < ApplicationRecord
  has_many :stats
  has_many :teams, -> { distinct }, through: :stats

  validates_presence_of :api_ref

  def self.current_season(overwrite: false)
    cache_key = "seasons/current"
    Rails.cache.fetch(cache_key, skip_nil: true, force: overwrite, expires_in: 1.day) do
      distinct.pluck(:season).max
    end
  end
end
