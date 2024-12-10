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
    |> Map.new(fn {a, b} -> {a, String.to_integer(b)} end)
  end

  def solve(input \\ file()) do
    map = parse(input)

    Enum.reduce(map, 0, &reduce_function_with_uniq(&1, &2, map))
  end

  def reduce_function_with_uniq({key, 0}, acc, map) do
    key
    |> find_trail(0, map)
    |> Enum.uniq()
    |> Enum.count()
    |> Kernel.+(acc)
  end

  # trail can only start from a 0
  def reduce_function_with_uniq(_, acc, _), do: acc

  def solve_two(input \\ file()) do
    map = parse(input)

    Enum.reduce(map, 0, &reduce_function(&1, &2, map))
  end

  def reduce_function({key, 0}, acc, map) do
    key
    |> find_trail(0, map)
    |> Enum.count()
    |> Kernel.+(acc)
  end

  # trail can only start from a 0
  def reduce_function(_, acc, _), do: acc

  def find_trail(key, 9, _), do: [{key, 9}]

  def find_trail(key, current_value, map) do
    key
    |> Utils.neighbours_no_diagonale()
    |> Enum.flat_map(fn neighbour ->
      next_value = Map.get(map, neighbour)

      if next_value == current_value + 1 do
        find_trail(neighbour, next_value, map)
      else
        []
      end
    end)
  end
end
