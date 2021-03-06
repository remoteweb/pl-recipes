# frozen_string_literal: true

class CreateRecipes < ActiveRecord::Migration[7.0]
  def change
    create_table :recipes do |t|
      t.string :title
      t.integer :cook_time
      t.integer :prep_time
      t.integer :total_cooking_time
      t.decimal :ratings, precision: 4, scale: 2
      t.string :recipe_category
      t.string :image_url
    end
  end
end
