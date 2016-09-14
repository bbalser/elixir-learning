defmodule FizzBuzzTest do
  use ExUnit.Case
  import FizzBuzz
  doctest FizzBuzz

  test "fizzbuzz" do
    assert ["1","2","4"] == fizzbuzz [1,2,4]
    assert ["fizz","fizz","fizz"] == fizzbuzz [3,6,9]
    assert ["buzz", "buzz", "buzz"] == fizzbuzz [5,10,20]
    assert ["fizzbuzz", "fizzbuzz"] == fizzbuzz [15,30]
  end
end
