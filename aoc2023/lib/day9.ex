defmodule Day9 do
  def file do
    Parser.read_file(9)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input |> Enum.map(fn string -> string |> String.split() |> Enum.map(&String.to_integer/1) end)
  end

  def solve(input) do
    input
    |> parse()
    |> Enum.map(fn list ->
      list
      |> repeat_until_zeroes([list])
      |> Enum.map(&List.last/1)
      |> Enum.reduce(&(&1 + &2))
    end)
    |> Enum.sum()
  end

  def solve_two(input) do
    input
    |> parse()
    |> Enum.map(fn list ->
      list
      |> build_history([list])
      |> Enum.map(&List.first/1)
      |> Enum.reduce(&(&1 - &2))
    end)
    |> Enum.sum()
  end

  def build_history(list, result_list) do
    new_result = next_line(list)
    new_result_list = [new_result | result_list]

    if Enum.all?(new_result, &(&1 == 0)) do
      new_result_list
    else
      build_history(new_result, new_result_list)
    end
  end

  def next_line(list, results \\ [])
  def next_line([_], results), do: results
  def next_line([a, b | rest], results), do: next_line([b | rest], results ++ [b - a])
end
