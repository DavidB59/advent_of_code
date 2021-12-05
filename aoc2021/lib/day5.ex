defmodule Day5 do
  def file do
    Parser.read_file("day5")
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Enum.map(fn string ->
      [a, b] = String.split(string, " -> ")
      [x1, y1] = String.split(a, ",") |> Enum.map(&String.to_integer/1)
      [x2, y2] = String.split(b, ",") |> Enum.map(&String.to_integer/1)
      {{x1, y1}, {x2, y2}}
    end)
  end

  def map_occupied_points(list) do
    Enum.reduce(list, %{}, fn
      {{x, y1}, {x, y2}}, acc ->
        # line of y
        y1..y2
        |> Enum.map(fn y -> {{x, y}, 1} end)
        |> Map.new()
        |> Map.merge(acc, fn _k, v1, v2 -> v1 + v2 end)

      {{x1, y}, {x2, y}}, acc ->
        # line of x
        x1..x2
        |> Enum.map(fn x -> {{x, y}, 1} end)
        |> Map.new()
        |> Map.merge(acc, fn _k, v1, v2 -> v1 + v2 end)

      {{x1, y1}, {x2, y2}}, acc ->
        # diagonals
        if y2 > y1 do
          x1..x2
          |> Stream.with_index()
          |> Enum.map(fn {x, index} -> {{x, y1 + index}, 1} end)
          |> Map.new()
          |> Map.merge(acc, fn _k, v1, v2 -> v1 + v2 end)
        else
          x1..x2
          |> Stream.with_index()
          |> Enum.map(fn {x, index} -> {{x, y1 - index}, 1} end)
          |> Map.new()
          |> Map.merge(acc, fn _k, v1, v2 -> v1 + v2 end)
        end
    end)
  end

  def solve() do
    file()
    |> parse()
    |> map_occupied_points()
    |> Map.values()
    |> Enum.count(&(&1 > 1))
  end
end
