class StatsController < ApplicationController

  before_action :authenticate, except: 'index'

  def authenticate
    user_hash = session[:user]
    return redirect_to root_url unless user_hash
    @user = RSpotify::User.new(user_hash)
  end

  def index
  end

  def show
    @playlists = @user.playlists
  end

  def show_saved_tracks
    analyze_tracks(@user.method(:saved_tracks))
    @name = 'My Saved Tracks'
    render :show_stats
  end

  def show_playlist
    playlist = RSpotify::Playlist.find(@user.id, params[:id])
    @name = playlist.name
    analyze_tracks(playlist.method(:tracks))
    render :show_stats
  end

  private

  def analyze_tracks(pager)
    by_year = query_counts_by_year(pager)
    oldest, newest = by_year.keys.minmax

    @year_labels = newest.downto(oldest)
    @year_values = @year_labels.map { |year| by_year[year] || 0 }
  end

  def query_counts_by_year(pager)
    by_year = Hash.new(0)
    years = get_saved_tracks(pager).inject([]) do |memo, track|
      begin
        memo << Date.parse(track.album.release_date).year
      rescue Date::Error => e
        # do nothing
      end
      memo
    end

    years.each do |year|
      by_year[year] += 1 
    end

    return by_year
  end

  def get_saved_tracks(pager)
    offset = 0
    limit = 20
    all = []
    while offset + limit < 1000
      tracks = pager.call(offset: offset, limit: limit)
      all.concat(tracks)
      break if tracks.empty? || tracks.size < limit
      offset += limit
    end
    return all
  end
end
