require 'test_helper'

class TestKayakSearch < Test::Unit::TestCase
  def test_start_search
    WebMock.allow_net_connect!
    kayak = Kayak::Session.new("jGNGZhB_jnwyhL1EGf$ZkQ")
    kayak_search = Kayak::Search.new(kayak, 'Nyisem')
    kayak_search.fetch
    # search = kayak.flights('GRU', 'LAX')
    # search.fetch
  end

  protected

  def kayak_session_mock
    OpenStruct.new(:session_id => 'token123')
  end
end
