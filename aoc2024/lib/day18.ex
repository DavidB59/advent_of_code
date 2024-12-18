defmodule Day18 do
  # @size 70
  # @fallen_bytes 1024

  @size 6
  @fallen_bytes 12
  def file do
    Parser.read_file(18)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn a -> String.split(a, ",") |> Enum.map(&String.to_integer/1) end)
    |> Enum.map(fn [x, y] -> {x, y} end)
  end

  def solve(input \\ file()) do
    input
    |> parse()
    |> Enum.take(@fallen_bytes)
    |> list_coordinates_without_fallen_bytes()
    |> generate_graph()
    |> Graph.dijkstra({0, 0}, {@size, @size})
    |> Enum.count()
    |> Kernel.-(1)
  end

  def solve_two(input \\ file()) do
    {to_remove, to_check} =
      input
      |> parse()
      |> Enum.split(@fallen_bytes)

    to_remove
    |> list_coordinates_without_fallen_bytes()
    |> generate_graph()
    |> check_one_by_one(to_check)
  end

  def list_coordinates_without_fallen_bytes(to_remove) do
    initial_square() -- to_remove
  end

  def initial_square() do
    Enum.map(0..@size, fn x -> Enum.map(0..@size, fn y -> {x, y} end) end) |> List.flatten()
  end

  def generate_graph(list_position) do
    map_existing_position = Map.new(list_position, fn x -> {x, true} end)

    Enum.reduce(list_position, Graph.new(), fn position, acc ->
      Utils.neighbours_no_diagonale(position)
      |> Enum.reduce(acc, fn neighbour, acc ->
        if Map.get(map_existing_position, neighbour) do
          acc |> Graph.add_edge(position, neighbour)
        else
          acc
        end
      end)
    end)
  end

  def check_one_by_one(graph, [position | rest]) do
    new_graph = Graph.delete_vertex(graph, position)

    output = Graph.dijkstra(new_graph, {0, 0}, {@size, @size})

    if is_nil(output) do
      position
    else
      check_one_by_one(new_graph, rest)
    end
  end
end
