class Game < ApplicationRecord
  has_many :stats
  has_many :teams, through: :stats
end
