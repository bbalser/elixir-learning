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

      def handle_call({:attack_bonus, %Attack{attacker: attacker} = attack}, _from, state) do
        bonus = cond do
          Hero.class(attacker) == identifier() -> attack_bonus(attack)
          true -> 0
        end
        {:reply, bonus, state}
      end

      def attack_bonus(%Attack{} = attack) do
        attack_bonus_from_abilities(attack) + attack_bonus_from_level(attack)
      end

      defp attack_bonus_from_abilities(%Attack{attacker: attacker}) do
        Hero.abilities(attacker).strength |> Abilities.modifier
      end

      defp attack_bonus_from_level(%Attack{attacker: attacker}) do
        div Hero.level(attacker), 2
      end

      defoverridable [attack_bonus: 1,
                      attack_bonus_from_abilities: 1,
                      attack_bonus_from_level: 1]
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
    @children
      |> Enum.map(fn proc -> Task.async(fn -> GenServer.call(proc, {:attack_bonus, attack}) end) end)
      |> Enum.map(fn task -> Task.await(task) end)
      |> Enum.sum
  end

end
