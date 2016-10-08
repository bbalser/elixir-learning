
alias Evercraft.{Abilities, Alignment, Attack}

defmodule Evercraft.Hero do
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

  def armor_class(pid, opts \\ []) do
    dexterity_mod = Abilities.modifier(get(pid, :abilities).dexterity)
    10 + case Keyword.get(opts, :flat_footed, false) do
      false -> dexterity_mod
      true -> min(dexterity_mod, 0)
    end
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
      class == :fighter -> 10
      true -> 5
    end + Abilities.modifier(constitution)
  end

  defp calculate_level(exp) do
    div(exp, 1000) + 1
  end

end

defmodule Evercraft.Hero.Attack do
  alias Evercraft.Hero

  def modifier(attack) do
    [attacker_modifier(attack, determine_attacker_ability(attack)), level(attack)] |> Enum.sum
  end

  def damage(attack) do
    attacker_modifier(attack, :strength)
  end

  defp attacker_modifier(%Attack{attacker: attacker}, modifier) do
    Hero.abilities(attacker) |> Map.get(modifier) |> Abilities.modifier
  end

  defp determine_attacker_ability(%Attack{attacker: attacker}) do
    case Hero.class(attacker) do
      :rogue -> :dexterity
      _ -> :strength
    end
  end

  defp level(%Attack{attacker: attacker}) do
    level = Hero.level(attacker)
    case Hero.class(attacker) do
      :fighter -> level
      _ -> div level, 2
    end
  end

end
