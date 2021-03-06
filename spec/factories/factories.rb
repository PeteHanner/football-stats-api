FactoryBot.define do
  factory :game do
    api_ref { 401110723 }
    away_team_drives { 29 }
    away_team_name { Faker::University.unique.name }
    away_team_score { 20 }
    home_team_drives { 0 }
    home_team_name { Faker::University.unique.name }
    home_team_score { 24 }
    season { 2000 }
    week { 1 }
  end

  factory :team do
    sequence(:name) { |n| "#{Faker::University.name} #{n}" }
  end

  factory :stat do
    association :game
    association :team
    name { "pop" }
    season { 2000 }
    value { 1.5 }
  end
end
