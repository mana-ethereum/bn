defmodule BN.BN128Arithmetic do
  require Integer
  alias BN.{FQ, FQP, FQ2, FQ12}

  # y^2 = x^3 + 3
  @y_power 2
  @x_power 3
  @b FQ.new(3)
  @b2 [3, 0] |> FQ2.new() |> FQ2.divide(FQ2.new([9, 1]))
  @b12 FQ12.new([3] ++ List.duplicate(0, 11))

  @type point :: {FQP.t(), FQP.t()} | {FQ.t(), FQ.t()}

  @spec on_curve?(point()) :: boolean()
  def on_curve?(point = {x, y} = {%FQ{}, %FQ{}}) do
    if infinity?(point) do
      true
    else
      minuend = FQ.pow(y, @y_power)
      substrahend = FQ.pow(x, @x_power)

      remainder = FQ.sub(minuend, substrahend)

      remainder == @b
    end
  end

  def on_curve?(point = {x, y} = {%FQP{}, %FQP{}}) do
    if infinity?(point) do
      true
    else
      minuend = FQP.pow(y, @y_power)
      substrahend = FQP.pow(x, @x_power)

      remainder = FQP.sub(minuend, substrahend)

      if x.dim == 2 do
        remainder == @b2
      else
        remainder == @b12
      end
    end
  end

  @spec add(point(), point()) :: {:ok, point()} | {:error, String.t()}
  def add(point1, point2) do
    cond do
      !on_curve?(point1) ->
        {:error, "point1 is not on the curve"}

      !on_curve?(point2) ->
        {:error, "point2 is not on the curve"}

      true ->
        {:ok, add_points(point1, point2)}
    end
  end

  @spec mult(point(), integer()) :: {:ok, point()} | {:error, String.t()}
  def mult(point, scalar) do
    if on_curve?(point) do
      {:ok, mult_point(point, scalar)}
    else
      {:error, "point is not on the curve"}
    end
  end

  @spec mult_point(point(), integer()) :: point()
  defp mult_point(point, scalar) do
    cond do
      scalar == 0 ->
        case point do
          {%FQ{}, %FQ{}} ->
            {FQ.new(0), FQ.new(0)}

          _ ->
            {FQ12.zero(), FQ12.zero()}
        end

      scalar == 1 ->
        point

      Integer.is_even(scalar) ->
        point
        |> mult_point(div(scalar, 2))
        |> double()

      true ->
        point
        |> mult_point(div(scalar, 2))
        |> double()
        |> calculate_points_addition(point)
    end
  end

  @spec add_points(point(), point()) :: point()
  def add_points(point1, point2) do
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

  @spec double(point()) :: point()
  def double({x, y} = {%FQ{}, %FQ{}}) do
    if y.value == 0 do
      {FQ.new(0), FQ.new(0)}
    else
      double_y = FQ.mult(y, 2)

      lambda =
        x
        |> FQ.pow(2)
        |> FQ.mult(3)
        |> FQ.divide(double_y)

      double_x = FQ.mult(x, 2)

      new_x = lambda |> FQ.pow(2) |> FQ.sub(double_x)

      new_y =
        x
        |> FQ.sub(new_x)
        |> FQ.mult(lambda)
        |> FQ.sub(y)

      {new_x, new_y}
    end
  end

  def double({x, y} = {%FQP{}, %FQP{}}) do
    if y == FQ12.zero() do
      {FQ12.zero(), FQ12.zero()}
    else
      double_y = FQ12.mult(y, 2)

      lambda =
        x
        |> FQ12.pow(2)
        |> FQ12.mult(3)
        |> FQ12.divide(double_y)

      double_x = FQ12.mult(x, 2)

      new_x = lambda |> FQ12.pow(2) |> FQ12.sub(double_x)

      new_y =
        x
        |> FQ12.sub(new_x)
        |> FQ12.mult(lambda)
        |> FQ12.sub(y)

      {new_x, new_y}
    end
  end

  @spec calculate_points_addition(point(), point()) :: point()
  defp calculate_points_addition({x1, y1} = {%FQ{}, %FQ{}}, {x2, y2}) do
    if x1 == x2 do
      {FQ.new(0), FQ.new(0)}
    else
      y_remainder = FQ.sub(y2, y1)
      x_remainder = FQ.sub(x2, x1)
      lambda = FQ.divide(y_remainder, x_remainder)

      x =
        lambda
        |> FQ.pow(2)
        |> FQ.sub(x1)
        |> FQ.sub(x2)

      y =
        x1
        |> FQ.sub(x)
        |> FQ.mult(lambda)
        |> FQ.sub(y1)

      {x, y}
    end
  end

  defp calculate_points_addition({x1, y1} = {%FQP{}, %FQP{}}, {x2, y2}) do
    if x1 == x2 do
      {FQ12.zero(), FQ12.zero()}
    else
      y_remainder = FQ12.sub(y2, y1)
      x_remainder = FQ12.sub(x2, x1)
      lambda = FQ12.divide(y_remainder, x_remainder)

      x =
        lambda
        |> FQ12.pow(2)
        |> FQ12.sub(x1)
        |> FQ12.sub(x2)

      y =
        x1
        |> FQ12.sub(x)
        |> FQ12.mult(lambda)
        |> FQ12.sub(y1)

      {x, y}
    end
  end

  def infinity?({x, y} = {%FQ{}, %FQ{}}) do
    x.value == 0 && y.value == 0
  end

  def infinity?({x, y} = {%FQP{}, %FQP{}}) do
    FQP.zero?(x) && FQP.zero?(y)
  end
end
