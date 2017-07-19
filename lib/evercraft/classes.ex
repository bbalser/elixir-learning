alias Evercraft.{Hero, Abilities, Attack}

defmodule Evercraft.Class do

  @callback attack_bonus(%Attack{}) :: integer
  @callback damage_bonus(%Attack{}) :: integer
  @callback critical_multiplier(%Attack{}) :: integer
  @callback hit_points_per_level() :: integer
  @callback identifier() :: atom

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Evercraft.Class
      use GenServer

      def start_link() do
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
      end

      def handle_call({method, %Attack{attacker: attacker} = attack}, _from, state) do
        {:reply, apply(__MODULE__, method, [attack]), state}
      end

      def handle_call(method, _from, state) do
        {:reply, apply(__MODULE__, method, []), state}
      end

      def attack_bonus(%Attack{} = attack) do
        attack_bonus_from_abilities(attack) + attack_bonus_from_level(attack)
      end

      def damage_bonus(%Attack{} = attack) do
        base_damage() + damage_bonus_from_abilities(attack)
      end

      def critical_multiplier(%Attack{} = attack) do
        2
      end

      defp attack_bonus_from_abilities(%Attack{attacker: attacker}) do
        Hero.abilities(attacker).strength |> Abilities.modifier
      end

      defp attack_bonus_from_level(%Attack{attacker: attacker}) do
        div Hero.level(attacker), 2
      end

      defp damage_bonus_from_abilities(%Attack{attacker: attacker}) do
        Hero.abilities(attacker).strength |> Abilities.modifier
      end

      defp base_damage(), do: 1

      def hit_points_per_level(), do: 5

      defoverridable [attack_bonus: 1,
                      attack_bonus_from_abilities: 1,
                      attack_bonus_from_level: 1,
                      damage_bonus: 1,
                      damage_bonus_from_abilities: 1,
                      base_damage: 0,
                      hit_points_per_level: 0,
                      critical_multiplier: 1]
    end
  end
end

defmodule Evercraft.Class.NoClass do
  use Evercraft.Class

  def identifier, do: nil

end

defmodule Evercraft.Class.Fighter do
  use Evercraft.Class

  def identifier, do: :fighter

  defp attack_bonus_from_level(%Attack{attacker: attacker}) do
    Hero.level(attacker)
  end

  def hit_points_per_level do
    10
  end

end

defmodule Evercraft.Class.Rogue do
  use Evercraft.Class

  def identifier, do: :rogue

  defp attack_bonus_from_abilities(%Attack{attacker: attacker}) do
      Hero.abilities(attacker).dexterity |> Abilities.modifier
  end

  def critical_multiplier(%Attack{} = _attack) do
    3
  end

end

defmodule Evercraft.Class.Monk do
  use Evercraft.Class

  def identifier, do: :monk

  def hit_points_per_level do
    6
  end

  defp base_damage, do: 3

end

defmodule Evercraft.Class.Supervisor do
  use Supervisor
  @children %{noclass: Evercraft.Class.NoClass,
              fighter: Evercraft.Class.Fighter,
              rogue: Evercraft.Class.Rogue,
              monk: Evercraft.Class.Monk}

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = @children |> Enum.map(fn {_name, child} -> worker(child, []) end)
    supervise(children, strategy: :one_for_one)
  end

  def attack_bonus(%Attack{attacker: attacker} = attack) do
    Hero.class(attacker) |> GenServer.call({:attack_bonus, attack})
  end

  def damage_bonus(%Attack{attacker: attacker} = attack) do
    Hero.class(attacker) |> GenServer.call({:damage_bonus, attack})
  end

  def hit_points_per_level(class) do
    GenServer.call(class, :hit_points_per_level)
  end

  def critical_multiplier(%Attack{attacker: attacker} = attack) do
    Hero.class(attacker) |> GenServer.call({:critical_multiplier, attack})
  end

  def ref(class_atom) when is_atom(class_atom) do
    case class_atom do
      nil -> @children[:noclass]
      _ -> @children[class_atom]
    end
  end

end
