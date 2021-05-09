class TeamBlueprint < Blueprinter::Base
  # identifier :uuid

  identifier :name

  field(:games_played) do |team, options|
    team.games.where(season: options[:season]).count
  end

  field(:apop) do |team, options|
    team.apop(season: options[:season])
  end

  field(:apdp) do |team, options|
    team.apdp(season: options[:season])
  end

  field(:appd) do |team, options|
    team.appd(season: options[:season])
  end

  field(:aopr) do |team, options|
    team.aopr(season: options[:season])
  end

  field(:adpr) do |team, options|
    team.adpr(season: options[:season])
  end

  field(:cpr) do |team, options|
    team.cpr(season: options[:season])
  end
end
