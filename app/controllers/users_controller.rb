class UsersController < ApplicationController
  def create
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    session[:user] = spotify_user.to_hash
    redirect_to controller: 'stats', action: 'show' 
  end
end
