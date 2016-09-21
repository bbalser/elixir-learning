defmodule RomanNumeral do
  @conversion_values [X: 10, IX: 9, V: 5, IV: 4, I: 1]

  def to_roman(arabic) do
    convert_to_roman(arabic, @conversion_values, "")
  end

  defp convert_to_roman(_, [], result), do: result
  defp convert_to_roman(arabic, [{cRoman, cArabic} | tail], result) do
    remainder = rem arabic, cArabic
    times = div arabic, cArabic
    convert_to_roman(remainder, tail, result <> String.duplicate(to_string(cRoman), times))
  end

  def to_arabic(roman), do: convert_to_arabic(roman, 0)

  defp convert_to_arabic("", result), do: result
  defp convert_to_arabic(roman, result) do
    {cRoman, cArabic} = @conversion_values |> Enum.find(fn {cRoman, cArabic} -> String.starts_with?(roman, to_string(cRoman)) end)
    convert_to_arabic(String.slice(roman, String.length(to_string(cRoman))..-1), result + cArabic)
  end

end
