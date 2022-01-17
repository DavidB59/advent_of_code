defmodule Day23_part2 do
  @cannot_move :cannot_move
  @letters ["A", "B", "C", "D"]
  @map %{
    1 => nil,
    2 => nil,
    4 => nil,
    6 => nil,
    8 => nil,
    10 => nil,
    11 => nil,
    {3, 1} => "B",
    {3, 2} => "D",
    {3, 3} => "D",
    {3, 4} => "B",
    {5, 1} => "A",
    {5, 2} => "C",
    {5, 3} => "B",
    {5, 4} => "C",
    {7, 1} => "A",
    {7, 2} => "B",
    {7, 3} => "A",
    {7, 4} => "D",
    {9, 1} => "D",
    {9, 2} => "A",
    {9, 3} => "C",
    {9, 4} => "C",
    cost: 0
  }

  @test %{
    1 => nil,
    2 => nil,
    4 => nil,
    6 => nil,
    8 => nil,
    10 => nil,
    11 => nil,
    {3, 1} => "B",
    {3, 2} => "D",
    {3, 3} => "D",
    {3, 4} => "A",
    {5, 1} => "C",
    {5, 2} => "C",
    {5, 3} => "B",
    {5, 4} => "D",
    {7, 1} => "B",
    {7, 2} => "B",
    {7, 3} => "A",
    {7, 4} => "C",
    {9, 1} => "D",
    {9, 2} => "A",
    {9, 3} => "C",
    {9, 4} => "A",
    cost: 0
  }

  @all_placed %{
    {3, 1} => "A",
    {3, 2} => "A",
    {3, 3} => "A",
    {3, 4} => "A",
    {5, 1} => "B",
    {5, 2} => "B",
    {5, 3} => "B",
    {5, 4} => "B",
    {7, 1} => "C",
    {7, 2} => "C",
    {7, 3} => "C",
    {7, 4} => "C",
    {9, 1} => "D",
    {9, 2} => "D",
    {9, 3} => "D",
    {9, 4} => "D"
  }

  @valid_position Map.keys(@map)

  def cave_pos("A"), do: 3
  def cave_pos("B"), do: 5
  def cave_pos("C"), do: 7
  def cave_pos("D"), do: 9

  def letter_cost("A"), do: 1
  def letter_cost("B"), do: 10
  def letter_cost("C"), do: 100
  def letter_cost("D"), do: 1000

  def update_cost(current_cost, letter, pos, target) do
    {pos, target}

    space_moved =
      if is_integer(pos) do
        {index, height} = target

        cost_down = height

        abs(index - pos) + cost_down
      else
        {index, height} = pos

        cost_up = height

        if is_integer(target) do
          abs(index - target) + cost_up
        else
          {index2, height2} = target

          cost_down = height2

          abs(index - index2) + cost_up + cost_down
        end
      end

    current_cost + letter_cost(letter) * space_moved
  end

  def correctly_placed?(pos, pos, 4, _letter, _map), do: true

  def correctly_placed?(pos, pos, deep, letter, map) do
    Enum.all?((deep + 1)..4, &(letter == Map.get(map, {pos, &1})))
  end

  def correctly_placed?(_, _, _, _, _), do: false

  def only_matching_letter(map, letter, cave_pos) do
    1..4
    |> Enum.all?(fn deep ->
      val = Map.get(map, {cave_pos, deep})
      val == letter || val == nil
    end)
  end

  def first_empty_spot(map, cave_pos) do
    4..1 |> Enum.find(&is_nil(Map.get(map, {cave_pos, &1})))
  end

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
          only_matching_letter(map, letter, cave_pos) ->
            deep = first_empty_spot(map, cave_pos)
            [{cave_pos, deep}]

          true ->
            possible_move
        end
      else
        possible_move
      end

    if possible_move == [] do
      @cannot_move
    else
      possible_move
      |> Enum.filter(&Enum.member?(@valid_position, &1))
      |> Enum.map(fn move ->
        map
        |> Map.put(move, letter)
        |> Map.put(key, nil)
        |> Map.update!(:cost, &update_cost(&1, letter, key, move))
      end)
    end
  end

  # letter is already where it belongs
  def list_possible_move({{3, 4}, "A"}, _map), do: @cannot_move
  def list_possible_move({{5, 4}, "B"}, _map), do: @cannot_move
  def list_possible_move({{7, 4}, "C"}, _map), do: @cannot_move
  def list_possible_move({{9, 4}, "D"}, _map), do: @cannot_move

  # No letter on that cave position
  def list_possible_move({{_pos, _}, nil}, _map), do: @cannot_move

  # Letter is in the cave
  def list_possible_move({{pos, deep} = key, letter}, map) do
    with true <- is_nil(Map.get(map, {pos, deep - 1})),
         false <- correctly_placed?(cave_pos(letter), pos, deep, letter, map) do
      move_out_of_the_cave(pos, map, key, letter)
    else
      _ -> @cannot_move
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
        only_matching_letter(map, letter, cave_pos) ->
          deep = first_empty_spot(map, cave_pos)
          move = {cave_pos, deep}

          map
          |> Map.put(move, letter)
          |> Map.put(pos, nil)
          |> Map.update!(:cost, &update_cost(&1, letter, pos, move))

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
    @map |> do_all() |> List.flatten() |> Enum.min()
  end

  def do_all(@all_placed = map), do: map.cost

  def do_all(map) do
    map
    |> Enum.map(fn
      {key, value} when value in @letters ->
        list_possible_move({key, value}, map)

      _ ->
        @cannot_move
    end)
    |> List.flatten()
    |> Enum.reject(&(&1 == @cannot_move))
    |> Enum.map(&do_all(&1))
  end

  def do_once(map) do
    map
    |> Enum.map(fn
      {key, value} when value in @letters ->
        list_possible_move({key, value}, map)

      _ ->
        @cannot_move
    end)
    |> List.flatten()
    |> Enum.reject(&(&1 == @cannot_move))
  end
end
