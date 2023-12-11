defmodule Day11 do
  def file do
    Parser.read_file(11)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input, enlarge_by) do
    galaxy_map =
      input
      |> Utils.to_list_of_list()
      |> Utils.nested_list_to_xy_map()
      |> Enum.filter(fn {_coords, value} -> value == "#" end)
      |> Stream.with_index()
      |> Map.new(fn {{coord, _}, index} -> {index, coord} end)

    {x_galaxy_list, y_galaxy_list} =
      galaxy_map
      |> Map.values()
      |> Enum.reduce({[], []}, fn {x, y}, {list_x, list_y} -> {[x | list_x], [y | list_y]} end)

    index_duplicate_line =
      0..Enum.max(y_galaxy_list) |> Enum.reject(&Enum.member?(y_galaxy_list, &1))

    index_duplicate_colum =
      0..Enum.max(x_galaxy_list) |> Enum.reject(&Enum.member?(x_galaxy_list, &1))

    Map.new(galaxy_map, fn {index, {x, y}} ->
      x = expand_universe(x, index_duplicate_colum, enlarge_by)
      y = expand_universe(y, index_duplicate_line, enlarge_by)

      {index, {x, y}}
    end)
  end


  def expand_universe(coordinate, list_duplicate_coordinate, enlarge_by) do
    multiplicator = list_duplicate_coordinate |> Enum.filter(&(&1 < coordinate)) |> Enum.count()
    coordinate + multiplicator * (enlarge_by - 1)
  end

  def solve(input) do
    input
    |> parse(2)
    |> find_all_path()
    |> Map.values()
    |> Enum.sum()
  end

  def solve_two(input) do
    input
    |> parse(1_000_000)
    |> find_all_path()
    |> Map.values()
    |> Enum.sum()
  end

  def find_all_path(galaxies_map) do
    limit = galaxies_map |> Map.keys() |> Enum.max()

    Enum.reduce(0..limit, %{}, fn source, acc ->
      Enum.reduce(0..limit, acc, fn
        ^source, acc ->
          acc

        target, acc ->
          if Map.get(acc, {source, target}) || Map.get(acc, {target, source}) do
            acc
          else
            source_coordinate = Map.get(galaxies_map, source)
            target_coordinate = Map.get(galaxies_map, target)

            path = distance_between_two_points(source_coordinate, target_coordinate)
            Map.put(acc, {source, target}, path)
          end
      end)
    end)
  end

  def distance_between_two_points({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end
end
