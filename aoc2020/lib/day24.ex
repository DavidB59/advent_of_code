defmodule Day24 do
  @moduledoc """
  Documentation for day24.
  """

  def part_one() do
    file() |> solve_one
  end

  def file() do
    Parser.read_file("day24")
  end

  def format(file) do
    file
  end

  def solve_one(file) do
    file
    |> get_map_tile()
    |> Enum.filter(fn {_key, value} -> value == "black" end)
    |> Enum.count()
  end

  def get_map_tile(file) do
    Enum.reduce(file, %{}, fn string, acc ->
      {x, y} = cut_line(string)
      current_tile_color = Map.get(acc, {x, y})

      tile_color =
        case current_tile_color do
          nil ->
            "black"

          "black" ->
            "white"

          "white" ->
            "black"
        end

      Map.put(acc, {x, y}, tile_color)
    end)
  end

  def solve_two(file, days) do
    file
    |> get_map_tile()
    |> flip_for_x_days(days)
    |> Enum.filter(fn {_key, value} -> value == "black" end)
    |> Enum.count()
  end

  def flip_for_x_days(tile_map, last_day, days \\ 0)
  def flip_for_x_days(tile_map, last_day, last_day), do: tile_map

  def flip_for_x_days(tile_map, last_day, days) do
    new_tile_map = tile_map |> populate_tile_map |> flip_tile_after_one_day()
    flip_for_x_days(new_tile_map, last_day, days + 1)
  end

  def populate_tile_map(tile_map) do
    tile_map
    |> Enum.reduce(tile_map, fn {key, _value}, acc ->
      neighbours = get_neighbour_coordinates(key)
      Enum.reduce(neighbours, acc, fn coords, acc2 -> Map.put_new(acc2, coords, "white") end)
    end)
  end

  def flip_tile_after_one_day(tile_map) do
    Enum.reduce(tile_map, %{}, fn {key, tile_color}, acc ->
      nb_black_adj_tiles =
        tile_map
        |> get_colors_adjacent_tiles(key)
        |> Enum.filter(&(&1 == "black"))
        |> Enum.count()

      new_tile_color = new_tile_color(tile_color, nb_black_adj_tiles)
      Map.put(acc, key, new_tile_color)
    end)
  end

  def new_tile_color("black", 0), do: "white"
  def new_tile_color("black", nb) when nb > 2, do: "white"
  def new_tile_color("white", 2), do: "black"
  def new_tile_color(color, _), do: color

  def get_colors_adjacent_tiles(tile_map, {x, y}) do
    ["e", "sw", "se", "nw", "ne", "w"]
    |> Enum.map(&move(&1, {x, y}))
    |> Enum.map(&Map.get(tile_map, &1))
  end

  def get_neighbour_coordinates({x, y}) do
    ["e", "sw", "se", "nw", "ne", "w"]
    |> Enum.map(&move(&1, {x, y}))
  end

  def cut_line(string, {x, y} \\ {0, 0}) do
    cond do
      String.starts_with?(string, "se") ->
        {new_x, new_y} = move("se", {x, y})
        {_, new_string} = String.split_at(string, 2)
        cut_line(new_string, {new_x, new_y})

      String.starts_with?(string, "sw") ->
        {new_x, new_y} = move("sw", {x, y})
        {_, new_string} = String.split_at(string, 2)
        cut_line(new_string, {new_x, new_y})

      String.starts_with?(string, "nw") ->
        {new_x, new_y} = move("nw", {x, y})
        {_, new_string} = String.split_at(string, 2)
        cut_line(new_string, {new_x, new_y})

      String.starts_with?(string, "ne") ->
        {new_x, new_y} = move("ne", {x, y})
        {_, new_string} = String.split_at(string, 2)
        cut_line(new_string, {new_x, new_y})

      String.starts_with?(string, "e") ->
        {new_x, new_y} = move("e", {x, y})
        {_, new_string} = String.split_at(string, 1)
        cut_line(new_string, {new_x, new_y})

      String.starts_with?(string, "w") ->
        {new_x, new_y} = move("w", {x, y})
        {_, new_string} = String.split_at(string, 1)
        cut_line(new_string, {new_x, new_y})

      true ->
        {x, y}
    end
  end

  # e, se, sw, w, nw, and ne
  def move("e", {x, y}), do: {x - 2, y}
  def move("se", {x, y}), do: {x - 1, y - 1}
  def move("sw", {x, y}), do: {x + 1, y - 1}
  def move("w", {x, y}), do: {x + 2, y}
  def move("nw", {x, y}), do: {x + 1, y + 1}
  def move("ne", {x, y}), do: {x - 1, y + 1}
end
