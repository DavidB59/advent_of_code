defmodule Day11 do
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

  def solve(input \\ file(), stop_at \\ 25) do
    cache()

    input
    |> parse
    |> Enum.map(&do_one_stone(&1, stop_at))
    |> Enum.sum()
  end

  @spec do_one_stone(any(), number()) :: any()
  def do_one_stone(stone, stop_at, count \\ 0) do
    case :ets.lookup(:count, {stone, stop_at - count}) do
      [{_key, result}] ->
        result

      [] ->
        result = blink(stone, stop_at, count)
        :ets.insert(:count, {{stone, stop_at - count}, result})
        result
    end
  end

  def blink(_stone, stop_at, stop_at), do: 1

  def blink(stone, stop_at, count) do
    modify_stone(stone)
    |> case do
      [one, two] -> do_one_stone(one, stop_at, count + 1) + do_one_stone(two, stop_at, count + 1)
      modified_stone -> do_one_stone(modified_stone, stop_at, count + 1)
    end
  end

  def modify_stone(0), do: 1

  def modify_stone(stone) do
    digits = Integer.digits(stone)

    case length(digits) do
      length when Integer.is_even(length) ->
        digits
        |> Enum.chunk_every(div(length, 2))
        |> Enum.map(&(&1 |> Enum.join() |> String.to_integer()))

      _ ->
        stone
        |> Kernel.*(2024)
    end
  end

  def key_stream(table_name \\ :count) do
    Stream.resource(
      fn -> :ets.first(table_name) end,
      fn
        :"$end_of_table" -> {:halt, nil}
        previous_key -> {[previous_key], :ets.next(table_name, previous_key)}
      end,
      fn _ -> :ok end
    )
    |> Enum.map(& &1)
  end

  def cache do
    if :ets.whereis(:count) != :undefined do
      :ets.delete(:count)
    end

    :ets.new(:count, [:named_table])
  end
end
