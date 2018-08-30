defmodule BN.BN128ArithmeticTest do
  use ExUnit.Case, async: true

  alias BN.IntegerModP.Point
  alias BN.BN128Arithmetic

  describe "on_curve?/2" do
    test "returns false if the point is not on the curve" do
      {:ok, point} = Point.new(5, 6)

      refute BN128Arithmetic.on_curve?(point)
    end

    test "returns true if the point is on the curve" do
      {:ok, point} = Point.new(1, 2)

      assert BN128Arithmetic.on_curve?(point)
    end
  end
end
