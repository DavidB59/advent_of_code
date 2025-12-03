defmodule Day3 do
  def file do
    Parser.read_file(3)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    Enum.map(input, fn batteries_bank ->
      batteries_bank
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def solve(input \\ file()) do
    input
    |> parse()
    |> Enum.map(&find_max(&1, 2))
    |> Enum.sum()
  end

  def solve_two(input \\ file()) do
    input
    |> parse()
    |> Enum.map(&find_max(&1, 12))
    |> Enum.sum()
  end

  def find_max(list, nb_digits) do
    list
    |> find_max_recursive(nb_digits)
    |> Integer.undigits()
  end

  def find_max_recursive(list, max_length, acc \\ [])
  def find_max_recursive(_list, 0, acc), do: acc

  def find_max_recursive(list, max_length, acc) do
    length = length(list)

    if length == max_length do
      acc ++ list
    else
      first =
        list
        |> Enum.take(length - max_length + 1)
        |> Enum.max()

      index = Enum.find_index(list, &(&1 == first))

      list
      |> Enum.split(index + 1)
      |> elem(1)
      |> find_max_recursive(max_length - 1, acc ++ [first])
    end
  end
end
