defmodule Day8 do
  # @max 4
  # @min 0

  @max 98
  @min 0
  def file do
    Parser.read_file(8)
  end

  def test do
    Parser.read_file("test")
  end

  def part_one() do
    map = file() |> format()

    map
    |> Enum.filter(fn tree -> visible(map, tree) end)
    |> Enum.count()
  end

  def format(file) do
    file
    |> Enum.map(fn string -> string |> String.graphemes() |> Enum.map(&String.to_integer/1) end)
    |> Utils.nested_list_to_xy_map()
  end

  def visible(_map, {{@min, _}, _height}), do: true
  def visible(_map, {{@max, _}, _height}), do: true
  def visible(_map, {{_, @min}, _height}), do: true
  def visible(_map, {{_, @max}, _height}), do: true

  def visible(map, {{x, y}, height}) do
    from_left(map, {x, y}, height) || from_right(map, {x, y}, height) ||
      from_top(map, {x, y}, height) || from_bottom(map, {x, y}, height)
  end

  def from_left(map, {x, y}, height) do
    Enum.map(@min..x, fn index -> Map.get(map, {index, y}, 0) end)
    |> Enum.all?(fn tree_height -> tree_height < height end)
  end

  def from_right(map, {x, y}, height) do
    map = Map.delete(map, {x, y})

    Enum.map(x..@max, fn index -> Map.get(map, {index, y}, 0) end)
    |> Enum.all?(fn tree_height -> tree_height < height end)
  end

  def from_top(map, {x, y}, height) do
    map = Map.delete(map, {x, y})

    Enum.map(@min..y, fn index -> Map.get(map, {x, index}, 0) end)
    |> Enum.all?(fn tree_height -> tree_height < height end)
  end

  def from_bottom(map, {x, y}, height) do
    map = Map.delete(map, {x, y})

    Enum.map(y..@max, fn index -> Map.get(map, {x, index}, 0) end)
    |> Enum.all?(fn tree_height -> tree_height < height end)
  end
end
