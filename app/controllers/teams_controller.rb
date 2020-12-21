class TeamsController < ApplicationController
  def show
    season = params[:season].to_i
    return redirect_to season_path(Game.current_season) if bad_params?

    team_stats = Team.all_with_games_in_season(season)

    render json: team_stats, each_serializer: TeamSerializer, season: season
  end

  private

  def bad_params?
    params[:season].blank? || Game.find_by(season: params[:season]).blank?
  end
end
