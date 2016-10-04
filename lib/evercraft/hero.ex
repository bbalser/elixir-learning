
alias Evercraft.Alignment
alias Evercraft.Attack
alias Evercraft.Abilities
alias Evercraft.Classes

defmodule Evercraft.Hero do
  require Evercraft.Classes
  require Evercraft.Alignment
  import AgentStateMap.Macros

  def create(name, keywords \\ []) do
    abilities = Keyword.get(keywords, :abilities, %Abilities{})
    exp = Keyword.get(keywords, :experience, 0)
    class = Keyword.get(keywords, :class, nil)

    Agent.start_link(fn -> %{ :name => name,
                              :alignment => Keyword.get(keywords, :alignment, Alignment.neutral),
                              :hit_points => Keyword.get(keywords, :hit_points, calculate_max_hit_points(exp, class, abilities)),
                              :abilities => abilities,
                              :experience => exp,
                              :class => class
                            } end)
  end

  def name(pid) do
    get pid, :name
  end

  def alignment(pid) do
    get pid, :alignment
  end

  def armor_class(pid) do
    10 + Abilities.modifier(get(pid, :abilities).dexterity)
  end

  def hit_points(pid) do
    get pid, :hit_points
  end

  def max_hit_points(pid) do
    {exp, class, abilities} = get pid, {:experience, :class, :abilities}
    calculate_max_hit_points(exp, class, abilities)
  end

  def level(pid) do
    calculate_level(get(pid, :experience))
  end

  def class(pid) do
    get pid, :class
  end

  def alive?(pid) do
    hit_points(pid) > 0
  end

  def abilities(pid), do: get pid, :abilities

  def apply_attack(pid, attack) do
    set pid, hit_points: state[:hit_points] - Attack.damage(attack)
  end

  defp calculate_max_hit_points(exp, class, abilities) do
    level = calculate_level(exp)
    hp_per_level = hit_points_per_level(class, abilities)
    (level * hp_per_level) |> max(1)
  end

  defp hit_points_per_level(class, %Abilities{constitution: constitution}) do
    cond do
      class == Classes.fighter -> 10
      true -> 5
    end + Abilities.modifier(constitution)
  end

  defp calculate_level(exp) do
    div(exp, 1000) + 1
  end

end

defmodule Evercraft.Hero.Attack do
  require Evercraft.Classes
  alias Evercraft.Hero

  def modifier(attack) do
    [strength(attack), level(attack)] |> Enum.sum
  end

  def damage(attack) do
    strength(attack)
  end

  defp strength(%Attack{attacker: hero}) do
    Hero.abilities(hero).strength |> Abilities.modifier
  end

  defp level(attack) do
    case Hero.class(attack.attacker) do
      Classes.fighter -> Hero.level(attack.attacker)
      _ -> div Hero.level(attack.attacker), 2
    end

  end

end
