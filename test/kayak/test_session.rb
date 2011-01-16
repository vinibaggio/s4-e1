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

  def test_get_flights
    stub_valid_session
    stub_flight_search

    kayak = Kayak::Session.new('token123')
    search = kayak.search_flights('SFO', 'GRU', Date.today)

    assert_equal true, search.instance_of?(Kayak::Search)
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

  def stub_flight_search
    query =  {
      :basicmode => 'true',
      :oneway => 'y',
      :origin => 'SFO',
      :destination => 'GRU',
      :depart_date => Date.today.strftime('%m/%d/%Y'),
      :return_date => Date.today.strftime('%m/%d/%Y'),
      :depart_time => 'a', # All
      :return_time => 'a',
      :travelers => '1',
      :cabin => 'e',
      :action => 'doFlights',
      :apimode => '1',
      :_sid_ => 'blablabla'
    }

    stub_request(:get, "http://api.kayak.com/s/apisearch").with(:query => query).
      to_return(:status => 200, :body =>  <<-BODY)
        <?xml version="1.0"?>
        <search>
          <url>![CDATA[http://www.kayak.com/h/basic?rss=1&searchid=8749JDWwiBUg4OF3ts88]]</url>
          <searchid>8749JDWwiBUg4OF3ts88</searchid>
        </search>
      BODY
  end
end
