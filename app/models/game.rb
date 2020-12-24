class Game < ApplicationRecord
  has_many :stats
  has_many :teams, -> { distinct }, through: :stats

  validates_presence_of :api_ref

  def home_team
    Team.find_or_create_by(name: home_team_name)
  end

  def away_team
    Team.find_or_create_by(name: away_team_name)
  end

  def missing_stats
    expected_stats = [
      "dpr",
      "dpr",
      "opr",
      "opr",
      "pdp",
      "pdp",
      "pop",
      "pop"
    ]
    expected_stats - stats.pluck(:name)
  end
end
