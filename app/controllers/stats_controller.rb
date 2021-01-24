class StatsController < ApplicationController
  def index
  end

  def show
    @user = RSpotify::User.new(session[:user])

    by_year = query_counts_by_year
    oldest, newest = by_year.keys.minmax

    @year_labels = oldest..newest
    @year_values = @year_labels.map { |year| by_year[year] || 0 }
  end

  def query_counts_by_year
    by_year = Hash.new(0)
    years = get_saved_tracks.inject([]) do |memo, track|
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

    by_year
  end

  def get_saved_tracks
    offset = 0
    limit = 20
    all = []
    while offset + limit < 60
      tracks = @user.saved_tracks(offset: offset, limit: limit)
      break if tracks.empty? || tracks.size < limit
      all.concat(tracks)
      offset += limit
    end
    return all
  end
end
