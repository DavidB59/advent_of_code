defmodule Day11 do
  def file do
    Parser.read_file(11)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input, enlarge_by) do
    index_duplicate_line = input |> add_extra_line() |> Enum.map(&elem(&1, 1)) |> IO.inspect()
    index_duplicate_colum = input |> add_extra_column() |> Enum.map(&elem(&1, 1)) |> IO.inspect()

    input
    |> Utils.to_list_of_list()
    |> Utils.nested_list_to_xy_map()
    |> Enum.filter(fn {_coords, value} -> value == "#" end)
    |> Stream.with_index()
    |> Map.new(fn {{coord, _}, index} -> {index, coord} end)
    |> Enum.reduce(%{}, fn {index, {x, y}}, acc ->
      multiplicator = Enum.filter(index_duplicate_colum, &(&1 < x)) |> Enum.count()
      x = x + multiplicator * enlarge_by - multiplicator
      multiplicator = Enum.filter(index_duplicate_line, &(&1 < y)) |> Enum.count()
      y = y + multiplicator * enlarge_by - multiplicator
      Map.put(acc, index, {x, y})
    end)
  end

  def add_extra_column(list) do
    nb_of_columns = list |> List.first() |> String.length() |> Kernel.-(1)

    line_map =
      list
      |> Stream.with_index()
      |> Map.new(fn {a, b} -> {b, a} end)

    nb_of_lines = line_map |> Map.keys() |> Enum.max()

    Enum.reduce(0..nb_of_columns, {line_map, %{}}, fn column_nb, {line_map, column_map} ->
      Enum.reduce(0..nb_of_lines, {line_map, column_map}, fn line_nb, {line_map, column_map} ->
        string = Map.get(line_map, line_nb)
        {first, rest} = String.split_at(string, 1)

        current_value = Map.get(column_map, column_nb, "")
        new_value = first <> current_value
        c_map = Map.put(column_map, column_nb, new_value)
        l_map = line_map |> Map.put(line_nb, rest)
        {l_map, c_map}
      end)
    end)
    |> elem(1)
    |> Enum.map(& &1)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(&elem(&1, 1))
    |> add_extra_line()
  end

  def add_extra_line(input) do
    input
    |> Stream.with_index()
    |> Enum.reject(&(&1 |> elem(0) |> String.contains?("#")))
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

    0..limit
    |> Enum.reduce(%{}, fn source, acc ->
      Enum.reduce(0..limit, acc, fn
        ^source, acc2 ->
          acc2

        target, acc2 ->
          if Map.get(acc2, {source, target}) || Map.get(acc2, {target, source}) do
            acc2
          else
            source_coordinate = Map.get(galaxies_map, source)
            target_coordinate = Map.get(galaxies_map, target)

            path = distance_between_two_points(source_coordinate, target_coordinate, 0)
            Map.put(acc2, {source, target}, path)
          end
      end)
    end)
  end

  def distance_between_two_points({x1, y1}, {x1, y1}, current), do: current

  def distance_between_two_points({x1, y1}, {x1, y2}, current) do
    abs(y2 - y1) + current
  end

  def distance_between_two_points({x1, y1}, {x2, y1}, current) do
    abs(x2 - x1) + current
  end

  def distance_between_two_points({x1, y1}, {x2, y2}, current) do
    new_x =
      if x1 > x2 do
        x1 - 1
      else
        x1 + 1
      end

    new_y =
      if y1 > y2 do
        y1 - 1
      else
        y1 + 1
      end

    distance_between_two_points({new_x, new_y}, {x2, y2}, current + 2)
  end
end
