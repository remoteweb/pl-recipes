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

    recipes = Recipy.select do |r|
      YAML.load(r.jsoningredients)
          .collect { |ingredient| ingredient[:name] }
          .select { |i| i.match(/#{search_terms.join('|')}/) }
          .size.positive?
    end

    ## Scoring search results relevance
    recipes.uniq.each do |recipy|
      # recipy = Recipy.includes(:ingredients).where(id: recipy.id).first
      recipy_ingredients = YAML.load(recipy.jsoningredients)
      total_recipy_ingredients_count = recipy_ingredients.size
      search_terms_count = search_terms.size

      matched_ingredients_count = YAML.load(recipy.jsoningredients)
                                      .collect { |ingredient| ingredient[:name] }
                                      .select { |i| i.match(/#{search_terms.join('|')}/) }.size

      non_matched_ingredients_count = total_recipy_ingredients_count - matched_ingredients_count

      ## RANK A are the results of recipes title or category include the word dinner
      ## and all ingredients get matched and the Recipes are complete.

      # NEGATIVE Factor How many ingredients left unused (search_terms_count - matched_ingredients_count

      if recipy.title.include?('dinner') || 
          recipy.recipy_category.include?('dinner') && 
          matched_ingredients_count >= total_recipy_ingredients_count

        rank_A << {
          id: recipy.id,
          title: recipy.title,
          rating: recipy.ratings.to_f,
          prep_time: recipy.prep_time,
          cook_time: recipy.cook_time,
          time: recipy.total_cooking_time,
          matched_ingredients_count: matched_ingredients_count,
          non_matched_ingredients_count: non_matched_ingredients_count,
          class: 'olive',
          complete: true,
          completeness: 100,
          image_url: recipy.image_url,
          relevance: RANK_BASE +  (matched_ingredients_count * 10) - 
                                  ((search_terms_count - matched_ingredients_count) * 10),
          ingredients: recipy_ingredients.as_json
        }

        next
      end

      ## RANK B are the results of recipes title or category include the word dinner 
      ## and some of the recipy ingredients got matched.
      ## Recipes are ranked by their relevance score then by rating

      # POSITIVE Factor How many ingredients from Recipy are matched. More better
      # NEGATIVE Factor How many ingredients are missing for the recipy. Less better

      if recipy.title.include?('dinner') || 
          recipy.recipy_category.include?('dinner')
          
        rank_B << {
          id: recipy.id,
          title: recipy.title,
          rating: recipy.ratings.to_f,
          prep_time: recipy.prep_time,
          cook_time: recipy.cook_time,
          time: recipy.total_cooking_time,
          matched_ingredients_count: matched_ingredients_count,
          non_matched_ingredients_count: non_matched_ingredients_count,
          class: '',
          complete: false,
          completeness: (matched_ingredients_count.to_f / total_recipy_ingredients_count).round(4) * 100,
          image_url: recipy.image_url,
          relevance: RANK_BASE + (
                                  (matched_ingredients_count.to_f * 10) + 
                                  (matched_ingredients_count.to_f / total_recipy_ingredients_count) * 1000).round,
          ingredients: recipy_ingredients.as_json
        }

        next
      end

      ## RANK C are the results where all ingredients get matched and the Recipes are complete.
      # NEGATIVE Factor How many ingredients left unused (search_terms_count - matched_ingredients_count

      if matched_ingredients_count >= total_recipy_ingredients_count
        rank_C << {
          id: recipy.id,
          title: recipy.title,
          rating: recipy.ratings.to_f,
          prep_time: recipy.prep_time,
          cook_time: recipy.cook_time,
          time: recipy.total_cooking_time,
          matched_ingredients_count: matched_ingredients_count,
          non_matched_ingredients_count: non_matched_ingredients_count,
          class: 'olive',
          complete: true,
          completeness: 100,
          image_url: recipy.image_url,
          relevance: RANK_BASE +  (matched_ingredients_count * 10) - 
                                  ((search_terms_count - matched_ingredients_count) * 10),
          ingredients: recipy_ingredients.as_json
        }

        next
      end

      ## RANK D are the results where some of the recipy ingredients got matched.
      ## Those recipes are ranked by their completeness e.g. the lesser ingredients are missing the higher ranking
      ## the recipy has.

      # POSITIVE Factor How many ingredients from Recipy are matched
      # NEGATIVE Factor How many ingredients are missing for the recipy

      rank_D << {
        id: recipy.id,
        title: recipy.title,
        rating: recipy.ratings.to_f,
        prep_time: recipy.prep_time,
        cook_time: recipy.cook_time,
        time: recipy.total_cooking_time,
        matched_ingredients_count: matched_ingredients_count,
        non_matched_ingredients_count: non_matched_ingredients_count,
        class: '',
        complete: false,
        completeness: (matched_ingredients_count.to_f / total_recipy_ingredients_count).round(4) * 100,
        image_url: recipy.image_url,
        relevance: RANK_BASE + (
                                (matched_ingredients_count.to_f * 10) + 
                                (matched_ingredients_count.to_f / total_recipy_ingredients_count) * 1000).round,
        ingredients: recipy_ingredients.as_json
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

      ## RANK A are the results of recipes title or category include the word dinner
      ## and all ingredients get matched and the Recipes are complete.

      # NEGATIVE Factor How many ingredients left unused (search_terms_count - matched_ingredients_count

      if recipy.title.include?('dinner') || 
        recipy.recipy_category.include?('dinner') && 
        matched_ingredients_count >= total_recipy_ingredients_count

        rank_A << {
          id: recipy.id,
          title: recipy.title,
          rating: recipy.ratings.to_f,
          prep_time: recipy.prep_time,
          cook_time: recipy.cook_time,
          time: recipy.total_cooking_time,
          matched_ingredients_count: matched_ingredients_count,
          non_matched_ingredients_count: non_matched_ingredients_count,
          class: 'olive',
          complete: true,
          completeness: 100,
          image_url: recipy.image_url,
          relevance: RANK_BASE +  (matched_ingredients_count * 10) - 
                                  ((search_terms_count - matched_ingredients_count) * 10),
          ingredients: recipy_ingredients.as_json
        }

        next
      end

      ## RANK B are the results of recipes title or category include the word dinner 
      ## and some of the recipy ingredients got matched.
      ## Recipes are ranked by their relevance score then by rating

      # POSITIVE Factor How many ingredients from Recipy are matched. More better
      # NEGATIVE Factor How many ingredients are missing for the recipy. Less better

      if recipy.title.include?('dinner') || 
          recipy.recipy_category.include?('dinner')
          
        rank_B << {
          id: recipy.id,
          title: recipy.title,
          rating: recipy.ratings.to_f,
          prep_time: recipy.prep_time,
          cook_time: recipy.cook_time,
          time: recipy.total_cooking_time,
          matched_ingredients_count: matched_ingredients_count,
          non_matched_ingredients_count: non_matched_ingredients_count,
          class: '',
          complete: false,
          completeness: (matched_ingredients_count.to_f / total_recipy_ingredients_count).round(4) * 100,
          image_url: recipy.image_url,
          relevance: RANK_BASE + (
                                  (matched_ingredients_count.to_f * 10) + 
                                  (matched_ingredients_count.to_f / total_recipy_ingredients_count) * 1000).round,
          ingredients: recipy_ingredients.as_json
        }

        next
      end

      ## RANK C are the results where all ingredients get matched and the Recipes are complete.
      # NEGATIVE Factor How many ingredients left unused (search_terms_count - matched_ingredients_count

      if matched_ingredients_count >= total_recipy_ingredients_count
        rank_C << {
          id: recipy.id,
          title: recipy.title,
          rating: recipy.ratings.to_f,
          prep_time: recipy.prep_time,
          cook_time: recipy.cook_time,
          time: recipy.total_cooking_time,
          matched_ingredients_count: matched_ingredients_count,
          non_matched_ingredients_count: non_matched_ingredients_count,
          class: 'olive',
          complete: true,
          completeness: 100,
          image_url: recipy.image_url,
          relevance: RANK_BASE +  (matched_ingredients_count * 10) - 
                                  ((search_terms_count - matched_ingredients_count) * 10),
          ingredients: recipy_ingredients.as_json
        }

        next
      end

      ## RANK D are the results where some of the recipy ingredients got matched.
      ## Those recipes are ranked by their completeness e.g. the lesser ingredients are missing the higher ranking
      ## the recipy has.

      # POSITIVE Factor How many ingredients from Recipy are matched
      # NEGATIVE Factor How many ingredients are missing for the recipy

      rank_D << {
        id: recipy.id,
        title: recipy.title,
        rating: recipy.ratings.to_f,
        prep_time: recipy.prep_time,
        cook_time: recipy.cook_time,
        time: recipy.total_cooking_time,
        matched_ingredients_count: matched_ingredients_count,
        non_matched_ingredients_count: non_matched_ingredients_count,
        class: '',
        complete: false,
        completeness: (matched_ingredients_count.to_f / total_recipy_ingredients_count).round(4) * 100,
        image_url: recipy.image_url,
        relevance: RANK_BASE + (
                                (matched_ingredients_count.to_f * 10) + 
                                (matched_ingredients_count.to_f / total_recipy_ingredients_count) * 1000).round,
        ingredients: recipy_ingredients.as_json
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
