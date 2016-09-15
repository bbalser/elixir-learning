defmodule BabysitterTest do
  use ExUnit.Case
  doctest Babysitter
  import Babysitter

  test "babysitter gets paid" do
    assert 10 == calculate(5,6,8)
    assert 6 == calculate(8,9,8)
    assert 12 == calculate(1,2,8)
    assert 20 == calculate(5,7,8)
    assert 12 == calculate(8,10,8)
    assert 24 == calculate(1,3,8)
    assert 16 == calculate(7, 9, 8)
    assert 12 == calculate(12, 1, 8)
    assert (3 * 10) + (4 * 6) + (2 * 12) == calculate(5, 2, 8)
  end

end
