defmodule Day5 do
  def file do
    Parser.read_file(5)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    {rules, ["" | updates]} = Enum.split_while(input, &(&1 != ""))
    rules = Enum.map(rules, &format_rules/1)

    updates =
      updates
      |> Enum.map(fn string -> string |> String.split(",") |> Enum.map(&String.to_integer/1) end)

    {rules, updates}
  end

  def format_rules(<<nb1::bytes-size(2)>> <> "|" <> <<nb2::bytes-size(2)>>) do
    {String.to_integer(nb1), String.to_integer(nb2)}
  end

  def solve(input \\ file()) do
    {rules, updates} = input |> parse()

    updates
    |> Enum.reject(&check_one_line(&1, rules))
    # |> IO.inspect()
    |> Enum.map(&find_middle/1)
    |> Enum.sum()
  end

  def check_one_line(line, rules) do
    Enum.any?(rules, fn {one, two} ->
      index_one = Enum.find_index(line, &(&1 == one))
      index_two = Enum.find_index(line, &(&1 == two))

      cond do
        is_nil(index_one) -> false
        is_nil(index_two) -> false
        index_one > index_two -> true
        true -> false
      end
    end)
  end

  def find_middle(line) do
    middle = (length(line) - 1) |> div(2)
    Enum.at(line, middle)
  end

  def solve_two(input \\ file()) do
    {rules, updates} = input |> parse()

    updates
    |> Enum.filter(&check_one_line(&1, rules))
    |> Enum.map(&fix_incorrect_line(&1, rules))
    |> Enum.map(&find_middle/1)
    |> Enum.sum()
  end

  def fix_incorrect_line(line, rules) do
    indexed_map = line |> Stream.with_index() |> Map.new()

    do_until_correct(indexed_map, rules)
  end

  def do_until_correct(indexed_map, rules) do
    as_line =
      indexed_map
      |> Enum.map(& &1)
      |> Enum.sort_by(&elem(&1, 1))
      |> Enum.reverse()
      |> Enum.map(&elem(&1, 0))

    if !check_one_line(as_line, rules) do
      as_line
    else
      re_order(indexed_map, rules) |> do_until_correct(rules)
    end
  end

  def re_order(indexed_map, rules) do
    Enum.reduce(rules, indexed_map, fn {key1, key2}, map ->
      index_one = Map.get(map, key1)
      index_two = Map.get(map, key2)

      if is_nil(index_one) || is_nil(index_two) do
        map
      else
        if index_one < index_two do
          map
          |> Map.put(key1, index_two)
          |> Map.put(key2, index_one)
        else
          map
        end
      end
    end)
  end
end
