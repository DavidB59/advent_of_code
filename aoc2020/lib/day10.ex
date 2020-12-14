defmodule Day10 do
  @moduledoc """
  Documentation for Day10.
  """

  def part_one do
    list_diff = file() |> list_diff()
    one = Enum.filter(list_diff, &(&1 == 1)) |> Enum.count() |> IO.inspect()
    three = Enum.filter(list_diff, &(&1 == 3)) |> Enum.count() |> IO.inspect()
    one * three
  end

  def test_part_one() do
    # file = test() |> solve_one()
    # one = Enum.filter(diff, &(&1 == 1)) |> Enum.count() |> IO.inspect()
    # three = Enum.filter(diff, &(&1 == 3)) |> Enum.count() |> IO.inspect()
    # one(x(3))
  end

  def part_two do
    list_ones =
      file()
      |> list_diff()
      |> Enum.chunk_by(fn x -> x == 3 end)
      |> Enum.filter(&(length(&1) > 1))
      |> Enum.filter(&Enum.member?(&1, 1))
      |> IO.inspect()
      |> Enum.map(fn list -> calcul_possibility(list) end)
      |> IO.inspect()
      |> Enum.reduce(fn x, acc -> x * acc end)
  end

  def calcul_possibility(list) do
    case length(list) do
      1 ->
        1

      2 ->
        2

      3 ->
        4

      length ->
        poss_long_list(length, 0)
    end
  end

  def poss_long_list(3, poss), do: poss + 4

  def poss_long_list(length, poss) do
    poss = (poss + 3 * (length - 3)) |> IO.inspect()
    poss_long_list(length - 1, poss)
  end

  def list_diff(file) do
    # file |> Enum.sort() |> Enu
    device = (Enum.max(file) + 3) |> IO.inspect()
    file = [0] ++ file ++ [device]

    diff =
      file
      |> Enum.sort()
      |> IO.inspect()
      |> Enum.reduce({nil, []}, fn
        e, {nil, acc} -> {e, acc}
        e, {prev, acc} -> {e, [prev - e | acc]}
      end)
      |> elem(1)
      |> :lists.reverse()
      |> Enum.map(&abs(&1))
      |> IO.inspect()
  end

  def file do
    Parser.read_file("day10") |> Enum.map(&String.to_integer/1)
  end

  def test do
    Parser.read_file("test") |> Enum.map(&String.to_integer/1)
  end

  # def format(file) do
  #   file
  #   |> Enum.map(&String.split(&1, " "))
  #   |> Enum.map(fn [a, b] -> {a, String.to_integer(b)} end)
  # end
end
