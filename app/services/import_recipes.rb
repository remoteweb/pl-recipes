# frozen_string_literal: true

class ImportRecipes
  def initialize
    Recipe.delete_all
    Ingredient.delete_all
    RecipeIngredient.delete_all
  end

  def perform
    # MARK_FOR_IMPROVEMENT | DONE IMPROVED
    # I would better import with the insert_all or SQL query to avoid N + 1 problem and
    # check for record.valid? of Rails while building the records_set

    recipes = JSON.load_file(Rails.root.join('public', 'recipes-english.json'))
    recipes.each_with_index do |recipe, recipeIndex|
      ## Heroku Dyno has 18000 mysql max_questions per hour.
      sleep ENV['IMPORT_RECPIPES_SQL_DELAY'].to_f if Rails.env.production?

      @recipe = Recipe.create(
        title: recipe['title'],
        cook_time: recipe['cook_time'],
        prep_time: recipe['prep_time'],
        total_cooking_time: recipe['cook_time'] + recipe['prep_time'],
        ratings: recipe['ratings'].to_f,
        recipe_category: recipe['category'],
        image_url: recipe['image']
      )

      recipe['ingredients'].each_with_index do |ingredient, _ingredientIndex|
        ingredient = Ingredient.find_or_create_by(name: ingredient)
        @recipe.ingredients << ingredient
      end

      puts "#{recipes.size - recipeIndex} records left"
    end

    # Benchmark
    # 459.719249  27.561099 487.280348 (815.783305)
  end

  def perform_better
    ## Below implementation improvement happened due to Heroku being imperformant

    ### First import took 460 seconds to complete but had all Validations
    ### running so in a production set would be preferred

    ### The improved import takes no more than 5 seconds
    ### but there are no validations occuring which would be required

    @recipes = []
    ingredientIndexOffset = 0

    recipes = JSON.load_file(Rails.root.join('public', 'recipes-english.json'))
    recipes.each_with_index do |recipe, recipeIndex|
      @ingredients = []
      @recipe_ingrecients = []

      ## Heroku Dyno has 18000 mysql max_questions per hour.
      sleep ENV['IMPORT_RECPIPES_SQL_DELAY'].to_f if Rails.env.production?
      recipe['ingredients'].each.with_index(ingredientIndexOffset) do |ingredient, ingredientIndex|
        @ingredients << { id: ingredientIndex, name: ingredient }

        @recipe_ingrecients << {
          id: ingredientIndexOffset,
          recipe_id: recipeIndex,
          ingredient_id: ingredientIndex
        }

        ingredientIndexOffset = ingredientIndex + 1
      end

      @recipes << {
        id: recipeIndex,
        title: recipe['title'],
        cook_time: recipe['cook_time'],
        prep_time: recipe['prep_time'],
        total_cooking_time: recipe['cook_time'] + recipe['prep_time'],
        ratings: recipe['ratings'].to_f,
        recipe_category: recipe['category'],
        image_url: recipe['image']
      }

      Ingredient.insert_all(@ingredients)
      RecipeIngredient.insert_all(@recipe_ingrecients)
    end

    Recipe.insert_all(@recipes)

    puts "#{recipes.size} recipes imported"
    # Benchmark
    # 4.499291   0.297917   4.797208 (  6.987056)
  end

  def perform_json
    ## Below implementation improvement happened due to Heroku being imperformant

    ### First import took 460 seconds to complete but had all Validations
    ### running so in a production set would be preferred

    ### The improved import takes no more than 5 seconds
    ### but there are no validations occuring which would be required

    @recipes = []
    ingredientIndexOffset = 0

    recipes = JSON.load_file(Rails.root.join('public', 'recipes-english.json'))
    recipes.each_with_index do |recipe, recipeIndex|
      @ingredients = []
      @recipe_ingrecients = []

      recipe['ingredients']
        .each.with_index(ingredientIndexOffset) do |ingredient, _ingredientIndex|
        @ingredients << { name: ingredient }

        # @recipe_ingrecients << {
        #   id: ingredientIndexOffset,
        #   recipe_id: recipeIndex,
        #   ingredient_id: ingredientIndex
        # }

        # ingredientIndexOffset = ingredientIndex + 1
      end

      @recipes << {
        id: recipeIndex,
        title: recipe['title'],
        cook_time: recipe['cook_time'],
        prep_time: recipe['prep_time'],
        total_cooking_time: recipe['cook_time'] + recipe['prep_time'],
        ratings: recipe['ratings'].to_f,
        recipe_category: recipe['category'],
        image_url: recipe['image'],
        jsoningredients: @ingredients
      }

      # Ingredient.insert_all(@ingredients)
      # RecipeIngredient.insert_all(@recipe_ingrecients)
    end

    Recipe.insert_all(@recipes)

    puts "#{recipes.size} recipes imported"
    # Benchmark
    # 4.499291   0.297917   4.797208 (  6.987056)
  end
end
