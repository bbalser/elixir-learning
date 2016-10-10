defmodule Evercraft.Attack_Test do
  use ExUnit.Case, async: true
  alias Evercraft.Hero, as: Hero
  alias Evercraft.Attack, as: Attack
  alias Evercraft.Abilities, as: Abilities

  describe "a standard attack" do
    setup do
      {:ok, attacker} = Hero.create("attacker")
      {:ok, defender} = Hero.create("defender")
      {:ok, attacker: attacker, defender: defender}
    end

    test "hits when roll is equals to defender's armor class", context do
      assert true == Attack.create(context[:attacker], context[:defender], 10) |> Attack.hit?
    end

    test "does not hit if roll is less than defender's armor class", context do
      assert false == Attack.create(context[:attacker], context[:defender], 9) |> Attack.hit?
    end

    test "hits when roll is greater than defender's armor class", context do
      assert true == Attack.create(context[:attacker], context[:defender], 11) |> Attack.hit?
    end

    test "damages the defender for 1 hit point when successfull", context do
      assert 4 == Attack.create(context[:attacker], context[:defender], 10)
                    |> Attack.defender
                    |> Hero.hit_points
    end

    test "does not damage the defender when it misses", context do
      assert 5 == Attack.create(context[:attacker], context[:defender], 9)
                  |> Attack.defender
                  |> Hero.hit_points
    end

    test "does double damage when it is a critial hit", context do
      assert 3 == Attack.create(context[:attacker], context[:defender], 20)
                  |> Attack.defender
                  |> Hero.hit_points
    end

  end

  describe "a strong attacker" do

    setup do
      {:ok, attacker} = Hero.create("strong attacker", abilities: %Abilities{strength: 12})
      {:ok, defender} = Hero.create("defender")
      {:ok, attacker: attacker, defender: defender}
    end

    test "add strength modifier to attack roll", c do
      assert true == Attack.create(c[:attacker], c[:defender], 9)
                  |> Attack.hit?
    end

    test "add strength modifier to damage done", c do
      assert 2 == Attack.create(c[:attacker], c[:defender], 10)
                  |> Attack.damage
    end

    test "add double strength modifier when it is a critical hit", c do
      assert 4 == Attack.create(c[:attacker], c[:defender], 20)
                  |> Attack.damage
    end

  end

  describe "a weak attacker" do

    test "has a minimum damage of 1 regardless of strength modifier" do
      {:ok, attacker} = Hero.create("attacker", abilities: %Abilities{strength: 5})
      {:ok, defender} = Hero.create("defender")
      assert -3 == Evercraft.Class.Supervisor.damage_bonus(%Attack{attacker: attacker, defender: defender, roll: 20})
      assert 1 == Attack.create(attacker, defender, 20)
                  |> Attack.damage
    end

  end

  describe "an agile defender" do

    test "adds dexterity modifier to armor class" do
      {:ok, attacker} = Hero.create("attacker")
      {:ok, defender} = Hero.create("defender", abilities: %Abilities{dexterity: 12})
      assert false == Attack.create(attacker, defender, 10)
                      |> Attack.hit?
    end

  end


end
