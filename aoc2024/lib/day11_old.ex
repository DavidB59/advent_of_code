defmodule Day11_old do
  require Integer

  def file do
    Parser.read_file(11)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> List.first()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  def solve(input \\ file(), stop_at) do
    input
    |> parse
    |> blink(stop_at)
    |> Enum.count()
  end

  def blink(stones, stop_at, counter \\ 0)

  def blink(stones, stop_at, stop_at), do: stones

  def blink(stones, stop_at, count) do
    stones
    |> Enum.flat_map(&modify_stone/1)
    |> blink(stop_at, count + 1)
  end

  def modify_stone(0), do: [1]

  def modify_stone(stone) do
    # length = String.length(stone)
    digits = Integer.digits(stone)

    case length(digits) do
      length when Integer.is_even(length) ->
        [one, two] =
          Enum.chunk_every(digits, div(length, 2))
          |> Enum.map(fn a -> a |> Enum.join() |> String.to_integer() end)

        [one, two]

      _ ->
        stone
        # |> String.to_integer()
        |> Kernel.*(2024)
        # |> Integer.to_string()
        |> List.wrap()
    end
  end

  def calc_one_number(number, max \\ 25) do
    number
    |> List.wrap()
    |> blink(max)

    # :ets.insert(:memory, {number, list})
  end

  # def solve_to_75(stones) do
  #   stones
  #   |> Enum.map(fn stone ->
  #     case :ets.lookup(:memory, stone) do
  #       [] ->
  #         result = calc_one_number(stone)
  #         :ets.insert(:memory, {stone, result})
  #         result

  #       [{_key, result}] ->
  #         result
  #     end
  #   end)
  # end

  def solve_two(input \\ file()) do
    input
    |> parse

    # |> solve_to_75()
  end

  def init_mem do
    # :ets.new(:memory, [:named_table])
    :ets.delete(:count)
    :ets.new(:count, [:named_table])
  end
end
