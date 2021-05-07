class Game < ApplicationRecord
  has_many :stats
  has_many :teams, -> { distinct }, through: :stats

  validates_presence_of :api_ref

  def home_team
    Team.find_or_create_by(
      name: home_team_name,
      urlnick: home_team_name.parameterize
    )
  end

  def away_team
    Team.find_or_create_by(
      name: away_team_name,
      urlnick: home_team_name.parameterize
    )
  end

  def missing_first_order_stats?
    stat_names = stats.pluck(:name)
    stat_names.count("pop") < 2 || stat_names.count("pdp") < 2
  end

  def missing_second_order_stats?
    stat_names = stats.pluck(:name)
    stat_names.count("opr") < 2 || stat_names.count("dpr") < 2
  end
end
