defmodule VendingMachine do
  import AgentStateMap.Macros

  @products %{:cola => 100, :chips => 50, :candy => 65}
  @coins %{:nickel => 5, :dime => 10, :quarter => 25}

  def new() do
    Agent.start_link(fn -> %{:total => 0, :return => [], :message => nil } end, name: __MODULE__)
  end

  def display(pid) do
    {message, total} = get pid, {:message, :total}
    cond do
      message ->
        set pid, message: nil
        message
      total == 0 -> "INSERT COIN"
      true -> to_string(:io_lib.format("~.2f", [total / 100]))
    end
  end

  def insert(pid, coin) do
    cond do
      Map.has_key?(@coins, coin) -> set pid, total: state[:total] + @coins[coin]
      true -> set pid, return: [coin | state[:return]]
    end
    pid
  end

  def coin_return(pid) do
    get_and_set(pid, return: []) |> elem(0)
  end

  def dispense(pid, product) do
    cond do
      get(pid, :total) >= @products[product] ->
        Agent.update pid, fn state ->
          newtotal = state[:total] - @products[product]
          Map.merge(state, %{:total => newtotal, message: "THANK YOU", return: determine_change(newtotal)})
        end
        product
      true ->
        set pid, message: to_string(:io_lib.format("PRICE: ~.2f", [@products[product] / 100]))
        nil
    end
  end

  def close(pid) do
    Agent.stop pid
  end

  defp determine_change(amount) do
    coins = @coins |> Enum.sort(fn a,b -> elem(b, 1) < elem(a, 1) end)
    determine_change(amount, coins, [])
  end

  defp determine_change(_, [], result), do: result
  defp determine_change(amount, [{coin, value} | tail], result) do
    coins = List.duplicate(coin, div(amount, value))
    determine_change(rem(amount,value), tail, result ++ coins)
  end

end
