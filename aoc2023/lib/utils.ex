defmodule Utils do
  def list_to_index_map(list) do
    list |> Stream.with_index() |> Enum.reduce(%{}, fn {v, k}, acc -> Map.put(acc, k, v) end)
  end

  def nested_list_to_xy_map(list) do
    list
    |> Enum.map(&Stream.with_index/1)
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {list, x}, acc ->
      Enum.reduce(list, acc, fn {value, y}, acc ->
        Map.put(acc, {y, x}, value)
      end)
    end)
  end

  def to_list_of_list(file), do: Enum.map(file, &String.graphemes/1)

  def exchange_key_value(map), do: Map.new(map, fn {k, v} -> {v, k} end)

  def median([]), do: nil

  def median(list) when is_list(list) do
    midpoint =
      (length(list) / 2)
      |> Float.floor()
      |> round

    {l1, l2} =
      Enum.sort(list)
      |> Enum.split(midpoint)

    case length(l2) > length(l1) do
      true ->
        [med | _] = l2
        med

      false ->
        [m1 | _] = l2
        [m2 | _] = Enum.reverse(l1)
        mean([m1, m2])
    end
  end

  def mean(list) when is_list(list), do: do_mean(list, 0, 0)

  defp do_mean([], 0, 0), do: nil
  defp do_mean([], t, l), do: t / l

  defp do_mean([x | xs], t, l) do
    do_mean(xs, t + x, l + 1)
  end

  def character_to_integer(char) do
    char |> String.to_charlist() |> hd
  end

  def string_pattern_match(string, string_size) do
    <<match::bytes-size(string_size)>> <> rest = string
    {match, rest}
  end

  def extract_number_from_string(string) do
    String.replace(string, ~r/[^\d]/, "")
  end
end

# prime decomposition
defmodule Prime do
  @spec decomposition(any) :: list
  def decomposition(n), do: decomposition(n, 2, [])

  defp decomposition(n, k, acc) when n < k * k, do: Enum.reverse(acc, [n])
  defp decomposition(n, k, acc) when rem(n, k) == 0, do: decomposition(div(n, k), k, [k | acc])
  defp decomposition(n, k, acc), do: decomposition(n, k + 1, acc)
end

prime =
  Stream.iterate(2, &(&1 + 1))
  |> Stream.filter(fn n -> length(Prime.decomposition(n)) == 1 end)
  |> Enum.take(17)

mersenne = Enum.map(prime, fn n -> {n, round(:math.pow(2, n)) - 1} end)

Enum.each(mersenne, fn {n, m} ->
  :io.format("~3s :~20w = ~s~n", ["M#{n}", m, Prime.decomposition(m) |> Enum.join(" x ")])
end)

# ppcm
defmodule RC do
  def gcd(a, 0), do: abs(a)
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(a, b), do: div(abs(a * b), gcd(a, b))
end
