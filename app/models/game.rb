class Game < ApplicationRecord
  has_many :stats
  has_many :teams, -> { distinct }, through: :stats

  validates_presence_of :api_ref

  def home_team
    Team.find_by(name: home_team_name)
  end

  def away_team
    Team.find_by(name: away_team_name)
  end
end
