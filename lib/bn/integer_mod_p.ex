defmodule BN.IntegerModP do
  defstruct [:value, :modulus]

  @type t :: %__MODULE__{
          value: integer(),
          modulus: integer()
        }

  @default_modulus 21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_583

  @spec new(integer(), keyword()) :: t()
  def new(number, params \\ []) do
    modulus = params[:modulus] || @default_modulus

    value =
      number
      |> rem(modulus)
      |> make_positive(modulus)

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

  @spec mult(t(), t() | integer()) :: t()
  def mult(number1 = %__MODULE__{}, number2 = %__MODULE__{}) do
    if number1.modulus != number2.modulus,
      do: raise(ArgumentError, message: "Numbers calculated with different modulus")

    new(number1.value * number2.value, modulus: number1.modulus)
  end

  def mult(number1 = %__MODULE__{}, number2) do
    new(number1.value * number2, modulus: number1.modulus)
  end

  def mult(_, _) do
    raise ArgumentError,
      message: "#{__MODULE__}.sub/2 can only multiplicate #{__MODULE__} structs"
  end

  @spec div(t(), t()) :: t()
  def div(number1 = %__MODULE__{}, number2 = %__MODULE__{}) do
    if number1.modulus != number2.modulus,
      do: raise(ArgumentError, message: "Numbers calculated with different modulus")

    number1.value
    |> Kernel./(number2.value)
    |> round()
    |> new(modulus: number1.modulus)
  end

  def div(_, _) do
    raise ArgumentError,
      message: "#{__MODULE__}.sub/2 can only divide #{__MODULE__} structs"
  end

  @spec pow(t(), t()) :: t()
  def pow(number1 = %__MODULE__{}, number2) do
    cond do
      number2 == 0 ->
        new(1, modulus: number1.modulus)

      number2 == 1 ->
        number1

      true ->
        number1.value
        |> :crypto.mod_pow(number2, number1.modulus)
        |> :binary.decode_unsigned()
        |> new(modulus: number1.modulus)
    end
  end

  def pow(_, _) do
    raise ArgumentError,
      message: "#{__MODULE__}.pow/2 can only exponent #{__MODULE__} structs"
  end

  @spec default_modulus() :: integer()
  def default_modulus, do: @default_modulus

  @spec make_positive(integer(), integer()) :: integer()
  defp make_positive(number, _) when number >= 0, do: number

  defp make_positive(number, modulus) do
    updated_number = number + modulus

    make_positive(updated_number, modulus)
  end
end
