require 'test_helper'

class TestKayakTrip < Test::Unit::TestCase
  def test_empty_search_results
    results = Kayak::Trip.parse(trip_data('empty_search_result.xml'))
    assert_equal true, results.empty?
  end

  def test_parse_a_bunch_of_trips
    results = Kayak::Trip.parse(trip_data('search_result.xml'))
    assert_equal false, results.empty?

    first_trip = results.first
    assert_equal 738, first_trip.price
    assert_equal false, first_trip.flights.empty?
  end

  protected
  def trip_data(filename)
    data = Crack::XML.parse(load_fixture(filename))
    data['searchresult']['trips']
  end
end
