defmodule Utils do
  def list_to_index_map(list) do
    list |> Stream.with_index() |> Enum.reduce(%{}, fn {v, k}, acc -> Map.put(acc, k, v) end)
  end

  def list_list_to_graph(list) do
    list
    |> Enum.map(&Stream.with_index/1)
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {list, x}, acc ->
      Enum.reduce(list, acc, fn {value, y}, acc ->
        Map.put(acc, {x, y}, value)
      end)
    end)
  end

  def exchange_key_value(map) do
    map
    |> Enum.map(fn {k, v} -> {v, k} end)
    |> Map.new()
  end
end
