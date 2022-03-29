task import_recipes: :environment do
  Recipy.delete_all
  Ingredient.delete_all

  # MARK_FOR_IMPROVEMENT
  # I would better import with the insert_all or SQL query to avoid N + 1 problem and
  # check for record.valid? of Rails while building the records_set
  
  puts Benchmark.measure {
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

      recipy['ingredients'].each_with_index do |ingredient, ingredientIndex|
        ingredient = Ingredient.find_or_create_by(name: ingredient)
        @recipy.ingredients << ingredient
      end

      puts "#{recipes.size - recipyIndex} records left"
    end
  }

  # Benchmark
  # 459.719249  27.561099 487.280348 (815.783305)
end
