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

    test "returns true if the point is infinity" do
      {:ok, point} = Point.new(0, 0)

      assert BN128Arithmetic.on_curve?(point)
    end
  end

  describe "add_points/2" do
    test "fails when point1 is not on the curve" do
      {:ok, point1} = Point.new(10, 11)
      {:ok, point2} = Point.new(10, 110)

      {:error, "point1 is not on the curve"} = BN128Arithmetic.add(point1, point2)
    end

    test "fails when point2 is not on the curve" do
      {:ok, point1} = Point.new(1, 2)
      {:ok, point2} = Point.new(10, 110)

      {:error, "point2 is not on the curve"} = BN128Arithmetic.add(point1, point2)
    end

    test "returns another number when one of the number is infinity" do
      {:ok, point1} = Point.new(1, 2)
      {:ok, point2} = Point.new(0, 0)

      {:ok, result} = BN128Arithmetic.add(point1, point2)

      assert result == point1
    end
  end
end
