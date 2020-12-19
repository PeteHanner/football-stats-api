class Stat < ApplicationRecord
  belongs_to :team
  belongs_to :game

  validates_presence_of :value

  scope :pop, -> { where(name: "pop") }
  scope :pdp, -> { where(name: "pdp") }
  scope :opr, -> { where(name: "opr") }
  scope :dpr, -> { where(name: "dpr") }
end
