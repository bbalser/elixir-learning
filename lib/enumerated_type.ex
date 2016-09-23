defmodule EnumeratedType do

  defmacro __using__(list) do
    quote bind_quoted: [list: list] do
      import EnumeratedType

      def values(), do: unquote(list)
      def valid?(x), do: x in unquote(list)

      for name <- list do
        funname = String.to_atom("#{name}")
        def unquote(funname)(), do: unquote(name)
      end
    end
  end

end
