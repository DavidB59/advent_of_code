defmodule Day10_addingspace do
  def profile do
    test() |> solve_two()
  end

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
    map =
      input
      |> parse()

    starting_point = Enum.find(map, fn {_a, b} -> b == "S" end)
    first_point_connect_to_start = find_connected_pipes(starting_point, map)

    loop =
      find_loop(first_point_connect_to_start, starting_point, map, [first_point_connect_to_start])

    (Enum.count(loop) + 1) / 2
  end

  def add_point_on_the_outside(map) do
    keys = map |> Map.keys()
    max = keys |> Enum.max() |> elem(0)

    0..(max + 1)
    |> Enum.reduce(map, fn a, acc ->
      acc
      |> Map.put_new({-1, a}, ".")
      |> Map.put_new({a, -1}, ".")
      |> Map.put_new({max + 1, a}, ".")
      |> Map.put_new({a, max + 1}, ".")
    end)
  end

  def solve_two(input) do
    map =
      input
      |> parse()
      |> add_point_on_the_outside

    IO.puts("adding point done")
    starting_point = Enum.find(map, fn {_a, b} -> b == "S" end)
    first_point_connect_to_start = find_connected_pipes(starting_point, map)

    loop =
      find_loop(first_point_connect_to_start, starting_point, map, [first_point_connect_to_start])

    IO.puts("loop fonud")

    graph =
      map
      |> Map.keys()
      |> add_intermediates_points()
      |> Enum.reduce(Graph.new(), fn {x, y}, graph ->
        {x, y}
        |> Utils.neighbours_no_diagonale()
        |> Enum.reduce(graph, &add_both_edges_if_exists(&2, &1, {x, y}, map))
      end)

    IO.puts("graph 1 done")

    list = [starting_point | loop] |> Enum.map(&elem(&1, 0))

    updated_graph =
      graph
      |> delete_edges(list, starting_point)

    coordinates = map |> Map.keys()
    coordinates_without_loop_pipes = coordinates -- list

    IO.puts("graph 2 done")

    Enum.filter(coordinates_without_loop_pipes, fn {x, y} ->
      Graph.get_shortest_path(updated_graph, {x / 1, y / 1}, {0.0, 0.0}) |> is_nil()
    end)
    |> Enum.count()
  end

  def add_both_edges_if_exists(graph, {x1, y1}, {x2, y2}, _map) do
    intermediate_coord = {(x1 + x2) / 2, (y1 + y2) / 2}

    graph
    |> Graph.add_edge({x1 / 1, y1 / 1}, intermediate_coord)
    |> Graph.add_edge(intermediate_coord, {x1 / 1, y1 / 1})
    |> Graph.add_edge({x2 / 1, y2 / 1}, intermediate_coord)
    |> Graph.add_edge(intermediate_coord, {x2 / 1, y2 / 1})
  end

  def delete_edges(graph, [last], {starting_point, _}) do
    do_delete(graph, last, starting_point)
  end

  def delete_edges(graph, [a, b | rest], starting_point) do
    graph
    |> do_delete(a, b)
    |> delete_edges([b | rest], starting_point)
  end

  defp do_delete(graph, {x1, y1}, {x2, y2}) do
    intermediate_coord = {(x1 + x2) / 2 / 1, (y1 + y2) / 2 / 1}

    graph
    |> Graph.delete_vertex({x1 / 1, y1 / 1})
    |> Graph.delete_vertex({x2 / 1, y2 / 1})
    |> Graph.delete_vertex(intermediate_coord)
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
    Utils.neighbours_no_diagonale(coordinates)
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

  def add_intermediates_points(list) do
    Enum.reduce(list, list, fn {x, y}, acc ->
      [{x + 0.5, y + 0.5} | acc]
    end)
  end
end
