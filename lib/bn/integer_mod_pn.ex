defmodule BN.IntegerModPN do
  defstruct [:value, :modulus]

  @type t :: %__MODULE__{
          value: [integer()],
          modulus: integer()
        }

  alias BN.IntegerModP

  def new(value, params \\ []) do
    modulus = params[:modulus] || @default_modulus

    value = Enum.map(value, fn value_i -> IntegerModP.new(value, modulus: modulus) end)

    %__MODULE__{value: value, modulus: modulus}
  end

  def add(number1, number2) do
    sum =
      number1.value
      |> Enum.zip(number2.value)
      |> Enum.map(fn {number1_i, number2_i} ->
        IntegerModP.add(number1_i, number2_i)
      end)

    %__MODULE__{value: sum, modulus: number1.modulus}
  end

  def sub(number1, number2) do
    result =
      number1.value
      |> Enum.zip(number2.value)
      |> Enum.map(fn {number1_i, number2_i} ->
        IntegerModP.sub(number1_i, number2_i)
      end)

    %__MODULE__{value: result, modulus: number1.modulus}
  end

  def mult(number1, number2) do
    result =
      number1.value
      |> Enum.map(fn number1_i ->
        IntegerModP.mult(number1_i, number2)
      end)

    %__MODULE__{value: result, modulus: number1.modulus}
  end
end
