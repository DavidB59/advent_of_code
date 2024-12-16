defmodule Day16 do
  require Integer

  @cache_name :visited
  def file do
    Parser.read_file(16)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    map =
      input
      |> Utils.to_list_of_list()
      |> Utils.nested_list_to_xy_map()

    start = Enum.find(map, fn {_x, y} -> y == "S" end) |> elem(0)
    {map, start}
  end

  def solve(input \\ file()) do
    cache()

    {map, start} =
      input
      |> parse

    # &move_it(map, 0, start, &1))
    :ets.insert(@cache_name, {start, 0})

    move_it_part_one(map, 0, start, {1, 0})
    |> List.flatten()
    |> Enum.min()
  end

  def solve_two(input \\ file()) do
    cache()

    {map, start} =
      input
      |> parse

    # &move_it(map, 0, start, &1))
    :ets.insert(@cache_name, {{start, {1, 0}}, 0})

    minimum = solve(input)

    map
    |> move_it(0, start, {1, 0}, [start], minimum)
    |> List.flatten()
    |> Enum.filter(fn {score, _path} -> score == minimum end)
    |> Enum.map(&elem(&1, 1))
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.count()

    # |> Enum.min()
  end

  def move_it(map, score, position, direction, visited_position, minimum) do
    next_position = move_reinder(direction, position)
    # :ets.insert(@cache_name, {{position, direction}, :true})
    Utils.neighbours_no_diagonale(position)
    |> Enum.flat_map(fn {x_new, y_new} = neighbour ->
      # + 1001 because I turn and move one step at the same tiem
      current_score = if neighbour == next_position, do: score + 1, else: score + 1001

      if current_score > minimum do
        []
      else
        case :ets.lookup(@cache_name, {neighbour, direction}) do
          [{_key, result}] ->
            cond do
              current_score <= result ->
                {x_pos, y_pos} = position
                new_direction = {x_new - x_pos, y_new - y_pos}
                :ets.insert(@cache_name, {{neighbour, direction}, current_score})

                move_it(
                  map,
                  current_score,
                  neighbour,
                  new_direction,
                  [neighbour | visited_position],
                  minimum
                )

              true ->
                []
            end

          _ ->
            case Map.get(map, neighbour) do
              "#" ->
                []

              "S" ->
                []

              "." ->
                {x_pos, y_pos} = position
                new_direction = {x_new - x_pos, y_new - y_pos}
                :ets.insert(@cache_name, {{neighbour, direction}, current_score})

                move_it(
                  map,
                  current_score,
                  neighbour,
                  new_direction,
                  [
                    neighbour | visited_position
                  ],
                  minimum
                )

              # need to add last movement
              "E" ->
                [{current_score, [neighbour | visited_position]}]
            end
        end
      end
    end)
  end

  def move_it_part_one(map, score, position, direction) do
    next_position = move_reinder(direction, position)

    Utils.neighbours_no_diagonale(position)
    |> Enum.flat_map(fn {x_new, y_new} = neighbour ->
      current_score = if neighbour == next_position, do: score + 1, else: score + 1001

      case :ets.lookup(@cache_name, neighbour) do
        [{_key, result}] ->
          if current_score < result do
            {x_pos, y_pos} = position
            new_direction = {x_new - x_pos, y_new - y_pos}
            :ets.insert(@cache_name, {neighbour, current_score})

            move_it_part_one(map, current_score, neighbour, new_direction)
          else
            []
          end

        _ ->
          case Map.get(map, neighbour) do
            "#" ->
              []

            "S" ->
              []

            "." ->
              {x_pos, y_pos} = position
              new_direction = {x_new - x_pos, y_new - y_pos}
              :ets.insert(@cache_name, {neighbour, current_score})
              move_it_part_one(map, current_score, neighbour, new_direction)

            "E" ->
              [current_score]
          end
      end
    end)
  end

  def move_reinder({x_move, y_move}, {x, y}), do: {x + x_move, y + y_move}

  def cache do
    if :ets.whereis(@cache_name) != :undefined do
      :ets.delete(@cache_name)
    end

    :ets.new(@cache_name, [:named_table])
  end
end
