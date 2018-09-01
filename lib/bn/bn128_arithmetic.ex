defmodule BN.BN128Arithmetic do
  alias BN.IntegerModP
  alias BN.IntegerModP.Point

  @default_b IntegerModP.new(3)

  @spec on_curve?(Point.t(), IntegerModP.t()) :: boolean()
  def on_curve?(point, b \\ @default_b) do
    if infinity?(point) do
      true
    else
      minuend = IntegerModP.pow(point.y, 2)
      subtrahend = IntegerModP.pow(point.x, 3)

      remainder = IntegerModP.sub(minuend, subtrahend)

      remainder == b
    end
  end

  @spec add(Point.t(), Point.t(), integer()) :: {:ok, Point.t()} | {:error, String.t()}
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

  @spec mult(Point.t(), integer(), integer()) :: {:ok, Point.t()} | {:error, String.t()}
  def mult(point, scalar, b \\ @default_b) do
    if !on_curve?(point, b) do
      {:error, "point1 is not on the curve"}
    else
      {:ok, mult_point(point, scalar)}
    end
  end

  @spec mult_point(Point.t(), integer()) :: Point.t()
  defp mult_point(point, scalar) do
    cond do
      scalar == 0 ->
        {:ok, result} = Point.new(0, 0, modulus: point.modulus)

        result

      scalar == 1 ->
        point

      div(scalar, 2) == 1 ->
        point
        |> mult_point(scalar - 1)
        |> add_points(point)

      true ->
        point
        |> double()
        |> mult_point(round(scalar / 2))
    end
  end

  @spec add_points(Point.t(), Point.t()) :: Point.t()
  defp add_points(point1, point2) do
    cond do
      point1 == point2 ->
        double(point1)

      infinity?(point1) ->
        point2

      infinity?(point2) ->
        point1

      true ->
        calculate_points_addition(point1, point2)
    end
  end

  @spec double(Point.t()) :: Point.t()
  defp double(point) do
    if point.y.value == 0 do
      {:ok, result} = Point.new(0, 0, modulus: point.modulus)

      result
    else
      double_y = IntegerModP.mult(point.y, 2)

      lambda =
        point.x
        |> IntegerModP.pow(2)
        |> IntegerModP.mult(3)
        |> IntegerModP.div(double_y)

      double_x = IntegerModP.mult(point.x, 2)

      x = lambda |> IntegerModP.pow(2) |> IntegerModP.sub(double_x)

      y =
        point.x
        |> IntegerModP.sub(x)
        |> IntegerModP.mult(lambda)
        |> IntegerModP.sub(point.y)

      %Point{
        x: x,
        y: y,
        modulus: point.modulus
      }
    end
  end

  @spec calculate_points_addition(Point.t(), Point.t()) :: Point.t()
  defp calculate_points_addition(point1, point2) do
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

  @spec infinity?(Point.t()) :: boolean()
  def infinity?(point) do
    point.x.value == 0 && point.y.value == 0
  end
end
