# frozen_string_literal: true

class Recipe < ApplicationRecord
  has_many :recipe_ingredients
  has_many :ingredients, through: :recipe_ingredients

  validates :title,
            :ratings,
            :prep_time,
            :cook_time, presence: true

  validates :image_url,
            allow_blank: false, format: {
              with: /\.(gif|jpg|png)\z/i,
              message: 'must be a URL for GIF, JPG or PNG image.'
            }
  serialize :jsonignredients, Hash
end
