defmodule Day25 do
  def file do
    Parser.read_file(25)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    {key, lock} =
      input
      |> Enum.chunk_by(&(&1 != ""))
      |> Enum.reject(&(&1 == [""]))
      |> Enum.map(fn list ->
        type =
          if list |> List.first() |> String.contains?("#") do
            :lock
          else
            :key
          end

        count =
          list
          |> Enum.map(fn string ->
            string
            |> String.graphemes()
            |> Stream.with_index()
            |> Map.new(fn {value, index} -> {index, value} end)
          end)
          |> Enum.reduce(fn map, acc -> Map.merge(acc, map, &merger/3) end)

        {type, count}
      end)
      |> Enum.split_with(fn {type, _} -> type == :key end)

    {key, lock}
  end

  def merger(_k, "#", "#"), do: 2
  def merger(_k, ".", "#"), do: 1
  def merger(_k, "#", "."), do: 1
  def merger(_k, ".", "."), do: 0
  def merger(_k, value, "#"), do: value + 1
  def merger(_k, value, "."), do: value

  def solve(input \\ file()) do
    {keys, locks} = parse(input)
    keys = Enum.map(keys, &elem(&1, 1))
    locks = Enum.map(locks, &elem(&1, 1))

    check_every_key(keys, locks)
  end

  def check_every_key(keys, locks, total_count \\ 0)
  def check_every_key([], _locks, total_count), do: total_count

  def check_every_key([key | rest], locks, total_count) do
    count =
      locks
      |> Enum.filter(fn lock -> !fit?(key, lock) end)
      |> Enum.count()

    check_every_key(rest, locks, count + total_count)
  end

  def fit?(key, lock) do
    key
    |> Map.merge(lock, fn _k, v1, v2 -> v1 + v2 end)
    |> Map.values()
    |> Enum.any?(&(&1 > 7))
  end
end
