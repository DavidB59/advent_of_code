defmodule Day16 do
  def file do
    Parser.read_file(16)
  end

  def test do
    "test" |> Parser.read_file()
  end

  def part_two() do
    file()
    |> format()
    |> solve_part_two()
  end

  def part_one() do
    file()
    |> format()
    |> solve_part_one()
  end

  def solve_test() do
    test()
    |> format()
    |> solve_part_one()
  end

  def format(file) do
    file
    |> Enum.map(fn string ->
      [a, b] = String.split(string, ";")

      {valve_name(a), lead_to(b)}
    end)
  end

  def valve_name("Valve " <> <<valve_name::bytes-size(2)>> <> rest) do
    pressure = Utils.extract_number_from_string(rest) |> String.to_integer()
    {valve_name, pressure}
  end

  def lead_to(" tunnels lead to valves " <> valves) do
    valves |> String.split(",") |> Enum.map(&String.trim/1)
  end

  def lead_to(" tunnel leads to valve " <> valves) do
    valves |> String.split(",") |> Enum.map(&String.trim/1)
  end

  def build_graph(list) do
    Enum.reduce(list, Graph.new(), fn {{start, _weight}, targets}, graph ->
      Enum.reduce(targets, graph, fn target, acc ->
        edge = Graph.Edge.new(start, target)
        Graph.add_edge(acc, edge)
      end)
    end)
  end

  def rate_map(list) do
    Enum.reduce(list, %{}, fn {{start, weight}, _targets}, map ->
      if weight == 0 do
        map
      else
        Map.put(map, start, weight)
      end
    end)
  end

  def all_path(file) do
    rate_map = rate_map(file)
    graph = build_graph(file)
    target_list = Map.keys(rate_map) ++ ["AA"]

    Enum.reduce(target_list, %{}, fn target, map ->
      Enum.reduce(target_list, map, fn target_2, acc ->
        path = Graph.dijkstra(graph, target, target_2)
        Map.put(acc, {target, target_2}, path)
      end)
      |> Map.merge(map)
    end)
  end

  def solve_part_one(list) do
    time_remaining = 30
    all_path = all_path(list)
    rate_map = rate_map(list)
    start_pos = "AA"

    current_pressure = 0

    target_valves = Map.keys(rate_map)

    Enum.reduce(target_valves, 0, fn target, acc ->
      res =
        go_to_target(
          target,
          rate_map,
          start_pos,
          time_remaining,
          current_pressure,
          all_path
        )

      if res > acc, do: res, else: acc
    end)
  end

  def solve_part_two(list) do
    time_remaining = 26
    all_path = all_path(list)
    rate_map = rate_map(list)
    start_pos = "AA"

    current_pressure = 0

    target_valves = Map.keys(rate_map)

    Enum.reduce(target_valves, 0, fn target, acc ->
      res =
        move_me(
          target,
          rate_map,
          {start_pos, start_pos},
          {time_remaining, time_remaining},
          current_pressure,
          all_path
        )

      if res > acc, do: res, else: acc
    end)
  end

  def move_me(_, _, _, {me_time, ele_time}, cp, _) when me_time <= 0 and ele_time <= 0, do: cp

  def move_me(t, r, {me_pos, ele_pos}, {me_time, ele_time}, cp, ap) when me_time <= 0 do
    move_elephant(t, r, {me_pos, ele_pos}, {me_time, ele_time}, cp, ap)
  end

  def move_me(
        target,
        rate_map,
        {me_pos, ele_pos},
        {me_time, ele_time},
        current_pressure,
        all_path
      ) do
    path = Map.get(all_path, {me_pos, target})
    time_to_go = Enum.count(path) - 1
    rate = Map.get(rate_map, target)

    time_remaining = me_time - time_to_go - 1
    pressure_gained = time_remaining * rate
    new_pressure = current_pressure + pressure_gained

    new_rate_map = Map.delete(rate_map, target)

    target_valves = Map.keys(new_rate_map)

    if target_valves == [] do
      new_pressure
    else
      Enum.reduce(target_valves, new_pressure, fn new_target, acc ->
        res =
          move_elephant(
            new_target,
            new_rate_map,
            {target, ele_pos},
            {time_remaining, ele_time},
            new_pressure,
            all_path
          )

        if res > acc, do: res, else: acc
      end)
    end
  end

  def move_elephant(_, _, _, {me_time, ele_time}, cp, _) when me_time <= 0 and ele_time <= 0,
    do: cp

  def move_elephant(t, r, {me_pos, ele_pos}, {me_time, ele_time}, cp, ap) when ele_time <= 0 do
    move_me(t, r, {me_pos, ele_pos}, {me_time, ele_time}, cp, ap)
  end

  def move_elephant(
        target,
        rate_map,
        {me_pos, ele_pos},
        {me_time, ele_time},
        current_pressure,
        all_path
      ) do
    path = Map.get(all_path, {ele_pos, target})
    time_to_go = Enum.count(path) - 1
    rate = Map.get(rate_map, target)

    time_remaining = ele_time - time_to_go - 1
    pressure_gained = time_remaining * rate
    new_pressure = current_pressure + pressure_gained

    new_rate_map = Map.delete(rate_map, target)

    target_valves = Map.keys(new_rate_map)

    if target_valves == [] do
      new_pressure
    else
      Enum.reduce(target_valves, new_pressure, fn new_target, acc ->
        res =
          move_me(
            new_target,
            new_rate_map,
            {me_pos, target},
            {me_time, time_remaining},
            new_pressure,
            all_path
          )

        if res > acc, do: res, else: acc
      end)
    end
  end

  def go_to_target(_, _, _, time, cp, _) when time <= 0, do: cp

  def go_to_target(
        target,
        rate_map,
        current_position,
        current_time,
        current_pressure,
        all_path
      ) do
    path = Map.get(all_path, {current_position, target})
    time_to_go = Enum.count(path) - 1
    rate = Map.get(rate_map, target)

    time_remaining = current_time - time_to_go - 1
    pressure_gained = time_remaining * rate
    new_pressure = current_pressure + pressure_gained

    new_rate_map = Map.delete(rate_map, target)

    target_valves = Map.keys(new_rate_map)

    if target_valves == [] do
      new_pressure
    else
      Enum.reduce(target_valves, new_pressure, fn new_target, acc ->
        res =
          go_to_target(
            new_target,
            new_rate_map,
            target,
            time_remaining,
            new_pressure,
            all_path
          )

        if res > acc, do: res, else: acc
      end)
    end
  end
end
