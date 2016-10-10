alias Evercraft.{Hero, Abilities, Attack}

defmodule Evercraft.Class do

  @callback attack_bonus(%Attack{}) :: integer
  @callback identifier() :: atom

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Evercraft.Class
      use GenServer

      def start_link() do
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
      end

      def handle_call({:hit_points_per_level, class}, _from, state) do
        hp_per_level = cond do
          class == identifier() -> {:ok, hit_points_per_level}
          true -> {:notapplicable, 0}
        end
        {:reply, hp_per_level, state}
      end

      def handle_call({method, %Attack{attacker: attacker} = attack}, _from, state) do
        bonus = cond do
          Hero.class(attacker) == identifier() -> {:ok, apply(__MODULE__, method, [attack])}
          true -> {:notapplicable, 0}
        end
        {:reply, bonus, state}
      end

      def attack_bonus(%Attack{} = attack) do
        attack_bonus_from_abilities(attack) + attack_bonus_from_level(attack)
      end

      def damage_bonus(%Attack{} = attack) do
        damage_bonus_from_abilities(attack)
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

      def hit_points_per_level do
        5
      end

      defoverridable [attack_bonus: 1,
                      attack_bonus_from_abilities: 1,
                      attack_bonus_from_level: 1,
                      damage_bonus: 1,
                      damage_bonus_from_abilities: 1,
                      hit_points_per_level: 0]
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

end

defmodule Evercraft.Class.Supervisor do
  use Supervisor
  @children [Evercraft.Class.NoClass, Evercraft.Class.Fighter, Evercraft.Class.Rogue]

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = @children |> Enum.map(fn child -> worker(child, []) end)

    supervise(children, strategy: :one_for_one)
  end

  def attack_bonus(%Attack{} = attack) do
    call_all({:attack_bonus, attack})
  end

  def damage_bonus(%Attack{} = attack) do
    call_all({:damage_bonus, attack})
  end

  def hit_points_per_level(class) do
    call_all({:hit_points_per_level, class})
  end

  defp call_all(message) do
    @children
      |> Enum.map(&Task.async(fn -> GenServer.call(&1, message) end))
      |> Enum.map(&Task.await/1)
      |> Enum.filter(fn {result, _} -> result == :ok end)
      |> Enum.map(fn {:ok, value} -> value end)
      |> Enum.sum
  end

end
