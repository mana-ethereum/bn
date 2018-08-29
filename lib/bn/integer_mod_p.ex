defmodule BN.IntegerModP do
  defstruct [:value, :modulus]

  @type t :: %__MODULE__{
          value: integer(),
          modulus: integer()
        }

  @spec new(integer(), keyword()) :: t()
  def new(number, modulus: modulus) do
    value = rem(number, modulus)

    %__MODULE__{value: value, modulus: modulus}
  end

  @spec add(t(), t()) :: t()
  def add(number1 = %__MODULE__{}, number2 = %__MODULE__{}) do
    if number1.modulus != number2.modulus,
      do: raise(ArgumentError, message: "Numbers calculated with different modulus")

    new(number1.value + number2.value, modulus: number1.modulus)
  end

  def add(_, _) do
    raise ArgumentError, message: "#{__MODULE__}.add/2 can only add #{__MODULE__} structs"
  end

  @spec sub(t(), t()) :: t()
  def sub(number1 = %__MODULE__{}, number2 = %__MODULE__{}) do
    if number1.modulus != number2.modulus,
      do: raise(ArgumentError, message: "Numbers calculated with different modulus")

    new(number1.value - number2.value, modulus: number1.modulus)
  end

  def sub(_, _) do
    raise ArgumentError, message: "#{__MODULE__}.sub/2 can only substract #{__MODULE__} structs"
  end

  @spec mult(t(), t()) :: t()
  def mult(number1 = %__MODULE__{}, number2 = %__MODULE__{}) do
    if number1.modulus != number2.modulus,
      do: raise(ArgumentError, message: "Numbers calculated with different modulus")

    new(number1.value * number2.value, modulus: number1.modulus)
  end

  def mult(_, _) do
    raise ArgumentError,
      message: "#{__MODULE__}.sub/2 can only multiplicate #{__MODULE__} structs"
  end

  @spec div(t(), t()) :: t()
  def div(number1 = %__MODULE__{}, number2 = %__MODULE__{}) do
    if number1.modulus != number2.modulus,
      do: raise(ArgumentError, message: "Numbers calculated with different modulus")

    new(round(number1.value / number2.value), modulus: number1.modulus)
  end

  def div(_, _) do
    raise ArgumentError,
      message: "#{__MODULE__}.sub/2 can only divide #{__MODULE__} structs"
  end
end
