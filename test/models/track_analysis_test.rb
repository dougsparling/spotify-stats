require "test_helper"
require "json"

class TrackAnalysisTest < ActiveSupport::TestCase
  test "release_date_range" do
    analysis = TrackAnalysis.new(tracks_fixture)
    range = analysis.release_date_range
    assert_equal [2020, 4], range.first
    assert_equal [1971, 1], range.last
  end

  def tracks_fixture
    body = file_fixture("tracks-response.json").read
    json = JSON.parse(body)
    json["items"].map { |elem| RSpotify::Track.new(elem['track']) }
  end
end
