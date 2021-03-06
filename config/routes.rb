Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'stats#index'
  get '/auth/spotify/callback', to: 'users#create'
  
  get '/stats', to: 'stats#show'
  get '/stats/saved', to: 'stats#show_saved_tracks'
  get '/stats/playlist/:id', to: 'stats#show_playlist'

  get '/stats/saved/export', to: 'stats#export'
  get '/stats/playlist/:id/export', to: 'stats#export'
end
