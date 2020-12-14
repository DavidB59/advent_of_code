defmodule Day12_part1 do
  @moduledoc """
  Documentation for Day12.
  """

  def solve() do
    file = file() |> format()
    ship = %{direction: "E", x: 0, y: 0}

    # Enum.reduce(file, ship, &command(&1, &2))
    %{x: x, y: y} = Enum.reduce(file, ship, &command/2)
    abs(x) + abs(y)
  end

  def test() do
    file = Parser.read_file("test") |> format()
    ship = %{direction: "E", x: 0, y: 0}

    # Enum.reduce(file, ship, &command(&1, &2))
    Enum.reduce(file, ship, &command/2)
  end

  def command({"L", degree}, %{direction: dir} = ship) do
    number = degree(degree)

    list = [
      ["N", "W", "S", "E"],
      ["W", "S", "E", "N"],
      ["S", "E", "N", "W"],
      ["E", "N", "W", "S"]
    ]

    direction = list |> Enum.find(fn [head | _tail] -> head == dir end) |> Enum.at(number)
    %{ship | direction: direction}
  end

  def command({"R", degree}, %{direction: dir} = ship) do
    number = degree(degree)

    list = [
      ["N", "E", "S", "W"],
      ["E", "S", "W", "N"],
      ["S", "W", "N", "E"],
      ["W", "N", "E", "S"]
    ]

    direction = list |> Enum.find(fn [head | _tail] -> head == dir end) |> Enum.at(number)
    %{ship | direction: direction}
  end

  def command({"N", value}, %{y: y} = ship), do: %{ship | y: y + value}

  def command({"S", value}, %{y: y} = ship), do: %{ship | y: y - value}

  def command({"E", value}, %{x: x} = ship), do: %{ship | x: x + value}

  def command({"W", value}, %{x: x} = ship), do: %{ship | x: x - value}

  def command({"F", value}, %{direction: dir} = ship) do
    command({dir, value}, ship)
  end

  def degree(degree) do
    case degree do
      90 -> 1
      180 -> 2
      270 -> 3
      other -> IO.inspect(other, label: "error")
    end
  end

  def file() do
    Parser.read_file("day12")
  end

  def format(file) do
    file
    |> Enum.map(&String.split_at(&1, 1))
    |> Enum.map(fn {a, b} -> {a, String.to_integer(b)} end)
  end
end
