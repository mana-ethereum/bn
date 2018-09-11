defmodule BN.FQ do
  defstruct [:value, :modulus]

  @type t :: %__MODULE__{
          value: integer(),
          modulus: integer()
        }

  @default_modulus 21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_583

  alias BN.FQ.ExtendedEuclideanAlgorithm

  @spec new(integer() | t(), keyword()) :: t()
  def new(number, params \\ [])

  def new(number = %__MODULE__{}, _), do: number

  def new(number, params) do
    modulus = Keyword.get(params, :modulus, @default_modulus)

    value =
      number
      |> rem(modulus)
      |> make_positive(modulus)

    %__MODULE__{value: value, modulus: modulus}
  end

  @spec one() :: t()
  def one do
    new(1)
  end

  @spec zero() :: t()
  def zero do
    new(0)
  end

  @spec add(t(), t()) :: t()
  def add(%__MODULE__{modulus: modulus1}, %__MODULE__{modulus: modulus2})
      when modulus1 != modulus2 do
    raise(ArgumentError, message: "Numbers calculated with different modulus")
  end

  def add(number1 = %__MODULE__{}, number2 = %__MODULE__{}) do
    new(number1.value + number2.value, modulus: number1.modulus)
  end

  def add(_, _) do
    raise ArgumentError, message: "#{__MODULE__}.add/2 can only add #{__MODULE__} structs"
  end

  @spec sub(t(), t()) :: t()
  def sub(%__MODULE__{modulus: modulus1}, %__MODULE__{modulus: modulus2})
      when modulus1 != modulus2 do
    raise(ArgumentError, message: "Numbers calculated with different modulus")
  end

  def sub(number1 = %__MODULE__{}, number2 = %__MODULE__{}) do
    new(number1.value - number2.value, modulus: number1.modulus)
  end

  def sub(_, _) do
    raise ArgumentError, message: "#{__MODULE__}.sub/2 can only substract #{__MODULE__} structs"
  end

  @spec mult(t(), t() | integer()) :: t()
  def mult(%__MODULE__{modulus: modulus1}, %__MODULE__{modulus: modulus2})
      when modulus1 != modulus2 do
    raise(ArgumentError, message: "Numbers calculated with different modulus")
  end

  def mult(number1 = %__MODULE__{}, number2 = %__MODULE__{}) do
    new(number1.value * number2.value, modulus: number1.modulus)
  end

  def mult(number1 = %__MODULE__{}, number2) do
    new(number1.value * number2, modulus: number1.modulus)
  end

  def mult(_, _) do
    raise ArgumentError,
      message: "#{__MODULE__}.sub/2 can only multiplicate #{__MODULE__} structs"
  end

  @spec divide(t(), t()) :: t()
  def divide(%__MODULE__{modulus: modulus1}, %__MODULE__{modulus: modulus2})
      when modulus1 != modulus2 do
    raise(ArgumentError, message: "Numbers calculated with different modulus")
  end

  def divide(number1 = %__MODULE__{}, number2 = %__MODULE__{}) do
    divide(number1, number2.value)
  end

  def divide(number1 = %__MODULE__{}, number2) when is_integer(number2) do
    {1, inverse} = ExtendedEuclideanAlgorithm.extended_gcd(number2, number1.modulus)

    mult(number1, inverse)
  end

  def divide(number1, number2) when is_integer(number2) and is_integer(number1) do
    {1, inverse} = ExtendedEuclideanAlgorithm.extended_gcd(number2, default_modulus())

    number1
    |> new()
    |> mult(inverse)
  end

  def divide(_, _) do
    raise ArgumentError,
      message: "#{__MODULE__}.div/2 can only divide #{__MODULE__} structs"
  end

  @spec pow(t(), integer()) :: t()
  def pow(base = %__MODULE__{}, exponent) do
    case exponent do
      0 ->
        new(1, modulus: base.modulus)

      1 ->
        base

      _ ->
        base.value
        |> :crypto.mod_pow(exponent, base.modulus)
        |> :binary.decode_unsigned()
        |> new(modulus: base.modulus)
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
