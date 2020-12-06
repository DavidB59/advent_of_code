defmodule Day1 do
  @moduledoc """
  Documentation for Day1.
  """

  def part_two() do
    {a, b, c} = file() |> filter_sum_less_2020() |> find_sum_2020(file()) |> List.first()
    a * b * c
  end

  def part_one() do
    [a, b] = file() |> sum_2020()
    a * b
  end

  def test() do
    list = test1()
    list |> filter_sum_less_2020() |> find_sum_2020(list)
  end

  def sum_2020(list) do
    Enum.filter(list, fn a -> Enum.any?(list, &(&1 + a == 2020)) end)
  end

  def filter_sum_less_2020(list) do
    Enum.map(list, fn a ->
      b = Enum.filter(list, fn b -> a + b < 2020 end)
      Enum.map(b, fn x -> {a, x} end)
    end)
    |> List.flatten()
    |> Enum.filter(fn {_a, b} -> b !== nil end)
  end

  def find_sum_2020(list1, list2) do
    Enum.map(list1, fn {a, b} ->
      c =
        Enum.find(list2, fn c ->
          a + b + c == 2020
        end)

      {a, b, c}
    end)
    |> Enum.filter(fn {_a, _b, c} -> c != nil end)
  end

  def test1() do
    [1721, 979, 366, 299, 675, 1456]
  end

  def file() do
    Parser.read_file("day1") |> Enum.map(&String.to_integer/1)
  end
end
