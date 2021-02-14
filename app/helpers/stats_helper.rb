module StatsHelper
  def describe_track(track)
    "#{track.name} on #{track.album.name} by #{track.artists.map(&:name).join(', ')}"
  end
end
