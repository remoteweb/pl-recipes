# frozen_string_literal: true

class CreateRecipeIngredients < ActiveRecord::Migration[7.0]
  def change
    create_table :recipe_ingredients do |t|
      t.references :ingredient, null: false
      t.references :recipe, null: false
    end
  end
end
