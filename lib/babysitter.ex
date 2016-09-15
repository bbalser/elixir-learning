defmodule Babysitter do
  @beforebedtime 10
  @afterbedtime 6
  @aftermidnight 12


  def calculate(start, finish, bedtime) do
    mapTime(start)..(mapTime(finish)-1)
        |> Enum.map(&(rate(&1, bedtime)))
        |> Enum.sum
  end

  defp rate(hour, _) when hour >= 12, do: @aftermidnight
  defp rate(hour, bedtime) when hour >= bedtime, do: @afterbedtime
  defp rate(_, _), do:  @beforebedtime

  defp mapTime(time) when time < 5, do: time + 12
  defp mapTime(time), do: time
end
