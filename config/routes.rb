Rails.application.routes.draw do

  scope :api do
    resources :books
    resources :authors
    resources :publishers
  end

  root to: 'books#index'
end
