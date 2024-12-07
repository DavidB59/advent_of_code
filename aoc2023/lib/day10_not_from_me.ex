defmodule Day10_copy do
  def part1(input) do
    digraph = process(input)
    [starting_position] = :digraph_utils.loop_vertices(digraph)
    :digraph.del_path(digraph, starting_position, starting_position)

    for vertix <- :digraph.in_neighbours(digraph, starting_position) do
      :digraph.add_edge(digraph, starting_position, vertix)
    end

    :digraph_utils.reachable_neighbours([starting_position], digraph)
    |> length
    |> then(&floor(&1 / 2))
  end

  def process(raw_sketch) do
    raw_lines =
      raw_sketch
      |> String.split("\n")

    height =
      raw_lines
      |> Enum.count()

    width =
      raw_lines
      |> List.first()
      |> String.length()

    digraph = :digraph.new()

    for h <- 0..(height + 1), w <- 0..(width + 1) do
      :digraph.add_vertex(digraph, {h, w})
    end

    for {raw_line, h} <- Enum.with_index(raw_lines, 1) do
      for {raw_char, w} <- Enum.with_index(String.graphemes(raw_line), 1) do
        case raw_char do
          "|" -> [{h - 1, w}, {h + 1, w}]
          "-" -> [{h, w - 1}, {h, w + 1}]
          "L" -> [{h - 1, w}, {h, w + 1}]
          "J" -> [{h - 1, w}, {h, w - 1}]
          "7" -> [{h + 1, w}, {h, w - 1}]
          "F" -> [{h + 1, w}, {h, w + 1}]
          "." -> []
          "S" -> [{h, w}]
        end
        |> Enum.map(&:digraph.add_edge(digraph, {h, w}, &1))
      end
    end

    digraph
  end
end
