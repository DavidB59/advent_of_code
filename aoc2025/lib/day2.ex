defmodule Day2 do
  def file, do: Parser.read_file(2)
  def test, do: Parser.read_file("test")

  def parse(input) do
    input
    |> Enum.join()
    |> String.split(",")
    |> Enum.map(&(&1 |> String.split("-") |> Enum.map(fn a -> String.to_integer(a) end)))
  end

  def solve(input \\ file()) do
    input
    |> parse()
    |> Enum.reduce([], fn range, acc ->
      range
      |> find_invalid_ids_in_range(&is_symmetric?/1)
      |> Enum.concat(acc)
    end)
    |> Enum.sum()
  end

  def solve_two(input \\ file()) do
    input
    |> parse()
    |> Enum.reduce([], fn range, acc ->
      range
      |> find_invalid_ids_in_range(&contain_pattern?/1)
      |> Enum.concat(acc)
    end)
    |> Enum.sum()
  end

  def find_invalid_ids_in_range([alpha, omega], filter_function) do
    Enum.filter(alpha..omega, &filter_function.(&1))
  end

  def is_symmetric?(number) do
    string = Integer.to_string(number)
    length = String.length(string)
    {a, b} = String.split_at(string, (length / 2) |> trunc())
    a == b
  end

  def contain_pattern?(number) do
    string = Integer.to_string(number)
    length = String.length(string)

    if length == 1 do
      false
    else
      divide_by = Enum.filter(2..length, fn a -> rem(length, a) == 0 end)
      Enum.any?(divide_by, &is_invalid_multiple(string, length, &1))
    end
  end

  def is_invalid_multiple(string, length, divide_by) do
    slice_to = trunc(length / divide_by) - 1
    pattern = string |> String.slice(0..slice_to)
    String.duplicate(pattern, divide_by) == string
  end
end
