require 'csv'

class StatsController < ApplicationController

  before_action :authenticate, except: 'index'

  def index
    # landing page
  end

  def show
    @playlists = @user.playlists
  end

  def show_saved_tracks
    @name = 'My Saved Tracks'
    @analysis = TrackAnalysis.new(get_tracks)

    render :show_stats
  end

  def show_playlist
    playlist = RSpotify::Playlist.find(@user.id, params[:id])

    @name = playlist.name
    @analysis = TrackAnalysis.new(get_tracks(playlist))

    render :show_stats
  end

  def export
    playlist = RSpotify::Playlist.find(@user.id, params[:id]) if params.key?(:id)
    tracks = get_tracks(playlist)

    # TODO: time at which track was added might be interesting, but only applies to playlists, hmm...
    csv = CSV.generate do |csv|
      csv << ['track', 'album', 'artists', 'release date', 'popularity']
      for track in tracks.sort_by(&:name)
        csv << [
          track.name,
          track.album.name,
          track.album.artists.map(&:name).join(', '),
          track.album.release_date,
          track.popularity
        ]
      end
    end

    render inline: csv, content_type: 'text/csv'
  end

  private

  def get_tracks(playlist = nil)
    pager = if playlist.nil?
      @user.method(:saved_tracks)
    else
      playlist.method(:tracks)
    end

    return get_saved_tracks(pager)
  end

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
