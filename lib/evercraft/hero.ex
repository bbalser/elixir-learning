defmodule Evercraft.Hero do
  import AgentStateMap.Macros
  alias Evercraft.Alignment, as: Alignment
  alias Evercraft.Attack, as: Attack
  alias Evercraft.Abilities, as: Abilities

  def create(name, keywords \\ []) do
    abilities = Keyword.get(keywords, :abilities, %Abilities{})
    exp = Keyword.get(keywords, :experience, 0)

    Agent.start_link(fn -> %{ :name => name,
                              :alignment => Keyword.get(keywords, :alignment, Alignment.neutral),
                              :hit_points => Keyword.get(keywords, :hit_points, calculate_max_hit_points(exp, abilities)),
                              :abilities => abilities,
                              :experience => exp
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
    {exp, abilities} = get pid, {:experience, :abilities}
    calculate_max_hit_points(exp, abilities)
  end

  def level(pid) do
    calculate_level(get(pid, :experience))
  end

  def alive?(pid) do
    hit_points(pid) > 0
  end

  def abilities(pid), do: get pid, :abilities

  def apply_attack(pid, attack) do
    set pid, hit_points: state[:hit_points] - Attack.damage(attack)
  end

  defp calculate_max_hit_points(exp, %Abilities{constitution: constitution}) do
    level = calculate_level(exp)
    for _ <- (1..level), into: [] do
      5 + Abilities.modifier(constitution)
    end |> Enum.sum |> max(1)
  end

  defp calculate_level(exp) do
    div(exp, 1000) + 1
  end

end

defmodule Evercraft.Hero.Attack do
  alias Evercraft.Hero, as: Hero
  alias Evercraft.Abilities, as: Abilities
  alias Evercraft.Attack, as: Attack

  def modifier(attack) do
    add_strength(0, attack)
  end

  def damage(attack) do
    add_strength(0, attack)
  end

  defp add_strength(total, %Attack{attacker: hero}) do
    total + (Hero.abilities(hero).strength |> Abilities.modifier)
  end

end
