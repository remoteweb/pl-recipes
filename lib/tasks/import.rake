# frozen_string_literal: true

task :import_recipes, [:import_type] => :environment do |t, args|
  case args[:import_type]
  when 'standard'
    ImportRecipes.new.perform
  when 'fast'
    ImportRecipes.new.perform_better
  when 'serialized_jsons'
    ImportRecipes.new.perform_json
  end
end
