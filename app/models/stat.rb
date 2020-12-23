class Stat < ApplicationRecord
  belongs_to :team
  belongs_to :game

  validates_presence_of :value

  scope :pop, -> { where(name: "pop") }
  scope :pdp, -> { where(name: "pdp") }
  scope :opr, -> { where(name: "opr") }
  scope :dpr, -> { where(name: "dpr") }


  def self.current_season(overwrite: false)
    cache_key = "seasons/current"
    Rails.cache.fetch(cache_key, skip_nil: true, force: overwrite, expires_in: 1.day) do
      distinct.pluck(:season).max
    end
  end
end
