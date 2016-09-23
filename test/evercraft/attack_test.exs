defmodule Evercraft.Attack_Test do
  use ExUnit.Case, async: true
  alias Evercraft.Hero, as: Hero
  alias Evercraft.Attack, as: Attack

  setup do
    {:ok, attacker} = Hero.create("attacker")
    {:ok, defender} = Hero.create("defender")
    {:ok, attacker: attacker, defender: defender}
  end

  test "an attack hits when roll is equals to defender's armor class", context do
    assert true == Attack.create(context[:attacker], context[:defender], 10) |> Attack.hit?
  end

  test "an attack does not hit if roll is less than defender's armor class", context do
    assert false == Attack.create(context[:attacker], context[:defender], 9) |> Attack.hit?
  end

  test "an attack hits when roll is greater than defender's armor class", context do
    assert true == Attack.create(context[:attacker], context[:defender], 11) |> Attack.hit?
  end

  test "an attack damages the defender for 1 hit point when successfull", context do
    assert 4 == Attack.create(context[:attacker], context[:defender], 10)
                  |> Attack.defender
                  |> Hero.hit_points
  end

  test "an attack does not damage the defender when it misses", context do
    assert 5 == Attack.create(context[:attacker], context[:defender], 9)
                |> Attack.defender
                |> Hero.hit_points
  end

  test "an attack does double damage when it is a critial hit", context do
    assert 3 == Attack.create(context[:attacker], context[:defender], 20)
                |> Attack.defender
                |> Hero.hit_points
  end




end
