alias Evercraft.{Hero, Abilities, Attack}

defmodule Evercraft.Classes do
  use EnumeratedType, [:fighter, :rogue]
  @modules %{fighter: Evercraft.Classes.Fighter, rogue: Evercraft.Classes.Rogue}

  def attack_modifier(attack) do
    %{} |> Evercraft.Classes.Base.attack_modifier_rules
        |> apply_class_module_rules(attack)
        |> Enum.map(fn {_key, fun} -> fun.(attack) end)
        |> Enum.sum
  end

  defp apply_class_module_rules(rules, attack) do
    if (Map.has_key?(@modules, Hero.class(attack.attacker))) do
      :erlang.apply @modules[Hero.class(attack.attacker)], :attack_modifier_rules, [rules]
    else
      rules
    end
  end

end

defmodule Evercraft.Classes.Base do

  def attack_modifier_rules(map) do
    Map.merge(map, %{ability_modifier: fn %Attack{attacker: attacker} -> Hero.abilities(attacker).strength |> Abilities.modifier end,
                      level: fn %Attack{attacker: attacker} -> div Hero.level(attacker), 2 end})
  end

end

defmodule Evercraft.Classes.Fighter do

  def attack_modifier_rules(map) do
    Map.put(map, :level, fn %Attack{attacker: attacker} -> Hero.level(attacker) end)
  end

end

defmodule Evercraft.Classes.Rogue do

  def attack_modifier_rules(map) do
    Map.put(map, :ability_modifier, fn %Attack{attacker: attacker} -> Hero.abilities(attacker).strength |> Abilities.modifier end)
  end

end
