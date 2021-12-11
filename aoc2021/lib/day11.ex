defmodule Day11 do
  def file do
    Parser.read_file("day11")
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Enum.map(fn line -> line |> String.graphemes() |> Enum.map(&String.to_integer/1) end)
    |> Utils.nested_list_to_xy_map()
  end

  def solve_part_one() do
    input = file() |> parse()

    Enum.reduce(1..100, {input, 0}, fn _, {map, flash_count} ->
      {new_input, new_flash, new_flash_count} = one_step(map, flash_count)
      {Map.merge(new_input, new_flash), new_flash_count}
    end)
    |> elem(1)
  end

  def solve_part_two do
    input = file() |> parse()

    Enum.reduce_while(1..1000, {input, 0}, fn step, {map, flash_count} ->
      {new_input, new_flash, new_flash_count} = one_step(map, flash_count)

      if Enum.empty?(new_input) do
        {:halt, step}
      else
        {:cont, {Map.merge(new_input, new_flash), new_flash_count}}
      end
    end)
  end

  def one_step(input, flash_count) do
    input
    |> Map.new(fn {k, v} -> {k, v + 1} end)
    |> flash(%{}, flash_count)
  end

  def flash(input, flashes, flash_count) do
    {new_input, new_flash, new_flash_count} =
      Enum.reduce(input, {input, flashes, flash_count}, fn
        {key, value}, {map, flashes, flash_count} when value > 9 ->
          one =
            map
            |> flash_neighbours(key)
            |> Map.delete(key)

          two = Map.put(flashes, key, 0)
          {one, two, flash_count + 1}

        {_, _}, acc ->
          acc
      end)

    if new_flash_count != flash_count do
      flash(new_input, new_flash, new_flash_count)
    else
      {new_input, new_flash, new_flash_count}
    end
  end

  def flash_neighbours(input, {x, y}) do
    Enum.reduce(adjacent(x, y), input, fn position, acc ->
      case acc do
        %{^position => value} -> Map.put(acc, position, value + 1)
        acc -> acc
      end
    end)
  end

  def adjacent(x, y) do
    [
      {x + 1, y},
      {x + 1, y + 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x - 1, y + 1},
      {x - 1, y - 1},
      {x, y + 1},
      {x, y - 1}
    ]
  end
end
