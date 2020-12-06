defmodule Day2 do
  @moduledoc """
  Documentation for Day2.
  """
  def part_one() do
    list = file() |> format()
    Enum.count(list, &valid_password_one(&1))
  end

  def part_two() do
    list = file() |> format_part_two()
    Enum.count(list, &valid_password_two(&1))
  end

  def valid_password_one({interval, letter, string}) do
    count = letter_count(letter, string)
    in_interval(interval, count)
  end

  def letter_count(letter, string) do
    list = String.graphemes(string)
    Enum.count(list, &(&1 == letter))
  end

  def in_interval(interval, count), do: Enum.member?(interval, count)

  def valid_password_two({one, two, letter, string}) do
    pos1 = one - 1
    pos2 = two - 1
    letter_one = String.at(string, pos1)
    letter_two = String.at(string, pos2)
    check1 = letter_one == letter
    check2 = letter_two == letter
    valid?(check1, check2)
  end

  def valid?(true, true), do: false
  def valid?(false, false), do: false
  def valid?(_, _), do: true

  def file() do
    Parser.read_file("day2")
  end

  def format(file) do
    file
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [range, letter, string] ->
      [a, b] = range |> String.split("-") |> Enum.map(&String.to_integer(&1))
      {a..b, String.trim(letter, ":"), string}
    end)
  end

  def format_part_two(file) do
    file
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [range, letter, string] ->
      [a, b] = range |> String.split("-") |> Enum.map(&String.to_integer(&1))
      {a, b, String.trim(letter, ":"), string}
    end)
  end
end
