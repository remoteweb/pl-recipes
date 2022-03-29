# frozen_string_literal: true

class AddIngredientsToRecipes < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :jsoningredients, :text
  end
end
