defmodule Day1 do
  def file do
    # "day1" |> Parser.read_file()
    Parser.read_file(1)
  end

  def test do
    "test" |> Parser.read_file()
  end

  def format(file) do
    file
    |> Enum.chunk_by(&(&1 == ""))
    |> Enum.reject(&(&1 == [""]))
    |> Enum.map(fn a -> Enum.map(a, &String.to_integer/1) |> Enum.sum() end)
  end

  def part_one do
    file()
    |> format()
    |> Enum.max()
  end

  def part_two do
    file()
    |> format()
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.take(3)
    |> Enum.sum()
  end
end
