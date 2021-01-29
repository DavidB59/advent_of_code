defmodule Day23 do
  @moduledoc """
  Documentation for day23.
  """

  def part_one() do
    file() |> format() |> solve_two
  end

  def part_two() do
    file() |> format() |> solve_two
  end

  def test(nb) do
    "389125467" |> format() |> recursive_two_list([], nb)
  end

  def test_1() do
    "389125467" |> format() |> solve_one()
  end

  def file() do
    "653427918"
  end

  def format(file) do
    file |> String.graphemes() |> Enum.map(&String.to_integer/1)
  end

  def solve_one(file) do
    recursive_two_list(file, [], 100)
  end

  def solve_two(file) do
    list = 10..1_000_000 |> Enum.map(& &1)
    file = file ++ list
    recursive_two_list(file, [], 100)
  end

  def max(), do: 9

  def determine_destination(head, three_cup, remainings) do
    destination_cup = head - 1

    cond do
      destination_cup == 0 -> Enum.max(remainings)
      !Enum.member?(three_cup, destination_cup) -> destination_cup
      true -> determine_destination(destination_cup, three_cup, remainings)
    end
  end

  def recursive_two_list(cup_list, cup_list_two, stop, count \\ 0)

  def recursive_two_list(list, cup_list_two, stop, stop) do
    Enum.reverse(cup_list_two) ++ list
  end

  def recursive_two_list([], cup_list_two, stop, count) do
    new_list = Enum.reverse(cup_list_two)
    recursive_two_list(new_list, [], stop, count)
  end

  def recursive_two_list([one], cup_list_two, stop, count) do
    new_list = Enum.reverse(cup_list_two)

    list_one = [one | new_list]

    recursive_two_list(list_one, [], stop, count)
  end

  def recursive_two_list([one, two], cup_list_two, stop, count) do
    new_list = Enum.reverse(cup_list_two)

    list_one = [one, two | new_list]
    recursive_two_list(list_one, [], stop, count)
  end

  def recursive_two_list([one, two, three], cup_list_two, stop, count) do
    # require IEx
    # IEx.pry()

    new_list = Enum.reverse(cup_list_two)

    # list_one = new_list ++ [one, two, three]
    list_one = [one, two, three | new_list]

    recursive_two_list(list_one, [], stop, count)
  end

  def recursive_two_list([head | rest], cup_list_two, stop, count) do
    IO.inspect(count, label: "count :")
    [a, b, c | remainings] = rest
    three_cup = [a, b, c]
    destination = determine_destination_two_list(head, three_cup)

    index = Enum.find_index(remainings, &(&1 == destination))

    if index do
      tail =
        remainings
        |> List.insert_at(index + 1, a)
        |> List.insert_at(index + 2, b)
        |> List.insert_at(index + 3, c)

      next_cup_list_two = [head | cup_list_two]
      recursive_two_list(tail, next_cup_list_two, stop, count + 1)
    else
      index = Enum.find_index(cup_list_two, &(&1 == destination))

      next_cup_list_two =
        cup_list_two
        |> List.insert_at(index, [c, b, a])
        |> List.flatten()

      next_cup_list_two = [head | next_cup_list_two]
      recursive_two_list(remainings, next_cup_list_two, stop, count + 1)
    end
  end

  def determine_destination_two_list(head, three_cup) do
    destination_cup = head - 1

    cond do
      destination_cup == 0 -> find_max(three_cup, max())
      !Enum.member?(three_cup, destination_cup) -> destination_cup
      true -> determine_destination_two_list(destination_cup, three_cup)
    end
  end

  def find_max(three_cup, max) do
    if Enum.member?(three_cup, max) do
      find_max(three_cup, max - 1)
    else
      max
    end
  end
end
