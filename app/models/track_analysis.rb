require 'memoist'

class TrackAnalysis
  extend Memoist

  def initialize(tracks)
    @tracks = tracks
  end

  def track_count
    @tracks.size
  end

  def tracks_by_release_year(year)
    @tracks.filter { |t| release_year(t) == year }
  end

  def release_date_range
    by_year = counts_by_year
    oldest, newest = by_year.keys.minmax

    year_labels = newest.downto(oldest)
    year_values = year_labels.map { |year| by_year[year] || 0 }
    year_labels.zip(year_values)
  end

  def most_popular
    @tracks.sort_by(&:popularity).reverse[0..2]
  end

  def least_popular
    @tracks.sort_by(&:popularity)[0..2]
  end

  def inspect
    "TrackAnalysis{@tracks=#{@tracks.size}}"
  end

  private

  def counts_by_year
    @tracks.inject(Hash.new(0)) do |memo, track|
      year = release_year(track)
      memo[year] += 1 unless year.nil?
      memo
    end
  end

  def release_year(track)
    begin
      Date.parse(track.album.release_date || "").year
    rescue Date::Error => e
      nil
    end
  end

  memoize :release_date_range
end