require 'memoist'

class TrackAnalysis
  extend Memoist

  def initialize(tracks)
    @tracks = tracks

    # audio_features are normally fetched lazily, but doing this for hundreds of tracks
    # hits 429 errors pretty quick. So we fetch features in batches ahead of time.
    @audio_features = {}
    @tracks.map(&:id).each_slice(100) do |ids|
      RSpotify::AudioFeatures.find(ids).zip(ids).each do |feature, track_id|
        @audio_features[track_id] = feature unless feature.nil?
      end
    end
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

  def danceability
    score = audio_features.map(&:danceability).sum / @tracks.size
    label = case score
      when 0..0.2     then "a funeral dirge"
      when 0.2..0.35  then "elevator music"
      when 0.35..0.45 then "a clinic waiting room"
      when 0.45..0.55 then "chain restaurant ambiance"
      when 0.55..0.65 then "a DJ's wedding set"  
      when 0.65..0.8  then "the club"
      when 0.8..1.0   then "a sick rave"
      else                 "nothing on earth"
    end
    [label, score]
  end

  def energy
    score = audio_features.map(&:energy).sum / @tracks.size
    label = case score
      when 0..0.2     then "swimming in molasses"
      when 0.2..0.35  then "lo-fi beats"
      when 0.35..0.45 then "a quiet afternoon at home"
      when 0.45..0.55 then "a second cup of coffee"
      when 0.55..0.65 then "a text from your crush"
      when 0.65..0.8  then "blast beats to the skull"
      when 0.8..1.0   then "cocaine to the main vein"
      else                 "nothing really"
    end
    [label, score]
  end

  def valence
    score = audio_features.map(&:valence).sum / @tracks.size
    label = case score
      when 0..0.2     then "gloom and doom"
      when 0.2..0.35  then "a moment of despair"
      when 0.35..0.45 then "a rainy day"
      when 0.45..0.55 then "ambivalence incarnate"
      when 0.55..0.65 then "a ray of sunshine"
      when 0.65..0.8  then "a polyphonic spree"
      when 0.8..1.0   then "a handful of soma"
      else                 "nothing describeable"
    end
    [label, score]
  end

  def most_popular
    @tracks.sort_by(&:popularity).reverse[0..2]
  end

  def least_popular
    @tracks.sort_by(&:popularity)[0..2]
  end

  [:valence, :energy, :danceability].each do |attr|
    define_method "highest_#{attr}" do
      track_id = @audio_features.max_by { |pair| pair[1].send(attr) }[0]
      @tracks.find { |t| t.id == track_id }
    end

    define_method "lowest_#{attr}" do
      track_id = @audio_features.min_by { |pair| pair[1].send(attr) }[0]
      @tracks.find { |t| t.id == track_id }
    end
  end

  def track_features(track)
    @audio_features[track.id] or raise "track not part of analysis: #{track.id}"
  end

  def inspect
    "TrackAnalysis{@tracks=#{@tracks.size}}"
  end

  private

  def audio_features
    @audio_features.values
  end

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

  memoize :release_date_range, :audio_features, :danceability, :energy, :valence
end