defmodule Day9 do
  def file do
    Parser.read_file("day9")
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input |> Enum.map(&String.graphemes/1) |> Utils.list_list_to_graph()
  end

  def find_low_points(input) do
    Enum.filter(input, fn {{x, y}, value} ->
      list =
        [
          Map.get(input, {x + 1, y}),
          Map.get(input, {x - 1, y}),
          Map.get(input, {x, y + 1}),
          Map.get(input, {x, y - 1})
        ]
        |> Enum.reject(&is_nil/1)

      Enum.min(list) > value
    end)
  end

  def solve do
    file()
    |> parse()
    |> find_low_points()
    |> Enum.map(&elem(&1, 1))
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(fn x -> x + 1 end)
    |> Enum.sum()
  end

  def find_bassin(low_point, input) do
    low_points = find_higher_points(low_point, input)

    ([low_point | low_points] ++ find_all(low_points, input))
    |> List.flatten()
    |> Enum.reject(&(&1 == []))
    |> Enum.uniq()
  end

  def find_all(low_points, input) do
    Enum.reduce(low_points, [], fn low_point, acc ->
      new_points = find_higher_points(low_point, input)

      if new_points == [] do
        [new_points | acc]
      else
        more_points = find_all(new_points, input)
        more_points ++ new_points ++ acc
      end
    end)
  end

  def find_higher_points({{x, y}, value}, input) do
    all_adjacents(x, y)
    |> Enum.reduce([], fn key, acc ->
      new_val = Map.get(input, key)

      if is_part_of_basin(new_val, value) do
        [{key, new_val} | acc]
      else
        acc
      end
    end)
  end

  def is_part_of_basin("9", _value), do: false
  def is_part_of_basin(_, nil), do: false
  def is_part_of_basin(new_val, value), do: new_val > value

  defp all_adjacents(x, y) do
    [
      {x + 1, y},
      {x - 1, y},
      {x, y + 1},
      {x, y - 1}
    ]
  end

  def solve_part_two() do
    input = file() |> parse()

    [a, b, c] =
      input
      |> find_low_points()
      |> Enum.map(&find_bassin(&1, input))
      |> Enum.map(fn bassin -> Enum.count(bassin) end)
      |> Enum.sort()
      |> Enum.reverse()
      |> Enum.slice(0..2)

    a * b * c
  end
end
