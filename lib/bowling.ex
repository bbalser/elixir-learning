defmodule Bowling do

  def score(game) do
    one = score(String.codepoints(game), [])
      |> Enum.reverse
      |> Enum.take(10)
      |> Enum.sum
  end

  defp score([], scored_frames), do: scored_frames

  defp score(["X" | tail], scored_frames) do
    frame = ["X" | Enum.take(tail,2)]
    score(tail, [score_frame(frame) | scored_frames])
  end

  defp score([head, "/" | tail], scored_frames) do
    frame = [ head, "/" | Enum.take(tail, 1)]
    score(tail, [score_frame(frame) | scored_frames])
  end

  defp score(rolls, scored_frames) do
    frame = Enum.take(rolls, 2)
    score(Enum.drop(rolls, 2), [score_frame(frame) | scored_frames])
  end

  defp score_frame(frame), do: Enum.reduce(frame, 0, fn (x, sofar) ->
      case x do
        "X" -> sofar + 10
        "/" -> Float.ceil((sofar + 1) / 10) * 10
        "-" -> sofar
        x -> sofar + String.to_integer(x)
      end
    end)


end
