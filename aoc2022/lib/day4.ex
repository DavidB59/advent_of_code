defmodule Day4 do
  def file do
    Parser.read_file(4)
  end

  def part_one do
    file()
    |> Enum.reduce(0, fn string, acc ->
      [s1, e1, s2, e2] =
        string
        |> String.split(",")
        |> Enum.map(&String.split(&1, "-"))
        |> List.flatten()
        |> Enum.map(&String.to_integer/1)

      r1 = s1..e1 |> MapSet.new()
      r2 = s2..e2 |> MapSet.new()

      cond do
        MapSet.subset?(r1, r2) -> acc + 1
        MapSet.subset?(r2, r1) -> acc + 1
        true -> acc
      end
    end)
  end

  def part_two do
    file()
    |> Enum.reduce(0, fn string, acc ->
      [s1, e1, s2, e2] =
        string
        |> String.split(",")
        |> Enum.map(&String.split(&1, "-"))
        |> List.flatten()
        |> Enum.map(&String.to_integer/1)

      r1 = s1..e1 |> MapSet.new()
      r2 = s2..e2 |> MapSet.new()

      cond do
        MapSet.disjoint?(r1, r2) -> acc
        true -> acc + 1
      end
    end)
  end
end
