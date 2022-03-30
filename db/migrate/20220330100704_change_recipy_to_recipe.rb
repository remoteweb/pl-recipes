class ChangeRecipyToRecipe < ActiveRecord::Migration[7.0]
  def change
    rename_table :recipy_ingredients, :recipe_ingredients
    rename_column :recipe_ingredients, :recipy_id, :recipe_id
    rename_column :recipes, :recipy_category, :recipe_category
  end
end
