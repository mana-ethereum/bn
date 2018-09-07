defmodule BN.FQ12 do
  alias BN.FQP

  @modulus_coef [82, 0, 0, 0, 0, 0, -18, 0, 0, 0, 0, 0]

  @spec new([integer()]) :: FQP.t()
  def new(coef) do
    if Enum.count(coef) != 12,
      do: raise(ArgumentError, message: "FQ12 should have dimension of 12")

    FQP.new(coef, @modulus_coef)
  end

  defdelegate add(fq12_1, fq12_2), to: FQP
  defdelegate sub(fq12_1, fq12_2), to: FQP
  defdelegate mult(fq12_1, fq12_2), to: FQP
  defdelegate divide(fq12_1, fq12_2), to: FQP
  defdelegate pow(fq12_1, fq12_2), to: FQP
end
