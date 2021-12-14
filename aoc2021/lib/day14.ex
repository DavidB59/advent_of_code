defmodule Day14 do
  def file do
    Parser.read_file("day14")
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    [polymer, _ | rules] = input

    rule_map =
      Map.new(rules, fn string ->
        [a, b] = String.split(string, " -> ")
        b = String.at(a, 0) <> b <> String.at(a, 1)
        {a, b}
      end)

    {polymer, rule_map}
  end

  def insert_smart(input, step, count \\ 0)

  def insert_smart({polymer, _rule}, step, step), do: polymer

  def insert_smart({polymer, rule}, step, count) do
    polymer
    |> String.graphemes()
    |> to_pair([])
    |> Enum.map(fn pair ->
      new_poly = string_match(pair, rule)
      insert_smart({new_poly, rule}, step, count + 1)
    end)
  end

  def to_pair([one, two], list_pair) do
    list_pair ++ [one <> two]
  end

  def to_pair([one, two | rest], list_pair) do
    result = list_pair ++ [one <> two]
    to_pair([two | rest], result)
  end

  @spec join_triple([binary, ...], binary) :: binary
  def join_triple([last], result), do: result <> last

  def join_triple([head | rest], result) do
    next = result <> String.at(head, 0) <> String.at(head, 1)
    join_triple(rest, next)
  end

  def string_match(pair, rule) do
    Map.get(rule, pair)
  end

  def find_increase(poly, rule, step \\ 20) do
    letter = String.at(poly, 0)
    letter2 = String.at(poly, 1)

    {poly, rule}
    |> insert_smart(step)
    |> List.flatten()
    |> join_triple("")
    |> String.graphemes()
    |> Enum.frequencies()
    |> Map.get_and_update(letter, fn value -> {value - 1, value - 1} end)
    |> elem(1)
    |> Map.get_and_update(letter2, fn value -> {value - 1, value - 1} end)
    |> elem(1)
  end

  def calculate_pair_to_count(rule) do
    rule
    |> Map.keys()
    |> Enum.reduce(%{}, fn key, acc ->
      result_map = find_increase(key, rule)
      Map.put(acc, key, result_map)
    end)
  end

  def solve_it() do
    {poly, rule} =
      file()
      |> parse

    poly_20 =
      insert_smart({poly, rule}, 20)
      |> List.flatten()
      |> join_triple("")
      |> IO.inspect()

    quick_map = calculate_pair_to_count(rule) |> IO.inspect()

    result =
      poly_20
      |> String.graphemes()
      |> process_pair_by_pair(quick_map, %{})
      |> Map.values()

    Enum.max(result) - Enum.min(result)
  end

  def process_pair_by_pair([one], _quick_map, sum) do
    value = Map.get(sum, one)
    Map.put(sum, one, value + 1)
  end

  def process_pair_by_pair([one, two], quick_map, sum) do
    key = one <> two
    map_value = Map.get(quick_map, key)

    new_sum =
      Map.merge(sum, map_value, fn _k, v1, v2 -> v1 + v2 end)
      |> Map.get_and_update(one, fn value -> {value + 1, value + 1} end)
      |> elem(1)

    process_pair_by_pair([two], quick_map, new_sum)
  end

  def process_pair_by_pair([one, two | rest], quick_map, sum) do
    key = one <> two
    map_value = Map.get(quick_map, key)

    new_sum =
      Map.merge(sum, map_value, fn _k, v1, v2 -> v1 + v2 end)
      |> Map.get_and_update(one, fn value -> {value + 1, value + 1} end)
      |> elem(1)

    process_pair_by_pair([two | rest], quick_map, new_sum)
  end
end
