defmodule Day2 do
  def file do
    Parser.read_file(2)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Enum.map(fn string ->
      {_, rest} = String.split_at(string, 5)
      [id, string_games] = String.split(rest, ":")

      games =
        String.split(string_games, ";")
        |> Enum.map(fn s ->
          s
          |> String.split(",")
          |> Enum.map(fn a -> a |> String.trim() |> extract_number() end)
        end)

      {String.to_integer(id), games}
    end)
    |> Map.new()
  end

  def extract_number(<<match::bytes-size(1)>> <> " blue"), do: {String.to_integer(match), "blue"}

  def extract_number(<<match::bytes-size(1)>> <> " green"),
    do: {String.to_integer(match), "green"}

  def extract_number(<<match::bytes-size(1)>> <> " red"), do: {String.to_integer(match), "red"}

  def extract_number(<<match::bytes-size(2)>> <> " blue"), do: {String.to_integer(match), "blue"}

  def extract_number(<<match::bytes-size(2)>> <> " green"),
    do: {String.to_integer(match), "green"}

  def extract_number(<<match::bytes-size(2)>> <> " red"), do: {String.to_integer(match), "red"}

  def solve(input) do
    input
    |> parse()
    |> Enum.reject(fn {_id, games} ->
      Enum.any?(games, &impossible_game?(&1))
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def impossible_game?(list_cubes) do
    Enum.any?(list_cubes, &max_cube_per_color/1)
  end

  def max_cube_per_color({number, "red"}), do: number > 12
  def max_cube_per_color({number, "green"}), do: number > 13
  def max_cube_per_color({number, "blue"}), do: number > 14

  def solve_two(input) do
    input
    |> parse()
    |> Enum.map(fn {_id, games} -> find_minimum_cube(games) end)
    |> Enum.map(fn %{blue: blue, red: red, green: green} -> green * red * blue end)
    |> Enum.sum()
  end

  def find_minimum_cube(games) do
    Enum.reduce(games, %{green: 0, red: 0, blue: 0}, fn game, acc ->
      Enum.reduce(game, acc, &update_minimum_cube/2)
    end)
  end

  def update_minimum_cube({number, "red"}, map), do: Map.update!(map, :red, &max(&1, number))
  def update_minimum_cube({number, "green"}, map), do: Map.update!(map, :green, &max(&1, number))
  def update_minimum_cube({number, "blue"}, map), do: Map.update!(map, :blue, &max(&1, number))
end
