defmodule Rogue_Test do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized
  require Evercraft.Classes
  alias Evercraft.{Hero, Classes, Attack, Abilities}

  describe "a rogue" do
    setup do
      {:ok, rogue} = Hero.create("rogue", class: Classes.rogue)
      {:ok, defender} = Hero.create("defender", abilities: %Abilities{dexterity: 12})
      {:ok, rogue: rogue, defender: defender}
    end

    test "does triple damage on critical hits", c do
      assert 3 == Attack.create(c[:rogue], c[:defender], 20)
                  |> Attack.damage
    end

    test "consideres defender flat footed for all attacks", c do
      assert true == Attack.create(c[:rogue], c[:defender], 10) |> Attack.hit?
    end

  end


end
