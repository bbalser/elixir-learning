defmodule Evercraft.Attack do
  require Evercraft.Classes
  alias Evercraft.{Hero, Classes}

  defstruct attacker: nil, defender: nil, roll: -1

  def create(attacker, defender, roll) do
    attack = %Evercraft.Attack{attacker: attacker, defender: defender, roll: roll}
    if hit?(attack) do
      Hero.apply_attack(attack.defender, attack)
    end
    attack
  end

  def attacker(attack), do: attack.attacker

  def defender(attack), do: attack.defender

  def hit?(attack) do
    flat_footed = if (Classes.rogue == Hero.class(attack.attacker)), do: true, else: false
    attack.roll + Hero.Attack.modifier(attack) >= Hero.armor_class(attack.defender, flat_footed: flat_footed)
  end

  def damage(attack) do
    damage_multiplier(attack) * (1 + Hero.Attack.damage(attack))
      |> max(1)
  end

  defp damage_multiplier(attack) do
    case {critical?(attack), Hero.class(attack.attacker)}  do
      {true, Classes.rogue} -> 3
      {true, _} -> 2
      {false, _} -> 1
    end
  end

  defp critical?(attack), do: attack.roll == 20

end
