defmodule Day15 do
  require Integer

  def file do
    Parser.read_file(15)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    {to_be_mapped, movement} =
      input
      |> Enum.split_while(&(&1 != ""))

    map =
      to_be_mapped
      |> Utils.to_list_of_list()
      |> Utils.nested_list_to_xy_map()

    list_movement = movement |> Enum.join() |> String.graphemes()
    {map, list_movement}
  end

  def solve(input \\ file()) do
    {map, list_movement} =
      input
      |> parse

    robot_position = Enum.find(map, fn {_k, v} -> v == "@" end) |> elem(0)

    follow_instruction(map, list_movement, robot_position)
    |> get_gps_coordinate()
    |> Enum.sum()
  end

  def plot_lost(map) do
    list = Enum.reject(map, fn {_k, v} -> v == "." end) |> Enum.map(&elem(&1, 0))
    # list = map |> Enum.map(&elem(&1, 0))
    Gnuplot.plot([[:plot, "-", :title, "counter ", :with, :circle]], [list])
  end

  def get_gps_coordinate(map) do
    map
    |> Enum.filter(fn {_k, v} -> v == "O" end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(fn {x, y} -> x + 100 * y end)
  end

  def follow_instruction(map, [], _robot_position), do: map

  def follow_instruction(map, [head | rest], robot_position) do
    # IO.inspect(rest, label: "rest")
    #     IO.inspect(head, label: "head")
    #  map
    #   |> plot_lost()
    # # expected = Enum.find(map, fn {_k, v} -> v == "@" end) |> elem(0)

    # # if expected == !robot_position do
    # #   raise "boom"
    # # end

    next_robot_position = move_robot(head, robot_position)

    Map.get(map, next_robot_position)
    |> case do
      "." ->
        map
        |> Map.put(robot_position, ".")
        |> Map.put(next_robot_position, "@")
        |> follow_instruction(rest, next_robot_position)

      "O" ->
        move_boxes(head, next_robot_position, [], map)
        |> case do
          "#" ->
            follow_instruction(map, rest, robot_position)

          new_map when is_map(new_map) ->
            new_map
            |> Map.put(robot_position, ".")
            |> Map.put(next_robot_position, "@")
            |> follow_instruction(rest, next_robot_position)
        end

      "#" ->
        follow_instruction(map, rest, robot_position)
    end
  end

  def move_boxes(instruction, current_position, list_box_to_move, map) do
    symbole = Map.get(map, current_position)
    next_position = move_robot(instruction, current_position)

    Map.get(map, next_position)
    |> case do
      # nothig_move
      "#" ->
        "#"

      # move everthing
      "." ->
        [{next_position, symbole} | list_box_to_move]
        |> Enum.reduce(map, fn {position, symbole}, acc ->
          Map.put(acc, position, symbole)
        end)

      # continue pushing
      "O" ->
        to_move = [{next_position, symbole} | list_box_to_move]
        move_boxes(instruction, next_position, to_move, map)
    end
  end

  def move_robot("v", {x, y}), do: {x, y + 1}
  def move_robot("<", {x, y}), do: {x - 1, y}
  def move_robot("^", {x, y}), do: {x, y - 1}
  def move_robot(">", {x, y}), do: {x + 1, y}
end
