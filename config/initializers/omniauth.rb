# all the junk required to get spotify + rails + omniauth playing together


# needed to allow callback to complete
# https://github.com/guilhermesad/rspotify/issues/87
module SpotifyOmniauthExtension
  extend ActiveSupport::Concern

  def callback_url
    full_host + script_name + callback_path
  end
end

config = Rails.application.config
creds = Rails.application.credentials

# TODO: omniauth and rails 6 don't play nice together... would be nice to turn these back on
# https://github.com/cookpad/omniauth-rails_csrf_protection/issues/8
config.action_controller.per_form_csrf_tokens = false
OmniAuth.config.request_validation_phase = false


# ruby-query client ID and secret
RSpotify::authenticate(creds.spotify[:client_id], creds.spotify[:client_secret])

config.to_prepare do
  OmniAuth::Strategies::Spotify.include(SpotifyOmniauthExtension)
end 

config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?

  # list of scopes: https://developer.spotify.com/documentation/general/guides/scopes/
  provider :spotify, creds.spotify[:client_id], creds.spotify[:client_secret], scope: 'user-library-read playlist-read-private'
end
