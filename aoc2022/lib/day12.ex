defmodule Day12 do
  def file do
    Parser.read_file(12)
  end

  def test do
    Parser.read_file("test")
  end

  def part_one() do
    {graph, start_coord, end_coord} =
      file()
      |> format()
      |> create_graph()

    IO.inspect(start_coord, label: "start_coord")
    IO.inspect(end_coord, label: "end_coord")

    Graph.dijkstra(graph, start_coord, end_coord)
    |> Enum.count()
    |> Kernel.-(1)
  end

  def part_two() do
    xy_map =
      file()
      |> format()

    {graph, start_coord, end_coord} = create_graph(xy_map)

    a_coordinates =
      xy_map
      |> Enum.filter(fn {_k, v} -> v == 1 end)
      |> Enum.map(&elem(&1, 0))

    (a_coordinates ++ [start_coord])
    |> Enum.map(&step_number(graph, &1, end_coord))
    |> Enum.min()
  end

  def path_for_given_coord(coord) do
    {graph, _, end_coord} =
      file()
      |> format()
      |> create_graph()

    Graph.dijkstra(graph, coord, end_coord)
  end

  def graph() do
    {graph, _, _} =
      file()
      |> format()
      |> create_graph()

    graph
  end

  def keep_edge_only(list) do
    list
    |> Enum.filter(fn
      {171, _y} -> true
      {0, _y} -> true
      {_x, 0} -> true
      {_x, 40} -> true
      _ -> false
    end)
  end

  def solve_test() do
    xy_map =
      test()
      |> format()

    {graph, _start_coord, end_coord} = create_graph(xy_map)

    a_coordinates = xy_map |> Enum.filter(fn {_k, v} -> v == 1 end) |> Enum.map(&elem(&1, 0))

    a_coordinates
    |> Enum.map(&step_number(graph, &1, end_coord))
    |> IO.inspect()
    |> Enum.min()
  end

  def step_number(graph, start_coord, end_coord) do
    case Graph.dijkstra(graph, start_coord, end_coord) do
      nil ->
        10000

      list when is_list(list) ->
        list
        |> Enum.count()
        |> Kernel.-(1)
    end
  end

  def format(file) do
    file
    |> Utils.to_list_of_list()
    |> Enum.map(fn list -> Enum.map(list, &replace_character_by_height/1) end)
    |> Utils.nested_list_to_xy_map()
  end

  def replace_character_by_height("S"), do: :start
  def replace_character_by_height("E"), do: :end

  def replace_character_by_height(char) do
    char |> Utils.character_to_integer() |> Kernel.-(96)
  end

  def weight_correct(weight) when weight > 1, do: 100_000
  def weight_correct(1), do: 1
  def weight_correct(0), do: 1
  def weight_correct(_negative), do: 1

  def create_graph(old_xy_map) do
    {start_coord, _} = old_xy_map |> Enum.find(fn {_k, v} -> v == :start end)
    {end_coord, _} = old_xy_map |> Enum.find(fn {_k, v} -> v == :end end)

    end_value = "z" |> replace_character_by_height()
    start_value = "a" |> replace_character_by_height |> IO.inspect(label: "start_value")
    xy_map = old_xy_map |> Map.put(start_coord, start_value) |> Map.put(end_coord, end_value)

    vertices = Map.keys(xy_map)

    graph =
      Enum.reduce(vertices, Graph.new(), fn vertex, acc -> Graph.add_vertex(acc, vertex) end)

    graph_with_weight =
      Enum.reduce(vertices, graph, fn {x, y}, acc ->
        acc =
          if Map.get(xy_map, {x, y + 1}) do
            # target = Map.get(xy_map, {x, y + 1})
            # destination = Map.get(xy_map, {x, y})

            weight2 =
              (Map.get(xy_map, {x, y + 1}) - Map.get(xy_map, {x, y}))
              |> weight_correct()

            if weight2 == 100_000 do
              acc
            else
              edge2 = Graph.Edge.new({x, y}, {x, y + 1}, weight: weight2)

              acc |> Graph.add_edge(edge2)
            end
          else
            acc
          end

        acc =
          if Map.get(xy_map, {x + 1, y}) do
            # target = Map.get(xy_map, {x + 1, y})
            # destination = Map.get(xy_map, {x, y})

            weight2 =
              (Map.get(xy_map, {x + 1, y}) - Map.get(xy_map, {x, y}))
              |> weight_correct()

            if weight2 == 100_000 do
              acc
            else
              edge2 = Graph.Edge.new({x, y}, {x + 1, y}, weight: weight2)

              acc |> Graph.add_edge(edge2)
            end
          else
            acc
          end

        acc =
          if Map.get(xy_map, {x - 1, y}) do
            # target = Map.get(xy_map, {x - 1, y})
            # destination = Map.get(xy_map, {x, y})

            weight2 =
              (Map.get(xy_map, {x - 1, y}) - Map.get(xy_map, {x, y}))
              |> weight_correct()

            if weight2 == 100_000 do
              acc
            else
              edge2 = Graph.Edge.new({x, y}, {x - 1, y}, weight: weight2)

              acc |> Graph.add_edge(edge2)
            end
          else
            acc
          end

        acc =
          if Map.get(xy_map, {x, y - 1}) do
            # target = Map.get(xy_map, {x, y - 1})
            # destination = Map.get(xy_map, {x, y})

            weight2 =
              (Map.get(xy_map, {x, y - 1}) - Map.get(xy_map, {x, y}))
              |> weight_correct()

            if weight2 == 100_000 do
              acc
            else
              edge2 = Graph.Edge.new({x, y}, {x, y - 1}, weight: weight2)
              acc |> Graph.add_edge(edge2)
            end
          else
            acc
          end

        acc
      end)

    {graph_with_weight, start_coord, end_coord}
  end
end
