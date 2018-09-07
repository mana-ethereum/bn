defmodule BN.FQ2Test do
  use ExUnit.Case, async: true

  alias BN.{FQP, FQ2, FQ}

  describe "new/1" do
    test "creates new fq2" do
      fq2 = FQ2.new([99, 121])

      expected_result = %FQP{
        coef: [
          %BN.FQ{
            modulus:
              21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_583,
            value: 99
          },
          %BN.FQ{
            modulus:
              21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_583,
            value: 121
          }
        ],
        dim: 2,
        modulus_coef: [1, 0]
      }

      assert fq2 == expected_result
    end
  end

  describe "add/2" do
    test "adds two elements" do
      fq2_1 = FQ2.new([75, 898])
      fq2_2 = FQ2.new([981, 121])

      result = FQ2.add(fq2_1, fq2_2)

      fq2_1.coef
      |> Enum.zip(fq2_2.coef)
      |> Enum.zip(result.coef)
      |> Enum.each(fn {{coef1, coef2}, expected_coef} ->
        assert expected_coef.value == coef1.value + coef2.value
      end)
    end
  end

  describe "substact/2" do
    test "substacts two elements" do
      fq2_1 = FQ2.new([75, 898])
      fq2_2 = FQ2.new([981, 121])

      result = FQ2.sub(fq2_1, fq2_2)

      fq2_1.coef
      |> Enum.zip(fq2_2.coef)
      |> Enum.zip(result.coef)
      |> Enum.each(fn {{coef1, coef2}, expected_coef} ->
        assert expected_coef.value == FQ.sub(coef1, coef2).value
      end)
    end
  end

  describe "mult/2" do
    test "multiplies two elements" do
      fq2_1 = FQ2.new([75, 898])
      fq2_2 = FQ2.new([981, 121])

      result = FQ2.mult(fq2_1, fq2_2)

      expected_coef = [
        21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_173_500,
        890_013
      ]

      result.coef
      |> Enum.zip(expected_coef)
      |> Enum.each(fn {coef, expected} ->
        coef.value == expected
      end)
    end
  end

  describe "divide/2" do
    test "divides two elements" do
      fq2_1 = FQ2.new([75, 898])
      fq2_2 = FQ2.new([981, 121])

      result = FQ2.divide(fq2_1, fq2_2)

      expected_coef = [
        4_075_707_939_158_380_910_434_915_048_684_075_627_236_074_250_276_961_535_582_708_982_077_358_580_171,
        13_687_830_587_004_704_333_523_026_843_111_981_453_124_657_402_403_571_359_495_127_741_246_690_601_895
      ]

      result.coef
      |> Enum.zip(expected_coef)
      |> Enum.each(fn {coef, expected} ->
        coef.value == expected
      end)
    end
  end

  describe "pow/2" do
    test "calculates pow" do
      fq2 = FQ2.new([78_578, 16_935_315])

      result = FQ2.pow(fq2, 20)

      expected_coef = [
        13_054_633_223_646_163_942_309_616_969_537_871_020_816_862_167_935_657_026_659_886_183_170_961_591_649,
        16_377_334_708_053_500_744_071_454_407_667_396_397_316_036_402_006_038_996_934_175_435_754_022_362_587
      ]

      result.coef
      |> Enum.zip(expected_coef)
      |> Enum.each(fn {coef, expected} ->
        coef.value == expected
      end)
    end
  end
end
