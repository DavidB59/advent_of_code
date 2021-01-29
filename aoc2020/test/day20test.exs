defmodule AocTest do
  use ExUnit.Case
  import Day20_2

  test "greets the world" do
    assert Aoc.hello() == :world
  end

  # test "full rotation" do
  #   big_picture = full_pic()

  #   rotated_pic =
  #     big_picture
  #     |> rotate_big_picture()
  #     |> rotate_big_picture()
  #     |> rotate_big_picture()
  #     |> rotate_big_picture()

  #   assert big_picture == rotated_pic
  # end

  # test "reversed right_left" do
  #   big_picture = full_pic()
  #   reversed = big_picture |> reverse_big_picture_right_left() |> reverse_big_picture_right_left()
  #   assert big_picture == reversed
  # end

  # test "reversed up_down" do
  #   big_picture = full_pic()
  #   reversed = big_picture |> reverse_big_picture_up_down() |> reverse_big_picture_up_down()
  #   assert big_picture == reversed
  # end

  test "tile 1951" do
    tile =
      "#...##.#..
..#.#..#.#
.###....#.
###.##.##.
.###.#####
.##.#....#
#...######
.....#..##
#.####...#
#.##...##."
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.map(fn {value, index} -> {index, value} end)
      |> Map.new()

    real_tile =
      %{1951 => tile}
      |> put_into_tuple()
      |> give_coord_to_tiles()
      |> Map.get(1951)
      |> reverse_right_left()

    # |> rotate_test()
    # |> rotate_test()
    # |> rotate_test()

    my_tile = test_map() |> Map.get(1951)
    assert real_tile == my_tile
  end

  test "tile 3079" do
    tile =
      "#.#.#####.
.#..######
..#.......
######....
####.#..#.
.#...#.##.
#.#####.##
..#.###...
..#.......
..#.###..."
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.map(fn {value, index} -> {index, value} end)
      |> Map.new()

    real_tile =
      %{3079 => tile}
      |> put_into_tuple()
      |> give_coord_to_tiles()
      |> Map.get(3079)
      |> reverse_right_left()

    my_tile = test_map() |> Map.get(3079)
    assert real_tile == my_tile
  end

  test "tile 2311" do
    tile =
      "..###..###
  ###...#.#.
  ..#....#..
  .#.#.#..##
  ##...#.###
  ##.##.###.
  ####.#...#
  #...##..#.
  ##..#.....
  ..##.#..#."
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.with_index()
      |> Enum.map(fn {value, index} -> {index, value} end)
      |> Map.new()

    real_tile =
      %{2311 => tile}
      |> put_into_tuple()
      |> give_coord_to_tiles()
      |> Map.get(2311)
      |> reverse_big_picture_right_left()

    my_tile = test_map() |> Map.get(2311)
    assert real_tile == my_tile
  end

  def test "tile 2729" do
    tile =
      "#..#.##.
#.####..
###.#.#.
#.####..
##..##.#
...#..#.
.#.#....
###.#..."
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.with_index()
      |> Enum.map(fn {value, index} -> {index, value} end)
      |> Map.new()

    real_tile =
      %{2729 => tile}
      |> put_into_tuple()
      |> give_coord_to_tiles()
      |> Map.get(2729)
      |> reverse_big_picture_right_left()

    my_tile = test_map() |> Map.get(2729)
    assert real_tile == my_tile
  end

  def put_into_tuple(map), do: {map, "", ""}

  def test_map do
    tile_map = "test" |> Parser.read_file() |> format()
    map_with_borders = map_with_borders(tile_map)
    map_with_borders |> Enum.count()
    find_neighbours(map_with_borders)

    corners =
      find_neighbours(map_with_borders)
      |> Enum.filter(fn {_, list} -> length(list) == 2 end)

    {3709, [{3203, {"right", "up_reversed"}}, {1409, {"up", "down"}}]}

    {current_tile_id, [first_neigh, second_neigh]} = List.first(corners)

    {_, {dir1, _}} = first_neigh
    {_, {dir2, _}} = second_neigh
    # [{_({dir1, _})}, {_({dir2, _})}]
    tile_map = Map.put(tile_map, :coord, %{{0, 0} => current_tile_id})
    # results in oriented tiles map + coordinate of each tiles
    go_line_by_line(current_tile_id, tile_map, {0, 0}, {dir1, dir2})
  end

  def rotate_test(tile) do
    rotate_tile("", "", tile)
  end
end
