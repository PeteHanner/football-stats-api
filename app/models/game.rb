class Game < ApplicationRecord
  has_many :stats
  has_many :teams, through: :stats

  validates_presence_of :api_ref
end
