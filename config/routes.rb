# frozen_string_literal: true

Rails.application.routes.draw do
  root 'application#index'
  get 'search/new', as: :new_search
end
