defmodule Day20 do
  @moduledoc """
  Documentation for day20.
  """

  def part_one() do
    file() |> format() |> solve_one
  end

  def part_two() do
    file() |> format()
  end

  def test() do
    Parser.read_file("test") |> format() |> solve_one
  end

  def file() do
    Parser.read_file("day20")
  end

  def solve_one(tile_map) do
    Enum.map(tile_map, fn {tile_id, tile} ->
      {tile_id, get_borders(tile)}
    end)
    |> Map.new()
    |> find_number_borders()
    |> Enum.filter(fn
      {_tile_id, 2} -> true
      _ -> false
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.reduce(fn x, acc -> x * acc end)
  end

  # take map of  tiles map with borders
  def find_number_borders(tiles_map) do
    tiles_map
    |> Enum.map(fn {tile_id, tile_borders} ->
      count =
        Enum.reduce(tiles_map, 0, fn
          {^tile_id, _match_tile_borders}, count ->
            count

          {_match_tile_id, match_tile_borders}, count ->
            match = find_match(tile_borders, match_tile_borders)
            if match, do: count + 1, else: count
        end)

      {tile_id, count}
    end)
  end

  # take map tile with borders
  def find_match(tile1, tile2) do
    borders1 = Map.values(tile1)
    borders2 = Map.values(tile2)
    Enum.find(borders1, fn border -> Enum.find(borders2, &(&1 == border)) end)
  end

  def format(file) do
    file
    |> Enum.reduce({%{}, "", 0}, fn string, {map, current_tile, index} ->
      cond do
        String.starts_with?(string, "Tile") ->
          tile_id = string |> String.trim("Tile ") |> Integer.parse() |> elem(0)
          new_map = Map.put(map, tile_id, %{})
          {new_map, tile_id, 0}

        string == "" ->
          {map, current_tile, index}

        true ->
          tile =
            map
            |> Map.get(current_tile)
            |> Map.put(index, string)

          new_map = Map.put(map, current_tile, tile)
          {new_map, current_tile, index + 1}
      end
    end)
    |> give_coord_to_tiles()
  end

  def give_coord_to_tiles({map, _, _}) do
    map
    |> Enum.map(fn {key, value} ->
      new_value =
        Enum.reduce(value, %{}, fn {x_index, string}, acc ->
          string
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.reduce(%{}, fn {y_value, y_index}, acc ->
            Map.put(acc, {x_index, y_index}, y_value)
          end)
          |> Map.merge(acc)
        end)

      {key, new_value}
    end)
    |> Map.new()
  end

  def get_borders(tile) do
    [:left, :right, :up, :down]
    |> Enum.reduce(%{}, fn direction, acc ->
      border = get_border(direction, tile) |> Enum.join()
      reverse_border = String.reverse(border)
      reversed = direction |> Atom.to_string()
      reversed = (reversed <> "_r") |> String.to_atom()
      map = %{direction => border, reversed => reverse_border}
      Map.merge(acc, map)
    end)
  end

  def get_border(:left, tile) do
    Enum.map(0..9, fn coord -> Map.get(tile, {0, coord}) end)
  end

  def get_border(:right, tile) do
    Enum.map(0..9, fn coord -> Map.get(tile, {9, coord}) end)
  end

  def get_border(:up, tile) do
    Enum.map(0..9, fn coord -> Map.get(tile, {coord, 0}) end)
  end

  def get_border(:down, tile) do
    Enum.map(0..9, fn coord -> Map.get(tile, {coord, 9}) end)
  end
end
