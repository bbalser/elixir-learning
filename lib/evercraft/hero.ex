
alias Evercraft.{Abilities, Alignment, Attack, Class}

defmodule Evercraft.Hero do
  require Evercraft.Alignment

  def create(name, keywords \\ []) do
    abilities = Keyword.get(keywords, :abilities, %Abilities{})
    exp = Keyword.get(keywords, :experience, 0)
    class = Keyword.get(keywords, :class, nil) |> Class.Supervisor.ref

    Agent.start_link(fn -> %{ :name => name,
                              :alignment => Keyword.get(keywords, :alignment, Alignment.neutral),
                              :hit_points => Keyword.get(keywords, :hit_points, calculate_max_hit_points(exp, class, abilities)),
                              :abilities => abilities,
                              :experience => exp,
                              :class => class
                            } end)
  end

  def name(pid) do
    Agent.get(pid, fn state -> state.name end)
  end

  def alignment(pid) do
    Agent.get(pid, fn state -> state.alignment end)
  end

  def armor_class(pid, opts \\ []) do
    Agent.get(pid, fn state -> 
      dexterity_mod = Abilities.modifier(state.abilities.dexterity)
      10 + case Keyword.get(opts, :flat_footed, false) do
        false -> dexterity_mod
        true -> min(dexterity_mod, 0)
      end
    end)
  end

  def hit_points(pid) do
    Agent.get(pid, fn state -> state.hit_points end)
  end

  def max_hit_points(pid) do
    Agent.get(pid, fn %{experience: experience, class: class, abilities: abilities} ->
      calculate_max_hit_points(experience, class, abilities)
    end)
  end

  def level(pid) do
    Agent.get(pid, fn state ->
      calculate_level(state.experience)
    end)
  end

  def class(pid) do
    Agent.get(pid, fn state -> state.class end)
  end

  def alive?(pid) do
    hit_points(pid) > 0
  end

  def abilities(pid), do: Agent.get(pid, fn state -> state.abilities end) 

  def apply_attack(pid, attack) do
    Agent.update(pid, fn state ->
      %{ state | hit_points: state.hit_points - Attack.damage(attack) }
    end)
  end

  defp calculate_max_hit_points(exp, class, abilities) do
    level = calculate_level(exp)
    hp_per_level = Class.Supervisor.hit_points_per_level(class) + Abilities.modifier(abilities.constitution)
    (level * hp_per_level) |> max(1)
  end

  defp calculate_level(exp) do
    div(exp, 1000) + 1
  end

end
