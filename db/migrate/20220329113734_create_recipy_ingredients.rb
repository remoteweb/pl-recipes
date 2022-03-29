# frozen_string_literal: true

class CreateRecipyIngredients < ActiveRecord::Migration[7.0]
  def change
    create_table :recipy_ingredients do |t|
      t.references :ingredient, null: false
      t.references :recipy, null: false
    end
  end
end
