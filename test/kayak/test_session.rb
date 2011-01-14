require 'test_helper'

class TestKayakSession < Test::Unit::TestCase
  def test_start_session_with_invalid_token
    stub_invalid_session

    assert_raise Kayak::InvalidSessionError do
      Kayak::Session.new('token123')
    end
  end

  def test_start_session_with_valid_token
    stub_valid_session

    assert_nothing_raised do
      Kayak::Session.new('token123')
    end
  end

  protected
  def stub_invalid_session
    stub_request(:get, "http://api.kayak.com/k/ident/apisession?token=token123").
      to_return(:status => 200, :body => <<-BODY, :headers => {})
        <?xml version="1.0"?>
        <ident>
          <uid></uid>
          <sid></sid>
          <token>123</token>
          <error>invalid token</error>
        </ident>
    BODY
  end

  def stub_valid_session
    stub_request(:get, "http://api.kayak.com/k/ident/apisession?token=token123").
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
