defmodule BN.BN128Arithmetic do
  alias BN.IntegerModP
  alias BN.IntegerModP.Point

  @default_b IntegerModP.new(3)

  @spec on_curve?(Point.t(), IntegerModP.t()) :: boolean()
  def on_curve?(point, b \\ @default_b) do
    minuend = IntegerModP.pow(point.y, 2)
    subtrahend = IntegerModP.pow(point.x, 3)

    remainder = IntegerModP.sub(minuend, subtrahend)

    remainder == b
  end
end
