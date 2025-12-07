defmodule Day7 do
  def file, do: Parser.read_file(7)
  def test, do: Parser.read_file("test")

  def parse(input) do
    input |> Utils.to_xy_map()
  end

  def part_one(input \\ test()) do
    map = input |> parse
    {start_position, _} = Enum.find(map, fn {_position, value} -> value == "S" end)

    max_y = map |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max()

    Enum.reduce(0..max_y, {[start_position], 0}, fn _, acc ->
      do_all(map, acc)
    end)
  end

  def do_all(map, {positions, counter}) do
    {next_pos, new_counter} =
      positions
      |> Enum.reduce({[], counter}, fn position, {next_pos, counter} ->
        case go_downward(position, map) do
          {pos, 0} -> {[pos | next_pos], counter}
          {pos1, pos2, 1} -> {[pos1, pos2 | next_pos], counter + 1}
          :finish -> {next_pos, counter}
        end
      end)

    unique = Enum.uniq(next_pos)
    {unique, new_counter}
  end

  def go_downward({x, y}, map) do
    case Map.get(map, {x, y + 1}) do
      "." -> {{x, y + 1}, 0}
      "^" -> {{x - 1, y + 1}, {x + 1, y + 1}, 1}
      nil -> :finish
    end
  end

  def part_two(input \\ test()) do
    cache()
    map = input |> parse
    {start_position, _} = Enum.find(map, fn {_position, value} -> value == "S" end)

    split_particles(start_position, map)
  end

  def split_particles({x, y} = pos, map, counter \\ 0) do
    case :ets.lookup(:my_cache, pos) do
      [{_key, result}] ->
        result

      [] ->
        case Map.get(map, {x, y + 1}) do
          "." ->
            result = split_particles({x, y + 1}, map, 1)
            :ets.insert(:my_cache, {{x, y}, result})
            result

          "^" ->
            {res1, res2} = {
              split_particles({x - 1, y + 1}, map, 1),
              split_particles({x + 1, y + 1}, map, 1)
            }

            :ets.insert(:my_cache, {{x, y + 1}, res1 + res2})

            res1 + res2

          nil ->
            :ets.insert(:my_cache, {pos, counter})
            1
        end
    end
  end

  def cache do
    if :ets.whereis(:my_cache) != :undefined do
      :ets.delete(:my_cache)
    end

    :ets.new(:my_cache, [:named_table])
  end
end
