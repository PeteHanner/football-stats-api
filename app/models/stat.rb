class Stat < ApplicationRecord
  belongs_to :team
  belongs_to :game

  validates_presence_of :value
end
