defmodule BN.FQPTest do
  use ExUnit.Case, async: true

  alias BN.{FQP, FQ}

  describe "new/2" do
    test "creates a new fqp12 field element" do
      modulus_coef = [82, 0, 0, 0, 0, 0, -18, 0, 0, 0, 0, 0]
      coef = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]

      result = FQP.new(coef, modulus_coef)

      assert result.modulus_coef == modulus_coef
      assert result.dim == 12

      result.coef
      |> Enum.zip(coef)
      |> Enum.each(fn {fq_coef, coef} ->
        assert fq_coef.value == coef
      end)
    end
  end

  describe "add/2" do
    test "add two fqp12 field elements" do
      modulus_coef = [82, 0, 0, 0, 0, 0, -18, 0, 0, 0, 0, 0]
      coef1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
      coef2 = Enum.reverse(coef1)

      fqp1 = FQP.new(coef1, modulus_coef)
      fqp2 = FQP.new(coef2, modulus_coef)

      result = FQP.add(fqp1, fqp2)

      assert result.modulus_coef == modulus_coef
      assert result.dim == 12

      result.coef
      |> Enum.zip(coef1)
      |> Enum.zip(coef2)
      |> Enum.each(fn {{fq_coef, coef1}, coef2} ->
        assert fq_coef.value == coef1 + coef2
      end)
    end
  end

  describe "sub/2" do
    test "substract two fqp12 field elements" do
      modulus_coef = [82, 0, 0, 0, 0, 0, -18, 0, 0, 0, 0, 0]
      coef1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
      coef2 = Enum.reverse(coef1)

      fqp1 = FQP.new(coef1, modulus_coef)
      fqp2 = FQP.new(coef2, modulus_coef)

      result = FQP.sub(fqp2, fqp1)

      assert result.modulus_coef == modulus_coef
      assert result.dim == 12

      result.coef
      |> Enum.zip(coef1)
      |> Enum.zip(coef2)
      |> Enum.each(fn {{fq_coef, coef1}, coef2} ->
        fq1 = FQ.new(coef2)
        fq2 = FQ.new(coef1)

        assert fq_coef == FQ.sub(fq1, fq2)
      end)
    end
  end

  describe "mult/2" do
    test "multiplies fq12 with fq" do
      modulus_coef = [82, 0, 0, 0, 0, 0, -18, 0, 0, 0, 0, 0]
      coef = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]

      fqp = FQP.new(coef, modulus_coef)
      fq = FQ.new(2)

      result = FQP.mult(fqp, fq)

      assert result.dim == fqp.dim
      assert result.modulus_coef == modulus_coef

      result.coef
      |> Enum.zip(fqp.coef)
      |> Enum.each(fn {res_coef, fqp_coef} ->
        assert res_coef == FQ.mult(fqp_coef, fq)
      end)
    end

    test "multiplies fq12 with integer" do
      modulus_coef = [82, 0, 0, 0, 0, 0, -18, 0, 0, 0, 0, 0]
      coef = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]

      fqp = FQP.new(coef, modulus_coef)
      integer = 2

      result = FQP.mult(fqp, 2)

      assert result.dim == fqp.dim
      assert result.modulus_coef == modulus_coef

      result.coef
      |> Enum.zip(fqp.coef)
      |> Enum.each(fn {res_coef, fqp_coef} ->
        assert res_coef == FQ.mult(fqp_coef, integer)
      end)
    end

    test "multiplies fq12 element to 1" do
      modulus_coef = [82, 0, 0, 0, 0, 0, -18, 0, 0, 0, 0, 0]

      coef1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
      fpq1 = FQP.new(coef1, modulus_coef)

      coef2 = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      fpq2 = FQP.new(coef2, modulus_coef)

      assert FQP.mult(fpq1, fpq2) == fpq1
    end
  end
end