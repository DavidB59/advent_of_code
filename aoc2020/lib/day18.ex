defmodule Day18 do
  @moduledoc """
  Documentation for Day18.
  """

  def part_one() do
    file() |> format() |> solve_one()
  end

  def part_two() do
    file() |> format() |> solve_two()
  end

  def test() do
    Parser.read_file("test") |> format()
  end

  def solve_one(list) do
    list
    |> Enum.map(&format_operation/1)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  def solve_two(list) do
    list
    |> Enum.map(&format_operation_two/1)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  def test1 do
    "5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"
  end

  def test2 do
    "5 + (8 * 3 + 9 + 3 * 4 * 3)"
  end

  def file() do
    Parser.read_file("day18")
  end

  def format(file) do
    Enum.map(file, &string_prep/1)
  end

  def string_prep(string) do
    string
    |> String.graphemes()
    |> Enum.reject(&(&1 == " "))
  end

  def calculate_inside_bracket_with_prio(operation) do
    index_plus = Enum.find_index(operation, &(&1 == "+"))

    if index_plus do
      [result] =
        operation
        |> Enum.slice((index_plus - 1)..(index_plus + 1))
        |> calculate_inside_bracket()

      operation
      |> List.replace_at(index_plus, result)
      |> List.pop_at(index_plus + 1)
      |> elem(1)
      |> List.pop_at(index_plus - 1)
      |> elem(1)
      |> calculate_inside_bracket_with_prio()
    else
      calculate_inside_bracket(operation)
    end
  end

  def calculate_inside_bracket([nb1, sign, nb2 | rest]) do
    {result, _} = [nb1, sign, nb2] |> List.to_string() |> Code.eval_string()
    next = ["#{result}"] ++ rest
    calculate_inside_bracket(next)
  end

  def calculate_inside_bracket(list), do: list

  def format_operation_two(operation) do
    index1 = find_index_closing_bracket(operation)

    if index1 do
      part1 = Enum.slice(operation, 0..index1)
      index2 = Enum.reverse(part1) |> find_index_opening_bracket()
      index2 = length(part1) - index2 - 1
      {before_closing_bracket, after_closing_bracket} = Enum.split(operation, index1 + 1)

      {before_opening_bracket, bracket} = Enum.split(before_closing_bracket, index2)

      result =
        bracket
        |> Enum.slice(1..(length(bracket) - 2))
        |> calculate_inside_bracket_with_prio()

      next_op = before_opening_bracket ++ result ++ after_closing_bracket
      format_operation_two(next_op)
    else
      calculate_inside_bracket_with_prio(operation)
    end
  end

  def format_operation(operation) do
    index1 = find_index_closing_bracket(operation)

    if index1 do
      part1 = Enum.slice(operation, 0..index1)
      index2 = Enum.reverse(part1) |> find_index_opening_bracket()
      index2 = length(part1) - index2 - 1
      {before_closing_bracket, after_closing_bracket} = Enum.split(operation, index1 + 1)

      {before_opening_bracket, bracket} = Enum.split(before_closing_bracket, index2)

      result =
        bracket
        |> Enum.slice(1..(length(bracket) - 2))
        |> calculate_inside_bracket()

      next_op = before_opening_bracket ++ result ++ after_closing_bracket
      format_operation(next_op)
    else
      calculate_inside_bracket(operation)
    end
  end

  defp find_index_closing_bracket(list), do: Enum.find_index(list, &(&1 == ")"))
  defp find_index_opening_bracket(list), do: Enum.find_index(list, &(&1 == "("))
end
