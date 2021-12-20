defmodule Day20 do
  def file, do: Parser.read_file("day20")
  def test, do: Parser.read_file("test")

  def parse(input) do
    [algo, _empty | image] = input

    index_map = algo |> String.graphemes() |> Utils.list_to_index_map()

    xy_map =
      image
      |> Enum.map(&String.graphemes/1)
      |> Utils.nested_list_to_xy_map()

    {index_map, xy_map}
  end

  def solve_part_one() do
    {algo, xy_map} =
      file()
      |> parse()

    xy_map
    |> extend_map_with_dark_points()
    |> one_step(algo)
    |> extend_map_with_light_points()
    |> step_two(algo)
    |> count_lit_pixels()
  end

  def solve_part_two() do
    {algo, xy_map} =
      file()
      |> parse()

    xy_map
    |> do_25_times(algo, 0)
    |> count_lit_pixels()
  end

  def do_25_times(xy_map, _algo, 25) do
    xy_map
  end

  def do_25_times(xy_map, algo, count) do
    two_steps(xy_map, algo) |> do_25_times(algo, count + 1)
  end

  def two_steps(xy_map, algo) do
    xy_map
    |> extend_map_with_dark_points()
    |> one_step(algo)
    |> extend_map_with_light_points()
    |> step_two(algo)
  end

  def count_lit_pixels(xy_map) do
    xy_map
    |> Enum.map(&elem(&1, 1))
    |> Enum.filter(&(&1 == "#"))
    |> Enum.count()
  end

  def neighbours({x, y}) do
    [
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x, y},
      {x + 1, y},
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1}
    ]
  end

  def one_step(xy_map, algo) do
    xy_map
    |> Enum.reduce(%{}, fn {pixel_position, _value}, acc ->
      algo_key = get_neighbours(pixel_position, xy_map)
      new_value = Map.get(algo, algo_key)
      Map.put(acc, pixel_position, new_value)
    end)
  end

  def get_neighbours(pixel_position, xy_map) do
    pixel_position
    |> neighbours()
    |> Enum.map(fn pixel_position ->
      Map.get(xy_map, pixel_position, ".")
      |> to_binary()
    end)
    |> Enum.reduce(&(&2 <> &1))
    |> Integer.parse(2)
    |> elem(0)
  end

  def step_two(xy_map, algo) do
    xy_map
    |> Enum.reduce(%{}, fn {pixel_position, _value}, acc ->
      algo_key = get_neighbours_step_two(pixel_position, xy_map)
      new_value = Map.get(algo, algo_key)
      Map.put(acc, pixel_position, new_value)
    end)
  end

  def get_neighbours_step_two(pixel_position, xy_map) do
    pixel_position
    |> neighbours()
    |> Enum.map(fn pixel_position ->
      Map.get(xy_map, pixel_position, "#")
      |> to_binary()
    end)
    |> Enum.reduce(&(&2 <> &1))
    |> Integer.parse(2)
    |> elem(0)
  end

  @spec to_binary(<<_::8>>) :: <<_::8>>
  def to_binary("."), do: "0"
  def to_binary("#"), do: "1"

  def extend_map_with_dark_points(xy_map) do
    keys = Map.keys(xy_map)
    {x_max, y_max} = Enum.max(keys)
    {x_min, y_min} = Enum.min(keys)

    xy_map = Enum.reduce((x_min - 1)..(x_max + 1), xy_map, &Map.put(&2, {&1, y_min - 1}, "."))
    xy_map = Enum.reduce((x_min - 1)..(x_max + 1), xy_map, &Map.put(&2, {&1, y_max + 1}, "."))
    xy_map = Enum.reduce((y_min - 1)..(y_max + 1), xy_map, &Map.put(&2, {x_min - 1, &1}, "."))
    xy_map = Enum.reduce((y_min - 1)..(y_max + 1), xy_map, &Map.put(&2, {x_max + 1, &1}, "."))

    xy_map
  end

  def extend_map_with_light_points(xy_map) do
    keys = Map.keys(xy_map)
    {x_max, y_max} = Enum.max(keys)
    {x_min, y_min} = Enum.min(keys)

    xy_map =
      Enum.reduce((x_min - 1)..(x_max + 1), xy_map, fn x, acc ->
        Map.put(acc, {x, y_min - 1}, "#")
      end)

    xy_map =
      Enum.reduce((x_min - 1)..(x_max + 1), xy_map, fn x, acc ->
        Map.put(acc, {x, y_max + 1}, "#")
      end)

    xy_map =
      Enum.reduce((y_min - 1)..(y_max + 1), xy_map, fn y, acc ->
        Map.put(acc, {x_min - 1, y}, "#")
      end)

    xy_map =
      Enum.reduce((y_min - 1)..(y_max + 1), xy_map, fn y, acc ->
        Map.put(acc, {x_max + 1, y}, "#")
      end)

    xy_map
  end
end
