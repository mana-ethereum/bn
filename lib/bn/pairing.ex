defmodule BN.Pairing do
  use Bitwise
  alias BN.{FQ12, FQP, FQ, BN128Arithmetic}

  @twist_point FQ12.new([0, 1] ++ List.duplicate(0, 10))
  @curve_order 21_888_242_871_839_275_222_246_405_745_257_275_088_548_364_400_416_034_343_698_204_186_575_808_495_617

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

  @spec miller_loop({FQP.t(), FQP.t()}, {FQP.t(), FQP.t()}) :: FQP.t()
  def miller_loop(point1 = {x1, y1}, point2) do
    one = FQ12.one()

    if BN128Arithmetic.infinity?(point1) || BN128Arithmetic.infinity?(point2) do
      one
    else
      r = point1
      f = one

      {f, r} =
        0..63
        |> Enum.to_list()
        |> Enum.reverse()
        |> Enum.reduce({f, r}, fn i, {f_acc, r_acc} ->
          f_acc =
            r_acc
            |> linefunc(r_acc, point2)
            |> FQP.mult(f_acc)
            |> FQP.mult(f_acc)

          r_acc = BN128Arithmetic.double(r_acc)

          if 29_793_968_203_157_093_288 &&& round(:math.pow(2, i)) != 0 do
            f_acc =
              r_acc
              |> linefunc(point1, point2)
              |> FQP.mult(f)

            r_acc = BN128Arithmetic.add_points(r_acc, point1)

            {f_acc, r_acc}
          else
            {f_acc, r_acc}
          end
        end)

      new_point1 =
        {new_point1_x, new_point1_y} =
        {FQP.pow(x1, FQ.default_modulus()), FQP.pow(y1, FQ.default_modulus())}

      new_point2 =
        {FQP.pow(new_point1_x, FQ.default_modulus()),
         new_point1_y |> FQP.pow(FQ.default_modulus()) |> FQP.negate()}

      f = f |> linefunc(new_point1, point2)
      r = BN128Arithmetic.add_points(r, new_point1)
      f = r |> linefunc(new_point2, point2) |> FQP.mult(f)

      power = FQ.default_modulus() |> :math.pow(12) |> Kernel.-(1) |> div(@curve_order)

      FQP.pow(f, power)
    end
  end
end
