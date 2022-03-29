class SearchController < ApplicationController
  def new
    render json: SearchRecipies.new(search_params[:q]).perform
  end

  private

  def search_params
    params.permit(:q)
  end
end
