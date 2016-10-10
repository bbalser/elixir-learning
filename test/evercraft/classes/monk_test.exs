defmodule Evercraft.Class.Monk_Test do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized
  alias Evercraft.Class

  test "monks get 6 hit points per level" do
    assert 6 == Class.Supervisor.hit_points_per_level(Evercraft.Class.Monk)
  end

end
