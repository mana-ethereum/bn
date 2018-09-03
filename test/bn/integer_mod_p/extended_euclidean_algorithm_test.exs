defmodule BN.IntegerModP.ExtendedEuclideanAlgorithmTest do
  use ExUnit.Case, async: true

  alias BN.IntegerModP.ExtendedEuclideanAlgorithm

  describe "common_greatest_divisor/2" do
    test "calculates gcd when it's bigger than 1" do
      result = ExtendedEuclideanAlgorithm.common_greatest_divisor(16, 30)

      assert result == 2
    end

    test "calculates gcd when it's  1" do
      result = ExtendedEuclideanAlgorithm.common_greatest_divisor(5, 7)

      assert result == 1
    end
  end

  describe "extended_gcd/2" do
    test "calculates gcd and modular inverse" do
      {gcd, inverse} = ExtendedEuclideanAlgorithm.extended_gcd(15, 26)

      assert gcd == 1
      assert inverse == 7
    end
  end
end
