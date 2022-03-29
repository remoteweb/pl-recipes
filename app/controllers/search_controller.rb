# frozen_string_literal: true

class SearchController < ApplicationController
  def new
    render json: SearchRecipes.new(search_params[:q]).perform
  end

  private

  def search_params
    params.permit(:q)
  end
end
