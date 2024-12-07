defmodule Day21 do
  def file do
    Parser.read_file(21)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Utils.to_list_of_list()
    |> Utils.nested_list_to_xy_map()
  end

  def solve(input \\ file(), max_step) do
    map = parse(input)

    {coord, _} = map |> Enum.find(fn {_, val} -> val == "S" end)
    original_map = Map.put(map, coord, ".")

    map
    |> Map.put(coord, "O")
    |> add_one_step(original_map, max_step)
    |> Enum.filter(fn {_, val} -> val == "O" end)
    |> Enum.count()
  end

  def add_one_step(map, original_map, max_step, step \\ 0)
  def add_one_step(map, _original_map, max_step, max_step), do: map

  def add_one_step(map, original_map, max_step, step) do
    old_coordinates =
      Enum.filter(map, fn {_coord, val} -> val == "O" end) |> Enum.map(&elem(&1, 0))

    # map2 =
    Enum.reduce(old_coordinates, original_map, fn
      coord, acc ->
        coord
        |> Utils.neighbours_no_diagonale()
        |> Enum.reduce(acc, fn coord2, acc ->
          if Map.get(acc, coord2) == "." do
            Map.put(acc, coord2, "O")
          else
            acc
          end
        end)
    end)
    |> add_one_step(original_map, max_step, step + 1)
  end

  def solve_two(input \\ file(), max_step) do
    map = parse(input)

    {coord, _} = map |> Enum.find(fn {_, val} -> val == "S" end)
    original_map = Map.put(map, coord, ".")

    start_map = Map.put(map, coord, "O")
    max = map |> Map.keys() |> Enum.max() |> elem(1)

    %{{0, 0} => start_map}
    |> run_on_each_map(original_map, %{}, max, max_step)
    |> Map.values()
    |> Enum.flat_map(&Enum.filter(&1, fn {_, val} -> val == "O" end))
    |> Enum.count()

    # :ets.delete(:the_cache)
  end

  def run_on_each_map(big_map, original_map, cache, limit, max_step, step \\ 0)

  def run_on_each_map(big_map, _original_map, _cache, _limit, max_step, max_step), do: big_map

  def run_on_each_map(big_map, original_map, cache, limit, max_step, step) do
    blank_sheet = Map.new(big_map, fn {key, _map} -> {key, original_map} end)

    if rem(step, 131) == 0 do
      count =
        big_map
        |> Map.values()
        |> Enum.flat_map(&Enum.filter(&1, fn {_, val} -> val == "O" end))
        |> Enum.count()

      IO.inspect(count, label: "#{step}")
    end

    {big_map, extras, cache} =
      big_map
      |> Enum.reduce({blank_sheet, [], cache}, fn {map_coord, map}, {acc, extras, cache} ->
        # {new_map, extra} =
        # case :ets.lookup(:the_cache, map) do
        # [] ->
        {new_map, extra, cache} =
          case Map.get(cache, map) do
            nil ->
              {new_map, extra} = add_one_step_infinity(map, original_map)
              # :ets.insert(:the_cache, {map, {new_map, extra}})
              cache = Map.put(cache, map, {new_map, extra})
              {new_map, extra, cache}

            {new_map, extra} ->
              # IO.puts("use cache")
              {new_map, extra, cache}
          end

        {Map.put(acc, map_coord, new_map), [{map_coord, extra} | extras], cache}
      end)

    {big_map, extras}
    |> add_extras(limit, original_map)
    |> run_on_each_map(original_map, cache, limit, max_step, step + 1)
  end

  def add_extras({big_map, extras}, limit, original_map) do
    Enum.reduce(extras, big_map, fn {map_coord, extra}, acc ->
      handle_extra(acc, extra, map_coord, limit, original_map)
    end)
  end

  def handle_extra(big_map, [], _, _, _), do: big_map

  def handle_extra(big_map, [head | rest], {x_map, y_map}, limit, original_map) do
    over_limit = limit + 1

    big_map =
      case head do
        {-1, y} ->
          update_in_new_map(big_map, {x_map - 1, y_map}, {limit, y}, original_map)

        {^over_limit, y} ->
          update_in_new_map(big_map, {x_map + 1, y_map}, {0, y}, original_map)

        {x, -1} ->
          update_in_new_map(big_map, {x_map, y_map - 1}, {x, limit}, original_map)

        {x, ^over_limit} ->
          update_in_new_map(big_map, {x_map, y_map + 1}, {x, 0}, original_map)
      end

    handle_extra(big_map, rest, {x_map, y_map}, limit, original_map)
  end

  def update_in_new_map(big_map, target_coord, new_o_coord, original_map) do
    small_map = Map.get(big_map, target_coord, original_map)
    small_map_updated = Map.put(small_map, new_o_coord, "O")
    Map.put(big_map, target_coord, small_map_updated)
  end

  def add_one_step_infinity(map, original_map) do
    old_coordinates =
      Enum.filter(map, fn {_coord, val} -> val == "O" end) |> Enum.map(&elem(&1, 0))

    # map2 =
    Enum.reduce(old_coordinates, {original_map, []}, fn
      coord, {acc_map, list_map} ->
        coord
        |> Utils.neighbours_no_diagonale()
        |> Enum.reduce({acc_map, list_map}, fn coord2, {acc, extra} ->
          case Map.get(acc, coord2) do
            "." -> {Map.put(acc, coord2, "O"), extra}
            nil -> {acc, [coord2 | extra]}
            _ -> {acc, extra}
          end
        end)
    end)
  end
end
