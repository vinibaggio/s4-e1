require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class KayakConnectionTest < Test::Unit::TestCase
  def setup
    @kayak = Kayak::Connection.new('kayak.yml.example')
  end

  def test_initialization
    assert_equal 'Your Kayak username', @kayak.username
    assert_equal 'Your Kayak dev key', @kayak.key
  end

  def test_start_session_with_invalid_token
    encoded_token = URI.encode('Your Kayak dev key')

    stub_request(:get, "http://api.kayak.com/k/ident/apisession?token=#{encoded_token}").
      to_return(:status => 200, :body => <<-BODY, :headers => {})
        <?xml version="1.0"?>
        <ident>
          <uid></uid>
          <sid></sid>
          <token>123</token>
          <error>invalid token</error>
        </ident>
    BODY

    assert_raise Kayak::InvalidSessionError do
      @kayak.start_session
    end
  end

  def test_start_session_with_valid_token
    stub_valid_session!

    assert_nothing_raised do
      @kayak.start_session
    end
  end

  def test_search_flight_without_established_session
    assert_raise Kayak::InvalidSessionError do
      @kayak.flights(nil, nil)
    end
  end

  protected
  def stub_valid_session!
    encoded_token = URI.encode('Your Kayak dev key')

    stub_request(:get, "http://api.kayak.com/k/ident/apisession?token=#{encoded_token}").
      to_return(:status => 200, :body => <<-BODY, :headers => {})
        <?xml version="1.0"?>
        <ident>
          <uid>1973099132</uid>
          <sid>20-$ki6bvrByf9Y1B9ANP7H</sid>
          <token>jGNGZhB_jnwyhL1EGf$ZkQ</token>
          <error></error>
        </ident>
    BODY

  end
end
