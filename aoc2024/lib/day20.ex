defmodule Day20 do
  def file do
    Parser.read_file(20)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Enum.reject(&(&1 == ""))
    |> Utils.to_list_of_list()
    |> Utils.nested_list_to_xy_map()
  end

  def solve(input \\ file()) do
    # map =
    input
    |> parse()

    # start = map |> Enum.find(fn {_x, y} -> y == "S" end) |> elem(0) |> IO.inspect()
    # finish = map |> Enum.find(fn {_x, y} -> y == "E" end) |> elem(0) |> IO.inspect()
    # without_walls = map |> Enum.reject(fn {_x, y} -> y == "#" end) |> Map.new()
    # walls_positions = map |> Enum.filter(fn {_x, y} -> y == "#" end) |> Enum.map(&elem(&1, 0))

    # cheat_list =
    #   determine_possible_cheats(
    #     walls_positions,
    #     without_walls |> Map.put(start, ".") |> Map.put(finish, ".")
    #   )

    # cheat_list = determine_possible_with_manhattan(without_walls)
    # orginal_graph = without_walls |> generate_graph()

    # total_time =
    #   orginal_graph
    #   |> Graph.dijkstra(start, finish)
    #   |> Enum.count()
    #   |> Kernel.-(1)

    # # IO.inspect(total_time)

    # calculate_cheats(orginal_graph, cheat_list, total_time, start, finish)
    # |> Enum.map(fn value -> total_time - value end)
    # |> Enum.filter(&(&1 > 49))
    # |> Enum.count()
  end

  def determine_possible_with_manhattan(without_walls) do
    list_positions = Map.keys(without_walls)

    list_positions
    |> Enum.reduce([], fn position, acc ->
      found =
        Enum.map(list_positions, fn pos2 ->
          distance = Utils.manhattan_distance(pos2, position)

          if distance > 1 and distance < 21 do
            [{position, pos2, distance}, {pos2, position, distance}]
          else
            nil
          end
        end)
        |> Enum.reject(&is_nil/1)

      found ++ acc
    end)
    |> List.flatten()
  end

  def determine_possible_cheats(walls_position, without_walls) do
    Enum.flat_map(walls_position, fn {x, y} ->
      one =
        if Map.get(without_walls, {x + 1, y}) == "." and Map.get(without_walls, {x - 1, y}) == "." do
          [{x + 1, y}, {x, y}, {x - 1, y}]
        else
          nil
        end

      two =
        if Map.get(without_walls, {x, y - 1}) == "." and Map.get(without_walls, {x, y + 1}) == "." do
          [{x, y - 1}, {x, y}, {x, y + 1}]
        else
          nil
        end

      [one, two]
    end)
    |> Enum.reject(&is_nil/1)
  end

  def calculate_cheats(graph, cheat_list, _total_time, start, finish) do
    Enum.map(cheat_list, fn {a, b, distance} ->
      new_graph =
        graph
        |> Graph.add_edge(a, b, weight: distance)
        |> Graph.add_edge(b, a, weight: distance)

      new_graph
      |> Graph.dijkstra(start, finish)
      |> case do
        nil ->
          nil

        list when is_list(list) ->
          list
          |> Enum.count()
          |> Kernel.-(1)
      end
    end)
  end

  def generate_graph(list_position) do
    # map_existing_position = Map.new(list_position, fn x -> {x, true} end)

    Enum.reduce(list_position, Graph.new(), fn
      {_position, "#"}, acc ->
        acc

      {position, _value}, acc ->
        Utils.neighbours_no_diagonale(position)
        |> Enum.reduce(acc, fn neighbour, acc ->
          case Map.get(list_position, neighbour) do
            "#" ->
              acc

            nil ->
              acc

            _ ->
              acc |> Graph.add_edge(position, neighbour)
          end
        end)
    end)
  end

  def check_one_by_one(graph, [position | rest]) do
    new_graph = Graph.delete_vertex(graph, position)

    output = Graph.dijkstra(new_graph, {0, 0}, {5, 5})

    if is_nil(output) do
      position
    else
      check_one_by_one(new_graph, rest)
    end
  end
end
