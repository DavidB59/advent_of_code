defmodule Day17 do
  def file do
    Parser.read_file(17)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Enum.map(fn string -> string |> String.graphemes() |> Enum.map(&String.to_integer/1) end)
    |> Utils.nested_list_to_xy_map()
  end

  def solve(input \\ file()) do
    path1 = %{total_cost: 4, points: [{1, 0}, {0, 0}, nil]}
    path2 = %{total_cost: 3, points: [{0, 1}, {0, 0}, nil]}
    paths = [path1, path2]
    map = parse(input)
    target = map |> Map.keys() |> Enum.max()

    find_shortest_path(map, paths, target)
  end

  def find_shortest_path(map, paths, target) do
    shortest_path = Enum.sort_by(paths, & &1.total_cost) |> List.first()
    next_possible_points = possible_next_point(shortest_path)

    case target_reached(next_possible_points, target) do
      nil ->
        keep_searching(map, paths, target, shortest_path, next_possible_points)

      _ ->
        shortest_path.total_cost
    end
  end

  def target_reached(list, target) do
    # spect(list)
    # IO.inspecIO.int(target)
    Enum.find(list, &(&1 == target))
  end

  def keep_searching(map, paths, target, shortest_path, next_possible_points) do
    list =
      Enum.reduce(next_possible_points, [], fn point, acc ->
        with cost when not is_nil(cost) <- Map.get(map, point),
             false <- Enum.member?(shortest_path.points, point) do
          [{point, cost} | acc]
        else
          _ -> acc
        end
      end)

    new_path =
      Enum.map(list, fn {point, cost} ->
        shortest_path
        |> Map.update!(:total_cost, &(&1 + cost))
        |> Map.update!(:points, fn points -> [point | points] end)
      end)

    removed_previous = paths |> List.delete(shortest_path)

    new_paths = new_path ++ removed_previous
    find_shortest_path(map, new_paths, target)
  end

  # aligned along x
  def possible_next_point(%{points: [{x, y}, {x, _}, {x, _} | _]}) do
    [{x + 1, y}, {x - 1, y}]
  end

  # aligned along y
  def possible_next_point(%{points: [{x, y}, {_, y}, {_, y} | _]}) do
    [{x, y - 1}, {x, y + 1}]
  end

  # Maybe can be optimized with different clause
  def possible_next_point(%{points: [current, previous | _]}) do
    Utils.neighbours_no_diagonale(current) |> List.delete(previous)
  end
end
