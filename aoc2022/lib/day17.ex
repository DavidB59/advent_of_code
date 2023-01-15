defmodule Day17 do
  @cycle_number 2022
  def file do
    Parser.read_file(17)
  end

  def test do
    "test" |> Parser.read_file()
  end

  def rocks do
    "rocks" |> Parser.read_file()
  end

  def part_two() do
    file()
    |> format()
  end

  def part_one do
    instructions = file() |> format()
    rock_list = rock_map() |> move_all_rock_two_unit_left()
    occupied_map = bottom()
    do_2022_rocks(0, occupied_map, instructions, rock_list, 0)
  end

  def solve_test do
    instructions = test() |> format()
    rock_list = rock_map() |> move_all_rock_two_unit_left()
    occupied_map = bottom()
    do_2022_rocks(0, occupied_map, instructions, rock_list, 0)
  end

  def move_all_rock_two_unit_left(rock_map) do
    rock_map
    |> Enum.map(fn rock ->
      rock
      |> Enum.map(fn {{x, y}, val} -> {{x + 3, y}, val} end)
      |> Map.new()
    end)
  end

  # def do_2022_rocks(2022, occupied_map, _, _, _), do: occupied_map

  def do_2022_rocks(
        rock_counter,
        occupied_map,
        instructions,
        rock_list,
        inst_count,
        highest_point \\ 0
      )

  def do_2022_rocks(@cycle_number, occupied_map, _, _, _, _),
    do:
      occupied_map
      |> get_highest_point()

  def do_2022_rocks(
        rock_counter,
        occupied_map,
        instructions,
        [rock | rest],
        inst_count,
        highest_point
      ) do
    {final_rock, new_inst_count} =
      make_rock_failing(rock, instructions, inst_count, highest_point, occupied_map)

    highest_point_rock = get_highest_point(final_rock)

    new_highest_point =
      if highest_point_rock > highest_point do
        highest_point_rock
      else
        highest_point
      end

    new_occupied_map = Map.merge(occupied_map, final_rock)
    # |> cut_bottom(new_highest_point)

    do_2022_rocks(
      rock_counter + 1,
      new_occupied_map,
      instructions,
      rest ++ [rock],
      new_inst_count,
      new_highest_point
    )
  end

  def cut_bottom(map, highest_point) do
    map
    |> Enum.reject(fn {{_x, y}, _val} -> y < highest_point - 10 end)
    |> Map.new()
  end

  def make_rock_failing(
        rock,
        instructions,
        inst_count \\ 0,
        highest_point \\ 0,
        occupied_positions
      ) do
    start_position =
      rock
      |> Enum.map(fn {{x, y}, val} -> {{x, y + highest_point + 4}, val} end)
      |> Map.new()

    move_rock(start_position, occupied_positions, instructions, inst_count)
  end

  def bottom do
    0..9 |> Map.new(fn a -> {{a, 0}, "-"} end)
  end

  def move_one_right(rock, occupied_positions) do
    rock
    |> Enum.reduce_while(%{}, fn {{x, y}, val}, acc ->
      new_x = x + 1

      new_pos = {new_x, y}

      if Map.get(occupied_positions, new_pos) || new_x == 0 || new_x == 8 do
        {:halt, rock}
      else
        {:cont, Map.put(acc, new_pos, val)}
      end
    end)
  end

  def move_one_left(rock, occupied_positions) do
    rock
    |> Enum.reduce_while(%{}, fn {{x, y}, val}, acc ->
      new_x = x - 1
      new_pos = {new_x, y}

      if Map.get(occupied_positions, new_pos) || new_x == 0 || new_x == 8 do
        {:halt, rock}
      else
        {:cont, Map.put(acc, new_pos, val)}
      end
    end)
  end

  def move_down(rock, occupied_positions) do
    rock
    |> Enum.reduce_while(%{}, fn {{x, y}, val}, acc ->
      new_pos = {x, y - 1}

      if Map.get(occupied_positions, new_pos) do
        {:halt, {rock, :stop_moving}}
      else
        {:cont, Map.put(acc, new_pos, val)}
      end
    end)
  end

  def move_rock({rock, :stop_moving}, _, _, inst_count), do: {rock, inst_count}

  def move_rock(rock, occupied_positions, instructions, inst_count) do
    {instruction, new_inst_count} = get_instruction(instructions, inst_count)

    rock
    |> push_rock(instruction, occupied_positions)
    |> move_down(occupied_positions)
    |> move_rock(occupied_positions, instructions, new_inst_count)
  end

  def get_instruction(instructions, inst_count) do
    instruction = Map.get(instructions, inst_count)

    if is_nil(instruction) do
      {Map.get(instructions, 0), 1}
    else
      {instruction, inst_count + 1}
    end
  end

  def push_rock(rock, "<", occupied_positions), do: move_one_left(rock, occupied_positions)
  def push_rock(rock, ">", occupied_positions), do: move_one_right(rock, occupied_positions)

  def rock_map do
    [
      %{{0, 0} => "1", {1, 0} => "1", {2, 0} => "1", {3, 0} => "1"},
      %{{0, 1} => "2", {1, 0} => "2", {1, 1} => "2", {1, 2} => "2", {2, 1} => "2"},
      %{{0, 0} => "3", {1, 0} => "3", {2, 0} => "3", {2, 1} => "3", {2, 2} => "3"},
      %{{0, 0} => "4", {0, 1} => "4", {0, 2} => "4", {0, 3} => "4"},
      %{{0, 0} => "5", {0, 1} => "5", {1, 0} => "5", {1, 1} => "5"}
    ]
  end

  def left_edge(rock) do
    rock
    |> Map.keys()
    |> Enum.min(fn {x, _}, {x2, _} -> x < x2 end)
  end

  def rock_length(rock) do
    rock
    |> Map.keys()
    |> Enum.map(&elem(&1, 1))
    |> Enum.max()
  end

  def get_highest_point(occupied_map) do
    occupied_map
    |> Map.keys()
    |> Enum.map(&elem(&1, 1))
    |> Enum.max()
  end

  # Each rock appears so that its left edge is two units away
  # from the left wall and its bottom edge is three units above
  # the highest rock in the room (or the floor, if there isn't one).

  def format(file) do
    file |> List.first() |> String.graphemes() |> Utils.list_to_index_map()
  end
end
