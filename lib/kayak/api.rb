module Kayak
  class Api
    include HTTParty
    class << self
      # TODO Refactor the tests

      def fetch_session(token)
        query = { :token => token }

        response = get(Kayak::BASE_URL + '/k/ident/apisession', :query => query).parsed_response

        # Manually parse when content-type is not XML (but it is actually a XML).
        #
        # That happens because HTTParty relies on Content-Type to check if it
        # should parse a XML or a JSON. There are calls that, even if response
        # is XML, Content-Type isn't set by the server, so nothing happens.
        # In that case, we manually use Crack to parse that.
        ident = Crack::XML.parse(response)['ident']

        [ident['sid'], ident['error']]
      end

      def fetch_search_results(session_id, search_id, quantity)
        query = {
          :searchid => search_id,
          :c        => quantity,
          :m        => 'normal',
          :d        => 'up',
          :s        => 'price',
          :_sid_    => session_id,
          :version  => '1',
          :apimode  => '1'
        }

        response = get(Kayak::BASE_URL + '/s/apibasic/flight', :query => query)
        response.parsed_response['searchresult']
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
      def fetch_flight_search(session_id, from, to, whn)
        query = {
          :basicmode   => 'true',
          :oneway      => 'y',
          :origin      => from,
          :destination => to,
          :depart_date => Kayak::Format.date_string(whn),
          :return_date => Kayak::Format.date_string(whn),
          :depart_time => 'a', # All
          :return_time => 'a',
          :travelers   => 1,
          :cabin       => 'e',
          :action      => 'doFlights',
          :apimode     => '1',
          :_sid_       => session_id
        }

        response = get(Kayak::BASE_URL + '/s/apisearch', :query => query)
        response['search']['searchid']
      end
    end
  end
end
