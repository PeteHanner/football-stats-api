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

    factory :opponent do
      name { "Test State" }
    end
  end
end
