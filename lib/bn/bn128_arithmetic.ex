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

  @spec add(Point.t(), Point.t()) :: {:ok, Point.t()} | {:error, String.t()}
  def add(point1, point2, b \\ @default_b) do
    cond do
      !on_curve?(point1, b) ->
        {:error, "point1 is not on the curve"}

      !on_curve?(point2, b) ->
        {:error, "point2 is not on the curve"}

      true ->
        {:ok, add_points(point1, point2)}
    end
  end

  @spec add_points(Point.t(), Point.t()) :: Point.t()
  defp add_points(point1, point2) do
    if point1.x == point2.x do
      {:ok, result} = Point.new(0, 0, modulus: point1.modulus)

      result
    else
      y_remainder = IntegerModP.sub(point2.y, point1.y)
      x_remainder = IntegerModP.sub(point2.x, point1.x)
      lambda = IntegerModP.div(y_remainder, x_remainder)

      x =
        lambda
        |> IntegerModP.pow(2)
        |> IntegerModP.sub(point1.x)
        |> IntegerModP.sub(point2.x)

      y =
        point1.x
        |> IntegerModP.sub(x)
        |> IntegerModP.mult(lambda)
        |> IntegerModP.sub(point1.y)

      %Point{
        x: x,
        y: y,
        modulus: point1.modulus
      }
    end
  end
end
