defmodule VendingMachineTest do
  use ExUnit.Case

  setup do
    {:ok, vm} = VendingMachine.new
    {:ok, vm: vm}
  end

  test "vm should display INSERT COIN when no coins are inserted", context do
    assert "INSERT COIN" == VendingMachine.display(context[:vm])
  end

  test "vm display 0.05 after inserting a nickel", context do
    result = context[:vm] |> VendingMachine.insert(:nickel)
                        |> VendingMachine.display
    assert "0.05" == result
  end

  test "vm display 0.10 after inserting a dime", context do
    result = context[:vm] |> VendingMachine.insert(:dime)
                        |> VendingMachine.display
    assert "0.10" == result
  end

  test "vm display 0.25 after inserting a quarter", context do
    result = context[:vm] |> VendingMachine.insert(:quarter)
                        |> VendingMachine.display
    assert "0.25" == result
  end

  test "vm should place rejected coins into coin return", context do
    result = context[:vm] |> VendingMachine.insert(:half_dollar)
                        |> VendingMachine.coin_return
    assert [:half_dollar] == result
  end

  test "vm should dispense cola for 1 dollar", context do
    insert_coins(context[:vm], 4, :quarter)
    assert "1.00" == VendingMachine.display context[:vm]
    assert :cola == VendingMachine.dispense context[:vm], :cola
    assert "THANK YOU" == VendingMachine.display context[:vm]
    assert "INSERT COIN" == VendingMachine.display context[:vm]
  end

  test "vm should dispense chips for 50 cents", context do
    insert_coins(context[:vm], 2, :quarter)
    assert "0.50" == VendingMachine.display context[:vm]
    assert :chips == VendingMachine.dispense context[:vm], :chips
    assert "THANK YOU" == VendingMachine.display context[:vm]
    assert "INSERT COIN" == VendingMachine.display context[:vm]
  end

  test "vm should dispense candy for 65 cents", context do
    insert_coins(context[:vm], 13, :nickel)
    assert "0.65" == VendingMachine.display context[:vm]
    assert :candy == VendingMachine.dispense context[:vm], :candy
    assert "THANK YOU" == VendingMachine.display context[:vm]
    assert "INSERT COIN" == VendingMachine.display context[:vm]
  end

  test "vm should dispense product and deduct price from total in machine", context do
    insert_coins(context[:vm], 4, :quarter)
    assert :candy == VendingMachine.dispense context[:vm], :candy
    assert "THANK YOU" == VendingMachine.display context[:vm]
    assert "0.35" == VendingMachine.display context[:vm]
  end

  test "vm should display price and cost of product when not enough money entered", context do
    insert_coins(context[:vm], 3, :quarter)
    assert nil == VendingMachine.dispense context[:vm], :cola
    assert "PRICE: 1.00" == VendingMachine.display context[:vm]
    assert "0.75" == VendingMachine.display context[:vm]
  end

  test "vm should put change in coin return when more money than necessary was inserted into machine", context do
    insert_coins(context[:vm], 4, :quarter)
    assert :candy == VendingMachine.dispense context[:vm], :candy
    assert [:quarter, :dime] == VendingMachine.coin_return context[:vm] 
  end

  defp insert_coins(pid, number, coin) do
    1..number |> Enum.each fn _ -> VendingMachine.insert(pid, coin) end
  end


end
