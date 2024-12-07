defmodule Day4 do
  def file do
    Parser.read_file(4)
  end

  def test do
    Parser.read_file("test")
  end

  def solve(input \\ file()) do
    map = parse(input)

    map
    |> Enum.map(&number_of_x_mas(&1, map))
    |> Enum.sum()
  end

  def parse(input) do
    input |> Utils.to_list_of_list() |> Utils.nested_list_to_xy_map()
  end

  def number_of_x_mas({{x, y}, "X"}, map) do
    Enum.reduce(Utils.neighbours_coordinates({x, y}), 0, fn coords, acc ->
      value = Map.get(map, coords)

      case value do
        "M" ->
          {next_x, next_y} = coords
          {x_translation, y_translation} = {next_x - x, next_y - y}
          a_coordinates = {next_x + x_translation, next_y + y_translation}
          s_coordinates = {next_x + 2 * x_translation, next_y + 2 * y_translation}

          if Map.get(map, a_coordinates) == "A" and Map.get(map, s_coordinates) == "S" do
            acc + 1
          else
            acc
          end

        _ ->
          acc
      end
    end)
  end

  def number_of_x_mas(_, _), do: 0

  def solve_two(input \\ file()) do
    map = parse(input)

    map
    |> Enum.map(&number_of_cross_mas(&1, map))
    |> Enum.sum()
  end

  def number_of_cross_mas({{x, y}, "A"}, map) do
    first = {x + 1, y + 1}
    second = {x - 1, y - 1}

    diag1 =
      [Map.get(map, first), Map.get(map, second)]
      |> case do
        ["M", "S"] -> true
        ["S", "M"] -> true
        _ -> false
      end

    first = {x + 1, y - 1}
    second = {x - 1, y + 1}

    diag2 =
      [Map.get(map, first), Map.get(map, second)]
      |> case do
        ["M", "S"] -> true
        ["S", "M"] -> true
        _ -> false
      end

    if diag1 and diag2 do
      1
    else
      0
    end
  end

  def number_of_cross_mas({{_x, _y}, _}, _map), do: 0
end
