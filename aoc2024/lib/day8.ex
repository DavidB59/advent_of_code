defmodule Day8 do
  def file do
    Parser.read_file(8)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input |> Utils.to_list_of_list() |> Utils.nested_list_to_xy_map()
  end

  def average do
    1..100
    |> Enum.map(fn _ -> :timer.tc(fn -> Day8.solve() end) end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
    |> Kernel./(100)
  end

  def solve(input \\ file()) do
    map = parse(input)

    map
    |> get_unique_antennas()
    |> Enum.map(fn letter -> find_antinodes_position(letter, map) end)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.count()
  end

  def get_unique_antennas(map) do
    map
    |> Map.values()
    |> Enum.uniq()
    |> Enum.reject(&(&1 == "."))
  end

  def find_antinodes_position(letter, map) do
    antennas_positions = get_antennas_positions(letter, map)

    Enum.map(antennas_positions, fn position ->
      Enum.map(antennas_positions, fn
        ^position ->
          []

        pos2 ->
          {x_pos, y_pos} = position
          {x2, y2} = pos2
          vector = {x_pos - x2, y_pos - y2}
          [pos2] ++ find_all_antinode_position(position, vector, map)
      end)
    end)
  end

  def get_antennas_positions(letter, map) do
    Enum.reduce(map, [], fn
      {pos, ^letter}, acc -> [pos | acc]
      _, acc -> acc
    end)
  end

  def find_all_antinode_position({x_pos, y_pos}, vector, map, all \\ []) do
    {vector_x, vector_y} = vector

    position2 = {x_pos + vector_x, y_pos + vector_y}

    if Map.get(map, position2) do
      find_all_antinode_position(position2, vector, map, [position2 | all])
    else
      all
    end
  end
end
