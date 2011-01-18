require 'test_helper'

class TestKayakData < Test::Unit::TestCase
  def test_airport_name
    assert_equal "La Guardia (LGA), US", Kayak::Data.airport_name('LGA')
  end

  def test_airline_name
    assert_equal "Lufthansa", Kayak::Data.airline_name('LH')
  end
end
