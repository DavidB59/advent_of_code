defmodule Utils do
  def list_to_index_map(list) do
    list |> Stream.with_index(1) |> Enum.reduce(%{}, fn {v, k}, acc -> Map.put(acc, k, v) end)
  end
end
