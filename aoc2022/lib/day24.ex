defmodule Day24 do
  @blizzard ["<", ">", "^", "v"]
  def file do
    Parser.read_file(24)
  end

  def test do
    "test" |> Parser.read_file()
  end

  def part_one do
    map = file() |> format()
    {start_pos, end_pos} = find_start_end(map)
    {blizzard_map, _} = create_blizzard_map(map)

    find_best_path(map, blizzard_map, start_pos, end_pos, %{}, 0, 1000)
  end

  def solve_test do
    map = test() |> format()
    {start_pos, end_pos} = find_start_end(map)
    {blizzard_map, _} = create_blizzard_map(map)

    find_best_path(map, blizzard_map, start_pos, end_pos, %{}, 0, 1000)
  end

  def find_best_path(
        map,
        blizzard_map,
        start_pos,
        end_pos,
        removed_targets,
        counter,
        best,
        cacheblizzard \\ %{}
      )

  def find_best_path(_map, _blizzard_map, _start_pos, _end_pos, _removed_targets, 100, best, _),
    do: best

  def find_best_path(
        map,
        blizzard_map,
        start_pos,
        end_pos,
        removed_targets,
        counter,
        best,
        saved_blizzard_map
      ) do
    case move_me(map, blizzard_map, start_pos, end_pos, 0, removed_targets, saved_blizzard_map) do
      {result, new_saved_blizzard_map} ->
        find_best_path(
          map,
          blizzard_map,
          start_pos,
          end_pos,
          result,
          counter,
          best,
          new_saved_blizzard_map
        )

      result ->
        new_best = if result < best, do: result, else: best

        new_removed_targets =
          removed_targets
          |> Map.put({end_pos, result}, true)

        find_best_path(
          map,
          blizzard_map,
          start_pos,
          end_pos,
          new_removed_targets,
          counter + 1,
          new_best,
          saved_blizzard_map
        )
    end
  end

  def part_two do
    file()
    |> format()
  end

  def move_me(_, _, pos, pos, minute, _, _), do: IO.inspect(minute, label: "TARGET REACHED")

  def move_me(
        inner_map,
        blizzard_map,
        start_pos,
        end_pos,
        minute,
        removed_target,
        saved_blizzard_map
      ) do
    check_cache = Map.get(saved_blizzard_map, minute)

    {new_blizzard_map, saved_blizzard_map} =
      if check_cache do
        {check_cache, saved_blizzard_map}
      else
        new_blizzard_map = move_blizzard(blizzard_map, inner_map)

        {new_blizzard_map, Map.put(saved_blizzard_map, minute, new_blizzard_map)}
      end

    possible_target = neighbours(start_pos, inner_map)

    blizzard_positions = Enum.map(new_blizzard_map, fn {{x, y, _}, _} -> {x, y} end)

    possible_target =
      Enum.reject(possible_target, fn target ->
        Map.get(removed_target, {target, minute + 1}) || Enum.member?(blizzard_positions, target)
      end)

    if possible_target == [] do
      {Map.put(removed_target, {start_pos, minute}, true), saved_blizzard_map}
    else
      best_target = go_closer(possible_target, end_pos)

      move_me(
        inner_map,
        new_blizzard_map,
        best_target,
        end_pos,
        minute + 1,
        removed_target,
        saved_blizzard_map
      )
    end
  end

  def go_closer(list_target, end_pos) do
    {_distance, pos} =
      Enum.map(list_target, fn target ->
        {distance(target, end_pos), target}
      end)
      |> Enum.min_by(fn {distance, _pos} -> distance end)

    pos
  end

  def distance({x1, y1}, {x2, y2}),
    do: (:math.pow(x1 - x2, 2) + :math.pow(y1 - y2, 2)) |> :math.sqrt()

  def neighbours({x, y}, map) do
    [{x + 1, y}, {x, y + 1}, {x - 1, y}, {x, y - 1}, {x, y}]
    |> Enum.filter(fn pos -> Map.get(map, pos) end)
  end

  def create_blizzard_map(map) do
    Enum.reduce(map, {%{}, 0}, fn {{x, y}, dir}, {blizzard_map, id} ->
      if Enum.member?(@blizzard, dir) do
        new_map = Map.put(blizzard_map, {x, y, id}, dir)
        {new_map, id + 1}
      else
        {blizzard_map, id}
      end
    end)
  end

  def move_blizzard(blizzard_map, map) do
    Enum.reduce(blizzard_map, %{}, fn {{x, y, blizzard_id}, dir} = blizzard, acc ->
      {new_x, new_y} = next_pos = blizzard_move(blizzard)

      if Map.get(map, next_pos) do
        acc
        |> Map.delete({x, y, blizzard_id})
        |> Map.put({new_x, new_y, blizzard_id}, dir)
      else
        {{new_x, new_y}, _} = wrap_around(map, {new_x, new_y}, dir)

        acc
        |> Map.delete({x, y, blizzard_id})
        |> Map.put({new_x, new_y, blizzard_id}, dir)
      end
    end)
  end

  def blizzard_move({{x, y, _}, "<"}), do: {x - 1, y}
  def blizzard_move({{x, y, _}, ">"}), do: {x + 1, y}
  def blizzard_move({{x, y, _}, "^"}), do: {x, y - 1}
  def blizzard_move({{x, y, _}, "v"}), do: {x, y + 1}

  def format(file) do
    file
    |> Utils.to_list_of_list()
    |> Utils.nested_list_to_xy_map()
    |> Enum.reject(fn {_k, v} -> v == "#" end)
    |> Map.new()
  end

  def find_start_end(map) do
    {start_pos, _v} = Enum.find(map, fn {{_x, y}, _v} -> y == 0 end)
    {end_pos, _v} = Enum.max_by(map, fn {{_x, y}, _v} -> y end)
    {start_pos, end_pos}
  end

  def wrap_around(map, {next_x, _next_y}, "v") do
    map
    |> Enum.filter(fn {{x, _y}, _val} -> x == next_x end)
    |> Enum.min_by(fn {{_x, y}, _val} -> y end)
  end

  def wrap_around(map, {next_x, _next_y}, "^") do
    map
    |> Enum.filter(fn {{x, _y}, _val} -> x == next_x end)
    |> Enum.max_by(fn {{_x, y}, _val} -> y end)
  end

  def wrap_around(map, {_next_x, next_y}, "<") do
    map
    |> Enum.filter(fn {{_x, y}, _val} -> y == next_y end)
    |> Enum.max_by(fn {{x, _y}, _val} -> x end)
  end

  def wrap_around(map, {_next_x, next_y}, ">") do
    map
    |> Enum.filter(fn {{_x, y}, _val} -> y == next_y end)
    |> Enum.min_by(fn {{x, _y}, _val} -> x end)
  end
end
