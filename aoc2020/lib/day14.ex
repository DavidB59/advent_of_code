defmodule Day14 do
  @moduledoc """
  Documentation for Day14.
  """

  def part_two() do
    list = file() |> format_part_two()
    solve_two(list)
  end

  def part_one() do
    list = file() |> format()
    solve_one(list)
  end

  def test() do
    list = Parser.read_file("test") |> format_part_two()
    solve_two(list)
  end

  def solve_two(list) do
    Enum.reduce(list, %{}, fn
      %{mask: mask_value}, memory ->
        Map.put(memory, :mask, mask_value)

      {type, value}, memory ->
        mask = Map.get(memory, :mask)
        address = type |> Integer.digits(2) |> prepare_list()

        addresses =
          Enum.reduce(
            mask,
            address,
            fn
              {"0", _index}, acc ->
                acc

              {"1", index}, acc ->
                List.replace_at(acc, index, 1)

              {"X", index}, acc ->
                List.replace_at(acc, index, "X")
            end
          )
          |> add_all_possibility([])
          |> List.flatten()

        addresses
        |> Enum.reduce(memory, fn address, memory ->
          Map.put(memory, address, value)
        end)
    end)
    |> Enum.map(fn
      {:mask, _value} ->
        0

      {_key, value} ->
        Integer.undigits(value, 2)
    end)
    |> Enum.sum()
  end

  def add_all_possibility([1], result) do
    (result ++ [1]) |> Integer.undigits(2)
  end

  def add_all_possibility([0], result) do
    (result ++ [0]) |> Integer.undigits(2)
  end

  def add_all_possibility(["X"], result) do
    branch1 = add_all_possibility([1], result)
    branch2 = add_all_possibility([0], result)
    [branch1, branch2]
  end

  def add_all_possibility([1 | rest], result) do
    new_result = result ++ [1]
    add_all_possibility(rest, new_result)
  end

  def add_all_possibility([0 | rest], result) do
    new_result = result ++ [0]
    add_all_possibility(rest, new_result)
  end

  def add_all_possibility(["X" | rest], result) do
    branch1 = add_all_possibility(rest, result ++ [1])
    branch2 = add_all_possibility(rest, result ++ [0])
    [branch1, branch2]
  end

  def solve_one(list) do
    Enum.reduce(list, %{}, fn
      %{mask: mask_value}, memory ->
        Map.put(memory, :mask, mask_value)

      {type, value}, memory ->
        mask = Map.get(memory, :mask)

        value =
          Enum.reduce(
            mask,
            value,
            fn {mask_bit, index}, acc ->
              List.replace_at(acc, index, mask_bit)
            end
          )

        Map.put(memory, type, value)
    end)
    |> Enum.map(fn
      {:mask, _value} ->
        0

      {_key, value} ->
        Integer.undigits(value, 2)
    end)
    |> Enum.sum()
  end

  def file() do
    Parser.read_file("day14")
  end

  def format(file) do
    file
    |> Enum.map(fn string ->
      [type, value] = string |> String.split("=") |> Enum.map(&String.trim(&1))

      case type do
        "mask" ->
          value =
            value
            |> String.graphemes()
            |> Enum.with_index()
            |> Enum.reject(fn {a, _b} -> a == "X" end)
            |> Enum.map(fn {a, b} -> {String.to_integer(a), b} end)

          Map.put(%{}, :mask, value)

        _ ->
          type = type |> String.trim("mem[") |> String.trim("]") |> String.to_integer()
          value = value |> String.to_integer() |> Integer.digits(2) |> prepare_list()
          {type, value}
      end
    end)
  end

  def format_part_two(file) do
    file
    |> Enum.map(fn string ->
      [type, value] = string |> String.split("=") |> Enum.map(&String.trim(&1))

      case type do
        "mask" ->
          value =
            value
            |> String.graphemes()
            |> Enum.with_index()

          Map.put(%{}, :mask, value)

        _ ->
          type = type |> String.trim("mem[") |> String.trim("]") |> String.to_integer()
          value = value |> String.to_integer() |> Integer.digits(2) |> prepare_list()
          {type, value}
      end
    end)
  end

  def prepare_list(list), do: add_0s(list, length(list))
  def add_0s(list, 36), do: list
  def add_0s(list, length), do: add_0s([0 | list], length + 1)
  # def add_0s(list, length) do

  # end
end
