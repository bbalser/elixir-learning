defmodule Evercraft.Hero_Test do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized
  alias Evercraft.Hero, as: Hero
  alias Evercraft.Alignment, as: Alignment
  alias Evercraft.Attack, as: Attack
  alias Evercraft.Abilities, as: Abilities

  test "a hero should have a name" do
    assert "John" == Hero.create("John") |> elem(1) |> Hero.name
  end

  test "a hero has a default alignment of neutral" do
    assert Alignment.neutral == Hero.create("x") |> elem(1) |> Hero.alignment
  end

  test "a hero can be good" do
    assert Alignment.good == Hero.create("x", alignment: Alignment.good) |> elem(1) |> Hero.alignment
  end

  test "a hero has a default armor_class of 10" do
    assert 10 == Hero.create("x") |> elem(1) |> Hero.armor_class
  end

  test "a hero has 5 hit points by default" do
    assert 5 == Hero.create("x") |> elem(1) |> Hero.hit_points
  end

  test "a hero is alive while hit_points are greater than 1" do
    {:ok, defender} = Hero.create("x")
    for _ <- 1..4 do Attack.create(elem(Hero.create("attacker"),1), defender, 10) end
    assert 1 == Hero.hit_points(defender)
    assert true == Hero.alive?(defender)
  end

  test "a hero is not alive when hit_points are less than 1" do
    {:ok, defender} = Hero.create("x")
    for _ <- 1..5 do Attack.create(elem(Hero.create("attacker"),1), defender, 10) end
    assert 0 == Hero.hit_points(defender)
    assert false == Hero.alive?(defender)
  end

  test_with_params "a hero has abilities that all default to 10",
    fn  ability ->
      {:ok, hero} = Hero.create("name")
      assert 10 == Hero.abilities(hero) |> Map.get(ability, nil)
    end do
      [{:strength}, {:dexterity}, {:constitution}, {:wisdom}, {:intelligence}, {:charisma}]
  end

  test "a hero can be createion with custom abilities" do
    {:ok, hero} = Hero.create("name", abilities: %Abilities{dexterity: 12})
    assert 12 == Hero.abilities(hero).dexterity
  end

  test "a hearty hero adds his constitution modifier to his hit_points" do
    {:ok, hero} = Hero.create("name", abilities: %Abilities{constitution: 12})
    assert 6 == Hero.hit_points(hero)
  end

  test "a sickly hero always has a leat one hit_point" do
    {:ok, hero} = Hero.create("name", abilities: %Abilities{constitution: 1})
    assert 1 == Hero.hit_points(hero)
  end

end
