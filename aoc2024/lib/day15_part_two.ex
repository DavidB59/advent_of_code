defmodule Day15_part_two do
  require Integer

  # expected first example = 618
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
      |> enlarge_map()
      |> Utils.to_list_of_list()
      |> Utils.nested_list_to_xy_map()

    list_movement = movement |> Enum.join() |> String.graphemes()
    {map, list_movement}
  end

  def enlarge_map(list) do
    list
    |> Enum.map(fn string ->
      string
      |> String.graphemes()
      |> Enum.map(&enlarger/1)
      |> Enum.join()
    end)

    # |> Enum.map(fn )
  end

  def enlarger("#"), do: "##"
  def enlarger("O"), do: "[]"
  def enlarger("."), do: ".."
  def enlarger("@"), do: "@."

  def solve(input \\ file()) do
    {map, list_movement} = parse(input)

    robot_position = Enum.find(map, fn {_k, v} -> v == "@" end) |> elem(0)

    map
    |> follow_instruction(list_movement, robot_position)
    |> get_gps_coordinate()
    |> Enum.sum()
  end

  def get_gps_coordinate(map) do
    map
    |> Enum.filter(fn {_k, v} -> v == "[" end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(fn {x, y} -> x + 100 * y end)
  end

  def follow_instruction(map, [], _robot_position), do: map

  def follow_instruction(map, [head | rest], robot_position) do
    next_robot_position = move_robot(head, robot_position)

    Map.get(map, next_robot_position)
    |> case do
      "." ->
        map
        |> Map.put(robot_position, ".")
        |> Map.put(next_robot_position, "@")
        |> follow_instruction(rest, next_robot_position)

      "#" ->
        follow_instruction(map, rest, robot_position)

      boxe_symbole when boxe_symbole in ["[", "]"] ->
        move_boxes(head, next_robot_position, [], map)
        |> after_moved_boxes(map)
        |> case do
          "#" ->
            follow_instruction(map, rest, robot_position)

          new_map when is_map(new_map) ->
            other_side_of_robot =
              case boxe_symbole do
                "]" -> move_robot("<", next_robot_position)
                "[" -> move_robot(">", next_robot_position)
              end

            new_map
            |> Map.put(robot_position, ".")
            |> Map.put(next_robot_position, "@")
            |> add_dot_if_up_down(head, other_side_of_robot)
            |> follow_instruction(rest, next_robot_position)
        end
    end
  end

  def add_dot_if_up_down(map, instruction, other_side_of_robot) do
    if instruction in ["v", "^"] do
      Map.put(map, other_side_of_robot, ".")
    else
      map
    end
  end

  def unique_list(list) do
    list
    |> Enum.map(fn {x, y} -> Map.put(%{}, x, y) end)
    |> Enum.reduce(%{}, fn map, acc ->
      Map.merge(acc, map, fn _key, v1, v2 ->
        cond do
          v1 in ["[", "]"] ->
            v1

          v2 in ["[", "]"] ->
            v2

          v1 == v2 and v1 == "." ->
            "."

          true ->
            IO.inspect(v1, label: "v1")
            IO.inspect(v2, label: "v2")
            raise "boom"
        end
      end)
    end)
  end

  def after_moved_boxes(list_box_to_move, map) do
    flat_list = list_box_to_move |> List.flatten() |> Enum.uniq()

    if Enum.any?(flat_list, &(&1 == "#")) do
      "#"
    else
      flat_list
      |> unique_list
      |> Enum.reduce(map, fn {position, symbole}, acc ->
        Map.put(acc, position, symbole)
      end)
    end
  end

  def move_boxes(instruction, current_position, list_box_to_move, map)
      when instruction in ["<", ">"] do
    symbole = Map.get(map, current_position)
    next_position = move_robot(instruction, current_position)

    Map.get(map, next_position)
    |> case do
      # nothig_move
      "#" ->
        ["#"]

      # move everthing
      "." ->
        [{next_position, symbole} | list_box_to_move]

      # continue pushing
      next_symbole when next_symbole in ["[", "]"] ->
        to_move = [{next_position, symbole} | list_box_to_move]
        move_boxes(instruction, next_position, to_move, map)
    end
  end

  def move_boxes(instruction, current_position, list_box_to_move, map)
      when instruction in ["v", "^"] do
    symbole = Map.get(map, current_position)

    other_side_of_box =
      case symbole do
        "]" -> move_robot("<", current_position)
        "[" -> move_robot(">", current_position)
      end

    move_updown(instruction, current_position, list_box_to_move, map) ++
      move_updown(instruction, other_side_of_box, list_box_to_move, map)
  end

  def move_updown(instruction, current_position, list_box_to_move, map) do
    symbole = Map.get(map, current_position)
    next_position = move_robot(instruction, current_position)

    next_symbole = Map.get(map, next_position)

    case next_symbole do
      "#" ->
        ["#"]

      # symbole are the same, simply keep moving
      ^symbole ->
        to_move = [{next_position, symbole} | list_box_to_move]
        move_updown(instruction, next_position, to_move, map)

      # symbole is a dot, return the list, don't update yet, might be a "#" in a different line
      "." ->
        [{next_position, symbole} | list_box_to_move]

      # symbole is different, would have to consider increase cases
      "]" ->
        other_side_of_box = move_robot("<", next_position)

        to_move = [{next_position, symbole}, {other_side_of_box, "."} | list_box_to_move]

        move_updown(instruction, next_position, to_move, map) ++
          move_updown(instruction, other_side_of_box, to_move, map)

      "[" ->
        other_side_of_box = move_robot(">", next_position)

        to_move = [{next_position, symbole}, {other_side_of_box, "."} | list_box_to_move]

        move_updown(instruction, next_position, to_move, map) ++
          move_updown(instruction, other_side_of_box, to_move, map)
    end
  end

  def move_robot("v", {x, y}), do: {x, y + 1}
  def move_robot("<", {x, y}), do: {x - 1, y}
  def move_robot("^", {x, y}), do: {x, y - 1}
  def move_robot(">", {x, y}), do: {x + 1, y}
end
