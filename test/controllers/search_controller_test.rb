# frozen_string_literal: true

require 'test_helper'

class SearchControllerTest < ActionDispatch::IntegrationTest
  fixtures :recipes, :ingredients

  setup do
    puts 'Importing Records is taking:'
    puts Benchmark.measure {  
      ImportRecipes.new.perform
    }
  end

  test 'Test the results are related to query string' do
    @search_params = 'bacon,eggs,cucumber,potato'

    puts 'Search is taking:'
    puts Benchmark.measure {  
      @result = SearchRecipes.new(@search_params).perform
    }
    
    assert_not @result
      .first[:ingredients]
      .collect{|k| k["name"]}
      .join.match(/#{@search_params.split(',').join("|")}/).blank?
  end
end
