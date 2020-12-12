class Team < ApplicationRecord
  has_many :stats
  has_many :games, through: :stats

  def apop(season, overwrite = false)
    # Average Points per Offensive Possession
    Rails.cache.fetch("#{name}/APOP/#{season}", force: overwrite, expires_in: 1.day) do
      calculate_apop(season)
    end
  end

  def calculate_apop(season)
    total_pop = pop_over_season(season).pluck(:value).sum
    games_played = pop_over_season(season).count
    total_pop / games_played
  end

  def pdp_over_season(season)
    stats.where(name: "pdp", season: season)
  end

  def pop_over_season(season)
    stats.where(name: "pop", season: season)
  end
end
