class TeamSerializer < ActiveModel::Serializer
  attributes :name, :games_played, :apop, :apdp, :appd, :aopr, :adpr, :cpr

  def games_played
    object.games.where(season: @instance_options[:season]).count
  end

  def apop
    object.apop(season: @instance_options[:season])
  end

  def apdp
    object.apdp(season: @instance_options[:season])
  end

  def appd
    object.appd(season: @instance_options[:season])
  end

  def aopr
    object.aopr(season: @instance_options[:season])
  end

  def adpr
    object.adpr(season: @instance_options[:season])
  end

  def cpr
    object.cpr(season: @instance_options[:season])
  end
end
