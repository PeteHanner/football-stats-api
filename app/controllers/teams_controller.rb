class TeamsController < ApplicationController
  def index
    season = params[:season].to_i
    if no_season_games?
      render json: []
    else
      team_stats = Team.all_with_games_in_season(season)
      render json: team_stats, season: season
    end
  end

  def show
    team = Team.find_by(urlnick: params[:name])
    if team.blank?
      render json: []
    else
      render json: team
    end
  end

  private

  def no_season_games?
    params[:season].blank? || Game.find_by(season: params[:season]).blank?
  end
end
