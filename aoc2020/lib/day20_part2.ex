defmodule Day20_2 do
  @moduledoc """
  Documentation for day20.
  """

  def part_one() do
    file() |> format()
  end

  def part_two() do
    file() |> format() |> solve_two()
  end

  def test() do
    # |> solve_two
    Parser.read_file("test") |> format() |> solve_two()
  end

  def test_full_pic_no_borders() do
    # |> solve_two
    tile_map = Parser.read_file("test") |> format()
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
    tile_map = Map.put(tile_map, :coord, %{{0, 0} => current_tile_id})
    # results in oriented tiles map + coordinate of each tiles
    oriented_tiles = go_line_by_line(current_tile_id, tile_map, {0, 0}, {dir1, dir2})

    coord = Map.get(oriented_tiles, :coord)
    tiles_with_no_borders = oriented_tiles |> Map.drop([:coord]) |> remove_all_borders()
    merge_all_tiles(coord, tiles_with_no_borders)
  end

  def test_full_pic_with_borders() do
    # |> solve_two
    tile_map = Parser.read_file("day20") |> format()
    map_with_borders = map_with_borders(tile_map)
    map_with_borders |> Enum.count()
    find_neighbours(map_with_borders)

    corners =
      find_neighbours(map_with_borders)
      |> Enum.filter(fn {_, list} -> length(list) == 2 end)

    {current_tile_id, [first_neigh, second_neigh]} = List.first(corners)

    {_, {dir1, _}} = first_neigh
    {_, {dir2, _}} = second_neigh
    IO.inspect(dir1, label: "dir1")
    IO.inspect(dir2, label: "dir1")
    tile_map = Map.put(tile_map, :coord, %{{0, 0} => current_tile_id})
    # results in oriented tiles map + coordinate of each tiles
    oriented_tiles = go_line_by_line(current_tile_id, tile_map, {0, 0}, {dir1, dir2})

    coord = Map.get(oriented_tiles, :coord)
    tiles_with_no_borders = oriented_tiles |> Map.drop([:coord])
    merge_with_borders(coord, tiles_with_no_borders)
  end

  def full_pic_no_border() do
    "test_result"
    |> Parser.read_file()
    |> Enum.reject(&(&1 == ""))
    |> Enum.with_index()
    |> Enum.map(fn {string, index} ->
      string
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {charac, index2} -> {{index2, index}, charac} end)
    end)
    |> List.flatten()
    |> Map.new()
  end

  def full_pic_with_border() do
    "test_with_borders"
    |> Parser.read_file()
    |> Enum.reject(&(&1 == ""))
    |> Enum.with_index()
    |> Enum.map(fn {string, index} ->
      string
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {charac, index2} -> {{index2, index}, charac} end)
    end)
    |> List.flatten()
    |> Map.new()
  end

  def file() do
    Parser.read_file("day20")
  end

  def solve_two(tile_map) do
    map_with_borders = map_with_borders(tile_map)
    map_with_borders |> Enum.count()
    find_neighbours(map_with_borders)

    corners =
      find_neighbours(map_with_borders)
      |> Enum.filter(fn {_, list} -> length(list) == 2 end)

    {current_tile_id, [first_neigh, second_neigh]} = List.first(corners)

    {_, {dir1, _}} = first_neigh
    {_, {dir2, _}} = second_neigh

    tile_map = Map.put(tile_map, :coord, %{{0, 0} => current_tile_id})
    # results in oriented tiles map + coordinate of each tiles
    oriented_tiles = go_line_by_line(current_tile_id, tile_map, {0, 0}, {dir1, dir2})

    oriented_tiles
    |> Map.drop([:coord])
    |> map_with_borders()
    |> find_neighbours()

    coord = Map.get(oriented_tiles, :coord)
    tiles_with_no_borders = oriented_tiles |> Map.drop([:coord]) |> remove_all_borders()
    big_picture = merge_all_tiles(coord, tiles_with_no_borders)
    big_picture |> Enum.count()
    found_monster = find_sea_monster(big_picture)

    number_of_hastag = Enum.count(big_picture, fn {_key, value} -> value == "#" end)

    number_of_hastag - found_monster
  end

  def find_sea_monster(big_picture, {rotation, reverse} \\ {0, 0}) do
    sea_monster = sea_monster()

    found_monsters =
      Enum.reduce(big_picture, [], fn
        {{x, y}, "#"}, acc ->
          if Enum.all?(sea_monster, fn {x_sea, y_sea} ->
               Map.get(big_picture, {x_sea + x, y_sea + y}) == "#"
             end) do
            map =
              Enum.map(sea_monster, fn {x_sea, y_sea} ->
                {x_sea + x, y_sea + y}
              end)

            acc ++ map
          else
            acc
          end

        {{_x, _y}, "."}, acc ->
          acc
      end)
      |> Enum.count()

    if found_monsters == 0 do
      case {rotation, reverse} do
        {7, 1} ->
          reverse_big_picture = reverse_big_picture_up_down(big_picture)

          find_sea_monster(reverse_big_picture, {0, 2})

        {7, 0} ->
          reverse_big_picture = reverse_big_picture_right_left(big_picture)

          find_sea_monster(reverse_big_picture, {0, 1})

        {7, 2} ->
          found_monsters

        _ ->
          rotated_big_picture = rotate_big_picture(big_picture)

          find_sea_monster(rotated_big_picture, {rotation + 1, reverse})
      end
    else
      found_monsters
    end
  end

  def rotate_big_picture(big_picture) do
    {{length, _}, _} = big_picture |> Enum.max()

    Enum.reduce(big_picture, %{}, fn {{x, y}, value}, acc ->
      new_x = -y + length
      new_y = x
      Map.put(acc, {new_x, new_y}, value)
    end)
  end

  def reverse_big_picture_right_left(big_picture) do
    {{length, _}, _} = big_picture |> Enum.max()

    Enum.reduce(big_picture, %{}, fn {{x, y}, value}, acc ->
      new_y = abs(y - length)
      Map.put(acc, {x, new_y}, value)
    end)
  end

  def reverse_big_picture_up_down(big_picture) do
    {{length, _}, _} = big_picture |> Enum.max()

    Enum.reduce(big_picture, %{}, fn {{x, y}, value}, acc ->
      new_x = abs(x - length)
      Map.put(acc, {new_x, y}, value)
    end)
  end

  def merge_all_tiles(coord, tiles_with_no_borders) do
    Enum.reduce(coord, %{}, fn {{x_tile, y_tile}, tile_id}, acc ->
      tile_content = Map.get(tiles_with_no_borders, tile_id)

      translated_tile =
        Enum.reduce(tile_content, %{}, fn {{x, y}, value}, acc2 ->
          Map.put(acc2, {x + 8 * x_tile, y - 8 * y_tile}, value)
        end)

      Map.merge(acc, translated_tile)
    end)

    # Enum.reduce(tile_with_no
  end

  def merge_with_borders(coord, tiles_with_no_borders) do
    Enum.reduce(coord, %{}, fn {{x_tile, y_tile}, tile_id}, acc ->
      tile_content = Map.get(tiles_with_no_borders, tile_id)

      translated_tile =
        Enum.reduce(tile_content, %{}, fn {{x, y}, value}, acc2 ->
          Map.put(acc2, {x + 10 * x_tile, y - 10 * y_tile}, value)
        end)

      Map.merge(acc, translated_tile)
    end)
  end

  def remove_all_borders(oriented_tiles) do
    Enum.reduce(oriented_tiles, %{}, fn {key, tile}, acc ->
      tile_with_no_border = remove_border_single_tile(tile)
      Map.put(acc, key, tile_with_no_border)
    end)
  end

  def remove_border_single_tile(tile) do
    tile
    |> Enum.reduce(tile, fn
      {{0, y}, _value}, acc -> Map.drop(acc, [{0, y}])
      {{9, y}, _value}, acc -> Map.drop(acc, [{9, y}])
      {{x, 0}, _value}, acc -> Map.drop(acc, [{x, 0}])
      {{x, 9}, _value}, acc -> Map.drop(acc, [{x, 9}])
      _, acc -> acc
    end)
    |> Enum.reduce(%{}, fn {{x, y}, value}, acc -> Map.put_new(acc, {x - 1, y - 1}, value) end)
  end

  def go_line_by_line(current_tile_id, tile_map, {x, y}, {direction1, direction2}) do
    map_with_borders = map_with_borders(tile_map)
    list_neighbour = find_neighbours_one_tile(current_tile_id, map_with_borders)

    case Enum.find(list_neighbour, fn {_tile_id, {dir1, _dir2}} -> dir1 == direction1 end) do
      {start_next_line_id, {dir1, dir2}} ->
        # Oriente tile below/up before starting

        coord_map = Map.get(tile_map, :coord)

        update_coord_map = coord_map |> Map.put({x + 1, y}, start_next_line_id)

        new_tile_map =
          oriente_tile(current_tile_id, {start_next_line_id, dir1, dir2}, tile_map)
          |> Map.put(:coord, update_coord_map)

        go_line_by_line(
          current_tile_id,
          new_tile_map,
          start_next_line_id,
          {x, y},
          {direction1, direction2}
        )

      nil ->
        go_line_by_line(current_tile_id, tile_map, :last_line, {x, y}, {direction1, direction2})
    end
  end

  def go_line_by_line(current_tile_id, tile_map, next_line_id, {x, y}, {direction1, direction2}) do
    map_with_borders = map_with_borders(tile_map)

    list_neighbour = find_neighbours_one_tile(current_tile_id, map_with_borders)

    case Enum.find(list_neighbour, fn {_tile_id, {dir1, _dir2}} -> dir1 == direction2 end) do
      {side_neighbour_id, {dir_tile1, dir_tile2}} ->
        # oriente tile on left/right then do next one
        coord_map = Map.get(tile_map, :coord)

        update_coord_map = coord_map |> Map.put({x, y + 1}, side_neighbour_id)

        new_tile_map =
          oriente_tile(current_tile_id, {side_neighbour_id, dir_tile1, dir_tile2}, tile_map)
          |> Map.put(:coord, update_coord_map)

        go_line_by_line(
          side_neighbour_id,
          new_tile_map,
          next_line_id,
          {x, y + 1},
          {direction1, direction2}
        )

      nil ->
        case next_line_id do
          :last_line -> tile_map
          _ -> go_line_by_line(next_line_id, tile_map, {x + 1, 0}, {direction1, direction2})
        end
    end
  end

  def map_with_borders(tile_map) do
    Enum.map(tile_map, fn {tile_id, tile} ->
      {tile_id, get_borders(tile)}
    end)
    |> Map.new()
  end

  def list_with_neighbours(tile_map) do
    Enum.map(tile_map, fn {tile_id, tile} ->
      {tile_id, get_borders(tile)}
    end)
    |> Map.new()
    |> find_neighbours()
  end

  # take map of  tiles map with borders
  def find_neighbours(tiles_map) do
    tiles_map
    |> Enum.map(fn {tile_id, tile_borders} ->
      neighbours =
        Enum.reduce(tiles_map, [], fn
          {^tile_id, _match_tile_borders}, neighbours ->
            neighbours

          {match_tile_id, match_tile_borders}, neighbours ->
            match = find_match(tile_borders, match_tile_borders)

            if match do
              neighbours ++ [{match_tile_id, match}]
            else
              neighbours
            end
        end)

      {tile_id, neighbours}
    end)
  end

  def find_neighbours_one_tile(tile_id, tiles_map) do
    tile_borders = Map.get(tiles_map, tile_id)

    Enum.reduce(tiles_map, [], fn
      {^tile_id, _match_tile_borders}, neighbours ->
        neighbours

      {match_tile_id, match_tile_borders}, neighbours ->
        match = find_match(tile_borders, match_tile_borders)

        if match do
          neighbours ++ [{match_tile_id, match}]
        else
          neighbours
        end
    end)
  end

  # take map tile with borders
  def find_match(tile1, tile2) do
    Enum.reduce(tile1, nil, fn {direction, border}, acc ->
      found = Enum.find(tile2, fn {_dir2, bor2} -> border == bor2 end)

      if found do
        if is_nil(acc) do
          {direction, elem(found, 0)}
        else
          acc
        end
      else
        acc
      end
    end)
  end

  # def reverse(key_tile1, {key_tile2, dir_tile1, dir_tile2})
  def oriente_tile(key_tile1, {key_tile2, dir_tile1, dir_tile2}, tile_map) do
    tile1 = Map.get(tile_map, key_tile1) |> reverse(dir_tile1)

    tile2 = Map.get(tile_map, key_tile2) |> reverse(dir_tile2)
    dir1 = dir_tile1 |> String.trim("_reversed")
    dir2 = dir_tile2 |> String.trim("_reversed")
    rotated_tile = rotate_tile(dir1, dir2, tile2)

    if rotated_tile == tile2 do
      tile2 = Map.get(tile_map, key_tile2) |> reverse(dir_tile2)
      tile_map |> Map.put(key_tile2, tile2)
    else
      border_tile1 = get_borders(tile1)
      border_tile2 = get_borders(rotated_tile)
      {new_dir1, new_dir2} = find_match(border_tile1, border_tile2)
      new_tile_map = tile_map |> Map.put(key_tile2, rotated_tile)
      oriente_tile(key_tile1, {key_tile2, new_dir1, new_dir2}, new_tile_map)
    end
  end

  def rotate_tile("left", "right", tile), do: tile
  def rotate_tile("right", "left", tile), do: tile
  def rotate_tile("up", "down", tile), do: tile
  def rotate_tile("down", "up", tile), do: tile

  def rotate_tile(_dir1, _dir2, tile) do
    Enum.reduce(tile, %{}, fn {{x, y}, value}, acc ->
      new_x = -y + 9
      new_y = x
      Map.put(acc, {new_x, new_y}, value)
    end)
  end

  def reverse(tile, direction)
  def reverse(tile, "down_reversed"), do: reverse_up_down(tile)
  def reverse(tile, "up_reversed"), do: reverse_up_down(tile)
  def reverse(tile, "right_reversed"), do: reverse_right_left(tile)
  def reverse(tile, "left_reversed"), do: reverse_right_left(tile)

  def reverse(tile, _dir) do
    tile
  end

  def reverse_right_left(coord_tile) do
    Enum.reduce(coord_tile, %{}, fn {{x, y}, value}, acc ->
      new_y = abs(y - 9)
      Map.put(acc, {x, new_y}, value)
    end)
  end

  def reverse_up_down(coord_tile) do
    Enum.reduce(coord_tile, %{}, fn {{x, y}, value}, acc ->
      new_x = abs(x - 9)
      Map.put(acc, {new_x, y}, value)
    end)
  end

  # list coordinates of the sea monster, starting with {0,0}
  def sea_monster() do
    "sea_monster"
    |> Parser.read_file()
    |> Enum.with_index()
    |> Enum.map(fn {string, index} ->
      string
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(&Tuple.append(&1, index))
      |> Enum.filter(fn {value, _x, _y} -> value == "O" end)
    end)
    |> List.flatten()
    |> Enum.map(fn {_value, y, x} -> {x - 1, y - 2} end)
  end

  def format(file) do
    file
    |> Enum.reduce({%{}, "", 0}, fn string, {map, current_tile, index} ->
      cond do
        String.starts_with?(string, "Tile") ->
          tile_id = string |> String.trim("Tile ") |> Integer.parse() |> elem(0)
          new_map = Map.put(map, tile_id, %{})
          {new_map, tile_id, 0}

        string == "" ->
          {map, current_tile, index}

        true ->
          tile =
            map
            |> Map.get(current_tile)
            |> Map.put(index, string)

          new_map = Map.put(map, current_tile, tile)
          {new_map, current_tile, index + 1}
      end
    end)
    |> give_coord_to_tiles()
  end

  def give_coord_to_tiles({map, _, _}) do
    map
    |> Enum.map(fn {key, value} ->
      new_value =
        Enum.reduce(value, %{}, fn {x_index, string}, acc ->
          string
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.reduce(%{}, fn {y_value, y_index}, acc ->
            Map.put(acc, {x_index, y_index}, y_value)
          end)
          |> Map.merge(acc)
        end)

      {key, new_value}
    end)
    |> Map.new()
  end

  def get_borders(tile) do
    ["left", "right", "up", "down"]
    |> Enum.reduce(%{}, fn direction, acc ->
      border = get_border(direction, tile) |> Enum.join()
      reverse_border = String.reverse(border)
      reversed = direction <> "_reversed"
      map = %{direction => border, reversed => reverse_border}
      # map = %{direction => border}

      Map.merge(acc, map)
    end)
    |> Enum.sort_by(fn {string, _} -> String.length(string) end)
  end

  def get_border("left", tile) do
    Enum.map(0..9, fn coord -> Map.get(tile, {0, coord}) end)
  end

  def get_border("right", tile) do
    Enum.map(0..9, fn coord -> Map.get(tile, {9, coord}) end)
  end

  def get_border("up", tile) do
    Enum.map(0..9, fn coord -> Map.get(tile, {coord, 0}) end)
  end

  def get_border("down", tile) do
    Enum.map(0..9, fn coord -> Map.get(tile, {coord, 9}) end)
  end
end
