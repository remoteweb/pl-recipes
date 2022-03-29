# frozen_string_literal: true

require 'test_helper'

class RecipyTest < ActiveSupport::TestCase  
  fixtures :recipes

  test "Tests Recipy required info not blank" do
    recipy = Recipy.new
    assert recipy.invalid?
    assert recipy.errors[:title].any?
    assert recipy.errors[:image_url].any?
    assert recipy.errors[:ratings].any?
  end

  test "Tests Recipes for valid and invalid data" do
    assert recipes(:valid_recipy).valid?
    assert_not recipes(:invalid_recipy).valid?
  end
end
