class Ingredient < ApplicationRecord
    has_many :recipy_ingredients
    has_many :recipes, through: :recipy_ingredients
end
