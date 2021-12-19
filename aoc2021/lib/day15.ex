defmodule Day15 do
  def file do
    Parser.read_file("day15")
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Enum.map(fn string ->
      string |> String.graphemes() |> Enum.map(&String.to_integer/1)
    end)
    |> Utils.nested_list_to_xy_map()
  end

  def create_graph(xy_map) do
    vertices = Map.keys(xy_map)
    vertices |> Enum.count() |> IO.inspect(label: "count vertices")

    graph =
      Enum.reduce(vertices, Graph.new(), fn vertex, acc -> Graph.add_vertex(acc, vertex) end)
      # |> Graph.add_vertices(vertices)
      |> IO.inspect(label: "graph with vertices")

    Enum.reduce(vertices, graph, fn {x, y}, acc ->
      acc =
        if Map.get(xy_map, {x, y + 1}) do
          weight2 = Map.get(xy_map, {x, y + 1})

          edge2 = Graph.Edge.new({x, y}, {x, y + 1}, weight: weight2)

          acc |> Graph.add_edge(edge2)
        else
          acc
        end

      acc =
        if Map.get(xy_map, {x + 1, y}) do
          weight2 = Map.get(xy_map, {x + 1, y})

          edge2 = Graph.Edge.new({x, y}, {x + 1, y}, weight: weight2)

          acc |> Graph.add_edge(edge2)
        else
          acc
        end

      acc =
        if Map.get(xy_map, {x - 1, y}) do
          weight2 = Map.get(xy_map, {x - 1, y})

          edge2 = Graph.Edge.new({x, y}, {x - 1, y}, weight: weight2)

          acc |> Graph.add_edge(edge2)
        else
          acc
        end

      acc =
        if Map.get(xy_map, {x, y - 1}) do
          weight2 = Map.get(xy_map, {x, y - 1})

          edge2 = Graph.Edge.new({x, y}, {x, y - 1}, weight: weight2)

          acc |> Graph.add_edge(edge2)
        else
          acc
        end

      acc
    end)
  end

  def solve_part_one() do
    xy_map = file() |> parse()
    graph = xy_map |> create_graph() |> IO.inspect()
    max = xy_map |> Map.keys() |> Enum.max()
    min = xy_map |> Map.keys() |> Enum.min()
    Map.get(xy_map, min) |> IO.inspect()

    path = Graph.dijkstra(graph, min, max)

    Enum.reduce(path, 0, fn key, sum ->
      sum + Map.get(xy_map, key)
    end)
  end

  def increase_original_map(xy_map, max) do
    one = xy_map |> add_one_left(max)
    two = one |> add_one_left(max)
    three = two |> add_one_left(max)
    four = three |> add_one_left(max)

    line1 =
      xy_map
      |> Map.merge(one, &show_conflict/3)
      |> Map.merge(two, &show_conflict/3)
      |> Map.merge(three, &show_conflict/3)
      |> Map.merge(four, &show_conflict/3)

    line2 = add_one_below(line1, max)
    line3 = add_one_below(line2, max)
    line4 = add_one_below(line3, max)
    line5 = add_one_below(line4, max)

    full_map =
      line1
      |> Map.merge(line2, &show_conflict/3)
      |> Map.merge(line3, &show_conflict/3)
      |> Map.merge(line4, &show_conflict/3)
      |> Map.merge(line5, &show_conflict/3)

    full_map
  end

  def show_conflict(key, val1, val2), do: IO.inspect({key, val1, val2}, label: "conffict")

  def add_one_left(xy_map, max) do
    Enum.reduce(xy_map, %{}, fn {{x, y}, value}, acc ->
      Map.put_new(acc, {x, y + max + 1}, new_val(value))
    end)
  end

  def add_one_below(xy_map, max) do
    Enum.reduce(xy_map, %{}, fn {{x, y}, value}, acc ->
      Map.put(acc, {x + max + 1, y}, new_val(value))
    end)
  end

  def new_val(9), do: 1
  def new_val(x), do: x + 1

  def solve_part_two() do
    xy_map = file() |> parse()
    max = xy_map |> Map.keys() |> Enum.max() |> elem(1)

    xy_map |> Enum.count() |> IO.inspect(label: "count one")
    full_map = increase_original_map(xy_map, max)
    full_map |> Enum.count() |> IO.inspect(label: "count 25")

    Enum.map(0..100, &Map.get(full_map, {0, &1})) |> IO.inspect(label: "line1")
    graph = full_map |> create_graph() |> IO.inspect()

    max = full_map |> Map.keys() |> Enum.max() |> IO.inspect()
    min = full_map |> Map.keys() |> Enum.min()
    Map.get(full_map, min) |> IO.inspect()

    path = Graph.dijkstra(graph, min, max)

    Enum.reduce(path, 0, fn key, sum ->
      sum + Map.get(full_map, key)
    end)
  end
end
