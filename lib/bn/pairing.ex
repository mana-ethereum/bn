defmodule BN.Pairing do
  use Bitwise
  alias BN.{FQ12, FQP, FQ, BN128Arithmetic}

  @twist_point FQ12.new([0, 1] ++ List.duplicate(0, 10))
  @power 552_484_233_613_224_096_312_617_126_783_173_147_097_382_103_762_957_654_188_882_734_314_196_910_839_907_541_213_974_502_761_540_629_817_009_608_548_654_680_343_627_701_153_829_446_747_810_907_373_256_841_551_006_201_639_677_726_139_946_029_199_968_412_598_804_882_391_702_273_019_083_653_272_047_566_316_584_365_559_776_493_027_495_458_238_373_902_875_937_659_943_504_873_220_554_161_550_525_926_302_303_331_747_463_515_644_711_876_653_177_129_578_303_191_095_900_909_191_624_817_826_566_688_241_804_408_081_892_785_725_967_931_714_097_716_709_526_092_261_278_071_952_560_171_111_444_072_049_229_123_565_057_483_750_161_460_024_353_346_284_167_282_452_756_217_662_335_528_813_519_139_808_291_170_539_072_125_381_230_815_729_071_544_861_602_750_936_964_829_313_608_137_325_426_383_735_122_175_229_541_155_376_346_436_093_930_287_402_089_517_426_973_178_917_569_713_384_748_081_827_255_472_576_937_471_496_195_752_727_188_261_435_633_271_238_710_131_736_096_299_798_168_852_925_540_549_342_330_775_279_877_006_784_354_801_422_249_722_573_783_561_685_179_618_816_480_037_695_005_515_426_162_362_431_072_245_638_324_744_480

  @dialyzer {:no_return, pairing: 2, twist: 1}

  @spec pairing({FQP.t(), FQP.t()}, {FQ.t(), FQ.t()}) :: FQP.t()
  def pairing(point1, point2) do
    point1_fq12 = twist(point1)
    point2_fq12 = point_to_fq12(point2)

    miller_loop(point1_fq12, point2_fq12)
  end

  @spec twist({FQP.t(), FQP.t()}) :: {FQP.t(), FQP.t()}
  def twist({x, y}) do
    x_1 = x.coef |> Enum.at(0)
    x_2 = x.coef |> Enum.at(1)

    y_1 = y.coef |> Enum.at(0)
    y_2 = y.coef |> Enum.at(1)

    inter_x_1 = x_1.value - x_2.value * 9
    inter_y_1 = y_1.value - y_2.value * 9

    inter_x_coef = [inter_x_1] ++ List.duplicate(0, 5) ++ [x_2] ++ List.duplicate(0, 5)
    inter_y_coef = [inter_y_1] ++ List.duplicate(0, 5) ++ [y_2] ++ List.duplicate(0, 5)

    inter_x = FQ12.new(inter_x_coef)
    inter_y = FQ12.new(inter_y_coef)

    new_x = @twist_point |> FQ12.pow(2) |> FQ12.mult(inter_x)
    new_y = @twist_point |> FQ12.pow(3) |> FQ12.mult(inter_y)

    {new_x, new_y}
  end

  @spec point_to_fq12({FQ.t(), FQ.t()}) :: {FQP.t(), FQP.t()}
  def point_to_fq12({x, y}) do
    new_x = [x.value] ++ List.duplicate(0, 11)
    new_y = [y.value] ++ List.duplicate(0, 11)

    {FQ12.new(new_x), FQ12.new(new_y)}
  end

  @spec linefunc({FQP.t(), FQP.t()}, {FQP.t(), FQP.t()}, {FQP.t(), FQP.t()}) :: FQP.t()
  def linefunc({x1, y1}, {x2, y2}, {xt, yt}) do
    cond do
      x1 != x2 ->
        dividend = FQ12.sub(y2, y1)
        separator = FQ12.sub(x2, x1)
        quotient = FQ12.divide(dividend, separator)

        xt
        |> FQ12.sub(x1)
        |> FQ12.mult(quotient)
        |> FQ12.sub(FQ12.sub(yt, y1))

      y1 == y2 ->
        dividend = x1 |> FQ12.pow(2) |> FQ12.mult(3)
        separator = FQ12.mult(y1, 2)
        quotient = FQ12.divide(dividend, separator)

        xt
        |> FQ12.sub(x1)
        |> FQ12.mult(quotient)
        |> FQ12.sub(FQ12.sub(yt, y1))

      true ->
        FQ12.sub(xt, x1)
    end
  end

  @spec miller_loop({FQP.t(), FQP.t()}, {FQP.t(), FQP.t()}) :: FQP.t()
  def miller_loop(point1 = {x1, y1}, point2) do
    one = FQ12.one()

    if BN128Arithmetic.infinity?(point1) || BN128Arithmetic.infinity?(point2) do
      one
    else
      r = point1
      f = one

      {f, r} =
        0..63
        |> Enum.to_list()
        |> Enum.reverse()
        |> Enum.reduce({f, r}, fn i, {f_acc, r_acc} ->
          f_acc =
            r_acc
            |> linefunc(r_acc, point2)
            |> FQP.mult(f_acc)
            |> FQP.mult(f_acc)

          r_acc = BN128Arithmetic.double(r_acc)

          if (29_793_968_203_157_093_288 &&& round(:math.pow(2, i))) != 0 do
            f_acc =
              r_acc
              |> linefunc(point1, point2)
              |> FQP.mult(f_acc)

            r_acc = BN128Arithmetic.add_points(r_acc, point1)

            {f_acc, r_acc}
          else
            {f_acc, r_acc}
          end
        end)

      new_point1 =
        {new_point1_x, new_point1_y} =
        {FQP.pow(x1, FQ.default_modulus()), FQP.pow(y1, FQ.default_modulus())}

      new_point2 =
        {FQP.pow(new_point1_x, FQ.default_modulus()),
         new_point1_y |> FQP.pow(FQ.default_modulus()) |> FQP.negate()}

      f = r |> linefunc(new_point1, point2) |> FQP.mult(f)
      r = BN128Arithmetic.add_points(r, new_point1)
      f = r |> linefunc(new_point2, point2) |> FQP.mult(f)

      FQP.pow(f, @power)
    end
  end
end
