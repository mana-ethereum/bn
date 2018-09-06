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

  defp mult_modulus_coef(pol_coef = [cur | tail_pol_coef], modulus_coef, dim)
       when length(pol_coef) > dim do
    current_idx = Enum.count(pol_coef) - dim - 1

    cur_result =
      Enum.reduce(0..(dim - 1), tail_pol_coef, fn i, acc ->
        current_acc_el = Enum.at(acc, i + current_idx)
        subtrahend = modulus_coef |> Enum.at(i) |> FQ.new() |> FQ.mult(cur)
        updated_acc_el = FQ.sub(current_acc_el, subtrahend)

        List.replace_at(acc, current_idx + i, updated_acc_el)
      end)

    mult_modulus_coef(cur_result, modulus_coef, dim)
  end

  defp mult_modulus_coef(pol_coef, _, _), do: Enum.reverse(pol_coef)
end
