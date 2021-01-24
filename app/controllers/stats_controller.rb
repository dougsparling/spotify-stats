class StatsController < ApplicationController
  def index
  end

  def show
    @user = RSpotify::User.new(session[:user])

    @by_year = Hash.new(0)
    offset = 0
    limit = 20
    while offset + limit < 1000
      tracks = @user.saved_tracks(offset: offset, limit: limit)
      break if tracks.empty? || tracks.size < limit

      years = tracks.map do |t|
        begin
          Date.parse(t.album.release_date).year
        rescue Date::Error => e
          0
        end
      end

      years.each do |year|
        @by_year[year] += 1 
      end

      offset += limit
    end
  end
end
