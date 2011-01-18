# Represents the Kayak API.
# Check http://www.kayak.com/labs/api/search/spec.html for more info
module Kayak
  class Session
    attr_reader :session_id

    def initialize(token)
      @token = token
      @session_id, error = Kayak::Api.fetch_session(@token)

      validate_response(@session_id, error)
    end

    # Gather flights.
    # TODO Make it more configurable, like the arriving time or the travel date
    #
    # Kayak's API tells that:
    #  basicmode -> must be "true"
    #  oneway -> "y" or "n"
    #  origin -> three-letter airport code (e.g. "BOS")
    #  destination -> three-letter airport code (e.g. "SFO")
    #  depart_date -> MM/DD/YYYY
    #  return_date -> MM/DD/YYYY
    #  depart_time -> Values:
    #           "a" = any time; "r"=early morning; "m"=morning;
    #           "12"=noon; "n"=afternoon; "e"=evening; "l"=night
    #  return_time -> see depart_time
    #  travelers -> integer from 1-8
    #  cabin -> f, b or e(default) (first, business, economy/coach)
    #  action -> must be "doFlights"
    #  apimode -> must be "1"
    #  _sid_ -> the Session ID you get from GetSession
    #  version -> The version of the API the client is expecting. The only current supported version is "1"
    def search_flights(from, to, whn)
      Search.new(self, Kayak::Api.fetch_flight_search(@session_id, from, to, whn))
    end

    private

    def validate_response(response, error)
      unless response
        raise InvalidSessionError, error
      end
    end
  end
end
