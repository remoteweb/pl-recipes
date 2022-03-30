# frozen_string_literal: true

require 'test_helper'

class RecipeTest < ActiveSupport::TestCase
  fixtures :recipes

  test 'Tests Recipe required info not blank' do
    recipe = Recipe.new
    assert recipe.invalid?
    assert recipe.errors[:title].any?
    assert recipe.errors[:image_url].any?
    assert recipe.errors[:ratings].any?
  end

  test 'Tests Recipes for valid and invalid data' do
    assert recipes(:valid_recipe).valid?
    assert_not recipes(:invalid_recipe).valid?
  end
end
