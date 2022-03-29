# frozen_string_literal: true

task import_recipes: :environment do
  ImportRecipes.new.perform
end
