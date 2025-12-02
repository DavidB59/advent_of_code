defmodule Day2 do
  def file do
    Parser.read_file(2)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Enum.join()
    |> String.split(",")
    |> Enum.map(&(&1 |> String.split("-") |> Enum.map(fn a -> String.to_integer(a) end)))
  end

  def solve_two(input \\ file()) do
    input
    |> parse()
    |> Enum.reduce([], fn range, acc ->
      found = find_invalid_ids_in_range_two(range)
      found ++ acc
    end)
    |> Enum.sum()
  end

  def find_invalid_ids_in_range_two([alpha, omega]) do
    range = alpha..omega
    Enum.filter(range, &is_invalid_two?/1)
  end

  def is_invalid_two?(number) do
    string = number |> Integer.to_string()

    length = string |> String.length()

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

  def solve(input \\ file()) do
    input
    |> parse()
    |> Enum.reduce([], fn range, acc ->
      found = find_invalid_ids_in_range(range)
      found ++ acc
    end)
    |> Enum.sum()
  end

  def find_invalid_ids_in_range([alpha, omega]) do
    range = alpha..omega
    Enum.filter(range, &is_invalid?/1)
  end

  def is_invalid?(number) do
    string =
      number
      |> Integer.to_string()

    length = string |> String.length()
    {a, b} = String.split_at(string, (length / 2) |> trunc())
    a == b
  end
end
