# Represents the Kayak API.
# Check http://www.kayak.com/labs/api/search/spec.html for more info
module Kayak
  class Session
    include HTTParty

    KAYAK_URL = "http://api.kayak.com"

    def initialize(token)
      @token = token

      ident = get('/k/ident/apisession', {:token => @token})['ident']
      @session_id = ident['sid']

      assert_valid_response(@session_id, ident['error'])
    end

    # Gather flights.
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
      # query = {
      #   :basicmode => 'true',
      #   :oneway => 'y',
      #   :origin => from,
      #   :destination => to,
      #   :depart_date => Date.today.to_s,
      #   :return_date => Date.today.to_s,
      #   :depart_time => 'a', # All
      #   :return_time => 'a',
      #   :travelers => 1,
      #   :cabin => 'e',
      #   :action => 'doFlights',
      #   :apimode => '1',
      #   :_sid_ => @session_id
      # }
      # get('/s/apisearch', query)
    end

    private
    def get(url, query)
      options = {:query => query}
      response = self.class.get(KAYAK_URL + url, options)
      Crack::XML.parse(response.parsed_response)
    end

    def assert_valid_response(response, error)
      if response
        true
      else
        raise InvalidSessionError, error
      end
    end
  end
end
