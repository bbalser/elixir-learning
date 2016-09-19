defmodule StateMapMacros do

    defmacro set(pid, keywords) do
      quote do
        Agent.update(unquote(pid), fn var!(state) ->
          Map.merge(var!(state), Enum.into(unquote(keywords), %{}))
        end)
      end
    end

    defmacro get(pid, :all) do
      quote do
        Agent.get(unquote(pid), fn state -> state end)
      end
    end

    defmacro get(pid, tuple) when is_tuple(tuple) do
      quote do
        list = Tuple.to_list(unquote(tuple))
        Agent.get(unquote(pid), fn state ->
          list |> Enum.map(fn atom -> state[atom] end) |> List.to_tuple
        end)
      end
    end

    defmacro get(pid, list) when is_list(list) do
      quote do
          Agent.get(unquote(pid), fn state ->
            unquote(list) |> Enum.map(fn atom -> state[atom] end)
          end)
      end
    end

    defmacro get(pid, atom) do
      quote do
        Agent.get(unquote(pid), fn state -> state[unquote(atom)] end)
      end
    end

end
