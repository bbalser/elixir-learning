defmodule RomanNumeralTest do
  use ExUnit.Case
  doctest RomanNumeral
  import RomanNumeral

  test "to_roman" do
    assert "I" == to_roman(1)
    assert "II" == to_roman(2)
    assert "IV" == to_roman(4)
    assert "V" == to_roman(5)
    assert "IX" == to_roman(9)
    assert "X" == to_roman(10)
    assert "XX" == to_roman(20)
  end

  test "to_arabic" do
    assert 1 == to_arabic("I")
    assert 2 == to_arabic("II")
    assert 5 == to_arabic("V")
    assert 24 == to_arabic("XXIV")
  end

end
