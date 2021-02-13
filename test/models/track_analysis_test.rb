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

  test "danceability" do
    label, score = @analysis.danceability
    assert_in_delta 0.5, score, 0.05
    assert_equal "chain restaurant ambiance", label
  end

  def tracks_fixture
    body = file_fixture("tracks-response.json").read
    json = JSON.parse(body)
    json["items"].map { |elem| RSpotify::Track.new(elem['track']) }
  end
end
