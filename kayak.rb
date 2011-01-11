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
