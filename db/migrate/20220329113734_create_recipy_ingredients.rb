class CreateRecipyIngredients < ActiveRecord::Migration[7.0]
  def change
    create_table :recipy_ingredients do |t|
      t.references :ingredient, null: false, foreign_key: true
      t.references :recipy, null: false, foreign_key: true
    end
  end
end
