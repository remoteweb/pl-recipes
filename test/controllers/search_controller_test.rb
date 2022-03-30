# frozen_string_literal: true

require 'test_helper'

class SearchControllerTest < ActionDispatch::IntegrationTest
  fixtures :recipes, :ingredients

  setup do
    puts 'Importing Records is taking:'
    puts Benchmark.realtime {
      ImportRecipes.new.perform_json
    }.round(2).to_s + " seconds"
  end

  test 'Test search results performance' do
    puts 'Test search results performance'
    @search_params = 'bacon,eggs,cucumber,potato'

    puts "Search for #{@search_params} is taking:"
    
    time_spent = Benchmark.realtime {
      @result = SearchRecipes.new(@search_params).perform_json
    }.round(2) 
    puts time_spent.to_s + " seconds"
    assert time_spent < 5
  end

  test 'Test search results relevance' do
    puts 'Test search results relevance'
    @search_params = 'bacon,eggs,cucumber,potato'
    @result = SearchRecipes.new(@search_params).perform_json

    assert_not @result
      .first[:ingredients]
      .collect { |k| k['name'] }
      .join.match(/#{@search_params.split(',').join("|")}/).blank?
  end
end
