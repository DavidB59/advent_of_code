defmodule Day16 do
  def file do
    Parser.read_file(16)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Utils.to_list_of_list()
    |> Utils.nested_list_to_xy_map()
  end

  def solve(input \\ file()) do
    input
    |> parse()
    |> calculate_nb_of_energized_tiles({{-1, 0}, :to_east})
  end

  def solve_two(input \\ file()) do
    map = parse(input)
    max = map |> Map.keys() |> Enum.max() |> elem(0)

    Enum.reduce(0..max, fn val, acc ->
      a = calculate_nb_of_energized_tiles(map, {{-1, val}, :to_east})
      b = calculate_nb_of_energized_tiles(map, {{max + 1, val}, :to_west})
      c = calculate_nb_of_energized_tiles(map, {{val, -1}, :to_south})
      d = calculate_nb_of_energized_tiles(map, {{val, max + 1}, :to_north})
      Enum.max([acc, a, b, c, d])
    end)
  end

  def calculate_nb_of_energized_tiles(map, starting_position) do
    {MapSet.new(), MapSet.new()}
    |> move_light(starting_position, map)
    |> elem(0)
    |> Enum.count()
  end

  def move_light(
        {energized_tiles, traversed_position},
        {light_position, light_direction} = pos,
        map
      ) do
    with false <- MapSet.member?(traversed_position, pos),
         next_light_position <- next_light_position(light_position, light_direction),
         next_point when not is_nil(next_point) <- Map.get(map, next_light_position) do
      next_direction = next_direction(light_direction, next_point)
      new_energized_tiles = MapSet.put(energized_tiles, next_light_position)
      map_set = MapSet.put(traversed_position, pos)

      case next_direction do
        [dir1, dir2] ->
          next_pos1 = {next_light_position, dir1}
          next_pos2 = {next_light_position, dir2}

          {new_energized_tiles, map_set}
          |> move_light(next_pos1, map)
          |> move_light(next_pos2, map)

        dir ->
          next_pos = {next_light_position, dir}

          move_light({new_energized_tiles, map_set}, next_pos, map)
      end
    else
      _ ->
        {energized_tiles, traversed_position}
    end
  end

  def next_direction(direction, next_point)
  def next_direction(dir, "."), do: dir

  def next_direction(dir, "|") when dir in [:to_north, :to_south], do: dir
  def next_direction(dir, "|") when dir in [:to_west, :to_east], do: [:to_north, :to_south]

  def next_direction(dir, "-") when dir in [:to_west, :to_east], do: dir
  def next_direction(dir, "-") when dir in [:to_north, :to_south], do: [:to_west, :to_east]

  def next_direction(:to_north, "\\"), do: :to_west
  def next_direction(:to_south, "\\"), do: :to_east
  def next_direction(:to_west, "\\"), do: :to_north
  def next_direction(:to_east, "\\"), do: :to_south

  def next_direction(:to_north, "/"), do: :to_east
  def next_direction(:to_east, "/"), do: :to_north
  def next_direction(:to_south, "/"), do: :to_west
  def next_direction(:to_west, "/"), do: :to_south

  def next_light_position(position, direction), do: apply(__MODULE__, direction, [position])

  def to_north({x, y}), do: {x, y - 1}
  def to_west({x, y}), do: {x - 1, y}
  def to_south({x, y}), do: {x, y + 1}
  def to_east({x, y}), do: {x + 1, y}
end
