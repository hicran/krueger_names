Rails.application.routes.draw do
  get 'suggest', to: 'search#suggest'
  get 'search',  to: 'search#index'
  root to: 'names#index'
  resources :names
  post 'do_it', to: 'names#do_it'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
