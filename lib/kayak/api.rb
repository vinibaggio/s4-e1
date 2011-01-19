module Kayak
  module Api
    # TODO Refactor the tests

    include HTTParty
    extend self

    def new_session(token)
      query = { :token => token }

      response = get(Kayak::BASE_URL + '/k/ident/apisession', :query => query)

      # Manually parse when content-type is not XML (but it is actually a XML).
      #
      # That happens because HTTParty relies on Content-Type to check if it
      # should parse a XML or a JSON. There are calls that, even if response
      # is XML, Content-Type isn't set by the server, so nothing happens.
      # In that case, we manually use Crack to parse that.
      ident = Crack::XML.parse(response.parsed_response)['ident']

      {:session_id => ident['sid'], :error => ident['error']}
    end

    def results(params)
      query = {
        :searchid => params[:search_id],
        :c        => params[:quantity],
        :m        => 'normal',
        :d        => 'up',
        :s        => 'price',
        :_sid_    => params[:session_id],
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
    def search(params)
      query = {
        :basicmode   => 'true',
        :oneway      => 'y',
        :origin      => params[:from],
        :destination => params[:to],
        :depart_date => Kayak::Format.date_string(params[:when]),
        :return_date => Kayak::Format.date_string(params[:when]),
        :depart_time => 'a', # All
        :return_time => 'a',
        :travelers   => 1,
        :cabin       => 'e',
        :action      => 'doFlights',
        :apimode     => '1',
        :_sid_       => params[:session_id]
      }

      response = get(Kayak::BASE_URL + '/s/apisearch', :query => query)
      response['search']['searchid']
    end
  end
end
