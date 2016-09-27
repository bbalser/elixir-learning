defmodule Evercraft.Hero do
  import AgentStateMap.Macros
  alias Evercraft.Alignment, as: Alignment
  alias Evercraft.Attack, as: Attack
  alias Evercraft.Abilities, as: Abilities

  def create(name, keywords \\ []) do
    abilities = Keyword.get(keywords, :abilities, %Abilities{})

    Agent.start_link(fn -> %{ :name => name,
                              :alignment => Keyword.get(keywords, :alignment, Alignment.neutral),
                              :hit_points => Keyword.get(keywords, :hit_points, calculate_max_hit_points(abilities)),
                              :abilities => abilities
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
    calculate_max_hit_points(get(pid, :abilities))
  end

  def alive?(pid) do
    hit_points(pid) > 0
  end

  def abilities(pid), do: get pid, :abilities

  def apply_attack(pid, attack) do
    set pid, hit_points: state[:hit_points] - Attack.damage(attack)
  end

  defp calculate_max_hit_points(%Abilities{constitution: constitution}) do
    max(5 + Abilities.modifier(constitution), 1)
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
