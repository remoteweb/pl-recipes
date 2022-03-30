class ChangeRecipeToRecipe < ActiveRecord::Migration[7.0]
  def change
    rename_table :recipe_ingredients, :recipe_ingredients
    rename_column :recipe_ingredients, :recipe_id, :recipe_id
    rename_column :recipes, :recipe_category, :recipe_category
  end
end
