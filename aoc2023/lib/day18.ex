defmodule Day18 do
  def file do
    Parser.read_file(18)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input), do: Enum.map(input, &extract_from_string/1)

  def extract_from_string(<<direction::binary-1>> <> " " <> <<count::binary-1>> <> " " <> rgb) do
    {direction, String.to_integer(count), rgb}
  end

  def extract_from_string(<<direction::binary-1>> <> " " <> <<count::binary-2>> <> " " <> rgb) do
    {direction, String.to_integer(count), rgb}
  end

  def solve(input) do
    input
    |> parse
    |> dig()
    |> Enum.uniq()
    |> calculate_nb_points()
  end

  def dig(instructions, list_point \\ [{0, 0}])

  def dig([], list_point), do: list_point

  def dig([{dir, count, _} | rest], list_point) do
    new_list =
      Enum.reduce(1..count, list_point, fn _, [position | _] = list ->
        next = next_point(dir, position)
        [next | list]
      end)

    dig(rest, new_list)
  end

  def calculate_nb_points(list) do
    boundary_points = Enum.count(list)
    area = Utils.polygon_area(list)
    # Picks Theorem
    # Area = interior_points + (boundary_points/2) - 1
    interior_points = area - boundary_points / 2 + 1
    interior_points + boundary_points
  end

  def next_point(direction, position)
  def next_point("R", pos), do: to_east(pos)
  def next_point("U", pos), do: to_north(pos)
  def next_point("D", pos), do: to_south(pos)
  def next_point("L", pos), do: to_west(pos)

  def to_north({x, y}), do: {x, y - 1}
  def to_west({x, y}), do: {x - 1, y}
  def to_south({x, y}), do: {x, y + 1}
  def to_east({x, y}), do: {x + 1, y}

  def solve_two(input) do
    input
    |> parse()
    |> read_instruction_from_rgb_code()
    |> dig
    |> Enum.uniq()
    |> calculate_nb_points()
  end

  def read_instruction_from_rgb_code(list) do
    Enum.map(list, fn {_, _, rgb} ->
      "(#" <> <<exa::bytes-size(5)>> <> <<dir::bytes-size(1)>> <> ")" = rgb
      {count, _} = Integer.parse(exa, 16)
      {dir_convert(dir), count, ""}
    end)
  end

  def dir_convert("0"), do: "R"
  def dir_convert("1"), do: "D"
  def dir_convert("2"), do: "L"
  def dir_convert("3"), do: "U"
end
