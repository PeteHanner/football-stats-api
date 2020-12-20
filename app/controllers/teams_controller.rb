class TeamsController < ApplicationController
  def show
    @season = params[:season].to_i
    return redirect_to season_path(Game.current_season) if bad_params?

    team_stats = {season: @season}

    render json: team_stats.to_json
  end

  private

  def bad_params?
    params[:season].blank? || Game.find_by(season: params[:season]).blank?
  end
end
