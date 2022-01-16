defmodule Day23 do
  def file, do: Parser.read_file("day23")
  def test, do: Parser.read_file("test")

  @cannot_move :cannot_move
  @map %{
    1 => nil,
    2 => nil,
    4 => nil,
    6 => nil,
    8 => nil,
    10 => nil,
    11 => nil,
    {3, "up"} => "B",
    {3, "down"} => "B",
    {5, "up"} => "A",
    {5, "down"} => "C",
    {7, "up"} => "A",
    {7, "down"} => "D",
    {9, "up"} => "D",
    {9, "down"} => "C"
  }

  @all_placed %{
    {3, "up"} => "A",
    {3, "down"} => "A",
    {5, "up"} => "B",
    {5, "down"} => "B",
    {7, "up"} => "C",
    {7, "down"} => "C",
    {9, "up"} => "D",
    {9, "down"} => "D"
  }

  @valid_position Map.keys(@map)

  def cave_pos("A"), do: 3
  def cave_pos("B"), do: 5
  def cave_pos("C"), do: 7
  def cave_pos("D"), do: 9

  def correctly_placed?(pos, pos, letter, map) do
    letter == Map.get(map, {pos, "down"})
  end

  def correctly_placed?(_, _, _, _), do: false

  # Letter in the cave
  # Find all empty hall left and right
  # Check if can go directly to the correct cave, if yes go there
  # If not try to go to every empty hall
  def move_out_of_the_cave(pos, map, key, letter) do
    left_pos = go_left(pos, map)
    right_pos = go_right(pos, map)
    possible_move = left_pos ++ right_pos
    cave_pos = cave_pos(letter)

    possible_move =
      if Enum.member?(possible_move, cave_pos) do
        cond do
          is_nil(Map.get(map, {cave_pos, "down"})) ->
            [{cave_pos, "down"}]

          is_nil(Map.get(map, {cave_pos, "up"})) and
              Map.get(map, {cave_pos, "down"}) == letter ->
            [{cave_pos, "up"}]

          true ->
            possible_move
        end
      else
        possible_move
      end

    possible_move
    |> Enum.filter(&Enum.member?(@valid_position, &1))
    |> Enum.map(fn move -> map |> Map.put(move, letter) |> Map.put(key, nil) end)
  end

  # letter is already where it belongs
  def list_possible_move({{3, "down"}, "A"}, _map), do: @cannot_move
  def list_possible_move({{5, "down"}, "B"}, _map), do: @cannot_move
  def list_possible_move({{7, "down"}, "C"}, _map), do: @cannot_move
  def list_possible_move({{9, "down"}, "D"}, _map), do: @cannot_move

  # No letter on that cave position
  def list_possible_move({{_pos, _}, nil}, _map), do: @cannot_move

  # Letter is down the cave
  def list_possible_move({{pos, "down"} = key, letter}, map) do
    if Map.get(map, {pos, "up"}) do
      @cannot_move
    else
      move_out_of_the_cave(pos, map, key, letter)
    end
  end

  # Letter is up the cave
  def list_possible_move({{pos, "up"} = key, letter}, map) do
    if correctly_placed?(cave_pos(letter), pos, letter, map) do
      @cannot_move
    else
      move_out_of_the_cave(pos, map, key, letter)
    end
  end

  # no letter on this hallway position
  def list_possible_move({_pos, nil}, _map), do: @cannot_move

  # letter on hallway position, can only go to its own cave
  def list_possible_move({pos, letter}, map) do
    cave_pos = cave_pos(letter)

    path_to_cave =
      if cave_pos < pos do
        cave_pos..(pos - 1)
      else
        (pos + 1)..cave_pos
      end

    if Enum.all?(path_to_cave, &is_nil(Map.get(map, &1))) do
      cond do
        is_nil(Map.get(map, {cave_pos, "down"})) ->
          map |> Map.put({cave_pos, "down"}, letter) |> Map.put(pos, nil)

        is_nil(Map.get(map, {cave_pos, "up"})) and
            Map.get(map, {cave_pos, "down"}) == letter ->
          map |> Map.put({cave_pos, "up"}, letter) |> Map.put(pos, nil)

        true ->
          @cannot_move
      end
    else
      @cannot_move
    end
  end

  def go_left(pos, map, list \\ [])
  def go_left(1, _map, list), do: list

  def go_left(pos, map, list) do
    if is_nil(Map.get(map, pos - 1)) do
      go_left(pos - 1, map, [pos - 1 | list])
    else
      list
    end
  end

  def go_right(pos, map, list \\ [])
  def go_right(11, _map, list), do: list

  def go_right(pos, map, list) do
    if is_nil(Map.get(map, pos + 1)) do
      go_right(pos + 1, map, [pos + 1 | list])
    else
      list
    end
  end

  def solve_part_one() do
    do_all(@map)
  end

  def do_all(map, old_map \\ %{})
  def do_all(@all_placed, _), do: true |> IO.inspect(label: "here")

  def do_all(map, map), do: @cannot_move

  def do_all(map, _old_map) do
    map
    |> IO.inspect()
    |> Enum.map(fn key -> list_possible_move(key, map) end)
    |> List.flatten()
    |> Enum.reject(&(&1 == @cannot_move))
    |> Enum.map(&do_all(&1, map))
  end

  def filter_possible_move(map) do
    Enum.reject(map, &(list_possible_move(&1, map) == @cannot_move))
  end
