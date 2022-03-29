# frozen_string_literal: true

class ImportRecipes
  def initialize
    Recipy.delete_all
    Ingredient.delete_all
    RecipyIngredient.delete_all
  end

  def perform
    # MARK_FOR_IMPROVEMENT | DONE IMPROVED
    # I would better import with the insert_all or SQL query to avoid N + 1 problem and
    # check for record.valid? of Rails while building the records_set

    recipes = JSON.load_file(Rails.root.join('public', 'recipes-english.json'))
    recipes.each_with_index do |recipy, recipyIndex|
      ## Heroku Dyno has 18000 mysql max_questions per hour.
      sleep ENV['IMPORT_RECPIPES_SQL_DELAY'].to_f if Rails.env.production?

      @recipy = Recipy.create(
        title: recipy['title'],
        cook_time: recipy['cook_time'],
        prep_time: recipy['prep_time'],
        total_cooking_time: recipy['cook_time'] + recipy['prep_time'],
        ratings: recipy['ratings'].to_f,
        recipy_category: recipy['category'],
        image_url: recipy['image']
      )

      recipy['ingredients'].each_with_index do |ingredient, _ingredientIndex|
        ingredient = Ingredient.find_or_create_by(name: ingredient)
        @recipy.ingredients << ingredient
      end

      puts "#{recipes.size - recipyIndex} records left"
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
    recipes.each_with_index do |recipy, recipyIndex|
      @ingredients = []
      @recipy_ingrecients = []

      ## Heroku Dyno has 18000 mysql max_questions per hour.
      sleep ENV['IMPORT_RECPIPES_SQL_DELAY'].to_f if Rails.env.production?
      recipy['ingredients'].each.with_index(ingredientIndexOffset) do |ingredient, ingredientIndex|
        @ingredients << { id: ingredientIndex, name: ingredient }

        @recipy_ingrecients << {
          id: ingredientIndexOffset,
          recipy_id: recipyIndex,
          ingredient_id: ingredientIndex
        }

        ingredientIndexOffset = ingredientIndex + 1
      end

      @recipes << {
        id: recipyIndex,
        title: recipy['title'],
        cook_time: recipy['cook_time'],
        prep_time: recipy['prep_time'],
        total_cooking_time: recipy['cook_time'] + recipy['prep_time'],
        ratings: recipy['ratings'].to_f,
        recipy_category: recipy['category'],
        image_url: recipy['image']
      }

      Ingredient.insert_all(@ingredients)
      RecipyIngredient.insert_all(@recipy_ingrecients)
    end

    Recipy.insert_all(@recipes)

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
    recipes.each_with_index do |recipy, recipyIndex|
      @ingredients = []
      @recipy_ingrecients = []

      recipy['ingredients']
        .each.with_index(ingredientIndexOffset) do |ingredient, _ingredientIndex|
        @ingredients << { name: ingredient }

        # @recipy_ingrecients << {
        #   id: ingredientIndexOffset,
        #   recipy_id: recipyIndex,
        #   ingredient_id: ingredientIndex
        # }

        # ingredientIndexOffset = ingredientIndex + 1
      end

      @recipes << {
        id: recipyIndex,
        title: recipy['title'],
        cook_time: recipy['cook_time'],
        prep_time: recipy['prep_time'],
        total_cooking_time: recipy['cook_time'] + recipy['prep_time'],
        ratings: recipy['ratings'].to_f,
        recipy_category: recipy['category'],
        image_url: recipy['image'],
        jsoningredients: @ingredients
      }

      # Ingredient.insert_all(@ingredients)
      # RecipyIngredient.insert_all(@recipy_ingrecients)
    end

    Recipy.insert_all(@recipes)

    puts "#{recipes.size} recipes imported"
    # Benchmark
    # 4.499291   0.297917   4.797208 (  6.987056)
  end
end
