defmodule Day12_part2 do
  @moduledoc """
  Documentation for Day12.
  """

  def solve() do
    file = file() |> format()
    # ship = %{direction: "E", x: 0, y: 0,}

    %{x: x, y: y} = Enum.reduce(file, ship(), &command/2)
    abs(x) + abs(y)
  end

  def test() do
    file = Parser.read_file("test") |> format()

    # Enum.reduce(file, ship, &command(&1, &2))
    Enum.reduce(file, ship(), &command/2)

    Enum.reduce(file, ship(), fn comand, ship ->
      IO.inspect(comand, label: "command")
      command(comand, ship) |> IO.inspect(label: "ship")
    end)
  end

  def ship, do: %{direction: "E", x: 0, y: 0, waypoint: %{x: 10, y: 1}}

  # def command({"L", degree}, %{direction: dir} = ship) do
  #   number = degree(degree)

  #   list = [
  #     ["N", "W", "S", "E"],
  #     ["W", "S", "E", "N"],
  #     ["S", "E", "N", "W"],
  #     ["E", "N", "W", "S"]
  #   ]

  #   direction = list |> Enum.find(fn [head | _tail] -> head == dir end) |> Enum.at(number)
  #   %{ship | direction: direction}
  # end

  # def command({"R", degree}, %{direction: dir} = ship) do
  #   number = degree(degree)

  #   list = [
  #     ["N", "E", "S", "W"],
  #     ["E", "S", "W", "N"],
  #     ["S", "W", "N", "E"],
  #     ["W", "N", "E", "S"]
  #   ]

  #   direction = list |> Enum.find(fn [head | _tail] -> head == dir end) |> Enum.at(number)
  #   %{ship | direction: direction}
  # end

  def command({"L", angle}, %{x: x_ship, y: y_ship, waypoint: %{x: x_wp, y: y_wp}} = ship) do
    # Convert to radians
    angle = angle * (:math.pi() / 180)
    x_wp_abs = x_wp + x_ship
    y_wp_abs = y_wp + y_ship

    x_rotated =
      (:math.cos(angle) * (x_wp_abs - x_ship) - :math.sin(angle) * (y_wp_abs - y_ship) + x_ship)
      |> round()

    y_rotated =
      (:math.sin(angle) * (x_wp_abs - x_ship) + :math.cos(angle) * (y_wp_abs - y_ship) + y_ship)
      |> round()

    x_wp = x_rotated - x_ship
    y_wp = y_rotated - y_ship

    waypoint = %{x: x_wp, y: y_wp}
    %{ship | waypoint: waypoint}
  end

  def command({"R", angle}, %{x: x_ship, y: y_ship, waypoint: %{x: x_wp, y: y_wp}} = ship) do
    # Convert to radians
    angle = -angle * (:math.pi() / 180)
    x_wp_abs = x_wp + x_ship
    y_wp_abs = y_wp + y_ship

    x_rotated =
      (:math.cos(angle) * (x_wp_abs - x_ship) - :math.sin(angle) * (y_wp_abs - y_ship) + x_ship)
      |> round()

    y_rotated =
      (:math.sin(angle) * (x_wp_abs - x_ship) + :math.cos(angle) * (y_wp_abs - y_ship) + y_ship)
      |> round()

    x_wp = x_rotated - x_ship
    y_wp = y_rotated - y_ship

    waypoint = %{x: x_wp, y: y_wp}
    %{ship | waypoint: waypoint}
  end

  def command({"F", times}, %{waypoint: %{x: x_wp, y: y_wp}, x: x, y: y} = ship) do
    x = x + x_wp * times
    y = y + y_wp * times
    %{ship | x: x, y: y}
  end

  def command(command, %{waypoint: waypoint} = ship) do
    waypoint = move_waypoint(command, waypoint)

    %{ship | waypoint: waypoint}
  end

  def move_waypoint({"N", value}, %{y: y} = waypoint), do: %{waypoint | y: y + value}

  def move_waypoint({"S", value}, %{y: y} = waypoint), do: %{waypoint | y: y - value}

  def move_waypoint({"E", value}, %{x: x} = waypoint), do: %{waypoint | x: x + value}

  def move_waypoint({"W", value}, %{x: x} = waypoint), do: %{waypoint | x: x - value}

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
