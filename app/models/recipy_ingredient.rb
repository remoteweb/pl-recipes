class RecipyIngredient < ApplicationRecord
  belongs_to :ingredient
  belongs_to :recipy
end
