defmodule Day14 do
  @bottom 164
  def file do
    Parser.read_file(14)
  end

  def test do
    Parser.read_file("test")
  end

  def part_one() do
    file()
    |> format()
    |> pour_sand()
    |> Map.values()
    |> Enum.filter(&(&1 == "o"))
    |> Enum.count()
  end

  def part_two() do
    rock_map = file() |> format()

    bottom = -500_00..500_00 |> Map.new(fn x -> {{x, @bottom}, "#"} end)

    # bottom = find_y_cave(rock_map)
    rock_map
    |> Map.merge(bottom)
    |> pour_sand()
    |> Map.values()
    |> Enum.filter(&(&1 == "o"))
    |> Enum.count()
  end

  def solve_test() do
    rock_map = test() |> format()

    bottom = -5000..5000 |> Map.new(fn x -> {{x, @bottom}, "#"} end)
    # bottom = find_y_cave(rock_map)

    rock_map
    |> Map.merge(bottom)
    |> pour_sand()
    |> Map.values()
    |> Enum.filter(&(&1 == "o"))
    |> Enum.count()
  end

  def format(file) do
    file
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn string ->
      String.split(string, "->")
      |> Enum.map(fn string2 ->
        string2
        |> String.trim()
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
      end)
    end)
    |> Enum.reduce(%{}, fn rocks, acc -> add_rocks(rocks, acc) end)
  end

  def add_rocks([], map), do: map
  def add_rocks([_], map), do: map

  def add_rocks([s, e | rest], map) do
    new_map = draw(s, e, map)
    add_rocks([e | rest], new_map)
  end

  def draw([x, sy], [x, ey], map) do
    Enum.reduce(sy..ey, map, fn y, acc -> Map.put(acc, {x, y}, "#") end)
  end

  def draw([sx, y], [ex, y], map) do
    Enum.reduce(sx..ex, map, fn x, acc -> Map.put(acc, {x, y}, "#") end)
  end

  def pour_sand(map, old_map \\ nil)
  def pour_sand(map, map), do: map

  def pour_sand(map, old_map) do
    sand = {500, 0}

    new_map = move_sand_until_rest(sand, map)

    if new_map == :ok do
      old_map
    else
      pour_sand(new_map, map)
    end
  end

  def move_sand_until_rest(sand_pos, occupied_map, old_sand_pos \\ nil, count \\ 0)

  def move_sand_until_rest(_, _, _, 1_000_000), do: :ok

  def move_sand_until_rest(sand_pos, occupied_map, sand_pos, _) do
    Map.put(occupied_map, sand_pos, "o")
  end

  def move_sand_until_rest(sand_pos, occupied_map, _, count) do
    new_sand_pos = move_down(sand_pos, occupied_map)

    move_sand_until_rest(new_sand_pos, occupied_map, sand_pos, count + 1)
  end

  # def move_down({x_sand, 10}, occupied_map) do

  # def move_down({x_sand, y_sand}, occupied_map) do
  #   with true <- is_occupied({x_sand, y_sand + 1}, occupied_map),
  #        true <- is_occupied({x_sand - 1, y_sand + 1}, occupied_map),
  #        true <- is_occupied({x_sand + 1, y_sand + 1}, occupied_map) do
  #     {x_sand, y_sand}
  #   else
  #     position -> position
  #   end
  # end

  # def is_occupied(position, occupied_map) do
  #   if is_nil(Map.get(occupied_map, position)) do
  #     position
  #   else
  #     true
  #   end
  # end

  def move_down({x_sand, y_sand}, occupied_map) do
    target_pos = {x_sand, y_sand + 1}

    if Map.get(occupied_map, target_pos) not in ["#", "o"] do
      target_pos
    else
      move_down_left({x_sand, y_sand}, occupied_map)
    end
  end

  def move_down_left({x_sand, y_sand}, occupied_map) do
    target_pos = {x_sand - 1, y_sand + 1}

    if Map.get(occupied_map, target_pos) not in ["#", "o"] do
      target_pos
    else
      move_down_right({x_sand, y_sand}, occupied_map)
    end
  end

  def move_down_right({x_sand, y_sand}, occupied_map) do
    target_pos = {x_sand + 1, y_sand + 1}

    if Map.get(occupied_map, target_pos) not in ["#", "o"] do
      target_pos
    else
      stay_on_top({x_sand, y_sand}, occupied_map)
    end
  end

  def stay_on_top({x_sand, y_sand}, _occupied_map) do
    target_pos = {x_sand, y_sand}

    target_pos
  end

  def find_y_cave(rock_map) do
    rock_map |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max() |> Kernel.+(2)
  end
end
