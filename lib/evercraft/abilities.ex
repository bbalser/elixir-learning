defmodule Evercraft.Abilities do

  defstruct strength: 10, dexterity: 10, constitution: 10, wisdom: 10, intelligence: 10, charisma: 10

  def modifier(score) when is_integer(score) do
    ((score - 10) / 2) |> Float.floor |> round
  end

end
