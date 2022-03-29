# frozen_string_literal: true

Rails.application.routes.draw do
  root 'application#index', as: :new_search
  get 'search' => 'search#new'
end
