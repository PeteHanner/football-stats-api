class Team < ApplicationRecord
  has_many :stats
  has_many :games, through: :stats

  def apdp(season:, overwrite: false)
    # Average Points per Defensive Possession
    # Sum of all PDP scores ÷ games played
    # How good is your defense on average?
    Rails.cache.fetch("#{name}/apdp/#{season}", force: overwrite, expires_in: 1.day) do
      calculate_apdp(season)
    end
  end

  def apop(season:, overwrite: false)
    # Average Points per Offensive Possession
    # Sum of all POP scores ÷ games played
    # How good is your offense on average?
    Rails.cache.fetch("#{name}/apop/#{season}", force: overwrite, expires_in: 1.day) do
      calculate_apop(season)
    end
  end

  def calculate_apdp(season)
    total_pdp = pdp_over_season(season).pluck(:value).sum
    games_played = pdp_over_season(season).count
    total_pdp / games_played
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
