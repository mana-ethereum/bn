defmodule BN.Pairing do
  alias BN.FQ12

  @twist_point FQ12.new([0, 1] ++ List.duplicate(0, 10))

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
end
