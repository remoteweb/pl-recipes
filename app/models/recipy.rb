class Recipy < ApplicationRecord
    has_many :recipy_ingredients
    has_many :ingredients, through: :recipy_ingredients
end
