defmodule Evercraft.Attack do
  alias Evercraft.Hero, as: Hero

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
    attack.roll + Hero.Attack.modifier(attack) >= Hero.armor_class(attack.defender)
  end

  def damage(attack) do
    max(damage_multiplier(attack) * (1 + Hero.Attack.damage(attack)), 1)
  end

  defp damage_multiplier(attack) do
    case critical?(attack) do
      true -> 2
      false -> 1
    end
  end

  defp critical?(attack), do: attack.roll == 20

end
