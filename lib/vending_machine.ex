defmodule VendingMachine do
  alias VendingMachine.Impl

  def new() do
    Agent.start_link(fn -> Impl.new() end)
  end

  def display(pid) do
    Agent.get_and_update(pid, fn state -> Impl.display(state) end)
  end

  def insert(pid, coin) do
    Agent.update(pid, fn state -> Impl.insert(state, coin) end)
    pid
  end

  def coin_return(pid) do
    Agent.get_and_update(pid, fn state -> Impl.coin_return(state) end)
  end

  def dispense(pid, product) do
    Agent.get_and_update(pid, fn state -> Impl.dispense(state, product) end)
  end

  def close(pid) do
    Agent.stop pid
  end

end
