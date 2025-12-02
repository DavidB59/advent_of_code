defmodule Day23 do
  def file do
    Parser.read_file(23)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    # map1 =
    input
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&get_computer_name/1)
    |> Enum.reduce(%{}, fn {comp1, comp2}, map ->
      map
      |> Map.update(comp1, [comp2], fn current -> [comp2 | current] end)
      |> Map.update(comp2, [comp1], fn current -> [comp1 | current] end)
    end)

    # |> Enum.filter(fn {k, v} -> String.starts_with?(k, "t") end)
  end

  def get_computer_name(<<left::bytes-size(2)>> <> "-" <> <<right::bytes-size(2)>>) do
    {left, right}
  end

  def solve(input \\ file()) do
    input
    |> parse()
    |> Map.new(fn {k, v} -> {k, MapSet.new(v)} end)
    |> find_three_connected_computers
    |> MapSet.to_list()
    |> Enum.filter(fn list -> Enum.any?(list, &String.starts_with?(&1, "t")) end)
    |> Enum.count()
  end

  def find_three_connected_computers(map) do
    map
    |> Enum.reduce(MapSet.new(), fn {comp1, mapset1}, acc ->
      mapset1
      |> Enum.reduce(acc, fn comp2, acc2 ->
        mapset2 = Map.get(map, comp2)
        intersection = MapSet.intersection(mapset1, mapset2)

        if intersection == MapSet.new([]) do
          acc2
        else
          intersection
          |> MapSet.to_list()
          |> Enum.reduce(acc2, fn comp3, acc3 ->
            new = [comp1, comp2, comp3] |> Enum.sort()
            MapSet.put(acc3, new)
          end)
          |> MapSet.union(acc2)
        end
      end)
      |> MapSet.union(acc)
    end)
  end

  def solve_two(input \\ file()) do
    input
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&get_computer_name/1)
    |> Enum.reduce(Graph.new(type: :undirected), fn {comp1, comp2}, graph ->
      graph
      |> Graph.add_edge(comp1, comp2)

      # |> Graph.add_edge(comp2, comp1)
    end)
    |> Graph.cliques()
    |> Enum.max_by(&length/1)
    |> Enum.sort()
    |> Enum.join(",")
  end
end
