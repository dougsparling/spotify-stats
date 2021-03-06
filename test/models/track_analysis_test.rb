require "test_helper"
require "json"

class TrackAnalysisTest < ActiveSupport::TestCase
  setup do
    @analysis = TrackAnalysis.new(tracks_fixture)
  end

  test "release_date_range" do
    range = @analysis.release_date_range
    assert_equal [2020, 4], range.first
    assert_equal [1971, 1], range.last
  end

  test "tracks_by_release_year" do
    tracks = @analysis.tracks_by_release_year(2020)
    assert_equal ["Erase", "Heron", "Spongy Hammer", "Tropical Heaven"], tracks.map(&:name).sort
  end

  test "danceability" do
    label, score = @analysis.danceability
    assert_in_delta 0.5, score, 0.05
    assert_equal "chain restaurant ambiance", label
  end

  test "energy" do
    label, score = @analysis.energy
    assert_in_delta 0.55, score, 0.05
    assert_equal "a text from your crush", label
  end

  test "valence" do
    label, score = @analysis.valence
    assert_in_delta 0.33, score, 0.05
    assert_equal "a moment of despair", label
  end

  test "highest_valence" do
    track = @analysis.highest_valence
    assert_equal "Sweet Dreams (Are Made of This) - Remastered", track.name
  end

  test "most_popular" do
    tracks = @analysis.most_popular
    assert_equal ["Seven Nation Army", "Sweet Dreams (Are Made of This) - Remastered", "Zombie"], tracks.map(&:name)
  end

  test "least_popular" do
    tracks = @analysis.least_popular
    assert_equal ["Heron", "Adagio For Strings - Radio Edit", "Heaven - 12\" Mix"], tracks.map(&:name)
  end

  def tracks_fixture
    body = file_fixture("tracks-response.json").read
    json = JSON.parse(body)
    json["items"].map { |elem| RSpotify::Track.new(elem['track']) }
  end
end
