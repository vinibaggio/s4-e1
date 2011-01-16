# Represents the Kayak API.
# Check http://www.kayak.com/labs/api/search/spec.html for more info
module Kayak
  class Session
    attr_reader :session_id

    include HTTParty

    def initialize(token)
      @token = token

      ident = get('/k/ident/apisession', {:token => @token})['ident']
      @session_id = ident['sid']

      assert_valid_response(@session_id, ident['error'])
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
    def flights(from, to)
       query = {
         :basicmode => 'true',
         :oneway => 'y',
         :origin => from,
         :destination => to,
         :depart_date => format_date(Date.today),
         :return_date => format_date(Date.today),
         :depart_time => 'a', # All
         :return_time => 'a',
         :travelers => 1,
         :cabin => 'e',
         :action => 'doFlights',
         :apimode => '1',
         :_sid_ => @session_id
       }

      response = get('/s/apisearch', query)
      Search.new(self, response['search']['searchid'])
    end

    private
    def get(url, query)
      options = {:query => query}
      response = self.class.get(Kayak.base_url + url, options).parsed_response

      # Manually parse when content-type is not XML (but it is actually a XML).
      #
      # That happens because HTTParty relies on Content-Type to check if it
      # should parse a XML or a JSON. There are calls that, even if response
      # is XML, Content-Type isn't set by the server, so nothing happens.
      # In that case, we manually use Crack to parse that.
      unless response.is_a?(Hash)
        response = Crack::XML.parse(response)
      end

      response
    end

    def assert_valid_response(response, error)
      unless response
        raise InvalidSessionError, error
      end
    end

    def format_date(date)
      date.strftime("%m/%d/%Y")
    end
  end
end
