defmodule Day23 do
  def file, do: Parser.read_file("day23")
  def test, do: Parser.read_file("test")

  def parse(input) do
    input
    |> Enum.map(&String.graphemes/1)
    |> Utils.nested_list_to_xy_map()
    |> Enum.reject(fn {_k, v} -> v == " " || v == "#" end)
  end
end
