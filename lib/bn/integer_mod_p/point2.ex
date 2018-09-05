defmodule BN.IntegerModP.Point2 do
  defstruct [:x, :y, :modulus]

  alias BN.IntegerModP
  alias BN.IntegerModP.Point12

  @type t :: %__MODULE__{
          x: [IntegerModP.t()],
          y: [IntegerModP.t()],
          modulus: integer()
        }

  def new(x, y, params \\ []) do
    modulus = params[:modulus] || IntegerModP.default_modulus()

    %__MODULE__{
      x: x,
      y: y,
      modulus: modulus
    }
  end

  @spec twist(t()) :: Point12.t()
  def twist(point) do
    x_coef_sub =
      point.x
      |> Enum.at(1)
      |> IntegerModP.mult(9)

    x_coef =
      point.x
      |> Enum.at(0)
      |> IntegerModP.sub(x_coef_sub)

    y_coef_sub =
      point.y
      |> Enum.at(1)
      |> IntegerModP.mult(9)

    y_coef =
      point.y
      |> Enum.at(0)
      |> IntegerModP.sub(x_coef_sub)

    x = x_coef ++ [for(_ <- 1..5, do: 0)] ++ List.at(point.x, 1) ++ [for(_ <- 1..5, do: 0)]
    y = y_coef ++ [for(_ <- 1..5, do: 0)] ++ List.at(point.y, 1) ++ [for(_ <- 1..5, do: 0)]

    Point12.new(x, y)
  end
end
