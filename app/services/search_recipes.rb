# frozen_string_literal: true

class SearchRecipes
  RANK_BASE = 10000

  def initialize(search_terms)
    @search_terms = search_terms
  end

  def perform
    return {} if @search_terms.blank?

    search_terms = @search_terms.split(',')
    first_stage_results = {}
    final_results = []
    @rank_A = []
    @rank_B = []

    ## Results of all Recipes including all ingredients
    ## MARKED_FOR_IMPROVEMENT
    ## Search uses a basic LIKE operator that can be improved in the feature with broader matching wording
    ## to include typos of the users etc

    ## Building the results
    ## Finds recipes including any of the ingredients in our discopal
    recipes = Recipy.joins(:ingredients)
                    .where([sql_query_constructor('ingredients.name', 'LIKE', 'OR')] + @search_sql_params)
                    
    
    ## Scoring search results relevance
    recipes.uniq.each do |recipy|
      # recipy = Recipy.includes(:ingredients).where(id: recipy.id).first
      recipy_ingredients = recipy.ingredients
      total_recipy_ingredients_count = recipy_ingredients.size
      search_terms_count = search_terms.size
      # binding.pry
      # Negative Points
      non_matched_ingredients_count = recipy_ingredients.where(
        [sql_query_constructor('ingredients.name', 'NOT LIKE', 'AND')] + @search_sql_params
      ).size

      # Positive Points
      matched_ingredients_count = recipy_ingredients.where(
        [sql_query_constructor('name', 'LIKE', 'OR')] + @search_sql_params
      ).size

      ## RANK A are the results where all ingredients get matched and the Recipes are complete.
      # NEGATIVE Factor How many ingredients left unused (search_terms_count - matched_ingredients_count

      if matched_ingredients_count >= total_recipy_ingredients_count
        @rank_A << {
          id: recipy.id,
          title: recipy.title,
          rating: recipy.ratings.to_f,
          prep_time: recipy.prep_time,
          cook_time: recipy.cook_time,
          time: recipy.total_cooking_time,
          class: 'olive',
          complete: true,
          image_url: recipy.image_url,
          relevance: RANK_BASE + (matched_ingredients_count * 10) - ((search_terms_count - matched_ingredients_count) * 10),
          ingredients: recipy_ingredients.as_json(only: :name)
        }
        
        next
      end

      ## RANK B are the results where some of the recipy ingredients got matched.
      ## Those recipes are ranked by their completeness e.g. the lesser ingredients are missing the higher ranking
      ## the recipy has.
      # POSITIVE Factor How many ingredients from Recipy are matched
      # NEGATIVE Factor How many ingredients are missing for the recipy

      @rank_B << {
        id: recipy.id,
        title: recipy.title,
        rating: recipy.ratings.to_f,
        prep_time: recipy.prep_time,
        cook_time: recipy.cook_time,
        time: recipy.total_cooking_time,
        class: '',
        complete: false,
        image_url: recipy.image_url,
        relevance: RANK_BASE + (matched_ingredients_count.to_f * 10 + (matched_ingredients_count.to_f / total_recipy_ingredients_count) * 1000).round,
        ingredients: recipy_ingredients.as_json(only: :name)
      }
    end


    (@rank_A.sort_by { |r| [-r[:relevance], r[:rating]] } +
    @rank_B.sort_by { |r| [-r[:relevance], r[:rating]] }).take(500)
  end

  def perform_json
    return {} if @search_terms.blank?

    search_terms = @search_terms.split(',')
    first_stage_results = {}
    final_results = []
    @rank_A = []
    @rank_B = []

    ## Results of all Recipes including all ingredients
    ## MARKED_FOR_IMPROVEMENT
    ## Search uses a basic LIKE operator that can be improved in the feature with broader matching wording
    ## to include typos of the users etc

    ## Building the results
    ## Finds recipes including any of the ingredients in our discopal

    recipes = Recipy.select{|r| YAML.load(r.jsoningredients).collect{|ingredient| ingredient[:name]}.select{|i| i.match(/#{search_terms.join('|')}/)}.size > 0}
              # YAML.load(Recipy.first.jsoningredients).collect{|ingredient| ingredient[:name]}.select{|i| i.match(/flour|sugar/)}

    ## Scoring search results relevance
    recipes.uniq.each do |recipy|
      # recipy = Recipy.includes(:ingredients).where(id: recipy.id).first
      recipy_ingredients = YAML.load(recipy.jsoningredients)
      total_recipy_ingredients_count = recipy_ingredients.size
      search_terms_count = search_terms.size
      # binding.pry
      # Negative Points
      # non_matched_ingredients_count = recipy_ingredients.where(
      #   [sql_query_constructor('ingredients.name', 'NOT LIKE', 'AND')] + @search_sql_params
      # ).size

      matched_ingredients_count = YAML.load(recipy.jsoningredients).collect{|ingredient| ingredient[:name]}.select{|i| i.match(/#{search_terms.join('|')}/)}.size
      non_matched_ingredients_count = total_recipy_ingredients_count - matched_ingredients_count
      # Positive Points
      # matched_ingredients_count = recipy_ingredients.where(
      #   [sql_query_constructor('name', 'LIKE', 'OR')] + @search_sql_params
      # ).size

      ## RANK A are the results where all ingredients get matched and the Recipes are complete.
      # NEGATIVE Factor How many ingredients left unused (search_terms_count - matched_ingredients_count

      if matched_ingredients_count >= total_recipy_ingredients_count
        @rank_A << {
          id: recipy.id,
          title: recipy.title,
          rating: recipy.ratings.to_f,
          prep_time: recipy.prep_time,
          cook_time: recipy.cook_time,
          time: recipy.total_cooking_time,
          class: 'olive',
          complete: true,
          image_url: recipy.image_url,
          relevance: RANK_BASE + (matched_ingredients_count * 10) - ((search_terms_count - matched_ingredients_count) * 10),
          ingredients: recipy_ingredients.as_json
        }
        
        next
      end

      ## RANK B are the results where some of the recipy ingredients got matched.
      ## Those recipes are ranked by their completeness e.g. the lesser ingredients are missing the higher ranking
      ## the recipy has.
      # POSITIVE Factor How many ingredients from Recipy are matched
      # NEGATIVE Factor How many ingredients are missing for the recipy

      @rank_B << {
        id: recipy.id,
        title: recipy.title,
        rating: recipy.ratings.to_f,
        prep_time: recipy.prep_time,
        cook_time: recipy.cook_time,
        time: recipy.total_cooking_time,
        class: '',
        complete: false,
        image_url: recipy.image_url,
        relevance: RANK_BASE + (matched_ingredients_count.to_f * 10 + (matched_ingredients_count.to_f / total_recipy_ingredients_count) * 1000).round,
        ingredients: recipy_ingredients.as_json
      }
    end

    
    (@rank_A.sort_by { |r| [-r[:relevance], r[:rating]] } +
    @rank_B.sort_by { |r| [-r[:relevance], r[:rating]] }).take(500)
  end
  private

  def sql_query_constructor(field, operator, condition)
    search_sql_query = ''
    @search_sql_params = []
    search_terms = @search_terms.split(',')

    search_terms.each_with_index do |term, index|
      search_sql_query += if index == search_terms.size - 1
                            "#{field} #{operator} ?"
                          else
                            "#{field} #{operator} ? #{condition} "
                          end

      @search_sql_params << "%#{term}%"
    end

    search_sql_query
  end
end
