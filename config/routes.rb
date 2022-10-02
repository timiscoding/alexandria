Rails.application.routes.draw do

  scope :api do
    resources :books
    resources :authors
    resources :publishers
    get '/search/:text', to: 'search#index'
  end

  root to: 'books#index'
end
