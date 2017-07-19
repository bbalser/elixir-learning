defmodule VendingMachine.Impl do

  alias VendingMachine.State

  @products %{:cola => 100, :chips => 50, :candy => 65}
  @coins %{:nickel => 5, :dime => 10, :quarter => 25}

  def new(), do: %State{}

  def display(state = %State{message: message, total: total}) do
    cond do
      message -> { message, %State{ state | message: nil } }
      total == 0 -> { "INSERT COIN", state }
      true -> { to_string(:io_lib.format("~.2f", [total / 100])), state }
    end
  end

  def insert(state = %State{}, coin) do
    attempt_to_insert_coin(state, coin, Map.has_key?(@coins, coin))
  end

  defp attempt_to_insert_coin(state, coin, _valid_coin = true) do
    %State{ state | total: state.total + @coins[coin] }
  end

  defp attempt_to_insert_coin(state, coin, _not_valid) do
    %State{ state | return: [coin | state.return] }
  end

  def coin_return(state = %State{}) do
    { state.return, %State{ state | return: [] } }
  end

  def dispense(state = %State{}, product) do
    attempt_dispense(state, @products[product], product)
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
