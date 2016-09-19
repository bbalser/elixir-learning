defmodule VendingMachine do

  defmacro set(pid, keywords) do
    quote do
      Agent.update(unquote(pid), fn var!(state) ->
        Map.merge(var!(state), Enum.into(unquote(keywords), %{}))
      end)
    end
  end

  defmacro get(atom) do
    quote do
      var!(state)[unquote(atom)]
    end
  end

  defmacro get(pid, atom) do
    quote do
      Agent.get(unquote(pid), fn state -> state[unquote(atom)] end)
    end
  end

  def new() do
    Agent.start_link(fn -> %{:total => 0, :return => [], :dispensed => false} end, name: __MODULE__)
  end

  def display(pid) do
    cond do
      get(pid, :dispensed) ->
        set pid, dispensed: false
        "THANK YOU"
      get(pid, :total) == 0 -> "INSERT COIN"
      true -> to_string(:io_lib.format("~.2f", [get(pid, :total) / 100]))
    end
  end

  def insert(pid, coin) when coin in [:nickel, :dime, :quarter] do
    set pid, total: get(:total) + value(coin)
    pid
  end

  def insert(pid, coin) do
    set pid, return: [coin | get(:return)]
    pid
  end

  def coin_return(pid) do
    return = get(pid, :return)
    set pid, return: []
    return
  end

  def dispense(pid, :cola) do
    set pid, dispensed: true, total: get(:total) - 100
    {:ok, :cola}
  end

  def dispense(pid, :chips) do
    set pid, dispensed: true, total: get(:total) - 50
    {:ok, :chips}
  end

  def close(pid) do
    Agent.stop pid
  end

  defp value(:nickel), do: 5
  defp value(:dime), do: 10
  defp value(:quarter), do: 25

end
