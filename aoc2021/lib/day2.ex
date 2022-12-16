defmodule Day2 do
  def file, do: Parser.read_file("day2")

  def parse(file) do
    Enum.map(file, fn string ->
      [command, value] = String.split(string, " ")
      {command, String.to_integer(value)}
    end)
  end

  def test do
    ["forward 5", "down 5", "forward 8", "up 3", "down 8", "forward 2"]
  end

  def solve() do
    {x, y} =
      file()
      |> parse()
      |> calculate_position()

    x * y
  end

  def calculate_position(command_list) do
    Enum.reduce(command_list, {0, 0}, &move(&1, &2))
  end

  def move({"forward", value}, {horizontal, depth}), do: {horizontal + value, depth}
  def move({"up", value}, {horizontal, depth}), do: {horizontal, depth - value}
  def move({"down", value}, {horizontal, depth}), do: {horizontal, depth + value}

  def solve_two() do
    {x, y, _} =
      file()
      |> parse()
      |> calculate_positon_two()

    x * y
  end

  def calculate_positon_two(command_list) do
    Enum.reduce(command_list, {0, 0, 0}, &move_two(&1, &2))
  end

  def move_two({"forward", value}, {horizontal, depth, aim}) do
    {horizontal + value, depth + aim * value, aim}
  end

  def move_two({"up", value}, {horizontal, depth, aim}), do: {horizontal, depth, aim - value}
  def move_two({"down", value}, {horizontal, depth, aim}), do: {horizontal, depth, aim + value}
end
