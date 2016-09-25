defmodule Evercraft.Abilities_Test do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized
  alias Evercraft.Abilities, as: Abilities


  test_with_params "abilities should have a default value of 10",
    fn (score) ->
      assert 10 == score
    end do
      [
        {%Abilities{}.strength},
        {%Abilities{}.dexterity},
        {%Abilities{}.constitution},
        {%Abilities{}.wisdom},
        {%Abilities{}.intelligence},
        {%Abilities{}.charisma}
      ]
  end

  test_with_params "an ability should base the modifier on the score",
    fn (score, modifier) ->
      assert modifier == Abilities.modifier(score)
    end do
      [
        {1, -5},
        {2, -4},
        {3, -4},
        {4, -3},
        {5, -3},
        {6, -2},
        {7, -2},
        {8, -1},
        {9, -1},
        {10, 0},
        {11, 0},
        {12, 1},
        {13, 1},
        {14, 2},
        {15, 2},
        {16, 3},
        {17, 3},
        {18, 4},
        {19, 4},
        {20, 5}
      ]
  end

end
