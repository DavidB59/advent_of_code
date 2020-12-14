defmodule Day13 do
  @moduledoc """
  Documentation for Day13.
  """

  def part_two() do
    list = Parser.read_file("day13") |> format_part_two()

    [{modulo, _, rest} | _rest] = list |> list_with_rest |> Enum.sort() |> Enum.reverse()

    solve_part_two(list, modulo, rest)
    # list =
    #   Parser.read_file("day13")
    #   |> format_part_two()
    #   |> list_with_rest()
    #   |> Enum.sort()
    #   |> IO.inspect()
    #   |> Enum.each(fn {a, _b, c} ->
    #     IO.inspect("x = #{c} mod #{a}")
    #     # {a,c}
    #   end)
  end

  def part_one() do
    {a, b} = Parser.read_file("day13") |> format()
    solve(a, b)
  end

  def test() do
    list = Parser.read_file("test") |> format_part_two() |> list_with_rest()

    # [{modulo, _, rest} | _rest] = list |> list_with_rest |> Enum.sort() |> Enum.reverse()

    # solve_part_two(list, modulo, rest)
  end

  def solve_part_two(list, modulo, rest) do
    one = 725_169_163_285_221
    two = 725_169_163_285_221 + 100_000

    start = Enum.find(one..two, fn nb -> Integer.mod(nb, modulo) == rest end)

    solution(list, start, modulo)
  end

  def solution(list, time, modulo) do
    case match_condition?(list, time) do
      true -> time
      _ -> solution(list, time + modulo, modulo)
    end
  end

  def list_with_rest(list) do
    list
    |> Enum.map(fn
      {a, 0} ->
        {a, 0, 0}

      {a, b} ->
        b = check_b_value(a, b)
        {a, b, a - b}
    end)
  end

  def check_b_value(a, b) do
    if b > a do
      b = b - a
      check_b_value(a, b)
    else
      b
    end
  end

  def match_condition?(list, time) do
    Enum.all?(list, fn {bus_time, rest} ->
      Integer.mod(time + rest, bus_time) == 0
    end)
  end

  def solve(a, b) do
    b
    |> Enum.map(fn string ->
      string |> String.to_integer() |> calculate(a)
    end)
    |> Enum.min_by(&elem(&1, 1))
    |> multiply()
  end

  def multiply({a, b}), do: a * b

  def calculate(b, a) do
    diviser = (a / b) |> ceil()
    time_to_wait = b * diviser - a
    {b, time_to_wait}
  end

  def file() do
    Parser.read_file("day13")
  end

  def format(file) do
    [a, b] = file
    a = String.to_integer(a)

    b = b |> String.split(",") |> Enum.reject(&(&1 == "x"))

    {a, b}
  end

  def format_part_two(file) do
    [_a, b] = file

    b
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.reject(fn {a, _b} -> a == "x" end)
    |> Enum.map(fn {a, b} -> {String.to_integer(a), b} end)
  end

  # def of(n) do
  #   factors(n, div(n, 2)) |> Enum.filter(&is_prime?/1)
  # end

  # def factors(1, _), do: [1]
  # def factors(_, 1), do: [1]

  # def factors(n, i) do
  #   if rem(n, i) == 0 do
  #     [i | factors(n, i - 1)]
  #   else
  #     factors(n, i - 1)
  #   end
  # end

  # def is_prime?(n) do
  #   factors(n, div(n, 2)) == [1]
  # end
  # def lcm_list(list) do
  #   list |> Enum.sort() |> Enum.reverse() |> Enum.reduce(fn a, b -> lcm(a, b) |> trunc() end)
  # end

  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(0, 0), do: 0
  def lcm(a, b), do: a * b / gcd(a, b)

  # a mod 7 = 0
  # (a - 1) mod 13 = 0

  #   # x = 4 mod 5
  #   # x = 4 mod 5
  #   # x = 4 mod 5

  # x = 0 mod 17
  # x = 26 mod 37
  # x = 432 mod 449
  # x = 21 mod 23
  # x = 9 mod 13
  # x = 2 mod 19
  # x = 559 mod 607
  # x = 24 mod 41
  # x = 10 mod 29

  # x = 9 mod 13
  # x = 0 mod 17
  # x = 2 mod 19
  # x = 21 mod 23
  # x = 10 mod 29
  # x = 26 mod 37
  # x = 24 mod 41
  # x = 432 mod 449
  # x = 559 mod 607
end
