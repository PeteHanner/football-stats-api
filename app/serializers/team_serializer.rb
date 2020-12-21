class TeamSerializer < ActiveModel::Serializer
  attributes :name, :apop, :apdp, :appd, :aopr, :adpr, :cpr

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
