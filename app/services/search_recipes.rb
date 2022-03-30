# frozen_string_literal: true

class SearchRecipes
  RANK_BASE = 10_000

  def initialize(search_terms)
    @search_terms = search_terms
  end

  def perform_json
    return {} if @search_terms.blank?

    search_terms = @search_terms.split(',')
    first_stage_results = {}
    final_results = []
    rank_A = []
    rank_B = []
    rank_C = []
    rank_D = []

    ## Search can be improved in the future with broader matching wording
    ## to include typos of the users etc

    ## Building the results
    ## Finds recipes including any of the ingredients in our discopal

    recipes = Recipe.select do |r|
      YAML.load(r.jsoningredients)
          .collect { |ingredient| ingredient[:name] }
          .select { |i| i.match(/#{search_terms.join('|')}/) }
          .size.positive?
    end

    ## Scoring search results relevance
    recipes.uniq.each do |recipe|
      # recipe = Recipe.includes(:ingredients).where(id: recipe.id).first
      recipe_ingredients = YAML.load(recipe.jsoningredients)
      total_recipe_ingredients_count = recipe_ingredients.size
      search_terms_count = search_terms.size

      matched_ingredients_count = YAML.load(recipe.jsoningredients)
                                      .collect { |ingredient| ingredient[:name] }
                                      .select { |i| i.match(/#{search_terms.join('|')}/) }.size

      non_matched_ingredients_count = total_recipe_ingredients_count - matched_ingredients_count

      ## RANK A are the results of recipes title or category include the word dinner
      ## and all ingredients get matched and the Recipes are complete.

      # NEGATIVE Factor How many ingredients left unused (search_terms_count - matched_ingredients_count

      if recipe.title.include?('dinner') || 
          recipe.recipe_category.include?('dinner') && 
          matched_ingredients_count >= total_recipe_ingredients_count

        rank_A << {
          id: recipe.id,
          title: recipe.title,
          recipe_category: recipe.recipe_category,
          rating: recipe.ratings.to_f,
          prep_time: recipe.prep_time,
          cook_time: recipe.cook_time,
          time: recipe.total_cooking_time,
          matched_ingredients_count: matched_ingredients_count,
          non_matched_ingredients_count: non_matched_ingredients_count,
          class: 'olive',
          complete: true,
          completeness: 100,
          relevance: RANK_BASE +  (matched_ingredients_count * 10) - 
                                  ((search_terms_count - matched_ingredients_count) * 10),
          ingredients: recipe_ingredients.as_json
        }

        next
      end

      ## RANK B are the results of recipes title or category include the word dinner 
      ## and some of the recipe ingredients got matched.
      ## Recipes are ranked by their relevance score then by rating

      # POSITIVE Factor How many ingredients from Recipe are matched. More better
      # NEGATIVE Factor How many ingredients are missing for the recipe. Less better

      if recipe.title.include?('dinner') || 
          recipe.recipe_category.include?('dinner')
          
        rank_B << {
          id: recipe.id,
          title: recipe.title,
          recipe_category: recipe.recipe_category,
          rating: recipe.ratings.to_f,
          prep_time: recipe.prep_time,
          cook_time: recipe.cook_time,
          time: recipe.total_cooking_time,
          matched_ingredients_count: matched_ingredients_count,
          non_matched_ingredients_count: non_matched_ingredients_count,
          class: '',
          complete: false,
          completeness: (matched_ingredients_count.to_f / total_recipe_ingredients_count).round(4) * 100,
          relevance: RANK_BASE + (
                                  (matched_ingredients_count.to_f * 10) + 
                                  (matched_ingredients_count.to_f / total_recipe_ingredients_count) * 1000).round,
          ingredients: recipe_ingredients.as_json
        }

        next
      end

      ## RANK C are the results where all ingredients get matched and the Recipes are complete.
      # NEGATIVE Factor How many ingredients left unused (search_terms_count - matched_ingredients_count

      if matched_ingredients_count >= total_recipe_ingredients_count
        rank_C << {
          id: recipe.id,
          title: recipe.title,
          recipe_category: recipe.recipe_category,
          rating: recipe.ratings.to_f,
          prep_time: recipe.prep_time,
          cook_time: recipe.cook_time,
          time: recipe.total_cooking_time,
          matched_ingredients_count: matched_ingredients_count,
          non_matched_ingredients_count: non_matched_ingredients_count,
          class: 'olive',
          complete: true,
          completeness: 100,
          relevance: RANK_BASE +  (matched_ingredients_count * 10) - 
                                  ((search_terms_count - matched_ingredients_count) * 10),
          ingredients: recipe_ingredients.as_json
        }

        next
      end

      ## RANK D are the results where some of the recipe ingredients got matched.
      ## Those recipes are ranked by their completeness e.g. the lesser ingredients are missing the higher ranking
      ## the recipe has.

      # POSITIVE Factor How many ingredients from Recipe are matched
      # NEGATIVE Factor How many ingredients are missing for the recipe

      rank_D << {
        id: recipe.id,
        title: recipe.title,
        recipe_category: recipe.recipe_category,
        rating: recipe.ratings.to_f,
        prep_time: recipe.prep_time,
        cook_time: recipe.cook_time,
        time: recipe.total_cooking_time,
        matched_ingredients_count: matched_ingredients_count,
        non_matched_ingredients_count: non_matched_ingredients_count,
        class: '',
        complete: false,
        completeness: (matched_ingredients_count.to_f / total_recipe_ingredients_count).round(4) * 100,
        relevance: RANK_BASE + (
                                (matched_ingredients_count.to_f * 10) + 
                                (matched_ingredients_count.to_f / total_recipe_ingredients_count) * 1000).round,
        ingredients: recipe_ingredients.as_json
      }
    end

    (rank_A.sort_by { |r| [-r[:relevance], -r[:rating]]} +
    rank_B.sort_by { |r| [-r[:relevance], -r[:rating]]} +
    rank_C.sort_by { |r| [-r[:relevance], -r[:rating]]} +
    rank_D.sort_by { |r| [-r[:relevance], -r[:rating]]}).take(500)
  end


  ## This is my initial iteration, i kept it only for the assigment purposes.
  def perform_active_record
    return {} if @search_terms.blank?

    search_terms = @search_terms.split(',')
    first_stage_results = {}
    final_results = []
    rank_A = []
    rank_B = []
    rank_C = []
    rank_D = []

    ## Search uses a basic LIKE operator that can be improved in the feature with broader matching wording
    ## to include typos of the users etc

    ## Building the results
    ## Finds recipes including any of the ingredients in our discopal
    recipes = Recipe.joins(:ingredients)
                    .where([sql_query_constructor('ingredients.name', 'LIKE', 'OR')] + @search_sql_params)

    ## Scoring search results relevance
    recipes.uniq.each do |recipe|
      # recipe = Recipe.includes(:ingredients).where(id: recipe.id).first
      recipe_ingredients = recipe.ingredients
      total_recipe_ingredients_count = recipe_ingredients.size
      search_terms_count = search_terms.size
      # binding.pry
      # Negative Points
      non_matched_ingredients_count = recipe_ingredients.where(
        [sql_query_constructor('ingredients.name', 'NOT LIKE', 'AND')] + @search_sql_params
      ).size

      # Positive Points
      matched_ingredients_count = recipe_ingredients.where(
        [sql_query_constructor('name', 'LIKE', 'OR')] + @search_sql_params
      ).size

      ## RANK A are the results of recipes title or category include the word dinner
      ## and all ingredients get matched and the Recipes are complete.

      # NEGATIVE Factor How many ingredients left unused (search_terms_count - matched_ingredients_count

      if recipe.title.include?('dinner') || 
        recipe.recipe_category.include?('dinner') && 
        matched_ingredients_count >= total_recipe_ingredients_count

        rank_A << {
          id: recipe.id,
          title: recipe.title,
          recipe_category: recipe.recipe_category,
          rating: recipe.ratings.to_f,
          prep_time: recipe.prep_time,
          cook_time: recipe.cook_time,
          time: recipe.total_cooking_time,
          matched_ingredients_count: matched_ingredients_count,
          non_matched_ingredients_count: non_matched_ingredients_count,
          class: 'olive',
          complete: true,
          completeness: 100,
          relevance: RANK_BASE +  (matched_ingredients_count * 10) - 
                                  ((search_terms_count - matched_ingredients_count) * 10),
          ingredients: recipe_ingredients.as_json
        }

        next
      end

      ## RANK B are the results of recipes title or category include the word dinner 
      ## and some of the recipe ingredients got matched.
      ## Recipes are ranked by their relevance score then by rating

      # POSITIVE Factor How many ingredients from Recipe are matched. More better
      # NEGATIVE Factor How many ingredients are missing for the recipe. Less better

      if recipe.title.include?('dinner') || 
          recipe.recipe_category.include?('dinner')
          
        rank_B << {
          id: recipe.id,
          title: recipe.title,
          recipe_category: recipe.recipe_category,
          rating: recipe.ratings.to_f,
          prep_time: recipe.prep_time,
          cook_time: recipe.cook_time,
          time: recipe.total_cooking_time,
          matched_ingredients_count: matched_ingredients_count,
          non_matched_ingredients_count: non_matched_ingredients_count,
          class: '',
          complete: false,
          completeness: (matched_ingredients_count.to_f / total_recipe_ingredients_count).round(4) * 100,
          relevance: RANK_BASE + (
                                  (matched_ingredients_count.to_f * 10) + 
                                  (matched_ingredients_count.to_f / total_recipe_ingredients_count) * 1000).round,
          ingredients: recipe_ingredients.as_json
        }

        next
      end

      ## RANK C are the results where all ingredients get matched and the Recipes are complete.
      # NEGATIVE Factor How many ingredients left unused (search_terms_count - matched_ingredients_count

      if matched_ingredients_count >= total_recipe_ingredients_count
        rank_C << {
          id: recipe.id,
          title: recipe.title,
          recipe_category: recipe.recipe_category,
          rating: recipe.ratings.to_f,
          prep_time: recipe.prep_time,
          cook_time: recipe.cook_time,
          time: recipe.total_cooking_time,
          matched_ingredients_count: matched_ingredients_count,
          non_matched_ingredients_count: non_matched_ingredients_count,
          class: 'olive',
          complete: true,
          completeness: 100,
          relevance: RANK_BASE +  (matched_ingredients_count * 10) - 
                                  ((search_terms_count - matched_ingredients_count) * 10),
          ingredients: recipe_ingredients.as_json
        }

        next
      end

      ## RANK D are the results where some of the recipe ingredients got matched.
      ## Those recipes are ranked by their completeness e.g. the lesser ingredients are missing the higher ranking
      ## the recipe has.

      # POSITIVE Factor How many ingredients from Recipe are matched
      # NEGATIVE Factor How many ingredients are missing for the recipe

      rank_D << {
        id: recipe.id,
        title: recipe.title,
        recipe_category: recipe.recipe_category,
        rating: recipe.ratings.to_f,
        prep_time: recipe.prep_time,
        cook_time: recipe.cook_time,
        time: recipe.total_cooking_time,
        matched_ingredients_count: matched_ingredients_count,
        non_matched_ingredients_count: non_matched_ingredients_count,
        class: '',
        complete: false,
        completeness: (matched_ingredients_count.to_f / total_recipe_ingredients_count).round(4) * 100,
        relevance: RANK_BASE + (
                                (matched_ingredients_count.to_f * 10) + 
                                (matched_ingredients_count.to_f / total_recipe_ingredients_count) * 1000).round,
        ingredients: recipe_ingredients.as_json
      }
    end

    (rank_A.sort_by { |r| [-r[:relevance], -r[:rating]]} +
    rank_B.sort_by { |r| [-r[:relevance], -r[:rating]]} +
    rank_C.sort_by { |r| [-r[:relevance], -r[:rating]]} +
    rank_D.sort_by { |r| [-r[:relevance], -r[:rating]]}).take(500)
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
