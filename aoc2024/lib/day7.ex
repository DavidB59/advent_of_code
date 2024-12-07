defmodule Day7 do
  def file do
    Parser.read_file(7)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    regex = ~r/[0-9]+/

    input
    |> Enum.map(fn string ->
      regex
      |> Regex.scan(string)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def solve(input \\ file()) do
    input
    |> parse()
    |> Enum.map(&is_valid_operation/1)
    |> Enum.sum()
  end

  def is_valid_operation([expected | list_number]) do
    valid? =
      list_number
      |> calculate(expected)
      |> List.flatten()
      |> Enum.any?()

    if valid?, do: expected, else: 0
  end

  def calculate(list_numbers, expected, result \\ 0)
  def calculate([a | rest], expected, 0), do: calculate(rest, expected, a)
  def calculate([], expected, expected), do: true
  def calculate([], _expected, _result), do: false
  def calculate(_, expected, result) when result > expected, do: false

  def calculate([a | rest], expected, result) do
    [
      calculate(rest, expected, result + a),
      calculate(rest, expected, result * a),
      calculate(rest, expected, concatenate(result, a))
    ]
  end

  def concatenate(n1, n2) do
    (Integer.to_string(n1) <> Integer.to_string(n2)) |> String.to_integer()
  end
end
