defmodule Day12 do
  require Integer

  def file do
    Parser.read_file(12)
  end

  def test do
    Parser.read_file("test")
  end

  def test2 do
    "AAAA
AABA
ABAA
AAAA"
    |> String.split("\n")
    |> solve_two()
  end

  def parse(input) do
    input
    |> Utils.to_list_of_list()
    |> Utils.nested_list_to_xy_map()
  end

  def solve_two(input \\ file()) do
    input
    |> parse
    |> list_of_region()
    |> Enum.map(fn region ->
      # region |> Map.values() |> Enum.uniq() |> IO.inspect(label: "letter")  # |> IO.inspect(label: "perimter")
      # |> IO.inspect(label: "perimeter")
      perimeter = trying_stuff(region) |> Enum.count()

      # |> IO.inspect(label: "area")
      # |> IO.inspect(label: "number")
      number = Enum.count(region)
      perimeter * number
    end)
    |> Enum.sum()
  end

  def trying_stuff(map_coordinate) do
    map_coordinate
    |> Enum.map(fn {key, _value} ->
      # neighbours =
      Utils.neighbours_no_diagonale(key)
      |> Enum.reject(fn neighbour -> Map.get(map_coordinate, neighbour) end)

      # |> IO.inspect(label: "rejected")
    end)
    |> List.flatten()
    |> get_rid_of_lines()
  end

  def get_rid_of_lines(list, result \\ [])

  def get_rid_of_lines([], result), do: result

  def get_rid_of_lines([pos | rest], result) do
    # IO.inspect(pos, label: "pos")
    # Enum.filter(rest, & &1 == {1, 1}) |> Enum.count() |> IO.inspect(label: "11 remaining")

    all_on_y = find_all_on_y(pos, rest) -- [pos]

    if length(all_on_y) > 0 do
      get_rid_of_lines(rest -- all_on_y, [all_on_y | result])
    else
      # all_on_x = find_all_on_x(pos, rest)
      all_on_x = find_all_on_x(pos, rest) -- [pos]

      if length(all_on_x) > 0 do
        get_rid_of_lines(rest -- all_on_x, [all_on_x | result])
      else
        # IO.inspect(pos, label: "pos")
        get_rid_of_lines(rest, [pos | result])
      end
    end
  end

  def find_all_on_x(pos, acc) do
    l1 = go_up_x(pos, acc, [pos])
    l2 = go_down_x(pos, acc, [])
    l1 ++ l2
  end

  def go_up_x({x, y}, acc, result) do
    Enum.find(acc, fn {x2, y2} -> x2 == x + 1 and y2 == y end)
    |> case do
      nil -> result
      found_one -> go_up_x(found_one, acc, [found_one | result])
    end
  end

  def go_down_x({x, y}, acc, result) do
    Enum.find(acc, fn {x2, y2} -> x2 == x - 1 and y2 == y end)
    |> case do
      nil -> result
      found_one -> go_down_x(found_one, acc, [found_one | result])
    end
  end

  # todo recursively find all position going +1 and -1
  def find_all_on_y(pos, acc) do
    l1 = go_up_y(pos, acc, [pos])
    l2 = go_down_y(pos, acc, [])
    l1 ++ l2
  end

  def go_up_y({x, y}, acc, result) do
    Enum.find(acc, fn {x2, y2} -> x2 == x and y2 == y + 1 end)
    |> case do
      nil -> result
      found_one -> go_up_y(found_one, acc, [found_one | result])
    end
  end

  def go_down_y({x, y}, acc, result) do
    Enum.find(acc, fn {x2, y2} -> x2 == x and y2 == y - 1 end)
    |> case do
      nil -> result
      found_one -> go_down_y(found_one, acc, [found_one | result])
    end
  end

  def solve(input \\ file()) do
    input
    |> parse
    |> list_of_region()
    |> Enum.map(fn region ->
      perimeter = calculate_perimeter(region)
      number = Enum.count(region)
      perimeter * number
    end)
    |> Enum.sum()
  end

  def list_of_region(map) do
    map
    |> Enum.reduce({map, []}, fn {coordinate, letter}, {acc, result_list} ->
      # becasue I'm reducing the entire map, but I remove from the map within the reducer
      # skip if coordinates not in the accumulator
      if Map.get(acc, coordinate) do
        {new_map, result_map} =
          gather_all_neighbours(coordinate, letter, acc, Map.new([{coordinate, letter}]))

        {new_map, [result_map | result_list]}
      else
        {acc, result_list}
      end
    end)
    |> elem(1)
  end

  def gather_all_neighbours(coordinate, letter, map, result_map) do
    coordinate
    |> Utils.neighbours_no_diagonale()
    |> Enum.reduce({map, result_map}, fn neighbour, {acc, result} ->
      next_value = Map.get(map, neighbour)

      if next_value == letter do
        new_map = Map.delete(acc, neighbour)
        new_result = Map.put(result, neighbour, letter)
        gather_all_neighbours(neighbour, letter, new_map, new_result)
      else
        {acc, result}
      end
    end)
  end

  def calculate_perimeter(map_coordinate) do
    map_coordinate
    |> Enum.reduce(0, fn {key, _value}, acc ->
      number_of_neighbours =
        Utils.neighbours_no_diagonale(key)
        |> Enum.filter(fn neighbour -> Map.get(map_coordinate, neighbour) end)
        |> Enum.count()

      sides = 4 - number_of_neighbours
      acc + sides
    end)
  end

  def solve_only_test_fail_on_input(input \\ file()) do
    input
    |> parse
    |> list_of_region()
    |> Enum.map(fn region ->
      # region |> Map.values() |> Enum.uniq() #|> IO.inspect(label: "letter")  # |> IO.inspect(label: "perimter")
      # |> IO.inspect(label: "number")
      perimeter = calculate_perimeter_v2(region)
      # |> IO.inspect(label: "area")
      number = Enum.count(region)
      perimeter * number
    end)
    |> Enum.sum()
  end

  def calculate_perimeter_v2(map_coordinates) do
    map_coordinates
    |> Map.keys()
    |> Enum.map(&transform_into_four_vector/1)
    |> List.flatten()
    |> remove_duplicate()
    |> remove_aligned_point()
    |> Enum.count()
  end

  def transform_into_four_vector({x, y}) do
    [
      {{x - 1 / 2, y - 1 / 2}, {x + 1 / 2, y - 1 / 2}},
      {{x + 1 / 2, y - 1 / 2}, {x + 1 / 2, y + 1 / 2}},
      {{x + 1 / 2, y + 1 / 2}, {x - 1 / 2, y + 1 / 2}},
      {{x - 1 / 2, y + 1 / 2}, {x - 1 / 2, y - 1 / 2}}
    ]
  end

  def remove_duplicate(list) do
    Enum.reduce(list, list, fn {a, b}, acc ->
      Enum.find(acc, &(&1 == {b, a}))
      |> case do
        nil -> acc
        _value -> acc -- [{a, b}, {b, a}]
      end
    end)
  end

  def remove_aligned_point(list) do
    points = list |> Enum.flat_map(fn {a, b} -> [a, b] end) |> Enum.uniq()

    Enum.reduce(list, points, fn {a, b}, acc ->
      acc
      |> remove_first(list, {a, b})
      |> remove_second(list, {a, b})
    end)
  end

  def remove_first(acc, list, {a, b}) do
    share_one_point = Enum.find(list -- [{a, b}], fn {c, _d} -> c == a || c == b end)
    to_remove = find_aligned_point({a, b}, share_one_point)
    diag? = diagonale?(to_remove, list)

    if diag? do
      Enum.filter(acc, &(&1 == List.first(to_remove)))
      |> Enum.count()
      |> case do
        1 -> acc ++ to_remove
        2 -> acc
      end
    else
      acc -- to_remove
    end
  end

  def remove_second(acc, list, {a, b}) do
    share_one_point = Enum.find(list -- [{a, b}], fn {_c, d} -> d == a || d == b end)
    to_remove = find_aligned_point({a, b}, share_one_point)
    diag? = diagonale?(to_remove, list)

    if diag? do
      Enum.filter(acc, &(&1 == List.first(to_remove)))
      |> Enum.count()
      |> case do
        1 -> acc ++ to_remove
        2 -> acc
      end
    else
      acc -- to_remove
    end
  end

  @doc """
  Be especially careful when counting the fence around regions
  like the one full of type A plants; in particular,
  each section of fence has an in-side and an out-side,
  so the fence does not connect across the middle of the region
  (where the two B regions touch diagonally).
  """
  def diagonale?([], _vector_list), do: false

  def diagonale?([point], vector_list) do
    found_in =
      Enum.filter(vector_list, fn {a, b} -> a == point || b == point end)
      |> Enum.count()

    if found_in == 4 do
      true
    else
      false
    end
  end

  def find_aligned_point({a, b}, {c, d}) do
    unique = [a, b, c, d] |> Enum.uniq()
    {x_a, y_a} = a
    aligned_by_x? = Enum.all?(unique, fn {x, _y} -> x == x_a end)
    aligned_by_y? = Enum.all?(unique, fn {_x, y} -> y == y_a end)

    cond do
      aligned_by_x? ->
        [_first, {x, y}, _last] = Enum.sort_by(unique, fn {_x, y} -> y end)

        [{x, y}]

      aligned_by_y? ->
        [_first, {x, y}, _last] = Enum.sort_by(unique, fn {x, _y} -> x end)

        [{x, y}]

      true ->
        []
    end
  end
end
