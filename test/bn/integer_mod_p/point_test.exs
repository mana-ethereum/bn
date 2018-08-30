defmodule BN.IntegerModP.PointTest do
  use ExUnit.Case, async: true

  alias BN.IntegerModP.Point

  describe "new/3" do
    test "create a new point" do
      x = 4
      y = 3
      modulus = 5

      {:ok, point} = Point.new(x, y, modulus: modulus)

      assert point.x.value == 4
      assert point.x.modulus == 5

      assert point.y.value == 3
      assert point.y.modulus == 5

      assert point.modulus == 5
    end

    test "fails if x bigger than modulus" do
      x = 7
      y = 3
      modulus = 5

      {:error, "x is bigger than modulus"} = Point.new(x, y, modulus: modulus)
    end

    test "fails if y bigger than modulus" do
      y = 7
      x = 3
      modulus = 5

      {:error, "y is bigger than modulus"} = Point.new(x, y, modulus: modulus)
    end
  end
end
