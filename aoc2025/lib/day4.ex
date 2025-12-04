defmodule Day4 do
  def file, do: Parser.read_file(4)
  def test, do: Parser.read_file("test")

  def parse(input) do
    Utils.to_xy_map(input)
  end

  def solve(input \\ file()) do
    map = parse(input)

    map
    |> Enum.reduce(0, fn
      {_pos, "."}, acc -> acc
      {pos, _value}, acc -> if four_rolls?(pos, map), do: acc + 1, else: acc
    end)
  end

  def four_rolls?(pos, map) do
    pos
    |> Utils.neighbours_coordinates()
    |> Enum.filter(fn coord -> Map.get(map, coord) == "@" end)
    |> Enum.count()
    |> Kernel.<(4)
  end

  def solve_two(input \\ file()) do
    map = parse(input)
    remove_rolls({map, 0})
  end

  def remove_rolls(tuple, map \\ %{})
  def remove_rolls({map, counter}, map), do: counter

  def remove_rolls({map, _counter} = tuple, _oldmap) do
    map
    |> Enum.reduce(tuple, fn
      {_pos, "."}, acc ->
        acc

      {pos, _value}, {updated_map, counter} ->
        if four_rolls?(pos, updated_map) do
          {Map.put(updated_map, pos, "."), counter + 1}
        else
          {updated_map, counter}
        end
    end)
    |> remove_rolls(map)
  end
end
