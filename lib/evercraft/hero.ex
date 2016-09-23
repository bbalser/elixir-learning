defmodule Evercraft.Hero do
  import AgentStateMap.Macros
  alias Evercraft.Alignment, as: Alignment
  alias Evercraft.Attack, as: Attack

  def create(name, keywords \\ []) do
    Agent.start_link(fn -> %{ :name => name,
                              :alignment => Keyword.get(keywords, :alignment, Alignment.neutral),
                              :hit_points => 5
                            } end)
  end

  def name(pid) do
    get pid, :name
  end

  def alignment(pid) do
    get pid, :alignment
  end

  def armor_class(pid) do
    10
  end

  def hit_points(pid) do
    get pid, :hit_points
  end

  def alive?(pid) do
    hit_points(pid) > 0
  end

  def apply_attack(pid, attack) do
    set pid, hit_points: state[:hit_points] - Attack.damage(attack)
  end

end
