defmodule BN.IntegerModP.Point do
  defstruct [:x, :y, :modulus]

  alias BN.IntegerModP.Point12
  alias BN.IntegerModP

  @type t :: %__MODULE__{
          x: IntegerModP.t(),
          y: IntegerModP.t(),
          modulus: integer()
        }

  @spec new(integer(), integer(), keyword()) :: {:ok, t()} | {:error, String.t()}
  def new(x, y, params \\ []) do
    modulus = params[:modulus] || IntegerModP.default_modulus()

    cond do
      x >= modulus ->
        {:error, "x is bigger than modulus"}

      y >= modulus ->
        {:error, "y is bigger than modulus"}

      true ->
        x_mod_p = IntegerModP.new(x, modulus: modulus)
        y_mod_p = IntegerModP.new(y, modulus: modulus)

        point = %__MODULE__{
          x: x_mod_p,
          y: y_mod_p,
          modulus: modulus
        }

        {:ok, point}
    end
  end

  @spec add(t(), t()) :: t()
  def add(point1, point2) do
    x = IntegerModP.add(point1.x, point2.x)
    y = IntegerModP.add(point1.y, point2.y)

    %__MODULE__{
      x: x,
      y: y,
      modulus: x.modulus
    }
  end
end
