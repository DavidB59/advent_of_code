defmodule Day22 do
  def file do
    Parser.read_file(22)
  end

  # @cube_size 4
  # @max_x 15
  # @max_y 11
  def test do
    "test" |> Parser.read_file()
  end

  def increase_index_by_one(map) do
    Enum.map(map, fn {{x, y}, value} -> {{x + 1, y + 1}, value} end)
  end

  def cube_test(map) do
    Enum.map(map, fn {{x, y}, value} ->
      cond do
        50 < x and x < 101 and 0 < y and y < 51 ->
          {{correct_coordinate(x), correct_coordinate(y), 1}, value}

        100 < x and x < 151 and 0 < y and y < 51 ->
          {{correct_coordinate(x), correct_coordinate(y), 2}, value}

        50 < x and x < 101 and 50 < y and y < 101 ->
          {{correct_coordinate(x), correct_coordinate(y), 3}, value}

        0 < x and x < 51 and 100 < y and y < 151 ->
          {{correct_coordinate(x), correct_coordinate(y), 4}, value}

        50 < x and x < 101 and 100 < y and y < 151 ->
          {{correct_coordinate(x), correct_coordinate(y), 5}, value}

        0 < x and x < 51 and 150 < y and y < 201 ->
          {{correct_coordinate(x), correct_coordinate(y), 6}, value}
          # true -> IO.inspect({x, y})
      end
    end)
    |> Map.new()
  end

  def correct_coordinate(coord) do
    rem = rem(coord, 50)
    if rem == 0, do: 50, else: rem
  end

  def part_one() do
    {map, instructions} = file() |> format()

    {x, y} = find_start_pos(map)

    %{facing: facing, x: x, y: y} =
      go_through_instruction(instructions, map, %{x: x, y: y, facing: ">"})

    1000 * y + 4 * x + facing_value(facing)
  end

  def part_two do
    {map, instructions} = file() |> format()

    start_pos = %{x: 1, y: 1, facing: ">", current_face: 1}
    cube_map = cube_test(map)

    response =
      go_through_instruction(instructions, cube_map, start_pos) |> IO.inspect(label: "result")

    %{x: x, y: y, facing: facing} = coordinate_from_cube_to_flat(response)
    1000 * y + 4 * x + facing_value(facing)
  end

  def coordinate_from_cube_to_flat(%{x: x, y: y, facing: facing, current_face: 5}) do
    %{x: x + 50, y: y + 100, facing: facing}
  end

  def format(file) do
    split_pos = file |> Enum.find_index(&(&1 == ""))

    {list_map, [_, instructions]} = Enum.split(file, split_pos)

    map =
      list_map
      |> Utils.to_list_of_list()
      |> Utils.nested_list_to_xy_map()
      |> Enum.reject(fn {_k, v} -> v == " " end)
      |> increase_index_by_one()
      |> Map.new()

    formated_instructions = String.split(instructions, ~r/[^\d]/, include_captures: true)

    {map, formated_instructions}
  end

  # Facing is 0 for right (>), 1 for down (v), 2 for left (<), and 3 for up (^).
  def solve_test do
    {map, instructions} = test() |> format()

    {x, y} = find_start_pos(map)
    new_map = map |> cube_test()

    %{facing: facing, x: x, y: y} =
      go_through_instruction(instructions, new_map, %{x: x, y: y, facing: ">", current_face: 1})

    1000 * y + 4 * x + facing_value(facing)
  end

  def facing_value("v"), do: 1
  def facing_value("<"), do: 2
  def facing_value("^"), do: 3
  def facing_value(">"), do: 0

  def find_start_pos(map) do
    keys = Map.keys(map)

    {_x, min_y} = Enum.min_by(keys, fn {_x, y} -> y end)

    Enum.filter(keys, fn {_x, y} -> y == min_y end)
    |> Enum.min_by(fn {x, _y} -> x end)
  end

  def go_through_instruction([], _map, position), do: position

  def go_through_instruction([instruction | rest], map, position) do
    # IO.inspect(instruction, label: "instr")
    # IO.inspect(position, label: "pos")
    new_pos = apply_instruction(instruction, map, position)
    go_through_instruction(rest, map, new_pos)
  end

  def apply_instruction("R", _map, %{facing: ">"} = position), do: %{position | facing: "v"}
  def apply_instruction("R", _map, %{facing: "v"} = position), do: %{position | facing: "<"}
  def apply_instruction("R", _map, %{facing: "<"} = position), do: %{position | facing: "^"}
  def apply_instruction("R", _map, %{facing: "^"} = position), do: %{position | facing: ">"}

  def apply_instruction("L", _map, %{facing: ">"} = position), do: %{position | facing: "^"}
  def apply_instruction("L", _map, %{facing: "^"} = position), do: %{position | facing: "<"}
  def apply_instruction("L", _map, %{facing: "<"} = position), do: %{position | facing: "v"}
  def apply_instruction("L", _map, %{facing: "v"} = position), do: %{position | facing: ">"}

  def apply_instruction(steps, map, position) do
    steps = String.to_integer(steps)

    Enum.reduce_while(1..steps, position, fn _step,
                                             %{facing: facing, current_face: current_face} =
                                               current_pos ->
      {next_x, next_y, _face} = possible_next_pos_coordinates = next_pos(current_pos)
      next_pos_value = Map.get(map, possible_next_pos_coordinates)

      if next_pos_value do
        case next_pos_value do
          "#" -> {:halt, current_pos}
          "." -> {:cont, %{x: next_x, y: next_y, facing: facing, current_face: current_face}}
        end
      else
        {{new_x, new_y, new_face}, new_map_value, new_facing} =
          wrap_around(map, possible_next_pos_coordinates, facing, current_pos)

        case new_map_value do
          "#" -> {:halt, current_pos}
          "." -> {:cont, %{x: new_x, y: new_y, facing: new_facing, current_face: new_face}}
        end
      end
    end)
  end

  ## 6 to 1
  ## < becomes  v

  ## 4 to 1
  ## < to >
  ## upside down
  def wrap_around(map, {_, _, 4}, "<", %{x: _current_x, y: current_y}) do
    new_pos = {1, 51 - current_y, 1}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, ">"}
  end

  #  1 goes to 4
  #  will be going to the <
  # y becomes 51 - y
  # up side down from < to >

  def wrap_around(map, {_, _, 1}, "<", %{x: _current_x, y: current_y}) do
    new_pos = {1, 51 - current_y, 4}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, ">"}
  end

  ## 3 to 4 or 6 to 1
  ## from left to bottom
  def wrap_around(map, {_, _, 3}, "<", %{x: _current_x, y: current_y}) do
    new_pos = {current_y, 1, 4}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, "v"}
  end

  def wrap_around(map, {_, _, 6}, "<", %{x: _current_x, y: current_y}) do
    new_pos = {current_y, 1, 1}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, "v"}
  end

  ## 3 to 1 or 5 to 3 or 6 to 4
  ## go same direction from top to bottom ^

  def wrap_around(map, {_, _, 3}, "^", %{x: current_x, y: _current_y}) do
    new_pos = {current_x, 50, 1}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, "^"}
  end

  ## 5 to 1
  def wrap_around(map, {_, _, 5}, "^", %{x: current_x, y: _current_y}) do
    new_pos = {current_x, 50, 3}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, "^"}
  end

  ## 6 to 4
  def wrap_around(map, {_, _, 6}, "^", %{x: current_x, y: _current_y}) do
    new_pos = {current_x, 50, 4}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, "^"}
  end

  ## 3 to 2 or 6 to 5
  ## > becomes   ^
  ## from right to bottom
  def wrap_around(map, {_, _, 3}, ">", %{x: _current_x, y: current_y}) do
    new_pos = {current_y, 50, 2}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, "^"}
  end

  # 6 to 5
  def wrap_around(map, {_, _, 6}, ">", %{x: _current_x, y: current_y}) do
    new_pos = {current_y, 50, 5}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, "^"}
  end

  ### face 1 vers face 2 or 4 to 5
  ## same direction from left to right >
  def wrap_around(map, {_, _, 1}, ">", %{x: _current_x, y: current_y}) do
    new_pos = {1, current_y, 2}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, ">"}
  end

  def wrap_around(map, {_, _, 4}, ">", %{x: _current_x, y: current_y}) do
    new_pos = {1, current_y, 5}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, ">"}
  end

  ## 1 goes to 3 normal or 3 to 5 or 4 to 6 or 6 to 2
  ## go same direction from bottom to top v
  def wrap_around(map, {_, _, 1}, "v", %{x: current_x, y: _current_y}) do
    new_pos = {current_x, 1, 3}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, "v"}
  end

  # or 3 to 5
  def wrap_around(map, {_, _, 3}, "v", %{x: current_x, y: _current_y}) do
    new_pos = {current_x, 1, 5}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, "v"}
  end

  # or 4 to 6
  def wrap_around(map, {_, _, 4}, "v", %{x: current_x, y: _current_y}) do
    new_pos = {current_x, 1, 6}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, "v"}
  end

  # or 6 to 2
  def wrap_around(map, {_, _, 6}, "v", %{x: current_x, y: _current_y}) do
    new_pos = {current_x, 1, 2}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, "v"}
  end

  #  1 goes to 6 or 4 goes to 3
  #  will be going to the >
  #  x becomes 1
  # y in 6 will be x from 1
  # from top to left side  ^  >
  def wrap_around(map, {_, _, 1}, "^", %{x: current_x, y: _current_y}) do
    new_pos = {1, current_x, 6}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, ">"}
  end

  ## 4 to 3
  ##  ^ to >
  def wrap_around(map, {_, _, 4}, "^", %{x: current_x, y: _current_y}) do
    new_pos = {1, current_x, 3}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, ">"}
  end

  # from face 2 to 1 or 5 to 4
  # no direction change
  ##
  def wrap_around(map, {_, _, 2}, "<", %{x: _current_x, y: current_y}) do
    new_pos = {50, current_y, 1}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, "<"}
  end

  # 5 to 4
  def wrap_around(map, {_, _, 5}, "<", %{x: _current_x, y: current_y}) do
    new_pos = {50, current_y, 4}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, "<"}
  end

  # from face 2 to 3 or 5 to 6
  # "v"  becomes  "<"
  # bottom to right side
  def wrap_around(map, {_, _, 2}, "v", %{x: current_x, y: _current_y}) do
    new_pos = {50, current_x, 3}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, "<"}
  end

  ## 5 to 6
  ## v to <
  def wrap_around(map, {_, _, 5}, "v", %{x: current_x, y: _current_y}) do
    new_pos = {50, current_x, 6}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, "<"}
  end

  # from face 2 to 6
  # no direction change
  # go in from the bottom ( y = 50, x no change)
  def wrap_around(map, {_, _, 2}, "^", %{x: current_x, y: _current_y}) do
    new_pos = {current_x, 50, 6}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, "^"}
  end

  # from face 2 to 5
  # upside down
  def wrap_around(map, {_, _, 2}, ">", %{x: _current_x, y: current_y}) do
    new_pos = {50, 51 - current_y, 5}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, "<"}
  end

  ## 5 to 2
  ## > to <
  ## upside down
  def wrap_around(map, {_, _, 5}, ">", %{x: _current_x, y: current_y}) do
    new_pos = {50, 51 - current_y, 2}
    new_map_value = Map.get(map, new_pos)
    {new_pos, new_map_value, "<"}
  end

  def next_pos(%{x: x, y: y, facing: "v", current_face: face}), do: {x, y + 1, face}
  def next_pos(%{x: x, y: y, facing: "<", current_face: face}), do: {x - 1, y, face}
  def next_pos(%{x: x, y: y, facing: "^", current_face: face}), do: {x, y - 1, face}
  def next_pos(%{x: x, y: y, facing: ">", current_face: face}), do: {x + 1, y, face}
end

# def wrap_around_part1(map, {next_x, _next_y}, "v") do
#   map
#   |> Enum.filter(fn {{x, _y}, _val} -> x == next_x end)
#   |> Enum.min_by(fn {{_x, y}, _val} -> y end)
# end

# def wrap_around_part1(map, {next_x, _next_y}, "^") do
#   map
#   |> Enum.filter(fn {{x, _y}, _val} -> x == next_x end)
#   |> Enum.max_by(fn {{_x, y}, _val} -> y end)
# end

# def wrap_around_part1(map, {_next_x, next_y}, "<") do
#   map
#   |> Enum.filter(fn {{_x, y}, _val} -> y == next_y end)
#   |> Enum.max_by(fn {{x, _y}, _val} -> x end)
# end

# def wrap_around_part1(map, {_next_x, next_y}, ">") do
#   map
#   |> Enum.filter(fn {{_x, y}, _val} -> y == next_y end)
#   |> Enum.min_by(fn {{x, _y}, _val} -> x end)
# end
