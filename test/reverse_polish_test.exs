defmodule ReversePolish_Test do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized

  test_with_params "Reverse Polish Notation",
    fn (expr, result) ->
      assert result == ReversePolish.evaluate(expr)
    end do
      [
        {"1 1 +", 2},
        {"2 2 +", 4},
        {"2 3 4 + -", -5},
        {"2 3 *", 6},
        {"6 3 /", 2}
      ]
  end


end
