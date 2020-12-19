class Team < ApplicationRecord
  has_many :stats
  has_many :games, -> { distinct }, through: :stats

  def adpr(season:, overwrite: false)
    # Average Defensive Performance Ratio
    # Sum of all DPR scores ÷ games played
    # By what percentage is your defense usually better than all your opponents' faced defenses?
    Rails.cache.fetch("#{name.parameterize}/aopr/#{season}", force: overwrite, expires_in: 6.hours) do
      calculate_adpr(season)
    end
  end

  def aopr(season:, overwrite: false)
    # Average Defensive Performance Ratio
    # Sum of all OPR scores ÷ games played
    # By what percentage is your offense usually better than all your opponents' faced offenses?
    Rails.cache.fetch("#{name.parameterize}/aopr/#{season}", force: overwrite, expires_in: 6.hours) do
      calculate_aopr(season)
    end
  end

  def apdp(season:, overwrite: false)
    # Average Points per Defensive Possession
    # Sum of all PDP scores ÷ games played
    # How good is your defense on average?
    Rails.cache.fetch("#{name.parameterize}/apdp/#{season}", force: overwrite, expires_in: 6.hours) do
      calculate_apdp(season)
    end
  end

  def apop(season:, overwrite: false)
    # Average Points per Offensive Possession
    # Sum of all POP scores ÷ games played
    # How good is your offense on average?
    Rails.cache.fetch("#{name.parameterize}/apop/#{season}", force: overwrite, expires_in: 6.hours) do
      calculate_apop(season)
    end
  end

  def calculate_adpr(season)
    total_dpr = dpr_over_season(season).pluck(:value).sum
    games_played = dpr_over_season(season).count
    total_dpr / games_played
  end

  def calculate_aopr(season)
    total_opr = opr_over_season(season).pluck(:value).sum
    games_played = opr_over_season(season).count
    total_opr / games_played
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

  def dpr_over_season(season)
    stats.dpr.where(season: season)
  end

  def opr_over_season(season)
    stats.opr.where(season: season)
  end

  def pdp_over_season(season)
    stats.pdp.where(season: season)
  end

  def pop_over_season(season)
    stats.pop.where(season: season)
  end
end
