defmodule BN.IntegerModPTest do
  use ExUnit.Case, async: true

  alias BN.IntegerModP

  describe "new/2" do
    test "creates new integer mod p" do
      integer = IntegerModP.new(10, modulus: 3)

      assert integer.value == 1
      assert integer.modulus == 3
    end

    test "create new integer mod p with default modulus" do
      integer =
        IntegerModP.new(
          21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_585
        )

      assert integer.value == 2

      assert integer.modulus ==
               21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_583
    end

    test "always returns postive number" do
      integer = IntegerModP.new(-12, modulus: 5)

      assert integer.value == 3
      assert integer.modulus == 5
    end
  end

  describe "add/2" do
    test "calculates (a + b) mod p" do
      integer1 = IntegerModP.new(11, modulus: 5)
      integer2 = IntegerModP.new(40, modulus: 5)

      result = IntegerModP.add(integer1, integer2)

      assert result.value == 1
      assert result.modulus == 5
    end

    test "raises error on different modulus" do
      integer1 = IntegerModP.new(11, modulus: 4)
      integer2 = IntegerModP.new(40, modulus: 5)

      assert_raise ArgumentError, fn ->
        IntegerModP.add(integer1, integer2)
      end
    end

    test "raies error on wrong input arguments" do
      integer1 = 1
      integer2 = 7

      assert_raise ArgumentError, fn ->
        IntegerModP.add(integer1, integer2)
      end
    end
  end

  describe "sub/2" do
    test "calculates (a - b) mod p" do
      integer1 = IntegerModP.new(11, modulus: 7)
      integer2 = IntegerModP.new(5, modulus: 7)

      result = IntegerModP.add(integer1, integer2)

      assert result.value == 2
      assert result.modulus == 7
    end

    test "raises error on different modulus" do
      integer1 = IntegerModP.new(11, modulus: 4)
      integer2 = IntegerModP.new(40, modulus: 5)

      assert_raise ArgumentError, fn ->
        IntegerModP.sub(integer1, integer2)
      end
    end

    test "raies error on wrong input arguments" do
      integer1 = 1
      integer2 = 7

      assert_raise ArgumentError, fn ->
        IntegerModP.sub(integer1, integer2)
      end
    end
  end

  describe "mult/2" do
    test "calculates (a * b) mod p" do
      integer1 = IntegerModP.new(17, modulus: 8)
      integer2 = IntegerModP.new(28, modulus: 8)

      result = IntegerModP.mult(integer1, integer2)

      assert result.value == 4
      assert result.modulus == 8
    end

    test "calculates (a * b) mod p when b is a simple integer" do
      integer1 = IntegerModP.new(17, modulus: 8)
      integer2 = 2

      result = IntegerModP.mult(integer1, integer2)

      assert result.value == 2
      assert result.modulus == 8
    end

    test "raises error on different modulus" do
      integer1 = IntegerModP.new(11, modulus: 4)
      integer2 = IntegerModP.new(40, modulus: 5)

      assert_raise ArgumentError, fn ->
        IntegerModP.mult(integer1, integer2)
      end
    end

    test "raies error on wrong input arguments" do
      integer1 = 1
      integer2 = 7

      assert_raise ArgumentError, fn ->
        IntegerModP.mult(integer1, integer2)
      end
    end
  end

  describe "div/2" do
    test "calculates (a / b) mod p" do
      integer1 = IntegerModP.new(2, modulus: 3)
      integer2 = IntegerModP.new(10, modulus: 3)

      result = IntegerModP.div(integer1, integer2)

      assert result.value == 2
      assert result.modulus == 3
    end

    test "raises error on different modulus" do
      integer1 = IntegerModP.new(11, modulus: 4)
      integer2 = IntegerModP.new(40, modulus: 5)

      assert_raise ArgumentError, fn ->
        IntegerModP.div(integer1, integer2)
      end
    end

    test "raies error on wrong input arguments" do
      integer1 = 1
      integer2 = 7

      assert_raise ArgumentError, fn ->
        IntegerModP.div(integer1, integer2)
      end
    end
  end

  describe "pow/2" do
    test "returns 1 when exponent is 0" do
      integer1 = IntegerModP.new(11, modulus: 5)
      integer2 = 0

      result = IntegerModP.pow(integer1, integer2)

      assert result.value == 1
      assert result.modulus == 5
    end

    test "returns original number when exponent is 1" do
      integer1 = IntegerModP.new(11, modulus: 5)
      integer2 = 1

      result = IntegerModP.pow(integer1, integer2)

      assert result.value == integer1.value
      assert result.modulus == integer1.modulus
    end

    test "calculate mod_pow(a, b)" do
      integer1 = IntegerModP.new(11, modulus: 5)
      integer2 = 2

      result = IntegerModP.pow(integer1, integer2)

      assert result.value == 1
      assert result.modulus == 5
    end

    test "raies error on wrong input arguments" do
      integer1 = 1
      integer2 = 7

      assert_raise ArgumentError, fn ->
        IntegerModP.pow(integer1, integer2)
      end
    end
  end
end
