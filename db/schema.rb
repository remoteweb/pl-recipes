# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 20_220_330_100_704) do
  create_table 'ingredients', charset: 'utf8mb4', collation: 'utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.string 'name'
  end

  create_table 'recipe_ingredients', charset: 'utf8mb4', collation: 'utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.bigint 'ingredient_id', null: false
    t.bigint 'recipe_id', null: false
    t.index ['ingredient_id'], name: 'index_recipe_ingredients_on_ingredient_id'
    t.index ['recipe_id'], name: 'index_recipe_ingredients_on_recipe_id'
  end

  create_table 'recipes', charset: 'utf8mb4', collation: 'utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.string 'title'
    t.integer 'cook_time'
    t.integer 'prep_time'
    t.integer 'total_cooking_time'
    t.decimal 'ratings', precision: 4, scale: 2
    t.string 'recipe_category'
    t.string 'image_url'
    t.text 'jsoningredients'
  end
end
