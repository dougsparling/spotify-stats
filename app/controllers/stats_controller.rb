class StatsController < ApplicationController

  before_action :authenticate, except: 'index'

  def authenticate
    user_hash = session[:user]
    return redirect_to root_url unless user_hash
    @user = RSpotify::User.new(user_hash)
  end

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
    tracks = playlist.method(:tracks)

    @name = playlist.name
    @analysis = TrackAnalysis.new(tracks)

    render :show_stats
  end

  private

  def get_saved_tracks(pager)
    offset = 0
    limit = 50 # maximum per batch
    all = []
    while offset + limit < 1000
      # RSpotify.raw_response = true
      tracks = pager.call(offset: offset, limit: limit)
      # File.write('tracks.json', tracks)
      all.concat(tracks)
      break if tracks.empty? || tracks.size < limit
      offset += limit
    end
    return all
  end
end
