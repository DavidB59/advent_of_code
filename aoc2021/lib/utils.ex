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

  def exchange_key_value(map) do
    map
    |> Enum.map(fn {k, v} -> {v, k} end)
    |> Map.new()
  end

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
end
