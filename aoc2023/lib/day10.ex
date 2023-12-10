defmodule Day10 do
  def file do
    Parser.read_file(10)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Utils.to_list_of_list()
    |> Utils.nested_list_to_xy_map()
  end

  def solve(input) do
    map = parse(input)

    starting_point = Enum.find(map, fn {_a, b} -> b == "S" end)
    first_point_connect_to_start = find_connected_pipes(starting_point, map)

    loop =
      find_loop(first_point_connect_to_start, starting_point, map, [first_point_connect_to_start])

    (Enum.count(loop) + 1) / 2
  end

  def solve_two(input) do
    map = parse(input)

    starting_point = Enum.find(map, fn {_a, b} -> b == "S" end)
    first_point_connect_to_start = find_connected_pipes(starting_point, map)

    loop =
      find_loop(first_point_connect_to_start, starting_point, map, [first_point_connect_to_start])

    list = [starting_point | loop] |> Enum.map(&elem(&1, 0))
    boundary_points = Enum.count(list)
    area = Utils.polygon_area(list)

    # Picks Theorem
    # Area = interior_points + (boundary_points/2) - 1
    # therefore
    # interior_points = area - (boundary_points/2) + 1
    area - boundary_points / 2 + 1
  end

  def find_loop(point, {previous_coords, _}, map, loop \\ []) do
    map_without_previous = Map.delete(map, previous_coords)
    next_pipe = go_next_pipe(point, map_without_previous)

    if elem(next_pipe, 1) == "S" do
      loop
    else
      find_loop(next_pipe, point, map, [next_pipe | loop])
    end
  end

  def go_next_pipe({{x, y}, "-"}, map) do
    val1 = Map.get(map, {x + 1, y})

    if val1 do
      {{x + 1, y}, val1}
    else
      {{x - 1, y}, Map.get(map, {x - 1, y})}
    end
  end

  def go_next_pipe({{x, y}, "|"}, map) do
    val1 = Map.get(map, {x, y + 1})

    if val1 do
      {{x, y + 1}, val1}
    else
      {{x, y - 1}, Map.get(map, {x, y - 1})}
    end
  end

  def go_next_pipe({{x, y}, "L"}, map) do
    val1 = Map.get(map, {x, y - 1})

    if val1 do
      {{x, y - 1}, val1}
    else
      {{x + 1, y}, Map.get(map, {x + 1, y})}
    end
  end

  def go_next_pipe({{x, y}, "J"}, map) do
    val1 = Map.get(map, {x, y - 1})

    if val1 do
      {{x, y - 1}, val1}
    else
      {{x - 1, y}, Map.get(map, {x - 1, y})}
    end
  end

  def go_next_pipe({{x, y}, "7"}, map) do
    val1 = Map.get(map, {x, y + 1})

    if val1 do
      {{x, y + 1}, val1}
    else
      {{x - 1, y}, Map.get(map, {x - 1, y})}
    end
  end

  def go_next_pipe({{x, y}, "F"}, map) do
    val1 = Map.get(map, {x, y + 1})

    if val1 do
      {{x, y + 1}, val1}
    else
      {{x + 1, y}, Map.get(map, {x + 1, y})}
    end
  end

  def find_connected_pipes({coordinates, current_value}, map) do
    coordinates
    |> Utils.neighbours_no_diagonale()
    |> Enum.map(fn coords -> {coords, Map.get(map, coords)} end)
    |> Enum.find(fn {coords, value} ->
      connect?({coords, value}, {coordinates, current_value})
    end)
  end

  def connect?({{x1, y1}, val1}, {{x2, y2}, _}) do
    cond do
      # current value is on the right
      x1 == x2 + 1 and y1 == y2 -> val1 in ["-", "J", "7"]
      # on the left
      x1 == x2 - 1 and y1 == y2 -> val1 in ["-", "L", "F"]
      # below
      x1 == x2 and y1 == y2 + 1 -> val1 in ["|", "J", "L"]
      # above
      x1 == x2 and y1 == y2 - 1 -> val1 in ["|", "7", "F"]
    end
  end
end
