defmodule Day1 do
  def file do
    Parser.read_file(1)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn string ->
      string
      |> String.split(" ")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.reduce({[], []}, fn [one, two], {list_one, list_two} ->
      {[one | list_one], [two | list_two]}
    end)
  end

  def solve(input \\ file()) do
    {list_one, list_two} = parse(input)

    sorted_1 = Enum.sort(list_one)
    sorted_2 = Enum.sort(list_two)
    length = length(sorted_1)

    Enum.map(1..length, fn nb ->
      index = nb - 1
      diff = Enum.at(sorted_1, index) - Enum.at(sorted_2, index)
      abs(diff)
    end)
    |> Enum.reduce(fn a, b -> a + b end)
  end

  def solve_two(input \\ file()) do
    {list_one, list_two} = parse(input)

    list_one
    |> Enum.map(fn number ->
      count = Enum.filter(list_two, &(&1 == number)) |> length()
      count * number
    end)
    |> Enum.reduce(fn a, b -> a + b end)
  end
end
