defmodule Day18 do
  def file do
    Parser.read_file(18)
  end

  def test do
    "test" |> Parser.read_file()
  end

  def part_two() do
    file() |> format()
  end

  def part_one() do
    list_coord = file() |> format()
    map_coord = create_map(list_coord)
    graph = build_graph()
    real_graph = delete_edges(list_coord, graph)

    Enum.reduce(list_coord, 0, fn coord, sum ->
      find_neighbours_with_cache(coord, map_coord, real_graph) + sum
    end)
  end

  def format(file) do
    file
    |> Enum.map(fn string -> string |> String.split(",") |> Enum.map(&String.to_integer/1) end)
  end

  def create_map(list) do
    list |> Map.new(fn coord -> {coord, 0} end)
  end

  def find_neighbours_with_cache(coord, map, graph) do
    neighbours_list = neighbour_list(coord)

    Enum.reduce(neighbours_list, 0, fn coord, acc ->
      is_trapped = check_if_trapped(neighbour_list(coord), graph)

      acc + Map.get(map, coord, is_trapped)
    end)
  end

  def neighbour_list([x, y, z]) do
    [[x, y, z + 1], [x, y, z - 1], [x, y + 1, z], [x, y - 1, z], [x + 1, y, z], [x - 1, y, z]]
  end

  def check_if_trapped(neighbours_list, graph) do
    Enum.reduce_while(neighbours_list, 0, fn coord, _acc ->
      case Graph.dijkstra(graph, coord, [-1, -1, -1]) do
        nil -> {:cont, 0}
        _ -> {:halt, 1}
      end
    end)
  end

  def build_graph() do
    range = -1..21

    range
    |> Enum.reduce(Graph.new(), fn x, graph ->
      Enum.reduce(range, graph, fn y, graph2 ->
        Enum.reduce(range, graph2, fn z, graph3 ->
          graph3
          |> Graph.add_edge([x, y, z], [x, y, z + 1])
          |> Graph.add_edge([x, y, z], [x, y, z - 1])
          |> Graph.add_edge([x, y, z], [x, y + 1, z])
          |> Graph.add_edge([x, y, z], [x, y - 1, z])
          |> Graph.add_edge([x, y, z], [x + 1, y, z])
          |> Graph.add_edge([x, y, z], [x - 1, y, z])
        end)
      end)
    end)
  end

  def delete_edges(list_coord, graph) do
    list_coord
    |> Enum.reduce(graph, fn [x, y, z], graph ->
      graph
      |> Graph.delete_edge([x, y, z], [x, y, z + 1])
      |> Graph.delete_edge([x, y, z], [x, y, z - 1])
      |> Graph.delete_edge([x, y, z], [x, y + 1, z])
      |> Graph.delete_edge([x, y, z], [x, y - 1, z])
      |> Graph.delete_edge([x, y, z], [x + 1, y, z])
      |> Graph.delete_edge([x, y, z], [x - 1, y, z])
    end)
  end

  def solve_test() do
    list_coord = test() |> format()
    map_coord = create_map(list_coord)
    graph = build_graph()
    real_graph = delete_edges(list_coord, graph)

    Enum.reduce(list_coord, 0, fn coord, sum ->
      find_neighbours_with_cache(coord, map_coord, real_graph) + sum
    end)
  end
end
