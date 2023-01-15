defmodule Day17_list do
  def file do
    Parser.read_file(17)
  end

  @cycle_number 1_000_000_000_000
  # @cycle_number 20000
  def test do
    "test" |> Parser.read_file()
  end

  @spec rocks :: list | {:error, atom}
  def rocks do
    "rocks" |> Parser.read_file()
  end

  def part_two() do
    file()
    |> format()
  end

  def part_one do
    instructions = file() |> List.first()
    rock_list = rock_map() |> move_all_rock_two_unit_left()
    occupied_map = bottom()
    do_2022_rocks(0, occupied_map, instructions, rock_list, 0)
  end

  def solve_test do
    instructions = test() |> List.first()
    rock_list = rock_map() |> move_all_rock_two_unit_left()
    occupied_map = bottom()
    do_2022_rocks(0, occupied_map, instructions, rock_list, 0)
  end

  def move_all_rock_two_unit_left(rock_map) do
    rock_map
    |> Enum.map(fn rock ->
      rock
      |> Enum.map(fn {x, y} -> {x + 3, y} end)
    end)
  end

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
    {final_rock_list, rest_instruction} =
      make_rock_failing(rock, instructions, inst_count, highest_point, occupied_map)

    final_rock = Map.new(final_rock_list, fn key -> {key, "#"} end)

    highest_point_rock = get_highest_point(final_rock)

    new_highest_point =
      if highest_point_rock > highest_point do
        highest_point_rock
      else
        highest_point
      end

    new_occupied_map =
      if rem(rock_counter, 100_000) == 0 do
        IO.inspect(rock_counter)
        Map.merge(occupied_map, final_rock) |> cut_bottom(new_highest_point)
      else
        Map.merge(occupied_map, final_rock)
      end

    do_2022_rocks(
      rock_counter + 1,
      new_occupied_map,
      rest_instruction,
      rest ++ [rock],
      inst_count,
      new_highest_point
    )
  end

  def cut_bottom(map, highest_point) do
    map
    |> Enum.reject(fn {{_x, y}, _val} -> y < highest_point - 300 end)
    |> Map.new()
  end

  def make_rock_failing(
        rock,
        instructions,
        inst_count,
        highest_point,
        occupied_positions
      ) do
    start_position =
      rock
      |> Enum.map(fn {x, y} -> {x, y + highest_point + 4} end)

    move_rock(start_position, occupied_positions, instructions, inst_count)
  end

  def bottom do
    0..9 |> Map.new(fn a -> {{a, 0}, "-"} end)
  end

  def move_one_right(old_rock, map, backup, new_rock \\ [])
  def move_one_right([], _, _, new_rock), do: new_rock

  def move_one_right([{7, _y} | _rest], _, old_rock, _), do: old_rock

  def move_one_right([{x, y} | rest], occupied_positions, old_rock, new_rock) do
    new_x = x + 1

    if Map.has_key?(occupied_positions, {new_x, y}) do
      old_rock
    else
      move_one_right(rest, occupied_positions, old_rock, [{new_x, y} | new_rock])
    end
  end

  def move_one_left(old_rock, map, backup, new_rock \\ [])
  def move_one_left([], _, _, new_rock), do: new_rock

  def move_one_left([{1, _y} | _rest], _, old_rock, _), do: old_rock

  def move_one_left([{x, y} | rest], occupied_positions, old_rock, new_rock) do
    new_x = x - 1

    if Map.has_key?(occupied_positions, {new_x, y}) do
      old_rock
    else
      move_one_left(rest, occupied_positions, old_rock, [{new_x, y} | new_rock])
    end
  end

  def move_down(rock, occupied_positions) do
    move_down(rock, occupied_positions, rock)
  end

  def move_down(old_rock, map, backup, new_rock \\ [])

  def move_down([], _, _, new_rock), do: new_rock

  def move_down([{x, y} | rest], occupied_positions, old_rock, new_rock) do
    new_y = y - 1

    if Map.has_key?(occupied_positions, {x, new_y}) do
      {old_rock, :stop_moving}
    else
      move_down(rest, occupied_positions, old_rock, [{x, new_y} | new_rock])
    end
  end

  def move_rock({rock, :stop_moving}, _, instructions, _), do: {rock, instructions}

  def move_rock(rock, occupied_positions, instructions, inst_count) do
    {instruction, rest} = get_instruction(instructions)

    rock
    |> push_rock(instruction, occupied_positions)
    |> move_down(occupied_positions)
    |> move_rock(occupied_positions, rest, inst_count)
  end

  def get_instruction(instructions) do
    {instruction, rest} = Utils.string_pattern_match(instructions, 1)
    real_rest = if rest == "", do: file() |> List.first(), else: rest
    {instruction, real_rest}
  end

  def push_rock(rock, "<", occupied_positions), do: move_one_left(rock, occupied_positions, rock)
  def push_rock(rock, ">", occupied_positions), do: move_one_right(rock, occupied_positions, rock)

  def rock_map do
    [
      [{0, 0}, {1, 0}, {2, 0}, {3, 0}],
      [{0, 1}, {1, 0}, {1, 1}, {1, 2}, {2, 1}],
      [{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}],
      [{0, 0}, {0, 1}, {0, 2}, {0, 3}],
      [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
    ]
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
