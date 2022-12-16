defmodule Day1 do
  def file do
    Parser.read_file(1)
  end

  def part_one do
    file()
    |> Enum.reduce(0, fn string, acc ->
      operator = String.first(string)
      change = string |> String.trim(operator) |> String.to_integer()
      apply_change(operator, change, acc)
    end)
  end

  def apply_change("+", val, current), do: val + current
  def apply_change("-", val, current), do: current - val

  def part_two(sum \\ 0, mapset \\ MapSet.new()) do
    file()
    |> Enum.reduce_while({sum, mapset}, fn string, {sum, mapset} ->
      operator = String.first(string)
      change = string |> String.trim(operator) |> String.to_integer()
      new_sum = apply_change(operator, change, sum)
      new_mapset = MapSet.put(mapset, new_sum)

      if new_mapset == mapset do
        {:halt, new_sum}
      else
        {:cont, {new_sum, new_mapset}}
      end
    end)
    |> case do
      {sum, mapset} -> part_two(sum, mapset)
      sum -> sum
    end
  end
end
