defmodule Day10 do
  defp file do
    Parser.read_file("day10")
  end

  defp test do
    Parser.read_file("test")
  end

  defp remove_pair(line, old_line \\ nil)
  defp remove_pair([], _), do: false

  defp remove_pair(line, line) do
    is_line_corrupted?(line)
  end

  defp remove_pair(line, _old_line) do
    line
    |> String.replace("<>", "")
    |> String.replace("{}", "")
    |> String.replace("()", "")
    |> String.replace("[]", "")
    |> remove_pair(line)
  end

  defp is_line_corrupted?(line) do
    not_corrupted =
      line
      |> String.graphemes()
      |> Enum.all?(&(&1 in open()))

    if not_corrupted, do: {false, line}, else: {true, line}
  end

  def solve_part_one() do
    file()
    |> Enum.map(&remove_pair/1)
    |> Enum.filter(fn {bool, _line} -> bool end)
    |> Enum.map(fn {_bool, string} ->
      string
      |> String.graphemes()
      |> Enum.find(&(&1 in close()))
      |> score()
    end)
    |> Enum.sum()
  end

  defp open(), do: ["(", "[", "{", "<"]
  defp close(), do: [")", "}", "]", ">"]

  defp score(")"), do: 3
  defp score("]"), do: 57
  defp score("}"), do: 1197
  defp score(">"), do: 25137

  def solve_part_two do
    file()
    |> Enum.map(&remove_pair/1)
    |> Enum.reject(fn {bool, _line} -> bool end)
    |> Enum.map(fn {_bool, string} ->
      string
      |> String.graphemes()
      |> Enum.reverse()
      |> complete_line([])
    end)
    |> Enum.map(&count_point/1)
    |> get_winner()
  end

  defp complete_line([head | rest], list_terminator) do
    closing = closing_match(head)
    complete_line(rest, [closing | list_terminator])
  end

  defp complete_line([], terminator), do: terminator

  defp closing_match("("), do: ")"
  defp closing_match("{"), do: "}"
  defp closing_match("<"), do: ">"
  defp closing_match("["), do: "]"

  defp count_point(list) do
    list
    |> Enum.reverse()
    |> Enum.reduce(0, fn char, acc ->
      score = score_two(char)
      acc * 5 + score
    end)
  end

  defp score_two(")"), do: 1
  defp score_two("]"), do: 2
  defp score_two("}"), do: 3
  defp score_two(">"), do: 4

  defp get_winner(list) do
    index = (length(list) / 2) |> floor()

    list
    |> Enum.sort()
    |> Enum.at(index)
  end
end
