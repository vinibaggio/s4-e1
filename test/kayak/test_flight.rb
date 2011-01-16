require 'test_helper'

class TestKayakFlight < Test::Unit::TestCase

  def test_parse_flight
    flights = Kayak::Flight.parse(flight_data('flight_data.json'))

    flight = flights.first
    assert_equal "Continental", flight.airline
    assert_equal :economy, flight.cabin
    assert_equal 1390, flight.duration_minutes
    assert_equal 1, flight.stops
    assert_equal 2, flight.segments.count
    assert_equal 'Guarulhos Intl (GRU), BR', flight.origin
    assert_equal 'Los Angeles (LAX), US', flight.destination
    assert_equal Time.new(2011, 01, 16, 23, 05, 00), flight.departure_time
    assert_equal Time.new(2011, 01, 17, 16, 15, 00), flight.arrival_time
  end

  def test_parse_segments
    flights = Kayak::Flight.parse(flight_data('flight_data.json'))

    segments = flights.first.segments
    first_segment = segments.first
    last_segment = segments.last

    assert_equal 'Continental', first_segment.airline
    assert_equal 600, first_segment.duration_minutes
    assert_equal 'Guarulhos Intl (GRU), BR', first_segment.origin
    assert_equal 'Newark (EWR), US', first_segment.destination
    assert_equal :economy, first_segment.cabin
    assert_equal Time.new(2011, 01, 16, 23, 05, 00), first_segment.departure_time
    assert_equal Time.new(2011, 01, 17, 06, 05, 00), first_segment.arrival_time


    assert_equal 'Continental', last_segment.airline
    assert_equal 365, last_segment.duration_minutes
    assert_equal 'Newark (EWR), US', last_segment.origin
    assert_equal 'Los Angeles (LAX), US', last_segment.destination
    assert_equal :economy, last_segment.cabin
    assert_equal Time.new(2011, 01, 17, 13, 10, 00), last_segment.departure_time
    assert_equal Time.new(2011, 01, 17, 16, 15, 00), last_segment.arrival_time
  end

  protected

  def flight_data(filename)
    Crack::JSON.parse(load_fixture(filename))
  end
end
