defmodule BN.FQ.ExtendedEuclideanAlgorithm do
  @spec common_greatest_divisor(integer(), integer()) :: integer()
  def common_greatest_divisor(number1, number2) do
    if number1 >= number2, do: gcd(number1, number2), else: gcd(number2, number1)
  end

  @spec extended_gcd(integer(), integer()) :: {integer(), integer()}
  def extended_gcd(a, b) do
    {last_remainder, last_x} = extended_gcd(abs(a), abs(b), 1, 0, 0, 1)
    {last_remainder, last_x * if(a < 0, do: -1, else: 1)}
  end

  defp extended_gcd(last_remainder, 0, last_x, _, _, _), do: {last_remainder, last_x}

  defp extended_gcd(last_remainder, remainder, last_x, x, last_y, y) do
    quotient = div(last_remainder, remainder)
    remainder2 = rem(last_remainder, remainder)
    extended_gcd(remainder, remainder2, x, last_x - quotient * x, y, last_y - quotient * y)
  end

  @spec gcd(integer(), integer()) :: integer()
  defp gcd(number1, number2) do
    remain = rem(number1, number2)

    if remain == 0, do: number2, else: gcd(number2, remain)
  end
end
