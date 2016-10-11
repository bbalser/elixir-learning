defmodule Evercraft.Class.Monk_Test do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized
  alias Evercraft.{Hero, Class, Attack}

  test "monks get 6 hit points per level" do
    assert 6 == Class.Supervisor.hit_points_per_level(Evercraft.Class.Monk)
  end

  test "monks get a base damage of 3" do
    {:ok, monk} = Hero.create("monk", class: :monk)
    {:ok, defender} = Hero.create("defender")
    attack = Attack.create(monk, defender, 10)
    assert 3 == Class.Supervisor.damage_bonus(attack)
  end

end
