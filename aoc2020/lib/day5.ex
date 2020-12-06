defmodule Day5 do
  @moduledoc """
  Documentation for Day5.
  """
  @rows Enum.map(0..127, & &1)
  @columns Enum.map(0..7, & &1)

  def part_one do
    file() |> find_each_row_col() |> calculate_ids() |> Enum.max()
  end

  def part_two do
    file() |> find_each_row_col() |> calculate_ids() |> Enum.sort() |> find_seat()
  end

  def find_seat(list) do
    {_x, res} =
      Enum.reduce(list, {List.first(list) - 1, nil}, fn x, {previous, res} ->
        res = if x - previous == 1, do: res, else: x
        {x, res}
      end)

    res - 1
  end

  def find_each_row_col(file) do
    Enum.map(file, fn string ->
      {rows, columns} = String.graphemes(string) |> Enum.split(7)
      [row] = which_row(rows)
      [col] = which_col(columns)
      {row, col}
    end)
  end

  def calculate_ids(list_row_col) do
    list_row_col |> Enum.map(fn {a, b} -> a * 8 + b end)
  end

  def which_row(rows) do
    Enum.reduce(rows, @rows, fn row, acc ->
      [a, b] = split_half(acc)
      row_half(row, [a, b])
    end)
  end

  def which_col(columns) do
    Enum.reduce(columns, @columns, fn col, acc ->
      [a, b] = split_half(acc)
      column_half(col, [a, b])
    end)
  end

  def split_half(list) do
    len = (length(list) / 2) |> round
    Enum.chunk_every(list, len)
  end

  def row_half("F", [a, _b]), do: a
  def row_half("B", [_a, b]), do: b
  def column_half("L", [a, _b]), do: a
  def column_half("R", [_a, b]), do: b

  def file do
    Parser.read_file("day5")
  end
end
