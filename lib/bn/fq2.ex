defmodule BN.FQ2 do
  alias BN.FQP

  @modulus_coef [1, 0]

  @spec new([integer()]) :: FQP.t()
  def new(coef) do
    if Enum.count(coef) != 2, do: raise(ArgumentError, message: "FQ2 should have dimension of 2")

    FQP.new(coef, @modulus_coef)
  end

  defdelegate add(fq2_1, fq2_2), to: FQP
  defdelegate sub(fq2_1, fq2_2), to: FQP
  defdelegate mult(fq2_1, fq2_2), to: FQP
  defdelegate divide(fq2_1, fq2_2), to: FQP
  defdelegate pow(fq2_1, fq2_2), to: FQP
end
