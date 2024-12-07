defmodule Day6 do
  def file do
    Parser.read_file(6)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input |> Utils.to_list_of_list() |> Utils.nested_list_to_xy_map()
  end

  def solve(input \\ file()) do
    map = input |> parse
    current_position = Enum.find(map, fn {_key, value} -> value == "^" end) |> elem(0)
   counter = move_guard(current_position, map, {0, -1}, 0)

    counter + 1
  end

  def solve_two(input \\ file()) do
    map = input |> parse
    current_position = Enum.find(map, fn {_key, value} -> value == "^" end) |> elem(0)

    Enum.map(map, &add_obstacle_and_check_if_loop(&1, map, current_position))
    |> Enum.filter(&(&1 == :loop))
    |> Enum.count()
  end

  def add_obstacle_and_check_if_loop({key, "."}, map, current_position) do
    map_with_obs = Map.put(map, key, "#")

    case move_guard(current_position, map_with_obs, {0, -1}, 0) do
      :loop -> :loop
      _ -> :no_loop
    end
  end

  def add_obstacle_and_check_if_loop({_key, _}, _map, _current_position), do: :no_loop

  def move_guard(current_position, map, direction, counter, visited_area \\ %{}) do
    if Map.get(visited_area, {direction, current_position}) do
      :loop
    else
      next_position = next_postion(current_position, direction)

      case Map.get(map, next_position) do
        nil -> counter


        "#" ->
          :must_rotate
          new_direction = rotate(direction)
          move_guard(current_position, map, new_direction, counter, visited_area)

        "." ->
          update_map = Map.put(map, next_position, "X")
          new_visited_area = visited_area |> Map.put({direction, current_position}, :blue)
          move_guard(next_position, update_map, direction, counter + 1, new_visited_area)

        _ ->
          move_guard(next_position, map, direction, counter, visited_area)
      end
    end
  end

  def next_postion({x_pos, y_pos}, {x_dir, y_dir}), do: {x_pos + x_dir, y_pos + y_dir}

  # def rotate({x, y}), do:
  def rotate({0, -1}), do: {1, 0}
  def rotate({1, 0}), do: {0, 1}
  def rotate({0, 1}), do: {-1, 0}
  def rotate({-1, 0}), do: {0, -1}

  # def is_loop
end
