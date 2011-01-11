require 'yaml'
require 'httparty'

# Represents the Kayak API.
# Check http://www.kayak.com/labs/api/search/spec.html for more info
class Kayak
  InvalidSessionError = Class.new(StandardError)

  KAYAK_URL = "http://api.kayak.com"

  attr_reader :username, :key

  def initialize(config_file='kayak.yml')
    config = YAML::load(open(config_file))
    @username = config['kayak']['username']
    @key = config['kayak']['key']
  end

  def start_session
    ident = get('/k/ident/apisession', {:token => @key})['ident']
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
    assert_session
  end

  private
  def get(url, query)
    options = {:query => query}
    response = HTTParty.get(KAYAK_URL + url, options)
    Crack::XML.parse(response.parsed_response)
  end

  def assert_valid_response(response, error)
    if response
      true
    else
      raise InvalidSessionError, error
    end
  end

  def assert_session
    raise InvalidSessionError, 'you need a session to perform calls' unless @session_id
  end
end
