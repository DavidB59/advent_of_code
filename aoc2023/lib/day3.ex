defmodule Day3 do
  def file do
    Parser.read_file(3)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Utils.to_list_of_list()
    |> Utils.nested_list_to_xy_map()
  end

  def nbs do
    ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
  end

  def find_numbers(map) do
    limit = map |> Map.keys() |> Enum.max() |> elem(1)

    Enum.reduce(0..limit, {[], map}, fn y, acc ->
      Enum.reduce(0..limit, acc, fn x, {acc2, updated_map} ->
        {new_map, {number, coords}} = check_next({x, y}, updated_map, {"", []})

        if coords == [] do
          {acc2, updated_map}
        else
          # new_acc2 = Map.put(acc2, number, coords)
          new_acc2 = [{number, coords} | acc2]
          {new_acc2, new_map}
        end
      end)
    end)
  end

  def check_next({x, y} = coord, map, {string, list} = result) do
    val = Map.get(map, coord)

    if Enum.member?(nbs(), val) do
      new_map = Map.delete(map, coord)
      new_result = {string <> val, [coord | list]}
      check_next({x + 1, y}, new_map, new_result)
    else
      {map, result}
    end
  end

  def solve(input) do
    # map = parse(input)
    {numbers, map_without_numbers} =
      input
      |> parse()
      |> find_numbers()

    # |> elem(0)

    #   numbers |> Map.keys() |> IO.inspect()

    clean_map =
      map_without_numbers
      |> Enum.reduce(%{}, fn
        {key, "."}, acc -> Map.put(acc, key, nil)
        {key, val}, acc -> Map.put(acc, key, val)
      end)
      |> IO.inspect()

    numbers
    |> Enum.filter(fn {_number, coordinates} ->
      Enum.any?(coordinates, &is_neighbour_symbol?(&1, clean_map))
    end)
    |> Enum.map(fn {a, _b} -> String.to_integer(a) end)
    |> Enum.sum()
  end

  def solve_two(input) do
    # map = parse(input)
    {numbers, map_without_numbers} =
      input
      |> parse()
      |> find_numbers()

    {next_gen_number_map, _} =
      numbers
      |> Enum.reduce({%{}, 0}, fn {number, coords}, {acc, index} ->
        new_map = coords |> Map.new(fn coord -> {coord, {index, number}} end) |> Map.merge(acc)
        {new_map, index + 1}
      end)
      |> IO.inspect()

    gear_coords =
      map_without_numbers
      |> Enum.reduce([], fn
        {key, "*"}, acc -> [key | acc]
        _, acc -> acc
      end)

    gear_coords
    |> Enum.map(fn coord ->
      # IO.inspect(coord, label: "Coord")
      neighbour_count(coord, next_gen_number_map)
    end)
    # |> IO.inspect()
    |> Enum.sum()
  end

  def neighbour_count({x, y}, map) do
    result =
      [
        Map.get(map, {x + 1, y}),
        Map.get(map, {x + 1, y - 1}),
        Map.get(map, {x + 1, y + 1}),
        Map.get(map, {x, y - 1}),
        Map.get(map, {x, y + 1}),
        Map.get(map, {x - 1, y}),
        Map.get(map, {x - 1, y - 1}),
        Map.get(map, {x - 1, y + 1})
      ]
      |> Enum.reject(&is_nil/1)
      |> IO.inspect()
      |> Map.new()
      |> Map.values()

    case result do
      [a, b] ->
        String.to_integer(a) * String.to_integer(b)

      here ->
        IO.inspect(here, label: "here")
        0
    end
  end

  def is_neighbour_symbol?({x, y}, map) do
    result =
      Map.get(map, {x + 1, y}) ||
        Map.get(map, {x + 1, y - 1}) ||
        Map.get(map, {x + 1, y + 1}) ||
        Map.get(map, {x, y - 1}) ||
        Map.get(map, {x, y + 1}) ||
        Map.get(map, {x - 1, y}) ||
        Map.get(map, {x - 1, y - 1}) ||
        Map.get(map, {x - 1, y + 1})

    if result do
      true
    else
      false
    end
  end
end
