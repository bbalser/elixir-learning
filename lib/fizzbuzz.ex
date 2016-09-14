defmodule FizzBuzz do
  def fizzbuzz(list) do
    fizzbuzz(list, [])
  end

  def fizzbuzz([], result), do: result

  def fizzbuzz([head | tail], result) when rem(head,15) == 0 do
    fizzbuzz(tail, result ++ ["fizzbuzz"])
  end

  def fizzbuzz([head | tail], result) when rem(head,5) == 0 do
    fizzbuzz(tail, result ++ ["buzz"])
  end

  def fizzbuzz([head | tail], result) when rem(head,3) == 0 do
    fizzbuzz(tail, result ++ ["fizz"])
  end

  def fizzbuzz([head | tail], result) do
    fizzbuzz(tail, result ++ [Integer.to_string(head)])
  end


end
