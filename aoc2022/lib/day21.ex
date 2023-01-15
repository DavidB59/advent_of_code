defmodule Day21 do
  def file do
    Parser.read_file(21)
  end

  def test do
    "test" |> Parser.read_file()
  end

  def part_one() do
    file() |> format() |> get_value(:root)
  end

  def part_two do
    file() |> format()
  end

  def format(file) do
    file
    |> Enum.map(fn string ->
      [monkey, value] = String.split(string, ": ")
      extract = Utils.extract_number_from_string(value)
      key = String.to_atom(monkey)

      if extract == "" do
        [mkey1, operation, mkey2] = value |> String.split(" ")
        {key, {String.to_atom(mkey1), operation, String.to_atom(mkey2)}}
      else
        {key, String.to_integer(extract)}
      end
    end)
    |> Map.new()
  end

  def get_value(map, key) do
    value = Map.get(map, key)

    if is_integer(value) do
      value
    else
      {mkey1, operation, mkey2} = value

      val1 = get_value(map, mkey1)
      val2 = get_value(map, mkey2)
      apply_operation(val1, operation, val2)
    end
  end

  def apply_operation(val1, "+", val2), do: val1 + val2
  def apply_operation(val1, "-", val2), do: val1 - val2
  def apply_operation(val1, "/", val2), do: val1 / val2
  def apply_operation(val1, "*", val2), do: val1 * val2

  def solve_two() do
    map = file() |> format()
    {mkey1, _op, mkey2} = Map.get(map, :root)

    part1 = map |> get_operation(mkey1)
    part2 = map |> get_operation(mkey2)

    if String.contains?(part1, "humn") do
      solve(part1, part2)
    else
      solve(part2, part1)
    end
  end

  def some_testing(myvalue) do
    map = file() |> format()
    {mkey1, _op, mkey2} = Map.get(map, :root)

    part1 = map |> Map.put(:humn, myvalue) |> get_value(mkey1) |> IO.inspect()
    part2 = map |> get_value(mkey2)

    # if String.contains?(part1, "humn") do
    #   solve(part1, part2)
    # else
    #   solve(part2, part1)
    # end
    cond do
      part1 > part2 -> IO.puts("increase input")
      part1 < part2 -> IO.puts("decrease input")
      part1 == part2 -> IO.puts("SOLUTION")
    end
  end

  def with_precise_range() do
    map = file() |> format()
    {mkey1, _op, mkey2} = Map.get(map, :root)

    # part1 = map |> Map.put(:humn, myvalue) |> get_value(mkey1)
    part2 = map |> get_operation(mkey2)

    3_378_273_370_000..3_378_273_380_000
    |> Enum.find(fn v ->
      part1 = map |> Map.put(:humn, v) |> get_value(mkey1) |> IO.inspect(label: "#{v} === ")
      part1 == part2
    end)
  end

  def solve_test do
    # [first, last] =
    map = test() |> format()
    {mkey1, _op, mkey2} = Map.get(map, :root)

    part1 = map |> get_operation(mkey1)
    part2 = map |> get_operation(mkey2)

    if String.contains?(part1, "humn") do
      solve(part1, part2)
    else
      solve(part2, part1)
    end

    # length = String.length(first)
    # {first_rest, first_operation} = Utils.string_pattern_match(first, length - 1)
    # {last_operation, last_rest} = Utils.string_pattern_match(last, 1)

    # first_result = Code.eval_string(first_rest) |> IO.inspect()
    # last_result = Code.eval_string(last_rest) |> IO.inspect()
  end

  def solve(with_humn, without_humn) do
    value_to_obtain = Code.eval_string(without_humn) |> IO.inspect()
  end

  def get_operation(_map, :humn) do
    :humn
  end

  def get_operation(map, key) do
    value = Map.get(map, key)

    if is_integer(value) do
      value
    else
      {mkey1, operation, mkey2} = value

      val1 = get_operation(map, mkey1)
      val2 = get_operation(map, mkey2)
      # apply_operation_2(val1, operation, val2)
      res = "(#{val1}" <> operation <> "#{val2})    "

      if String.contains?(res, "humn") do
        res
      else
        Code.eval_string(res) |> elem(0)
      end
    end
  end

  def apply_operation_2(val1, "+", val2), do: val1 + val2
  def apply_operation_2(val1, "-", val2), do: val1 - val2
  def apply_operation_2(val1, "/", val2), do: val1 / val2
  def apply_operation_2(val1, "*", val2), do: val1 * val2
end
