defmodule VendingMachine do
  import StateMapMacros

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
    return = get(pid, :return)
    set pid, return: []
    return
  end

  def dispense(pid, product) do
    cond do
      get(pid, :total) >= @products[product] ->
        set pid, message: "THANK YOU", total: state[:total] - @products[product]
        product
      true ->
        set pid, message: to_string(:io_lib.format("PRICE: ~.2f", [@products[product] / 100]))
        nil
    end
  end

  def close(pid) do
    Agent.stop pid
  end

end
