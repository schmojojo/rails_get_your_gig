Rails.application.routes.draw do
  devise_for :users

  root to: "events#index"

  resources :events, only: [:index,:new,:create]

  get "up" => "rails/health#show", as: :rails_health_check
end
