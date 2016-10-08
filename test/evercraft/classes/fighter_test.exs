defmodule Evercraft.Classes.Fighter_Test do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized
  alias Evercraft.{Attack, Hero}

  test_with_params "a fighter adds 1 to attack modifier for every level",
    fn exp, mod ->
      {:ok, fighter} = Hero.create("Fred", class: :fighter, experience: exp)
      {:ok, defender} = Hero.create("defender")
      assert mod == Hero.Attack.modifier(%Attack{attacker: fighter, defender: defender, roll: 10})
    end do
      [
        {0, 1},
        {1000, 2},
        {2000, 3},
        {3000, 4},
        {4000, 5},
        {5000, 6}
      ]
  end

  test_with_params "a fighter gains 10 hit points per level",
    fn exp, hp ->
      {:ok, fighter} = Hero.create("fighter", experience: exp, class: :fighter)
      assert hp == Hero.hit_points(fighter)
    end do
      for x <- (1..20), into: [] do
        {(x-1)*1000, x*10}
      end
  end

end
