defmodule Day3 do
  def file do
    Parser.read_file("day3")
  end

  def test do
    [
      "00100",
      "11110",
      "10110",
      "10111",
      "10101",
      "01111",
      "00111",
      "11100",
      "10000",
      "11001",
      "00010",
      "01010"
    ]
  end

  def parse(input) do
    input
    |> Enum.reduce(%{}, fn string, acc ->
      string
      |> String.graphemes()
      |> Utils.list_to_index_map()
      |> Map.merge(acc, fn
        _k, v1, v2 when is_list(v2) -> [v1 | v2]
        _k, v1, v2 -> [v1, v2]
      end)
    end)
  end

  def gamma(parsed_input) do
    Enum.reduce(parsed_input, "", fn {_key, value}, acc ->
      {one, zero} = Enum.split_with(value, &(&1 == "1"))
      bit = if Enum.count(one) >= Enum.count(zero), do: "1", else: "0"
      acc <> bit
    end)
  end

  def epsilon(parsed_input) do
    Enum.reduce(parsed_input, "", fn {_key, value}, acc ->
      {one, zero} = Enum.split_with(value, &(&1 == "1"))
      bit = if Enum.count(zero) > Enum.count(one), do: "1", else: "0"
      acc <> bit
    end)
  end

  def binary_to_decimal(string) do
    string |> Integer.parse(2) |> elem(0)
  end

  def solve_part_one do
    parsed_input = file() |> parse()
    epsilon = epsilon(parsed_input) |> binary_to_decimal
    gamma = gamma(parsed_input) |> binary_to_decimal
    gamma * epsilon
  end

  def solve_part_two do
    input = file()
    oxygen = find_element(input, &gamma/1) |> binary_to_decimal
    carbon_dioxide = find_element(input, &epsilon/1) |> binary_to_decimal
    oxygen * carbon_dioxide
  end

  def find_element(input, function, index \\ 0)
  def find_element([input], _, _), do: input

  def find_element(input, function, index) do
    filter_value =
      input
      |> parse()
      |> function.()

    input
    |> Enum.filter(&(String.at(&1, index) == String.at(filter_value, index)))
    |> find_element(function, index + 1)
  end
end
