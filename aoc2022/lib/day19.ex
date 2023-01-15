defmodule Day19 do
  @part_1 24
  @part_2 32
  def file do
    Parser.read_file(19)
  end

  def test do
    "test_19" |> Parser.read_file()
  end

  def part_two() do
    blueprints = file() |> format |> Map.take([1, 2, 3])
    ressource_map = %{ore: 0, geode: 0, clay: 0, obsidian: 0}
    robot_map = %{ore_robot: 1, clay_robot: 0, geode_robot: 0, obsidian_robot: 0}

    Enum.map(blueprints, fn {blueprint_id, blueprint_map} ->
      IO.inspect(blueprint_id)

      geodes =
        do_24(blueprint_map, ressource_map, robot_map, @part_2)
        |> List.flatten()
        |> Enum.map(fn a -> a.geode end)
        |> Enum.max()

      geodes
    end)
    |> IO.inspect()
    |> Enum.product()
  end

  def part_one() do
    blueprints = file() |> format
    ressource_map = %{ore: 0, geode: 0, clay: 0, obsidian: 0}
    robot_map = %{ore_robot: 1, clay_robot: 0, geode_robot: 0, obsidian_robot: 0}
    # blueprint = Map.get(blueprints, 1)

    Enum.map(blueprints, fn {blueprint_id, blueprint_map} ->
      IO.inspect(blueprint_id)

      geodes =
        do_24(blueprint_map, ressource_map, robot_map, @part_1)
        |> List.flatten()
        |> Enum.map(fn a -> a.geode end)
        |> Enum.max()

      {blueprint_id, geodes}
    end)
    |> Enum.map(fn {a, b} -> a * b end)
    |> Enum.sum()
  end

  def do_24(blueprint_map, ressource, robot_map, minute \\ 1, total)

  def do_24(_blueprint_map, ressource, robot_map, minute, minute),
    do: collect(robot_map, ressource)

  def do_24(blueprint_map, ressource, robot_map, minute, total) do
    if minute < total do
      list = build_robot({robot_map, ressource}, blueprint_map)

      Enum.map(list, fn {new_robot_map, ressource_map} ->
        new_ressource_map = collect(robot_map, ressource_map)

        do_24(blueprint_map, new_ressource_map, new_robot_map, minute + 1, total)
      end)
    else
      list = build_advanced({robot_map, ressource}, blueprint_map)

      Enum.map([list], fn {new_robot_map, ressource_map} ->
        new_ressource_map = collect(robot_map, ressource_map)

        do_24(blueprint_map, new_ressource_map, new_robot_map, minute + 1, total)
      end)
    end
  end

  def build_robot(start_value, blueprint_map) do
    with {:no_build, resp} <- build_geode_robot(start_value, blueprint_map),
         {:no_build, resp} <- build_obsidian_robot(resp, blueprint_map) do
      resp
      |> build_ore_robot(blueprint_map)
      |> build_clay_robot_list(blueprint_map)
    else
      resp -> [resp]
    end
  end

  def build_advanced(start_value, blueprint_map) do
    with {:no_build, resp} <- build_geode_robot(start_value, blueprint_map),
         {:no_build, resp} <- build_obsidian_robot(resp, blueprint_map) do
      resp
    end
  end

  def collect(robot_map, ressource) do
    ressource
    |> collect(robot_map, :clay_robot, :clay)
    |> collect(robot_map, :ore_robot, :ore)
    |> collect(robot_map, :obsidian_robot, :obsidian)
    |> collect(robot_map, :geode_robot, :geode)
  end

  def collect(ressource_map, robot_map, robot_key, ressource_key) do
    robot_nb = Map.get(robot_map, robot_key, 0)

    if robot_nb == 0 do
      ressource_map
    else
      Map.update!(ressource_map, ressource_key, fn ressource -> ressource + robot_nb end)
    end
  end

  def build_clay_robot_list(list, robot_map) do
    Enum.reduce(list, [], fn elem, acc ->
      case elem do
        {:no_build, resp} ->
          build_clay_robot(resp, robot_map) ++ acc

        elem ->
          [elem | acc]
      end
    end)
    |> Enum.uniq()
  end

  # def build_clay_robot({%{clay_robot: 0} = robot_map, %{ore: ore} = ressource_map}, %{
  #       clay_robot: ore_cost
  #     }) do
  #   if ore >= ore_cost do
  #     robot_built = Map.update!(robot_map, :clay_robot, fn a -> a + 1 end)
  #     one = {robot_built, Map.put(ressource_map, :ore, ore - ore_cost)}
  #     [one]
  #   else
  #     [{robot_map, ressource_map}]
  #   end
  # end

  # def build_clay_robot({%{clay_robot: clay_robot} = robot_map, ressource_map}, _blueprint_map)
  #     when clay_robot > 6 do
  #   [{robot_map, ressource_map}]
  # end

  def build_clay_robot(
        {robot_map, %{ore: ore} = ressource_map},
        %{
          clay_robot: clay_robot_cost,
          ore_robot: ore_robot_cost,
          obsidian_robot: [obsidian_ore_cost, _clay_cost]
        }
      ) do
    if ore >= clay_robot_cost and ore > ore_robot_cost and ore > obsidian_ore_cost do
      robot_built = Map.update!(robot_map, :clay_robot, fn a -> a + 1 end)
      one = {robot_built, Map.put(ressource_map, :ore, ore - clay_robot_cost)}
      [one]
    else
      if ore >= clay_robot_cost do
        robot_built = Map.update!(robot_map, :clay_robot, fn a -> a + 1 end)
        one = {robot_built, Map.put(ressource_map, :ore, ore - clay_robot_cost)}
        [one, {robot_map, ressource_map}]
      else
        [{robot_map, ressource_map}]
      end
    end
  end

  def build_ore_robot({%{ore_robot: ore_robot} = robot_map, ressource_map}, _blueprint_map)
      when ore_robot > 5 do
    [{:no_build, {robot_map, ressource_map}}]
  end

  def build_ore_robot({robot_map, %{ore: ore} = ressource_map}, %{ore_robot: ore_cost}) do
    if ore >= ore_cost do
      robot_built = Map.update!(robot_map, :ore_robot, fn a -> a + 1 end)
      one = {robot_built, Map.put(ressource_map, :ore, ore - ore_cost)}
      [one, {:no_build, {robot_map, ressource_map}}]
    else
      [{:no_build, {robot_map, ressource_map}}]
    end
  end

  def build_obsidian_robot({robot_map, %{ore: ore, clay: clay} = ressource_map}, %{
        obsidian_robot: [ore_cost, clay_cost]
      }) do
    if ore >= ore_cost and clay >= clay_cost do
      robot_built = Map.update!(robot_map, :obsidian_robot, fn a -> a + 1 end)

      {robot_built,
       Map.put(ressource_map, :ore, ore - ore_cost) |> Map.put(:clay, clay - clay_cost)}
    else
      {:no_build, {robot_map, ressource_map}}
    end
  end

  def build_geode_robot({robot_map, %{ore: ore, obsidian: obsidian} = ressource_map}, %{
        geode_robot: [ore_cost, obsidian_cost]
      }) do
    if ore >= ore_cost and obsidian >= obsidian_cost do
      robot_built = Map.update!(robot_map, :geode_robot, fn a -> a + 1 end)

      {robot_built,
       Map.put(ressource_map, :ore, ore - ore_cost)
       |> Map.put(:obsidian, obsidian - obsidian_cost)}
    else
      {:no_build, {robot_map, ressource_map}}
    end
  end

  def format(file) do
    file
    |> Enum.reduce(%{}, fn string, acc ->
      [blueprint, ore_robot, clay_robot, obsidian_robot, geode_robot] =
        String.split(string, "Each")

      blueprint_id = blueprint_id(blueprint)
      ore_robot = ore_robot(ore_robot)
      clay_robot = clay_robot(clay_robot)
      obsidian_robot = obsidian_robot(obsidian_robot)
      geode_robot = geode_robot(geode_robot)

      costs = %{
        ore_robot: ore_robot,
        clay_robot: clay_robot,
        obsidian_robot: obsidian_robot,
        geode_robot: geode_robot
      }

      Map.put(acc, blueprint_id, costs)
    end)
  end

  def blueprint_id(blueprint),
    do: Utils.extract_number_from_string(blueprint) |> String.to_integer()

  # cost ore only
  def ore_robot(string), do: Utils.extract_number_from_string(string) |> String.to_integer()
  # cost ore only
  def clay_robot(string), do: Utils.extract_number_from_string(string) |> String.to_integer()
  # cost ore then clay
  def obsidian_robot(string) do
    string
    |> String.split(" ")
    |> Enum.map(&Utils.extract_number_from_string/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.to_integer/1)
  end

  # cost ore then obsidian
  def geode_robot(string) do
    string
    |> String.split(" ")
    |> Enum.map(&Utils.extract_number_from_string/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.to_integer/1)
  end

  def solve_test() do
    blueprints = test() |> format
    ressource_map = %{ore: 0, geode: 0, clay: 0, obsidian: 0}
    robot_map = %{ore_robot: 1, clay_robot: 0, geode_robot: 0, obsidian_robot: 0}

    Enum.map(blueprints, fn {blueprint_id, blueprint_map} ->
      geodes =
        do_24(blueprint_map, ressource_map, robot_map, @part_2)
        |> List.flatten()
        |> Enum.map(fn a -> a.geode end)
        |> Enum.max()

      {blueprint_id, geodes} |> IO.inspect()
    end)
    |> Enum.map(fn {a, b} -> a * b end)
    |> Enum.sum()
  end
end
