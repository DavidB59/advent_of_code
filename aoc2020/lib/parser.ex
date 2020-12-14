defmodule Parser do
  def read_file(day) do
    path = "/Users/dehub/advent_of_code/aoc2020/lib/input/#{day}"

    case File.read(path) do
      {:ok, file} -> file |> String.split("\n")
      error -> error
    end
  end
end
