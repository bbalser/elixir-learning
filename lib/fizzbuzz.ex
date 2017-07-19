defmodule FizzBuzz do

  def fizzbuzz(list) do
    list
    |> Stream.map(fn entry -> { rem(entry,3), rem(entry, 5), entry } end)
    |> Enum.map(&convert/1)
  end

  defp convert({0, 0, _entry}), do: "fizzbuzz"
  defp convert({0, _, _entry}), do: "fizz"
  defp convert({_, 0, _entry}), do: "buzz"
  defp convert({_, _, entry}), do: to_string(entry)

end
