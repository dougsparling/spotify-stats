require 'memoist'

class TrackAnalysis
  extend Memoist

  def initialize(tracks)
    @tracks = tracks
  end

  def release_date_range
    by_year = counts_by_year
    oldest, newest = by_year.keys.minmax

    year_labels = newest.downto(oldest)
    year_values = year_labels.map { |year| by_year[year] || 0 }
    year_labels.zip(year_values)
  end

  memoize :release_date_range

  private

  def counts_by_year
    @tracks.inject(Hash.new(0)) do |memo, track|
      begin
        year = Date.parse(track.album.release_date || "").year
        memo[year] += 1
      rescue Date::Error => e
        # ignore
      end
      memo
    end
  end
end