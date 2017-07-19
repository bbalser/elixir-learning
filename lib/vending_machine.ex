defmodule VendingMachine do
  alias VendingMachine.State

  @products %{:cola => 100, :chips => 50, :candy => 65}
  @coins %{:nickel => 5, :dime => 10, :quarter => 25}

  def new() do
    Agent.start_link(fn -> %State{} end)
  end

  def display(pid) do
    Agent.get_and_update(pid, fn state ->
      cond do
        state.message -> { state.message, %State{ state | message: nil } }
        state.total == 0 -> { "INSERT COIN", state }
        true -> { to_string(:io_lib.format("~.2f", [state.total / 100])), state }
      end
    end)
  end

  def insert(pid, coin) do
    Agent.update(pid, fn state ->
      attempt_to_insert_coin(state, coin, Map.has_key?(@coins, coin))
    end)
    pid
  end

  defp attempt_to_insert_coin(state, coin, _valid_coin = true) do
    %State{ state | total: state.total + @coins[coin] }
  end

  defp attempt_to_insert_coin(state, coin, _not_valid) do
    %State{ state | return: [coin | state.return] }
  end

  def coin_return(pid) do
    Agent.get_and_update(pid, fn state ->
      { state.return, %State{ state | return: [] } }
    end)
  end

  def dispense(pid, product) do
    Agent.get_and_update(pid, fn state ->
      attempt_dispense(state, @products[product], product)
   end)
  end

  defp attempt_dispense(state = %State{ total: total}, cost, product) when total >= cost do
    new_total = total - cost
    { product, %State{ state | total: new_total, 
                               message: "THANK YOU", 
                               return: determine_change(new_total) } }
  end

  defp attempt_dispense(state, cost, _product) do
    { nil, %State{ state | message: to_string(:io_lib.format("PRICE: ~.2f", [cost / 100])) } }
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
