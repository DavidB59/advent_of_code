defmodule Day3 do
  def file do
    Parser.read_file(3)
  end

  def part_one do
    file()
    |> Enum.map(fn string ->
      string
      |> String.length()
      |> div(2)
      |> split_string_in_two(string)
      |> find_match()
      |> adjust_priority()
    end)
    |> Enum.sum()
  end

  def split_string_in_two(half_length, string) do
    <<one::bytes-size(half_length)>> <> <<two::bytes-size(half_length)>> = string
    {one, two}
  end

  def find_match({one, two}) do
    one |> String.graphemes() |> Enum.find(&String.contains?(two, &1))
  end

  def adjust_priority(char) do
    if String.downcase(char) == char do
      # a = 97, must be 1
      Utils.character_to_integer(char) - 96
    else
      # A = 65, must be 27
      Utils.character_to_integer(char) - 38
    end
  end

  def part_two do
    take_three_by_three(file())
  end

  def take_three_by_three(sum \\ 0, list)
  def take_three_by_three(sum, []), do: sum

  def take_three_by_three(sum, [one, two, three | rest]) do
    one
    |> String.graphemes()
    |> Enum.filter(&String.contains?(two, &1))
    |> Enum.find(&String.contains?(three, &1))
    |> adjust_priority()
    |> Kernel.+(sum)
    |> take_three_by_three(rest)
  end
end
