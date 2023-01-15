defmodule Day23 do
  @order ["N", "S", "W", "E"]
  @stop_at 10

  def file do
    Parser.read_file(23)
  end

  def test do
    "test" |> Parser.read_file()
  end

  def solve_test do
    test()
    |> format()
    |> do_until_no_move(@order, 0)
  end

  def part_one do
    file()
    |> format()
    |> do_10_times(@order, 0)
  end

  def part_two do
    file()
    |> format()
    |> do_until_no_move(@order, 0)
  end

  def format(file) do
    file
    |> Utils.to_list_of_list()
    |> Utils.nested_list_to_xy_map()
    |> Enum.reject(fn {_k, v} -> v == "." end)
    |> Map.new()
  end

  def do_until_no_move(elf_map, direction, counter, old_map \\ %{})

  def do_until_no_move(elf_map, _, counter, elf_map), do: counter

  def do_until_no_move(elf_map, [one, two, three, four] = directions, counter, _old_map) do
    elf_map
    |> first_round(directions)
    |> remove_duplicate_target()
    |> second_round(elf_map)
    |> do_until_no_move([two, three, four, one], counter + 1, elf_map)
  end

  def do_10_times(elf_map, _, @stop_at) do
    keys = Map.keys(elf_map)
    x_list = keys |> Enum.map(fn {x, _y} -> x end)
    y_list = keys |> Enum.map(fn {_x, y} -> y end)
    x_min = Enum.min(x_list)
    x_max = Enum.max(x_list)
    y_min = Enum.min(y_list)
    y_max = Enum.max(y_list)
    x_wide = x_min..x_max |> Enum.count() |> IO.inspect(label: "count")
    y_wide = y_min..y_max |> Enum.count()
    # x_wide = (x_max - x_min) |> IO.inspect(label: "div")
    nb_of_elfs = Enum.count(keys)
    empty_space = x_wide * y_wide - nb_of_elfs

    empty_space
  end

  def do_10_times(elf_map, [one, two, three, four] = directions, counter) do
    elf_map
    |> first_round(directions)
    |> remove_duplicate_target()
    |> second_round(elf_map)
    |> do_10_times([two, three, four, one], counter + 1)
  end

  def first_round(elf_map, directions) do
    Enum.reduce(elf_map, {%{}, []}, fn {{x, y}, _value}, {acc, list} ->
      if Enum.all?(directions, &check_direction(&1, {x, y}, elf_map)) do
        {acc, list}
      else
        proposed_position = Enum.find_value(directions, &check_direction(&1, {x, y}, elf_map))

        if proposed_position do
          # if proposed position already in the map, get rid of it
          if Map.get(acc, proposed_position) == nil do
            map_pos = Map.put(acc, proposed_position, {x, y})
            {map_pos, list}
          else
            # map_pos = Map.delete(acc, proposed_position)
            {acc, [proposed_position | list]}
          end
        else
          {acc, list}
        end
      end
    end)
  end

  def remove_duplicate_target({map, []}), do: map

  def remove_duplicate_target({map, [head | rest]}) do
    # IO.inspect(hea?d)
    new_map = Map.delete(map, head)
    remove_duplicate_target({new_map, rest})
  end

  def second_round(proposed_position, elf_map) do
    Enum.reduce(proposed_position, elf_map, fn {new_elf, old_elf}, elf_map ->
      elf_map
      |> Map.delete(old_elf)
      |> Map.put(new_elf, "#")
    end)
  end

  def check_direction("N", {x, y}, map) do
    result =
      if Map.take(map, [{x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1}]) == %{} do
        {x, y - 1}
      else
        false
      end

    result
  end

  def check_direction("S", {x, y}, map) do
    if Map.take(map, [{x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}]) == %{} do
      {x, y + 1}
    else
      false
    end
  end

  def check_direction("W", {x, y}, map) do
    if Map.take(map, [{x - 1, y - 1}, {x - 1, y}, {x - 1, y + 1}]) == %{} do
      {x - 1, y}
    else
      false
    end
  end

  def check_direction("E", {x, y}, map) do
    if Map.take(map, [{x + 1, y - 1}, {x + 1, y}, {x + 1, y + 1}]) == %{} do
      {x + 1, y}
    else
      false
    end
  end
end
