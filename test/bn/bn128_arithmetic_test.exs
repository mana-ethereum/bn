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

    test "doubles number" do
      {:ok, point} = Point.new(1, 2)

      {:ok,
       %BN.IntegerModP.Point{
         modulus:
           21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_583,
         x: %BN.IntegerModP{
           modulus:
             21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_583,
           value:
             1_368_015_179_489_954_701_390_400_359_078_579_693_043_519_447_331_113_978_918_064_868_415_326_638_035
         },
         y: %BN.IntegerModP{
           modulus:
             21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_583,
           value:
             9_918_110_051_302_171_585_080_402_603_319_702_774_565_515_993_150_576_347_155_970_296_011_118_125_764
         }
       }} = BN128Arithmetic.add(point, point)
    end
  end

  describe "mult/2" do
    test "multiplicates a point on the curve with a scalar when scalar is even" do
      scalar = 32
      {:ok, point} = Point.new(1, 2)

      {:ok,
       %BN.IntegerModP.Point{
         modulus:
           21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_583,
         x: %BN.IntegerModP{
           modulus:
             21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_583,
           value:
             4_873_079_524_557_847_867_653_965_550_062_716_553_062_346_862_158_697_560_012_111_398_864_356_025_363
         },
         y: %BN.IntegerModP{
           modulus:
             21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_583,
           value:
             11_422_470_166_079_944_859_104_614_283_946_245_081_791_188_387_376_113_119_760_245_565_153_108_742_933
         }
       }} = BN128Arithmetic.mult(point, scalar)
    end

    test "multiplicates a point on the curve with a scalar when scalar is odd" do
      scalar = 129
      {:ok, point} = Point.new(1, 2)

      {:ok,
       %BN.IntegerModP.Point{
         modulus:
           21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_583,
         x: %BN.IntegerModP{
           modulus:
             21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_583,
           value:
             21_647_570_815_953_321_868_971_961_252_431_263_291_150_719_596_283_258_975_644_850_610_841_440_708_605
         },
         y: %BN.IntegerModP{
           modulus:
             21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_583,
           value:
             653_550_967_422_245_716_267_912_758_477_437_695_534_825_672_172_644_162_691_979_910_407_789_070_686
         }
       }} = BN128Arithmetic.mult(point, scalar)
    end
  end
end
