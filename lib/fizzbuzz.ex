defmodule FizzBuzz do
  def fizzbuzz(list) do
    list |> Enum.map(&(convert(&1)))
  end

  defp convert(entry) do
    case {rem(entry, 3), rem(entry, 5)} do
      {0, 0} -> "fizzbuzz"
      {_, 0} -> "buzz"
      {0, _} -> "fizz"
      _ -> to_string(entry)
    end
  end

end
