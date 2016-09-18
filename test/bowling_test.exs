defmodule BowlingTest do
  use ExUnit.Case, async: true
  import Bowling

  test "all numbers should equal themselves" do
    result = 1..9 |> Enum.map(&(score(to_string(&1))))
    assert [1,2,3,4,5,6,7,8,9] == result
  end

  test "- should be zero" do
    assert 0 == score("-")
  end

  test "X should be 10" do
    assert 10 == score("X")
  end

  test "54 should be 9" do
    assert 9 == score("54")
  end

  test "X5454 should be 37 since strikes count next 2 rolls" do
    assert 37 == score("X5454")
  end

  test "5/7 should be 24 since spare counts next ball" do
    assert 24 == score("5/7")
  end

  test "3/X should be 30" do
    assert 30 == score("3/X")
  end

  test "X4/ should be 30" do
    assert 30 == score("X4/")
  end

  test "X-/ shoudl be 30" do
    assert 30 == score("X-/")
  end

  test "XXXXXXXXXXXX should be 300" do
    assert 300  == score("XXXXXXXXXXXX")
  end

end
