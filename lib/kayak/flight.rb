module Kayak
  class FlightSegment
    attr_reader :duration_minutes, :departure_time, :arrival_time, :cabin
    def initialize(segment)
      @airline_code = segment['airline']
      @duration_minutes = segment['duration_minutes'].to_i
      @origin = segment['o']
      @departure_time = Kayak.parse_time(segment['dt'])
      @destination = segment['d']
      @arrival_time = Kayak.parse_time(segment['at'])
      @cabin = segment['cabin'].downcase.to_sym
    end

    def airline
      Kayak.airline_name(@airline_code)
    end

    def origin
      @origin_full_name ||= Kayak.airport_name(@origin)
    end

    def destination
      @destination_full_name ||= Kayak.airport_name(@destination)
    end
  end

  class Flight
    attr_reader :cabin, :airline, :departure_time, :arrival_time,
                :duration_minutes, :stops, :segments

    # Parse the flights.
    # All the examples I've tried, only one 'leg' is returned.
    # Further flight legs are specified in 'segments' tag,
    # but it may be incorrect. The resulting data is not
    # explained in Kayak API's documentation, so I tried
    # to program it according to some experimentation.
    #
    # See test/fixtures/flight_data.json for examples of data
    def self.parse(legs)
      leg = legs['leg']

      if leg.is_a?(Array)
        leg.map do |l|
          new(l)
        end
      else
        [new(leg)]
      end
    end

    def initialize(flight)
      @airline = flight['airline_display']
      @origin = flight['orig']
      @destination = flight['dest']
      @cabin = flight['cabin'].downcase.to_sym
      @duration_minutes = flight['duration_minutes'].to_i
      @stops = flight['stops'].to_i
      @segments = flight['segment'].map { |s| FlightSegment.new(s) }
      @departure_time = Kayak.parse_time(flight['depart'])
      @arrival_time = Kayak.parse_time(flight['arrive'])
    end

    def origin
      @origin_full_name ||= Kayak.airport_name(@origin)
    end

    def destination
      @destination_full_name ||= Kayak.airport_name(@destination)
    end

  end
end
