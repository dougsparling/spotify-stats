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

  def danceability
    score = @tracks.map(&:audio_features).map(&:danceability).sum / @tracks.size
    label = case score
      when 0..0.2     then "a funeral dirge"
      when 0.2..0.35  then "elevator music"
      when 0.35..0.45 then "clinic waiting room"
      when 0.45..0.55 then "chain restaurant ambiance"
      when 0.55..0.65 then "wedding music"  
      when 0.65..0.8  then "the club"
      when 0.8..1.0   then "a sick rave"
      else                 "nothing really"
    end
    [label, score]
  end

  memoize :release_date_range, :danceability

  def inspect
    "TrackAnalysis{@tracks=#{@tracks.size}}"
  end

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