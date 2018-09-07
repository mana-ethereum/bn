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

    mudulus_coef =
      Enum.map(modulus_coef, fn coef_el ->
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

  def divide(fqp1, fqp2) do
    inverse = inverse(fqp2)

    mult(fqp1, inverse)
  end

  def inverse(fqp) do
    lm = [FQ.new(1)] ++ List.duplicate(FQ.new(0), fqp.dim)
    hm = List.duplicate(FQ.new(0), fqp.dim + 1)
    low = fqp.coef ++ [FQ.new(0)]
    high = fqp.modulus_coef ++ [1]

    deg_low = deg(low)

    calculate_inverse({high, low}, {hm, lm}, fqp, deg_low)
  end

  def pow(base, exp) do
    cond do
      exp == 0 ->
        coef = [1] ++ List.duplicate([0], base.dim - 1)
        new(coef, base.modulus_coef)

      exp == 1 ->
        base

      rem(exp, 2) == 0 ->
        base
        |> mult(base)
        |> pow(div(exp, 2))

      true ->
        base
        |> mult(base)
        |> pow(div(exp, 2))
        |> mult(base)
    end
  end

  def one do
    @one
  end

  defp calculate_inverse({high, low}, {hm, lm}, fqp, deg_low) when deg_low != 0 do
    r = poly_rounded_div(high, low)
    r = r ++ List.duplicate(FQ.new(0), fqp.dim + 1 - Enum.count(r))

    nm = hm

    new = high

    {nm, new} =
      0..fqp.dim
      |> Enum.reduce({nm, new}, fn i, {nm, new} ->
        0..(fqp.dim - i)
        |> Enum.reduce({nm, new}, fn j, {nm, new} ->
          nmmult = lm |> Enum.at(i) |> FQ.new() |> FQ.mult(Enum.at(r, j))
          new_nm_val = nm |> Enum.at(i + j) |> FQ.new() |> FQ.sub(nmmult)
          nm = List.replace_at(nm, i + j, new_nm_val)

          newmult = low |> Enum.at(i) |> FQ.new() |> FQ.mult(Enum.at(r, j))
          new_val = new |> Enum.at(i + j) |> FQ.new() |> FQ.sub(newmult)
          new = List.replace_at(new, i + j, new_val)

          {nm, new}
        end)
      end)

    deg_low = deg(new)

    calculate_inverse({low, new}, {lm, nm}, fqp, deg_low)
  end

  defp calculate_inverse({_, low}, {_, lm}, fqp, _) do
    coef =
      lm
      |> Enum.take(fqp.dim)
      |> Enum.map(fn el ->
        FQ.divide(el, Enum.at(low, 0))
      end)

    new(coef, fqp.modulus_coef)
  end

  defp poly_rounded_div(a, b) do
    dega = deg(a)
    degb = deg(b)
    temp = a

    output = List.duplicate(FQ.new(0), Enum.count(a))

    output =
      if dega - degb >= 0 do
        {output, _} =
          0..(dega - degb)
          |> Enum.to_list()
          |> Enum.reverse()
          |> Enum.reduce({output, temp}, fn i, {out_acc, temp_acc} ->
            new_val =
              temp_acc
              |> Enum.at(degb + i)
              |> FQ.new()
              |> FQ.divide(Enum.at(b, degb))
              |> FQ.add(Enum.at(out_acc, i))

            new_out_acc = List.replace_at(out_acc, i, new_val)

            new_temp_acc =
              0..degb
              |> Enum.reduce(temp_acc, fn j, acc ->
                updated_value =
                  acc |> Enum.at(i + j) |> FQ.new() |> FQ.sub(Enum.at(new_out_acc, j))

                List.replace_at(
                  acc,
                  i + j,
                  updated_value
                )
              end)

            {new_out_acc, new_temp_acc}
          end)

        output
      else
        output
      end

    dego = deg(output)

    Enum.take(output, dego + 1)
  end

  defp deg(list) do
    idx =
      list
      |> Enum.reverse()
      |> Enum.find_index(fn el ->
        if is_integer(el) do
          el != 0
        else
          el.value != 0
        end
      end)

    if is_nil(idx), do: 0, else: Enum.count(list) - idx - 1
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
