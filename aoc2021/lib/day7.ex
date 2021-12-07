defmodule Day7 do
  def file do
    Parser.read_file("day7")
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> List.first()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def solve_part_one() do
    file() |> parse() |> calculate_fuel_median()
  end

  def calculate_fuel_median(input) do
    median = Utils.median(input)

    input
    |> Enum.map(fn x -> abs(x - median) end)
    |> Enum.sum()
  end

  def solve_part_two do
    file() |> parse() |> calculate_fuel_mean()
  end

  def calculate_fuel_mean(input) do
    mean1 = Utils.mean(input) |> floor() |> calculate_cost(input)
    mean2 = Utils.mean(input) |> round() |> calculate_cost(input)
    min(mean1, mean2)
  end

  def calculate_cost(mean, input) do
    input
    |> Enum.map(fn x ->
      diff = abs(x - mean)

      0..diff
      |> Enum.sum()
    end)
    |> Enum.sum()
  end
end
