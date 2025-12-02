defmodule Day22 do
  def file do
    Parser.read_file(22)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.to_integer/1)
  end

  def solve(input \\ file()) do
    input
    |> parse()
    |> Enum.map(&calculate_n_times(&1, 2000))
    |> Enum.sum()
  end

  def solve_two(input \\ file()) do
    input
    |> parse()
    |> Enum.map(fn secret ->
      secret |> get_full_sequences(2000) |> generate_sequence_number_map()
    end)
    |> Enum.reduce(fn map, acc -> Map.merge(map, acc, fn _k, v1, v2 -> v2 + v1 end) end)
    |> Map.values()
    |> Enum.max()
  end

  def get_full_sequences(secret, n_times) do
    first_last = get_last_number(secret)

    prices =
      Enum.reduce(1..n_times, {secret, [first_last]}, fn _, {previous_secret, list} ->
        next_secret = calculate(previous_secret)
        price = get_last_number(next_secret)
        {next_secret, [price | list]}
      end)
      |> elem(1)
      |> Enum.reverse()

    sequences =
      prices
      |> Enum.reduce({nil, []}, fn number, {previous, change_list} ->
        if previous == nil do
          {number, change_list}
        else
          {number, [number - previous | change_list]}
        end
      end)
      |> elem(1)
      |> Enum.reverse()

    {prices, sequences}
  end

  def generate_sequence_number_map({prices, sequences}) do
    [_, _, _, _ | possible_prices] = prices
    go_through_sequences(sequences, possible_prices, %{})
  end

  def go_through_sequences(
        [first, second, third, fourth | rest_sequence],
        [price | rest_price],
        map
      ) do
    new_map = Map.put_new(map, [first, second, third, fourth], price)
    go_through_sequences([second, third, fourth | rest_sequence], rest_price, new_map)
  end

  def go_through_sequences(_l1, _l2, map), do: map

  def get_last_number(number), do: number |> Integer.digits() |> List.last()

  def calculate_n_times(secret, n_time) do
    Enum.reduce(1..n_time, secret, fn _, acc -> calculate(acc) end)
  end

  def calculate(secret) do
    step1 =
      secret
      |> Kernel.*(64)
      |> mix(secret)
      |> prune()

    step2 =
      step1
      |> div(32)
      |> mix(step1)
      |> prune()

    step2
    |> Kernel.*(2048)
    |> mix(step2)
    |> prune()
  end

  def mix(result, secret), do: Bitwise.bxor(result, secret)
  def prune(result), do: rem(result, 16_777_216)
end
