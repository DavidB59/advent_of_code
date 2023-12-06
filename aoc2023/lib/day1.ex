defmodule Day1 do
  def file do
    Parser.read_file(1)
  end

  def test do
    Parser.read_file("test")
  end

  def solve do
    regex = ~r/1|2|3|4|5|6|7|8|9/

    file()
    |> Enum.map(&find_number(&1, regex))
    |> Enum.sum()
  end

  def solve_two do
    regex = ~r/one|two|three|four|five|six|seven|eight|nine|1|2|3|4|5|6|7|8|9/

    file()
    |> Enum.map(&find_number_2(&1, regex))
    |> Enum.sum()
  end

  def find_number(string, regex) do
    regex
    |> Regex.scan(string)
    |> List.flatten()
    |> Enum.map(&format/1)
    |> combine_first_last()
    |> String.to_integer()
  end

  def find_number_2(string, regex) do
    reverse_regex = ~r/9|8|7|6|5|4|3|2|1|enin|thgie|neves|xis|evif|ruof|eerht|owt|eno/
    n1 = Regex.scan(regex, string) |> List.flatten() |> List.first() |> format()

    n2 =
      Regex.scan(reverse_regex, String.reverse(string))
      |> List.flatten()
      |> List.first()
      |> format()

    (n1 <> n2) |> String.to_integer()
  end

  def combine_first_last([a]), do: a <> a
  def combine_first_last([a, b]), do: a <> b
  def combine_first_last([a | rest]), do: a <> List.last(rest)

  def format("one"), do: "1"
  def format("two"), do: "2"
  def format("three"), do: "3"
  def format("four"), do: "4"
  def format("five"), do: "5"
  def format("six"), do: "6"
  def format("seven"), do: "7"
  def format("eight"), do: "8"
  def format("nine"), do: "9"

  def format("enin"), do: "9"
  def format("thgie"), do: "8"
  def format("neves"), do: "7"
  def format("xis"), do: "6"
  def format("evif"), do: "5"
  def format("ruof"), do: "4"
  def format("eerht"), do: "3"
  def format("owt"), do: "2"
  def format("eno"), do: "1"
  def format(a), do: a
end
