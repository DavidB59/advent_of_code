defmodule DjikDay17 do
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

  def build_graph(map) do
    map
    |> Enum.reduce(Graph.new(), fn {coord1, _val}, acc ->
      coord1
      |> Utils.neighbours_no_diagonale()
      |> Enum.reduce(acc, fn coord2, acc ->
        value = Map.get(map, coord2)

        if value do
          Graph.add_edge(acc, coord1, coord2, weight: value)
        else
          acc
        end
      end)
    end)
  end

  def solve(input \\ file()) do
    map = parse(input)
    graph = build_graph(map)
    target = map |> Map.keys() |> Enum.max()

    Graph.dijkstra(graph, {0, 0}, target)

    # Graph.a_star(graph, {0, 0}, target, fn v ->
    #   #   IO.inspect(v, label: "inpect")
    #   0
    # end)
  end
end
