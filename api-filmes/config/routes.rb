Rails.application.routes.draw do
  resources :movies
  resources :profiles
  resources :users
  post '/login', to: 'users#login'
  get '/teste', to: 'movies#teste'
  get '/search-movies', to: 'movies#search'
  post '/add-movie', to: 'movies#add_movie'
  get '/suggested-movies', to: 'movies#suggested_movies'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
