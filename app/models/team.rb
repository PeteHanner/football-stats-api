class Team < ApplicationRecord
  has_many :stats
  has_many :games, through: :stats

  def pop_over_season(season)
    stats.where(name: "pop", season: season)
  end

  def pdp_over_season(season)
    stats.where(name: "pdp", season: season)
  end
end


