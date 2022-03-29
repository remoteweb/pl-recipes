# frozen_string_literal: true

class Recipy < ApplicationRecord
  has_many :recipy_ingredients
  has_many :ingredients, through: :recipy_ingredients

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
