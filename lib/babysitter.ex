defmodule Babysitter do
  @beforebedtime 10
  @afterbedtime 6
  @aftermidnight 12

  def calculate(start, finish, bedtime) do
    to_range(start, finish) 
    |> Stream.map(fn hour -> rate(hour, bedtime) end)
    |> Enum.sum
  end

  defp to_range(start, finish), do: mapTime(start)..(mapTime(finish)-1)

  defp rate(hour, _) when hour >= 12, do: @aftermidnight
  defp rate(hour, bedtime) when hour >= bedtime, do: @afterbedtime
  defp rate(_, _), do:  @beforebedtime

  defp mapTime(time) when time < 5, do: time + 12
  defp mapTime(time), do: time

end
