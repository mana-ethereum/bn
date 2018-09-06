defmodule BN.FQP do
  defstruct [:coef, :modulus_coef, :dim]

  alias BN.FQ

  def new(coef, modulus_coef, params \\ []) do
    modulus = params[:modulus] || FQ.default_modulus()
    coef_size = Enum.count(coef)
    modulus_coef_size = Enum.count(modulus_coef)

    if coef_size != modulus_coef_size,
      do:
        raise(ArgumentError,
          message: "Coefficients and modulus coefficients have different dimensions"
        )

    fq_coef =
      Enum.map(coef, fn coef_el ->
        FQ.new(coef_el, modulus: modulus)
      end)

    %__MODULE__{
      coef: fq_coef,
      modulus_coef: modulus_coef,
      dim: coef_size
    }
  end

  def add(
        fqp1 = %__MODULE__{dim: dim1, modulus_coef: modulus_coef1},
        fqp2 = %__MODULE__{dim: dim2, modulus_coef: modulus_coef2}
      )
      when dim1 == dim2 and modulus_coef1 == modulus_coef2 do
    coef =
      fqp1.coef
      |> Enum.zip(fqp2.coef)
      |> Enum.map(fn {coef1, coef2} ->
        FQ.add(coef1, coef2)
      end)

    %__MODULE__{modulus_coef: modulus_coef1, dim: dim1, coef: coef}
  end

  def add(_, _), do: raise(ArgumentError, message: "Can't add elements of different fields")

  def sub(
        fqp1 = %__MODULE__{dim: dim1, modulus_coef: modulus_coef1},
        fqp2 = %__MODULE__{dim: dim2, modulus_coef: modulus_coef2}
      )
      when dim1 == dim2 and modulus_coef1 == modulus_coef2 do
    coef =
      fqp1.coef
      |> Enum.zip(fqp2.coef)
      |> Enum.map(fn {coef1, coef2} ->
        FQ.sub(coef1, coef2)
      end)

    %__MODULE__{modulus_coef: modulus_coef1, dim: dim1, coef: coef}
  end

  def sub(_, _), do: raise(ArgumentError, message: "Can't substact elements of different fields")

  def mult(
        fqp = %__MODULE__{dim: dim, modulus_coef: modulus_coef},
        fq = %FQ{}
      ) do
    coef =
      Enum.map(fqp.coef, fn coef ->
        FQ.mult(coef, fq)
      end)

    %__MODULE__{modulus_coef: modulus_coef, dim: dim, coef: coef}
  end

  def mult(
        fqp = %__MODULE__{dim: dim, modulus_coef: modulus_coef},
        number
      )
      when is_integer(number) do
    coef =
      Enum.map(fqp.coef, fn coef ->
        FQ.mult(coef, number)
      end)

    %__MODULE__{modulus_coef: modulus_coef, dim: dim, coef: coef}
  end

  def mult(
        fqp1 = %__MODULE__{dim: dim1, modulus_coef: modulus_coef1},
        fqp2 = %__MODULE__{dim: dim2, modulus_coef: modulus_coef2}
      )
      when dim1 == dim2 and modulus_coef1 == modulus_coef2 do
    pol_coef = List.duplicate(FQ.new(0), dim1 * 2 - 1)

    intermediate_result =
      Enum.reduce(0..(dim1 - 1), pol_coef, fn i, acc1 ->
        Enum.reduce(0..(dim1 - 1), acc1, fn j, acc2 ->
          cur_acc = Enum.at(acc2, i + j)

          summand = FQ.mult(Enum.at(fqp1.coef, i), Enum.at(fqp2.coef, j))

          List.replace_at(acc2, i + j, FQ.add(cur_acc, summand))
        end)
      end)

    coef =
      mult_modulus_coef(
        Enum.reverse(intermediate_result),
        modulus_coef1,
        dim1
      )

    %__MODULE__{modulus_coef: modulus_coef1, dim: dim1, coef: coef}
  end

  def mult(_, _), do: raise(ArgumentError, message: "Can't multiply elements of different fields")

  def reverse(fqp) do
  end

  defp poly_rounded_div(a, b) do
    dega = deg(a)
    degb = deg(b)
    temp = a

    out = List.duplicate(FQ.new(0), Enum.count(a))

    {output, _} =
      0..(dega - geb - 1)
      |> Enum.to_list()
      |> Enum.reverse()
      |> Enum.reduce({out, temp}, fn i ->
        new_val =
          temp
          |> Enum.at(degb + i)
          |> FQ.div(Enum.at(b, degb))
          |> FQ.add(Enum.at(output, i))

        out = List.replace_at(output, i, new_val)

        temp =
          0..degb
          |> Enum.reduce(temp, fn j, acc ->
            List.replace_at(acc, i + j, FQ.sub(Enum.at(acc, i + j), Enum.at(output, j)))
          end)

        {out, temp}
      end)

    dego = deg(output)
    Enum.take(list, dego + 1)
  end

  defp deg(list) do
    idx =
      Enum.find_index(list, fn el ->
        el.value != 0
      end)

    if is_nil(idx), do: Enum.count(list) - 1, else: Enum.count(list) - idx - 1
  end

  defp mult_modulus_coef(pol_coef = [cur | tail_pol_coef], modulus_coef, dim)
       when length(pol_coef) > dim do
    current_idx = Enum.count(pol_coef) - dim - 1
    tail_pol_coef = Enum.reverse(tail_pol_coef)

    cur_result =
      Enum.reduce(0..(dim - 1), tail_pol_coef, fn i, acc ->
        current_acc_el = acc |> Enum.at(i + current_idx)
        subtrahend = modulus_coef |> Enum.at(i) |> FQ.new() |> FQ.mult(cur)
        updated_acc_el = FQ.sub(current_acc_el, subtrahend)

        List.replace_at(acc, current_idx + i, updated_acc_el)
      end)

    cur_result
    |> Enum.reverse()
    |> mult_modulus_coef(modulus_coef, dim)
  end

  defp mult_modulus_coef(pol_coef, _, _), do: Enum.reverse(pol_coef)
end
