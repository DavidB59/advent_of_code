defmodule MapDay23 do
  @moduledoc """
  Documentation for day23.
  """

  def part_one() do
    file() |> format() |> solve(100)
  end

  def part_two() do
    file() |> format() |> solve(10_000_000)
  end

  def test() do
    "389125467" |> format()
  end

  # def test_1() do
  #   "389125467" |> format() |> solve
  # end

  def file() do
    "653427918"
  end

  def solve(file, nb) do
    map = file |> from_list
    map2 = map_to_ten_million()
    map = Map.merge(map, map2) |> Map.put(1_000_000, 6) |> Map.put(8, 10)

    result = recursive(map, nb)
    # Map.get(result, 1)
    # Enum.reverse(result)
    result
  end

  def map_to_ten_million() do
    10..1_000_000 |> Enum.reduce(%{}, fn number, acc -> Map.put(acc, number, number + 1) end)
  end

  def recursive(map, stop, count \\ 0)

  def recursive(map, stop, stop), do: map

  def recursive(map, stop, count) do
    three_labels = get_three_labels(map)
    [one, _two, three] = three_labels
    pos = Map.get(map, :current)
    key_dest = find_destination(pos, three_labels)

    new_value_for_last_label = Map.get(map, key_dest)

    new_value_for_pos = Map.get(map, three)
    new_current = Map.get(map, three)
    new_value_for_dest = one

    map =
      map
      |> Map.put(pos, new_value_for_pos)
      |> Map.put(three, new_value_for_last_label)
      |> Map.put(:current, new_current)
      |> Map.put(key_dest, new_value_for_dest)
      |> recursive(stop, count + 1)

    Map.get(map, 1) |> IO.inspect(label: "one")
    map
  end

  def extract_order_after_one_from_map(map) do
    Enum.reduce(1..9, {1, []}, fn _, {key, list} ->
      next_key = Map.get(map, key)
      next_list = [next_key | list]
      {next_key, next_list}
    end)
  end

  def map do
  end

  def format(file) do
    file |> String.graphemes() |> Enum.map(&String.to_integer/1)
  end

  # must change it myself
  def from_list(lst = [hd | _]) do
    last = List.last(lst)
    {_, m} = Enum.reduce(lst, {last, %{}}, fn el, {p, m} -> {el, Map.put(m, p, el)} end)
    Map.put(m, :current, hd)
  end

  def get_three_labels(map) do
    pos = Map.get(map, :current)
    first = Map.get(map, pos)
    second = Map.get(map, first)
    third = Map.get(map, second)
    [first, second, third]
  end

  def find_destination(pos, three_labels) do
    destination = pos - 1

    cond do
      destination == 0 -> find_max(max(), three_labels)
      !Enum.member?(three_labels, destination) -> destination
      true -> find_destination(destination, three_labels)
    end
  end

  def find_max(max, three_label) do
    if Enum.member?(three_label, max) do
      find_max(max - 1, three_label)
    else
      max
    end
  end

  def max, do: 1_000_000
end
