defmodule AgentStateMap.Macros do

    defmacro set(pid, keywords) do
      quote do
        Agent.update(unquote(pid), fn var!(state) ->
          Map.merge(var!(state), Enum.into(unquote(keywords), %{}))
        end)
      end
    end

    defmacro get_and_set(pid, tuple, keywords) when is_tuple(tuple) do
      quote do
        Agent.get_and_update(unquote(pid), fn var!(state) ->
          get_and_set_from_tuple(var!(state), unquote(tuple), unquote(keywords))
        end)
      end
    end

    defmacro get_and_set(pid, keywords) do
      quote do
        keyword_tuple = Keyword.keys(unquote(keywords)) |> List.to_tuple
        Agent.get_and_update(unquote(pid), fn var!(state) ->
          get_and_set_from_tuple(var!(state), keyword_tuple, unquote(keywords))
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

    defmacro get(pid, atom) do
      quote do
        Agent.get(unquote(pid), fn state -> state[unquote(atom)] end)
      end
    end

    def get_and_set_from_tuple(state, get_tuple, set_keywords) do
      new_state = Map.merge(state, Enum.into(set_keywords, %{}))
      return_list = Tuple.to_list(get_tuple)
                    |> Enum.map fn field ->
                        cond do
                          set_keywords[:_returnNew] -> new_state[field]
                          true -> state[field]
                        end
                      end
      {List.to_tuple(return_list), new_state}
    end

    defmacro attr_reader(list) when is_list(list) do
      name = Enum.join(list, "_and_")
      getter = String.to_atom("get_#{name}")
      quote do
        def unquote(getter)(pid) do
          Agent.get(pid, fn state ->
            unquote(list) |> Enum.map(fn key -> state[key] end)
                           |> List.to_tuple
          end)
        end
      end
    end

    defmacro attr_reader(atom) do
      getter = String.to_atom("get_#{atom}")
      quote do
        def unquote(getter)(pid) do
          Agent.get(pid, &(&1[unquote(atom)]))
        end
      end
    end

    defmacro attr_accessor(atom) do
      getter = String.to_atom("get_#{atom}")
      setter = String.to_atom("set_#{atom}")
      quote do
        def unquote(getter)(pid) do
          Agent.get(pid, &(&1[unquote(atom)]))
        end
        def unquote(setter)(pid, value) do
          Agent.update(pid, fn state ->
            Map.merge(state, %{unquote(atom) => value})
          end)
        end
      end
    end

end
