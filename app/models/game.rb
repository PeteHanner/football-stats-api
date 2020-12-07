class Game < ApplicationRecord
  has_many :stats, dependent: :destroy
  has_many :teams, through: :stats, dependent: :destroy

  validates_presence_of :api_ref

  def generate_first_order_stats
    home_team = set_home_team
    away_team = set_away_team

    set_pop(team: home_team, home_team: true)
    set_pdp(team: home_team, home_team: true)
    set_pop(team: away_team, home_team: false)
    set_pdp(team: away_team, home_team: false)
  end

  # Points per Offensive Possession
  def set_pop(team:, home_team:)
    pop = if home_team
      home_team_score / home_team_drives
    else
      away_team_score / away_team_drives
    end

    Stat.create(
      game: self,
      season: season,
      name: "pop",
      team: team,
      value: pop
    )
  end

  # Points per Defensive Possession
  def set_pdp(team:, home_team:)
    pdp = if home_team
      away_team_score / away_team_drives
    else
      home_team_score / home_team_drives
    end

    Stat.create(
      game: self,
      season: season,
      name: "pdp",
      team: team,
      value: pdp
    )
  end

  def set_home_team
    Team.find_or_create_by(name: home_team_name)
  end

  def set_away_team
    Team.find_or_create_by(name: away_team_name)
  end
end
