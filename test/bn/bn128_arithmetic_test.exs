defmodule BN.BN128ArithmeticTest do
  use ExUnit.Case, async: true

  alias BN.{FQ, FQ2}
  alias BN.BN128Arithmetic

  describe "on_curve?/2" do
    test "returns false if the FQ point is not on the curve" do
      x = FQ.new(5)
      y = FQ.new(6)

      refute BN128Arithmetic.on_curve?({x, y})
    end

    test "returns true if the FQ point is on the curve" do
      x = FQ.new(1)
      y = FQ.new(2)

      assert BN128Arithmetic.on_curve?({x, y})
    end

    test "returns true if the FQ point is infinity" do
      x = FQ.new(0)
      y = FQ.new(0)

      assert BN128Arithmetic.on_curve?({x, y})
    end

    test "returns false if the FQ2 point is not on the curve" do
      x = FQ2.new([5, 1])
      y = FQ2.new([6, 2])

      refute BN128Arithmetic.on_curve?({x, y})
    end

    test "returns true if the FQ2 point is on the curve" do
      x =
        FQ2.new([
          10_857_046_999_023_057_135_944_570_762_232_829_481_370_756_359_578_518_086_990_519_993_285_655_852_781,
          11_559_732_032_986_387_107_991_004_021_392_285_783_925_812_861_821_192_530_917_403_151_452_391_805_634
        ])

      y =
        FQ2.new([
          8_495_653_923_123_431_417_604_973_247_489_272_438_418_190_587_263_600_148_770_280_649_306_958_101_930,
          4_082_367_875_863_433_681_332_203_403_145_435_568_316_851_327_593_401_208_105_741_076_214_120_093_531
        ])

      assert BN128Arithmetic.on_curve?({x, y})
    end

    test "returns true if the FQ2 point is infinity" do
      x = FQ2.new([0, 0])
      y = FQ2.new([0, 0])

      assert BN128Arithmetic.on_curve?({x, y})
    end
  end

  describe "add_points/2" do
    test "fails when point1 is not on the curve" do
      point1 = {FQ.new(10), FQ.new(11)}
      point2 = {FQ.new(10), FQ.new(110)}

      {:error, "point1 is not on the curve"} = BN128Arithmetic.add(point1, point2)
    end

    test "fails when point2 is not on the curve" do
      point1 = {FQ.new(1), FQ.new(2)}
      point2 = {FQ.new(10), FQ.new(110)}

      {:error, "point2 is not on the curve"} = BN128Arithmetic.add(point1, point2)
    end

    test "returns another number when one of the number is infinity" do
      point1 = {FQ.new(1), FQ.new(2)}
      point2 = {FQ.new(0), FQ.new(0)}

      {:ok, result} = BN128Arithmetic.add(point1, point2)

      assert result == point1
    end

    test "doubles number" do
      point = {FQ.new(1), FQ.new(2)}

      {:ok, {x, y}} = BN128Arithmetic.add(point, point)

      assert x.value ==
               1_368_015_179_489_954_701_390_400_359_078_579_693_043_519_447_331_113_978_918_064_868_415_326_638_035

      assert y.value ==
               9_918_110_051_302_171_585_080_402_603_319_702_774_565_515_993_150_576_347_155_970_296_011_118_125_764
    end
  end

  describe "mult/2" do
    test "multiplicates a point on the curve with a scalar when scalar is even" do
      scalar = 32
      point = {FQ.new(1), FQ.new(2)}

      {:ok, {x, y}} = BN128Arithmetic.mult(point, scalar)

      assert x.value ==
               4_873_079_524_557_847_867_653_965_550_062_716_553_062_346_862_158_697_560_012_111_398_864_356_025_363

      assert y.value ==
               11_422_470_166_079_944_859_104_614_283_946_245_081_791_188_387_376_113_119_760_245_565_153_108_742_933
    end

    test "multiplicates a point on the curve with a scalar when scalar is odd" do
      scalar = 129
      point = {FQ.new(1), FQ.new(2)}

      {:ok, {x, y}} = BN128Arithmetic.mult(point, scalar)

      assert x.value ==
               21_647_570_815_953_321_868_971_961_252_431_263_291_150_719_596_283_258_975_644_850_610_841_440_708_605

      assert y.value ==
               653_550_967_422_245_716_267_912_758_477_437_695_534_825_672_172_644_162_691_979_910_407_789_070_686
    end
  end
end
