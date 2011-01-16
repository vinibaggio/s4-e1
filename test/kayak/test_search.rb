require 'test_helper'

class TestKayakSearch < Test::Unit::TestCase
  def setup
    stub_valid_session
    stub_first_flight_request
    stub_last_flight_request

    @kayak = Kayak::Session.new("token123")
    @kayak_search = Kayak::Search.new(@kayak, 'SeArCh')
  end

  def test_initial_search_state
    assert_equal true, @kayak_search.init?
    assert_equal false, @kayak_search.complete?
    assert_equal false, @kayak_search.fetching?

    assert_equal true, @kayak_search.results.empty?
  end

  def test_start_search_state
    @kayak_search.fetch

    assert_equal false, @kayak_search.init?
    assert_equal false, @kayak_search.complete?
    assert_equal true, @kayak_search.fetching?
    # search = kayak.flights('GRU', 'LAX')
    # search.fetch
  end

  def test_complete_search_state
    2.times { @kayak_search.fetch }

    assert_equal true, @kayak_search.complete?
    assert_equal false, @kayak_search.init?
    assert_equal false, @kayak_search.fetching?
  end

  def test_complete_state_doesnt_request_more
    8.times { @kayak_search.fetch }

    assert_equal true, @kayak_search.complete?
    # First request, see that c = 10
    assert_requested(:get, 'http://api.kayak.com/s/apibasic/flight?_sid_=blablabla&apimode=1&c=10&d=up&m=normal&s=price&searchid=SeArCh&version=1', :times => 1)
    # Last request, see that c = 50
    assert_requested(:get, 'http://api.kayak.com/s/apibasic/flight?_sid_=blablabla&apimode=1&c=50&d=up&m=normal&s=price&searchid=SeArCh&version=1', :times => 1)
  end

  def test_fetch_should_build_trips
    trips = @kayak_search.fetch
    trips.each do |trip|
      assert_equal true, trip.instance_of?(Kayak::Trip)
    end
  end

  protected

  def kayak_session_mock
    OpenStruct.new(:session_id => 'token123')
  end

  def stub_first_flight_request
    query = {
      :_sid_ => 'blablabla',
      :apimode => '1',
      :c => '10',
      :d => 'up',
      :m => 'normal',
      :s => 'price',
      :searchid => 'SeArCh',
      :version => '1'
    }
    stub_request(:get, "http://api.kayak.com/s/apibasic/flight").with(:query => query).
      to_return(:status => 200,
                :body => load_fixture('search_result.xml'),
                :headers => { 'Content-Type' => 'application/xml' }
               )
  end

  def stub_last_flight_request
    query = {
      :_sid_ => 'blablabla',
      :apimode => '1',
      :c => '50',
      :d => 'up',
      :m => 'normal',
      :s => 'price',
      :searchid => 'SeArCh',
      :version => '1'
    }
    stub_request(:get, "http://api.kayak.com/s/apibasic/flight").with(:query => query).
      to_return(:status => 200,
                :body => load_fixture('last_search_result.xml'),
                :headers => { 'Content-Type' => 'application/xml' }
               )
  end

end
