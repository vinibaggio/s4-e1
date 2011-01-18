require 'test_helper'

class TestKayakFormat < Test::Unit::TestCase

  def test_parse_time
    time = Kayak::Format.parse_time("2011/01/10 22:00")
    assert_equal Time.new(2011, 01, 10, 22, 00), time
  end

  def test_date_string
    assert_equal "01/22/2010", Kayak::Format.date_string(Date.new(2010, 01, 22))
  end

end
