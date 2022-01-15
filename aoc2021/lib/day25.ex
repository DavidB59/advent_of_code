defmodule Day25 do
  def file, do: Parser.read_file("day25")
  def test, do: Parser.read_file("test")

  def format(file) do
    file
    |> Enum.map(&String.graphemes/1)
    |> Utils.nested_list_to_xy_map()
  end

  def move_down(file, max_y) do
    Enum.reduce(file, %{}, fn
      {{x, y}, "v"}, acc ->
        y_destination = if y < max_y, do: y + 1, else: 0

        case Map.get(file, {x, y_destination}) do
          "." -> acc |> Map.put({x, y_destination}, "v") |> Map.put({x, y}, ".")
          _ -> Map.put(acc, {x, y}, "v")
        end

      {k, v}, acc ->
        if Map.get(acc, k), do: acc, else: Map.put(acc, k, v)
    end)
  end

  def move_east(file, max_x) do
    Enum.reduce(file, %{}, fn
      {{x, y}, ">"}, acc ->
        x_destination = if x < max_x, do: x + 1, else: 0

        case Map.get(file, {x_destination, y}) do
          "." -> acc |> Map.put({x_destination, y}, ">") |> Map.put({x, y}, ".")
          _ -> Map.put(acc, {x, y}, ">")
        end

      {k, v}, acc ->
        if Map.get(acc, k), do: acc, else: Map.put(acc, k, v)
    end)
  end

  def move_sea_cumcumber(position_map, x_max, y_max, old_map \\ %{}, step \\ 0)

  def move_sea_cumcumber(map, _x_max, _y_max, map, step), do: step

  def move_sea_cumcumber(position_map, x_max, y_max, _old_map, step) do
    position_map
    |> move_east(x_max)
    |> move_down(y_max)
    |> move_sea_cumcumber(x_max, y_max, position_map, step + 1)
  end

  def solve_part_one() do
    input = file() |> format()
    {x_max, y_max} = input |> Map.keys() |> Enum.max()

    move_sea_cumcumber(input, x_max, y_max)
  end

  def undo_map(map, x_max, y_max) do
    Enum.map(0..y_max, fn y ->
      Enum.reduce(0..x_max, "", fn x, acc ->
        acc <> Map.get(map, {x, y})
      end)
    end)
    |> Enum.each(&IO.inspect(&1))
  end
end
