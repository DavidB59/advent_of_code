defmodule Day25 do
  def file do
    Parser.read_file(25)
  end

  def test do
    "test" |> Parser.read_file()
  end

  def part_one do
    file()
    |> Enum.map(&snafu_to_decimal/1)
    |> Enum.sum()
    |> Kernel.trunc()
    |> integer_to_snafu()
  end

  def snafu_to_decimal(string) do
    string
    |> String.graphemes()
    |> Enum.map(fn val -> correct_number(val) end)
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {number, index} ->
      String.to_integer(number) * :math.pow(5, index)
    end)
    |> Enum.sum()
  end

  def integer_to_snafu(integer) do
    integer
    |> change_base()
    |> Enum.sort_by(fn {k, _v} -> k end)
    |> Enum.reverse()
    |> Enum.map(&elem(&1, 1))
    |> Enum.join()
  end

  def change_base(rest, map \\ %{}, index \\ 0) do
    new_rest = rem(rest, 5)

    new_map =
      case rest_convert(new_rest) do
        {a, b} ->
          map
          |> Map.put(index + 1, a)
          |> Map.update(index, b, fn current -> addition(current, b) end)

        "2" ->
          if Map.get(map, index) do
            map
            |> Map.put(index + 1, "1")
            |> Map.put(index, "=")
          else
            Map.put(map, index, "2")
          end

        a ->
          Map.update(map, index, a, fn current -> addition(current, a) end)
      end

    quotient = div(rest, 5)

    if quotient == 0 do
      new_map
    else
      change_base(quotient, new_map, index + 1)
    end
  end

  def addition(a, b) do
    int_a = a |> correct_number() |> String.to_integer()
    int_b = b |> correct_number() |> String.to_integer()
    sum = int_a + int_b
    uncorrect(sum)
  end

  def rest_convert(4), do: {"1", "-"}
  def rest_convert(3), do: {"1", "="}
  def rest_convert(rest), do: Integer.to_string(rest)

  def correct_number("-"), do: "-1"

  def correct_number("="), do: "-2"

  def correct_number(a), do: a

  def uncorrect(-1), do: "-"
  def uncorrect(-2), do: "="
  def uncorrect(a), do: Integer.to_string(a)

  def sum() do
    file()
    |> Enum.map(&snafu_to_decimal/1)
    |> Enum.sum()
  end
end
