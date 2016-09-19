defmodule VendingMachineTest do
  use ExUnit.Case

  setup do
    {:ok, vm} = VendingMachine.new
    {:ok, vm: vm}
  end

  test "vm should display INSERT COIN when no coins are inserted", state do
    assert "INSERT COIN" == VendingMachine.display(state[:vm])
  end

  test "vm display 0.05 after inserting a nickel", state do
    result = state[:vm] |> VendingMachine.insert(:nickel)
                        |> VendingMachine.display
    assert "0.05" == result
  end

  test "vm display 0.10 after inserting a dime", state do
    result = state[:vm] |> VendingMachine.insert(:dime)
                        |> VendingMachine.display
    assert "0.10" == result
  end

  test "vm display 0.25 after inserting a quarter", state do
    result = state[:vm] |> VendingMachine.insert(:quarter)
                        |> VendingMachine.display
    assert "0.25" == result
  end

  test "vm should place rejected coins into coin return", state do
    result = state[:vm] |> VendingMachine.insert(:half_dollar)
                        |> VendingMachine.coin_return
    assert [:half_dollar] == result
  end

  test "vm should dispense cola for 1 dollar", state do
    insert_coins(state[:vm], 4, :quarter)
    assert "1.00" == VendingMachine.display state[:vm]
    assert {:ok, :cola} == VendingMachine.dispense state[:vm], :cola
    assert "THANK YOU" == VendingMachine.display state[:vm]
    assert "INSERT COIN" == VendingMachine.display state[:vm]
  end

  test "vm should dispense chips for 50 cents", state do
    insert_coins(state[:vm], 2, :quarter)
    assert "0.50" == VendingMachine.display state[:vm]
    assert {:ok, :chips} == VendingMachine.dispense state[:vm], :chips
    assert "THANK YOU" == VendingMachine.display state[:vm]
    assert "INSERT COIN" == VendingMachine.display state[:vm]
  end


  defp insert_coins(pid, number, coin) do
    1..number |> Enum.each fn _ -> VendingMachine.insert(pid, coin) end
  end


end
