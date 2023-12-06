defmodule Day5 do
  def file do
    Parser.read_file(5)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    ["seeds: " <> raw_seeds | rest] = input
    seeds = raw_seeds |> String.split(" ") |> Enum.map(&String.to_integer/1)

    almanac =
      rest
      |> Enum.chunk_by(fn a -> a == "" end)
      |> Enum.reject(&(&1 == [""]))
      |> Enum.map(fn [_head | rest] ->
        Enum.map(rest, fn string ->
          [destination_start, source_start, range_length] =
            string |> String.split(" ") |> Enum.map(&String.to_integer/1)

          {{destination_start, destination_start + range_length},
           {source_start, source_start + range_length}}
        end)
      end)

    {seeds, almanac}
  end

  def solve_two(input) do
    {seeds, almanac} = parse(input)

    seed_range =
      seeds
      |> Enum.chunk_every(2)
      |> Enum.map(fn [a, b] -> {a, a + b} end)

    reverse_almanac = Enum.reverse(almanac)
    find_lowest_location(reverse_almanac, seed_range)
  end

  def find_lowest_location(reverse_almanac, seeds_list, location \\ 0) do
    tentative_seed = find_reverse(location, reverse_almanac)

    case Enum.find(seeds_list, fn {r1, r2} -> tentative_seed >= r1 and tentative_seed <= r2 end) do
      nil -> find_lowest_location(reverse_almanac, seeds_list, location + 1)
      _ -> location
    end
  end

  def solve(input) do
    {seeds, almanac} = parse(input)

    seeds
    |> Enum.map(&find_location(&1, almanac))
    |> Enum.min()
  end

  def find_location(seed, []), do: seed

  def find_location(seed, [map1 | rest]) do
    map1
    |> Enum.find(fn {_, {s1, s2}} -> s1 <= seed and seed <= s2 end)
    |> case do
      nil ->
        seed

      {{_d1, d2}, {_s1, s2}} ->
        diff = s2 - seed
        d2 - diff
    end
    |> find_location(rest)
  end

  def find_reverse(seed, []), do: seed

  def find_reverse(seed, [map1 | rest]) do
    new_seed =
      case Enum.find(map1, fn {{d1, d2}, _} -> d1 <= seed and seed <= d2 end) do
        nil ->
          seed

        {{_d1, d2}, {_s1, s2}} ->
          diff = d2 - seed
          s2 - diff
      end

    find_reverse(new_seed, rest)
  end
end
