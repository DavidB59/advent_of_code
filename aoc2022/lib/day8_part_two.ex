defmodule Day8_two do
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
    |> Enum.map(fn tree -> visible(map, tree) end)
    |> Enum.max()
  end

  def format(file) do
    file
    |> Enum.map(fn string -> string |> String.graphemes() |> Enum.map(&String.to_integer/1) end)
    |> Utils.nested_list_to_xy_map()
  end

  def visible(_map, {{@min, _}, _height}), do: 0
  def visible(_map, {{@max, _}, _height}), do: 0
  def visible(_map, {{_, @min}, _height}), do: 0
  def visible(_map, {{_, @max}, _height}), do: 0

  def visible(map, {{x, y}, height}) do
    from_left(map, {x, y}, height) * from_right(map, {x, y}, height) *
      from_top(map, {x, y}, height) * from_bottom(map, {x, y}, height)
  end

  def from_left(map, {x, y}, height) do
    map = Map.delete(map, {x, y})

    Enum.map((x - 1)..@min, fn index -> Map.get(map, {index, y}, 10) end)
    |> Enum.reduce_while(0, fn tree_height, acc ->
      if tree_height < height do
        {:cont, acc + 1}
      else
        {:halt, acc + 1}
      end
    end)
  end

  def from_right(map, {x, y}, height) do
    map = Map.delete(map, {x, y})

    Enum.map((x + 1)..@max, fn index -> Map.get(map, {index, y}, 10) end)
    |> Enum.reduce_while(0, fn tree_height, acc ->
      if tree_height < height do
        {:cont, acc + 1}
      else
        {:halt, acc + 1}
      end
    end)
  end

  def from_top(map, {x, y}, height) do
    map = Map.delete(map, {x, y})

    Enum.map((y - 1)..@min, fn index -> Map.get(map, {x, index}, 10) end)
    |> Enum.reduce_while(0, fn tree_height, acc ->
      if tree_height < height do
        {:cont, acc + 1}
      else
        {:halt, acc + 1}
      end
    end)
  end

  def from_bottom(map, {x, y}, height) do
    map = Map.delete(map, {x, y})

    Enum.map((y + 1)..@max, fn index -> Map.get(map, {x, index}, 10) end)
    |> Enum.reduce_while(0, fn tree_height, acc ->
      if tree_height < height do
        {:cont, acc + 1}
      else
        {:halt, acc + 1}
      end
    end)
  end
end
