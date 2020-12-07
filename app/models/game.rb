class Game < ApplicationRecord
  has_many :stats
  has_many :teams, through: :stats

  validates_presence_of :api_ref

  def generate_first_order_stats
    home_team = set_home_team
    away_team = set_away_team

    set_pop(home_team)
    set_pdp(home_team)
    set_pop(away_team)
    set_pdp(away_team)
  end

  def set_pop(team)
    Stat.create(
      game: self,
      season: season,
      name: "pop",
      team: team
    )
  end

  def set_home_team
    Team.find_or_create_by(name: home_team_name)
  end

  def set_away_team
    Team.find_or_create_by(name: home_team_name)
  end
end
