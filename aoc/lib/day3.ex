defmodule Day3 do
  @moduledoc """
  Documentation for Day3.
  """

  def part_one() do
    [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]
    |> Enum.map(&move(&1))
    |> Enum.reduce(fn x, acc -> x * acc end)
  end

  def move({right, skip}) do
    list = Parser.read_file("day3")

    if skip == 2 do
      skip_one(list, right)
    else
      regular(list, right)
    end
  end

  def regular(list, right) do
    {count, _y} =
      Enum.reduce(list, {0, 0}, fn line, {count, y} ->
        y = check_length(line, y)
        tree? = line |> String.at(y) |> is_tree
        count = if tree?, do: count + 1, else: count
        {count, y + right}
      end)

    count
  end

  def skip_one(list, right) do
    {count, _y, _index} =
      Enum.reduce(list, {0, 0, 0}, fn
        line, {count, y, index} ->
          if check_even(index, 2) do
            y = check_length(line, y)
            tree? = line |> String.at(y) |> is_tree
            count = if tree?, do: count + 1, else: count
            {count, y + right, index + 1}
          else
            {count, y, index + 1}
          end
      end)

    count
  end

  def check_even(a, b) do
    if Integer.mod(a, b) == 0, do: true, else: false
  end

  def is_tree("#"), do: true
  def is_tree("."), do: false

  def check_length(line, y) do
    max = String.length(line)

    if y > max - 1 do
      y - max
    else
      y
    end
  end

  def test do
    [
      "..##.........##.........##.........##.........##.........##.......",
      "#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..",
      ".#....#..#..#....#..#..#....#..#..#....#..#..#....#..#..#....#..#.",
      "..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#",
      ".#...##..#..#...##..#..#...##..#..#...##..#..#...##..#..#...##..#.",
      "..#.##.......#.##.......#.##.......#.##.......#.##.......#.##.....",
      ".#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#",
      ".#........#.#........#.#........#.#........#.#........#.#........#",
      "#.##...#...#.##...#...#.##...#...#.##...#...#.##...#...#.##...#...",
      "#...##....##...##....##...##....##...##....##...##....##...##....#",
      ".#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.# "
    ]
  end
end
