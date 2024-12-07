defmodule Day14 do
  def file do
    Parser.read_file(14)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Utils.to_list_of_list()
    |> Utils.nested_list_to_xy_map()
  end

  def solve(input) do
    input
    |> parse
    |> move_rock_north
    |> count_weight()
  end

  def move_rock_north(map) do
    max = Map.keys(map) |> Enum.max() |> elem(0)

    Enum.reduce(1..max, map, fn y, acc ->
      Enum.reduce(0..max, acc, fn x, acc ->
        go_down_until_you_cannot(acc, {x, y}, &go_north/1)
      end)
    end)
  end

  def move_rock_west(map) do
    max = Map.keys(map) |> Enum.max() |> elem(0)

    Enum.reduce(1..max, map, fn x, acc ->
      Enum.reduce(0..max, acc, fn y, acc ->
        go_down_until_you_cannot(acc, {x, y}, &go_west/1)
      end)
    end)
  end

  def move_rock_south(map) do
    max = Map.keys(map) |> Enum.max() |> elem(0)

    Enum.reduce(max..0, map, fn y, acc ->
      Enum.reduce(0..max, acc, fn x, acc ->
        go_down_until_you_cannot(acc, {x, y}, &go_south/1)
      end)
    end)
  end

  def move_rock_east(map) do
    max = Map.keys(map) |> Enum.max() |> elem(0)

    Enum.reduce(max..0, map, fn x, acc ->
      Enum.reduce(0..max, acc, fn y, acc ->
        go_down_until_you_cannot(acc, {x, y}, &go_east/1)
      end)
    end)
  end

  def go_down_until_you_cannot(map, coord, transform_function) do
    target_coord = transform_function.(coord)

    with "O" <- Map.get(map, coord),
         "." <- Map.get(map, target_coord) do
      map
      |> Map.put(coord, ".")
      |> Map.put(target_coord, "O")
      |> go_down_until_you_cannot(target_coord, transform_function)
    else
      _ -> map
    end
  end

  def go_north({x, y}), do: {x, y - 1}
  def go_west({x, y}), do: {x - 1, y}
  def go_south({x, y}), do: {x, y + 1}
  def go_east({x, y}), do: {x + 1, y}

  def count_weight(map) do
    max = Map.keys(map) |> Enum.max() |> elem(0)

    map
    |> Enum.filter(fn {_, val} -> val == "O" end)
    |> Enum.map(fn {{_, y}, _} -> max + 1 - y end)
    |> Enum.sum()
  end

  def solve_two(input) do
    input
    |> parse
    |> repeat_cycle(1000)
    |> calculate_result_using_period
  end

  def calculate_result_using_period({map_record, beginning_of_repeat, period}) do
    a = rem(1_000_000_000 - beginning_of_repeat, period)

    map_record
    |> Map.new(fn {a, b} -> {b, a} end)
    |> Map.get(a + beginning_of_repeat - 1)
    |> count_weight()
  end

  def repeat_cycle(map, total_cycle, map_record \\ %{}, counter \\ 0)
  def repeat_cycle(map, total_cycle, _first_map, total_cycle), do: map

  def repeat_cycle(map, total_cycle, map_record, counter) do
    map
    |> move_rock_north
    |> move_rock_west
    |> move_rock_south
    |> move_rock_east()
    |> stop_if_repeat(map_record, total_cycle, counter)
  end

  def stop_if_repeat(map, map_record, total_cycle, counter) do
    if Map.get(map_record, map) do
      {map_record, Map.get(map_record, map), Map.get(map_record, map) - counter}
    else
      new_record = Map.put(map_record, map, counter)

      repeat_cycle(map, total_cycle, new_record, counter + 1)
    end
  end
end
