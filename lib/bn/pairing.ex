defmodule BN.Pairing do
  alias BN.{FQ12, FQP, FQ}

  @twist_point FQ12.new([0, 1] ++ List.duplicate(0, 10))

  @spec twist(FQP.t()) :: FQP.t()
  def twist({x, y}) do
    x_1 = x.coef |> Enum.at(0)
    x_2 = x.coef |> Enum.at(1)

    y_1 = y.coef |> Enum.at(0)
    y_2 = y.coef |> Enum.at(1)

    inter_x_1 = x_1.value - x_2.value * 9
    inter_y_1 = y_1.value - y_2.value * 9

    inter_x_coef = [inter_x_1] ++ List.duplicate(0, 5) ++ [x_2] ++ List.duplicate(0, 5)
    inter_y_coef = [inter_y_1] ++ List.duplicate(0, 5) ++ [y_2] ++ List.duplicate(0, 5)

    inter_x = FQ12.new(inter_x_coef)
    inter_y = FQ12.new(inter_y_coef)

    new_x = @twist_point |> FQ12.pow(2) |> FQ12.mult(inter_x)
    new_y = @twist_point |> FQ12.pow(3) |> FQ12.mult(inter_y)

    {new_x, new_y}
  end

  @spec point_to_fq12({FQ.t(), FQ.t()}) :: FQP.t()
  def point_to_fq12({x, y}) do
    new_x = [x.value] ++ List.duplicate(0, 11)
    new_y = [y.value] ++ List.duplicate(0, 11)

    {FQ12.new(new_x), FQ12.new(new_y)}
  end

  @spec linefunc({FQP.t(), FQP.t()}, {FQP.t(), FQP.t()}, {FQP.t(), FQP.t()}) :: FQP.t()
  def linefunc({x1, y1}, {x2, y2}, {xt, yt}) do
    cond do
      x1 != x2 ->
        dividend = FQ12.sub(y2, y1)
        separator = FQ12.sub(x2, x1)
        quotient = FQ12.divide(dividend, separator)

        xt
        |> FQ12.sub(x1)
        |> FQ12.mult(quotient)
        |> FQ12.sub(FQ12.sub(yt, y1))

      y1 == y2 ->
        dividend = x1 |> FQ12.pow(2) |> FQ12.mult(3)
        separator = FQ12.mult(y1, 2)
        quotient = FQ12.divide(dividend, separator)

        xt
        |> FQ12.sub(x1)
        |> FQ12.mult(quotient)
        |> FQ12.sub(FQ12.sub(yt, y1))

      true ->
        FQ12.sub(xt, x1)
    end
  end
end
