Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'stats#index'
  get '/auth/spotify/callback', to: 'users#create'
  get '/stats', to: 'stats#show'
end
