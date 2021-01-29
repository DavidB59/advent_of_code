defmodule Day17 do
  @moduledoc """
  Documentation for Day17.
  """

  def part_one() do
    file() |> format() |> solve_one
  end

  def test() do
    Parser.read_file("test") |> format() |> solve_one()
  end

  def file() do
    Parser.read_file("day17")
  end

  def solve_one(cube_map) do
    do_six_times(cube_map, 0)
    |> Enum.filter(fn {_key, state} -> state == "#" end)
    |> Enum.count()
  end

  def one_cycle(cubes_map) do
    Enum.reduce(cubes_map, %{}, fn {key, state}, result_map ->
      neighbours = all_neighbours(key)

      number_actives_adjacent_cubes =
        neighbours
        |> Enum.map(fn neighbour ->
          Map.get(cubes_map, neighbour, ".")
        end)
        |> Enum.filter(&(&1 == "#"))
        |> Enum.count()

      new_cube_state = new_cube_state(state, number_actives_adjacent_cubes)
      Map.put(result_map, key, new_cube_state)
    end)
  end

  def extend_map_by_one(cubes_map) do
    Enum.reduce(cubes_map, cubes_map, fn {key, _state}, result_map ->
      new = all_neighbours(key) |> Enum.reduce(%{}, fn key, acc -> Map.put(acc, key, ".") end)
      Map.merge(result_map, new, fn _k, v1, _v2 -> v1 end)
    end)
  end

  def do_six_times(cubes_map, 6), do: cubes_map

  def do_six_times(cubes_map, number) do
    cubes_map |> extend_map_by_one() |> one_cycle() |> do_six_times(number + 1)
  end

  def new_cube_state(cube_state, number_active_neighbours)
  def new_cube_state("#", 3), do: "#"
  def new_cube_state("#", 2), do: "#"
  def new_cube_state("#", _), do: "."

  def new_cube_state(".", 3), do: "#"
  def new_cube_state(".", _), do: "."

  # create a map with key a tuple coordinate {x,y,z}
  def format(file) do
    file
    |> Enum.with_index()
    |> Enum.map(fn {string, y_index} ->
      string
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {state, x_index} -> {{x_index, y_index, 0}, state} end)
    end)
    |> List.flatten()
    |> Map.new()
  end

  def all_neighbours({x, y, z}) do
    goes_through_all_x({x, y, z}) -- [{x, y, z}]
  end

  def goes_through_all_x({x, y, z}) do
    goes_through_all_y({x - 1, y, z}) ++
      goes_through_all_y({x, y, z}) ++
      goes_through_all_y({x + 1, y, z})
  end

  def goes_through_all_y({x, y, z}) do
    goes_through_all_z({x, y - 1, z}) ++
      goes_through_all_z({x, y, z}) ++
      goes_through_all_z({x, y + 1, z})
  end

  def goes_through_all_z({x, y, z}) do
    [{x, y, z + 1}] ++
      [{x, y, z}] ++
      [{x, y, z - 1}]
  end
end
