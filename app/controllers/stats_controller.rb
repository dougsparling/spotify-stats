class StatsController < ApplicationController

  before_action :authenticate, except: 'index'

  def index
    # landing page
  end

  def show
    @playlists = @user.playlists
  end

  def show_saved_tracks
    tracks = get_saved_tracks(@user.method(:saved_tracks))

    @name = 'My Saved Tracks'
    @analysis = TrackAnalysis.new(tracks)

    render :show_stats
  end

  def show_playlist
    playlist = RSpotify::Playlist.find(@user.id, params[:id])
    tracks = get_saved_tracks(playlist.method(:tracks))

    @name = playlist.name
    @analysis = TrackAnalysis.new(tracks)

    render :show_stats
  end

  private

  def authenticate
    user_hash = session[:user]
    return redirect_to root_url unless user_hash
    @user = RSpotify::User.new(user_hash)
  end

  def get_saved_tracks(pager)
    offset = 0
    limit = 20 # maximum per batch
    all = []
    while offset + limit < ::MAX_TRACKS
      RSpotify.raw_response = false
      tracks = pager.call(offset: offset, limit: limit)
      # File.write('tracks.json', tracks)
      all.concat(tracks)
      break if tracks.empty? || tracks.size < limit
      offset += limit
    end
    return all
  end
end
