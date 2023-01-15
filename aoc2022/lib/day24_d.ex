defmodule Day24_d do
  @blizzard ["<", ">", "^", "v"]
  def file do
    Parser.read_file(24)
  end

  def test do
    "test" |> Parser.read_file()
  end

  def part_one do
    map = file() |> format()
    {start_pos, end_pos} = find_start_end(map) |> IO.inspect()
    {blizzard_map, _} = create_blizzard_map(map)
    new(blizzard_map, map, [start_pos], start_pos, end_pos, Graph.new())
  end

  def solve_test do
    map = test() |> format()
    {start_pos, end_pos} = find_start_end(map) |> IO.inspect()
    {blizzard_map, _} = create_blizzard_map(map)

    {minute1, blizzard_map1} =
      new(blizzard_map, map, [start_pos], start_pos, end_pos, Graph.new())

    {minute2, blizzard_map2} = new(blizzard_map1, map, [end_pos], end_pos, start_pos, Graph.new())

    {minute3, _blizzard_map3} =
      new(blizzard_map2, map, [start_pos], start_pos, end_pos, Graph.new())

    {minute1, minute2, minute3}
  end

  def part_two do
    map = file() |> format()
    {start_pos, end_pos} = find_start_end(map) |> IO.inspect()
    {blizzard_map, _} = create_blizzard_map(map)

    {minute1, blizzard_map1} =
      new(blizzard_map, map, [start_pos], start_pos, end_pos, Graph.new())

    {minute2, blizzard_map2} = new(blizzard_map1, map, [end_pos], end_pos, start_pos, Graph.new())

    {minute3, _blizzard_map3} =
      new(blizzard_map2, map, [start_pos], start_pos, end_pos, Graph.new())

    {minute1, minute2, minute3}
  end

  def new(blizzard_map, map, start_positions, start_pos, end_pos, graph, minute \\ 0) do
    # IO.inspect(minute, label: "minute :")
    new_blizzard_map = move_blizzard(blizzard_map, map)
    blizzard_positions = Enum.map(new_blizzard_map, fn {{x, y, _}, _} -> {x, y} end)

    {new_graph, new_targets} =
      Enum.reduce(start_positions, {graph, []}, fn position, {acc1, new_targets} ->
        # neighbours(position, end_pos)
        targets =
          neighbours(position, map)
          |> Enum.reject(&Enum.member?(blizzard_positions, &1))

        next_graph =
          targets
          |> Enum.reduce(acc1, fn target, acc2 ->
            Graph.add_edge(acc2, {position, minute}, {target, minute + 1})
          end)

        {next_graph, [targets | new_targets]}
      end)

    path = Graph.dijkstra(new_graph, {start_pos, 0}, {end_pos, minute})

    if path != nil do
      # {minute, path
      {minute, blizzard_map}
    else
      new(
        new_blizzard_map,
        map,
        List.flatten(new_targets) |> Enum.uniq(),
        start_pos,
        end_pos,
        new_graph,
        minute + 1
      )
    end
  end

  def neighbours({1, 0}, _) do
    [{1, 0}, {1, 1}]
  end

  def neighbours(end_pos, {x, y} = end_pos) do
    [{x, y}, {x, y - 1}]
  end

  def neighbours({x, y}, map) do
    [{x + 1, y}, {x, y + 1}, {x - 1, y}, {x, y - 1}, {x, y}]
    |> Enum.filter(fn pos -> Map.get(map, pos) end)

    # |> Enum.reject(fn {x, y} -> x < 1 || x > 7 || y > 5 || y < 1 end)
  end

  # def neighbours({x, y}, {x_max, y_max}) do
  #   [{x + 1, y}, {x, y + 1}, {x - 1, y}, {x, y - 1}, {x, y}]
  #   |> Enum.reject(fn {x, y} -> x < 1 || x > 7 || y > 5 || y < 1 end)
  # end

  def create_blizzard_map(map) do
    Enum.reduce(map, {%{}, 0}, fn {{x, y}, dir}, {blizzard_map, id} ->
      if Enum.member?(@blizzard, dir) do
        new_map = Map.put(blizzard_map, {x, y, id}, dir)
        {new_map, id + 1}
      else
        {blizzard_map, id}
      end
    end)
  end

  @spec move_blizzard(any, any) :: any
  def move_blizzard(blizzard_map, map) do
    Enum.reduce(blizzard_map, %{}, fn {{x, y, blizzard_id}, dir} = blizzard, acc ->
      {new_x, new_y} = next_pos = blizzard_move(blizzard)

      if Map.get(map, next_pos) do
        acc
        |> Map.delete({x, y, blizzard_id})
        |> Map.put({new_x, new_y, blizzard_id}, dir)
      else
        {{new_x, new_y}, _} = wrap_around(map, {new_x, new_y}, dir)

        acc
        |> Map.delete({x, y, blizzard_id})
        |> Map.put({new_x, new_y, blizzard_id}, dir)
      end
    end)
  end

  def blizzard_move({{x, y, _}, "<"}), do: {x - 1, y}
  def blizzard_move({{x, y, _}, ">"}), do: {x + 1, y}
  def blizzard_move({{x, y, _}, "^"}), do: {x, y - 1}
  def blizzard_move({{x, y, _}, "v"}), do: {x, y + 1}

  def format(file) do
    file
    |> Utils.to_list_of_list()
    |> Utils.nested_list_to_xy_map()
    |> Enum.reject(fn {_k, v} -> v == "#" end)
    |> Map.new()
  end

  def find_start_end(map) do
    {start_pos, _v} = Enum.find(map, fn {{_x, y}, _v} -> y == 0 end)
    {end_pos, _v} = Enum.max_by(map, fn {{_x, y}, _v} -> y end)
    {start_pos, end_pos}
  end

  def wrap_around(map, {next_x, _next_y}, "v") do
    map
    |> Enum.filter(fn {{x, _y}, _val} -> x == next_x end)
    |> Enum.min_by(fn {{_x, y}, _val} -> y end)
  end

  def wrap_around(map, {next_x, _next_y}, "^") do
    map
    |> Enum.filter(fn {{x, _y}, _val} -> x == next_x end)
    |> Enum.max_by(fn {{_x, y}, _val} -> y end)
  end

  def wrap_around(map, {_next_x, next_y}, "<") do
    map
    |> Enum.filter(fn {{_x, y}, _val} -> y == next_y end)
    |> Enum.max_by(fn {{x, _y}, _val} -> x end)
  end

  def wrap_around(map, {_next_x, next_y}, ">") do
    map
    |> Enum.filter(fn {{_x, y}, _val} -> y == next_y end)
    |> Enum.min_by(fn {{x, _y}, _val} -> x end)
  end
end
