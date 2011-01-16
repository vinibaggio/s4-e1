module Kayak
  class Trip
    attr_reader :price, :flights

    # Parse the Hash created by Kayak::Search.
    # Current data comes as follows:
    # {
    #   trip => [
    #     {price => '...', ...}, {price => '...', ...}
    #   ]
    # }
    def self.parse(trips)
      if trips
        trips['trip'].map { |trip| new(trip) }
      else
        []
      end
    end

    # Parse the data structure to fetch the results.
    def initialize(trip)
      @price = trip['price'].to_i
      @flights = Kayak::Flight.parse(trip['legs'])
    end

    def to_s
      "Trip <price: USD #{@price}, flights: #{@flights}>"
    end
  end
end
