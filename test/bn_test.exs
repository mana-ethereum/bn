defmodule BnTest do
  use ExUnit.Case
  doctest Bn

  test "greets the world" do
    assert Bn.hello() == :world
  end
end
