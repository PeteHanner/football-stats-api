FactoryBot.define do
  factory :game do
    api_ref { 401110723 }
    away_team_drives { 29 }
    away_team_name { "Miami" }
    away_team_score { 20 }
    home_team_drives { 0 }
    home_team_name { "Florida" }
    home_team_score { 24 }
    season { 2019 }
    week { 1 }
  end

  factory :team do
    name { "Test University" }

    trait :opponent do
      name { "Test State" }
    end
  end

  factory :stat do
    association :game
    association :team
    name { "pop" }
    season { 2019 }
    value { 1.5 }
  end
end