end

# {{9, "up"}, "D"} |> Day23.list_possible_move(map)

# {{7, "up"}, "A"} |> Day23.list_possible_move(map)

# {{9, "down"}, "C"} |> Day23.list_possible_move(map)
# %{
#   1 => "A",
#   2 => nil,
#   4 => nil,
#   6 => "C",
#   8 => nil,
#   10 => "D",
#   11 => nil,
#   {3, "down"} => "B",
#   {3, "up"} => "B",
#   {5, "down"} => "C",
#   {5, "up"} => "A",
#   {7, "down"} => "D",
#   {7, "up"} => nil,
#   {9, "down"} => nil,
#   {9, "up"} => nil
#   }
# {10, "D"} |> Day23.list_possible_move(map)
# {{7, "down"}, "D"} |> Day23.list_possible_move(map)

# %{
#   1 => "A",
#   2 => "A",
#   4 => nil,
#   6 => nil,
#   8 => nil,
#   10 => nil,
#   11 => nil,
#   {3, "down"} => "B",
#   {3, "up"} => "B",
#   {5, "down"} => "C",
#   {5, "up"} => nil,
#   {7, "down"} => "C",
#   {7, "up"} => nil,
#   {9, "down"} => "D",
#   {9, "up"} => "D"
#   }

# {{5, "down"}, "C"} |> Day23.list_possible_move(map)

# %{
#   1 => "A",
#   2 => "A",
#   4 => nil,
#   6 => nil,
#   8 => nil,
#   10 => nil,
#   11 => nil,
#   {3, "down"} => "B",
#   {3, "up"} => "B",
#   {5, "down"} => nil,
#   {5, "up"} => nil,
#   {7, "down"} => "C",
#   {7, "up"} => "C",
#   {9, "down"} => "D",
#   {9, "up"} => "D"
#   }

#   {{3, "up"}, "B"} |> Day23.list_possible_move(map)

#   %{
#     1 => "A",
#     2 => "A",
#     4 => nil,
#     6 => nil,
#     8 => nil,
#     10 => nil,
#     11 => nil,
#     {3, "down"} => "B",
#     {3, "up"} => nil,
#     {5, "down"} => "B",
#     {5, "up"} => nil,
#     {7, "down"} => "C",
#     {7, "up"} => "C",
#     {9, "down"} => "D",
#     {9, "up"} => "D"
#     }
