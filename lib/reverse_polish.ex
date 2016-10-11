defmodule ReversePolish do

  def evaluate(expr) do
    String.split(expr)
      |> Enum.map(fn str -> parse(str) end)
      |> process([])
  end

  defp process([], [head | _tail]) do
    head
  end

  defp process([operand | tail], stack) when is_number(operand) do
    process(tail, [operand | stack])
  end

  defp process([operator | tail], [operand1, operand2 | stack]) do
    result = perform_operation(operator, operand1, operand2)
    process(tail, [result | stack])
  end

  defp perform_operation(operator, operand1, operand2) do
    case operator do
      "+" -> operand2 + operand1
      "-" -> operand2 - operand1
      "*" -> operand2 * operand1
      "/" -> div operand2, operand1
    end
  end

  defp parse(x) do
    case Integer.parse(x) do
      {num, _} -> num
      :error -> x
    end
  end

end
