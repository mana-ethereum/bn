defmodule BN.IntegerModP.Point12 do
  defstruct [:x, :y, :modulus]

  alias BN.IntegerModP

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
end
