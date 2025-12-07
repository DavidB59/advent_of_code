defmodule Day5 do
  def file, do: Parser.read_file(5)
  def test, do: Parser.read_file("test")

  def parse(input) do
    input
    |> Enum.reduce(%{ranges: [], ingredients: []}, fn
      "", acc ->
        acc

      line, acc ->
        if String.contains?(line, "-") do
          range = to_range(line)
          Map.update!(acc, :ranges, fn a -> [range | a] end)
        else
          ingredient = String.to_integer(line)
          Map.update!(acc, :ingredients, fn a -> [ingredient | a] end)
        end
    end)
  end

  def to_range(line) do
    line
    |> String.split("-")
    |> Enum.map(&String.to_integer/1)
  end

  def part_one(input \\ file()) do
    %{ranges: ranges, ingredients: ingredients} = parse(input)

    ingredients
    |> Enum.filter(fn ing -> Enum.any?(ranges, &is_fresh?(ing, &1)) end)
    |> Enum.count()
  end

  def is_fresh?(ingredient, [a, b]), do: ingredient >= a and ingredient <= b

  def part_two(input \\ file()) do
    input
    |> parse
    |> Map.get(:ranges)
    |> merge_ranges([])
    |> Enum.uniq()
    |> Enum.map(fn [a, b] -> b - a + 1 end)
    |> Enum.sum()
  end

  def merge_ranges(list, list), do: list

  def merge_ranges(list, _old_list) do
    list
    |> Enum.map(fn range1 -> Enum.reduce(list, range1, &try_merge(&2, &1)) end)
    |> merge_ranges(list)
  end

  def try_merge([range1_min, range1_max] = range1, [range2_min, range2_max] = range2) do
    if is_fresh?(range1_min, range2) || is_fresh?(range1_max, range2) do
      [min(range1_min, range2_min), max(range1_max, range2_max)]
    else
      range1
    end
  end
end
