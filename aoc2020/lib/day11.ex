defmodule Day11 do
  @moduledoc """
  Documentation for Day11.
  """

  def part_one do
    seat_map = file() |> format()

    seat_map
    |> change_all_seat_once()
    |> execute()
    |> total_number_occupied_seat()
  end

  def test_solution() do
    seat_map = test() |> format()

    seat_map
    |> change_all_seat_once_part_two()
    |> execute()
    |> total_number_occupied_seat()
  end

  def test_result(), do: Parser.read_file("test_result") |> format()

  def part_two do
    seat_map = file() |> format()

    seat_map
    |> change_all_seat_once_part_two()
    |> execute()
    |> total_number_occupied_seat()
  end

  def execute(seat_map) do
    next_seat_map = seat_map |> change_all_seat_once_part_two()

    if seat_map == next_seat_map do
      seat_map
    else
      execute(next_seat_map)
    end
  end

  def total_number_occupied_seat(seat_map) do
    Enum.reduce(seat_map, 0, fn {_x_pos, y_map}, acc ->
      acc +
        Enum.reduce(y_map, 0, fn
          {_y_pos, "#"}, acc -> acc + 1
          {_, _}, acc -> acc
        end)
    end)
  end

  def change_all_seat_once_part_two(seat_map) do
    Enum.reduce(seat_map, %{}, fn {x_pos, y_map}, acc ->
      y_value =
        Enum.reduce(y_map, %{}, fn {y_pos, seat_status}, acc ->
          occ_seats =
            seat_map |> visible_seat_statuses(x_pos, y_pos) |> number_occupied_adjacent_seat()

          # seat_status = seat_status(seat_map, x_pos, y_pos)
          new_seat_status = new_seat_status(seat_status, occ_seats)
          Map.put(acc, y_pos, new_seat_status)
        end)

      Map.put(acc, x_pos, y_value)
    end)
  end

  def change_all_seat_once(seat_map) do
    Enum.reduce(seat_map, %{}, fn {x_pos, y_map}, acc ->
      y_value =
        Enum.reduce(y_map, %{}, fn {y_pos, seat_status}, acc ->
          occ_seats = seat_map |> adjacent_seats(x_pos, y_pos) |> number_occupied_adjacent_seat()
          # seat_status = seat_status(seat_map, x_pos, y_pos)
          new_seat_status = new_seat_status(seat_status, occ_seats)
          Map.put(acc, y_pos, new_seat_status)
        end)

      Map.put(acc, x_pos, y_value)
    end)
  end

  # def change_status(seat_map, x_pos, y_pos) do
  # end

  def adjacent_seats(seat_map, x_pos, y_pos) do
    [{1, 1}, {1, -1}, {-1, -1}, {-1, 1}, {1, 0}, {-1, 0}, {0, 1}, {0, -1}]
    |> Enum.map(fn {x, y} -> seat_status(seat_map, x + x_pos, y + y_pos) end)
  end

  def seat_status(seat_map, x_pos, y_pos) do
    get_in(seat_map, [x_pos, y_pos])
  end

  def visible_seat_statuses(seat_map, x_pos, y_pos) do
    [{1, 1}, {1, -1}, {-1, -1}, {-1, 1}, {1, 0}, {-1, 0}, {0, 1}, {0, -1}]
    |> Enum.map(fn vecteur -> visible_seat_status(seat_map, x_pos, y_pos, vecteur) end)
  end

  def visible_seat_status(seat_map, x_pos, y_pos, {x, y}) do
    case get_in(seat_map, [x_pos + x, y_pos + y]) do
      nil -> nil
      "." -> visible_seat_status(seat_map, x_pos + x, y_pos + y, {x, y})
      status -> status
    end
  end

  def number_occupied_adjacent_seat(list_seat_status) do
    list_seat_status |> Enum.filter(&(&1 == "#")) |> Enum.count()
  end

  def new_seat_status("L", 0), do: "#"
  def new_seat_status("L", _), do: "L"
  def new_seat_status("#", occupied_seats) when occupied_seats > 4, do: "L"
  def new_seat_status("#", _), do: "#"
  def new_seat_status(".", _), do: "."

  def file do
    Parser.read_file("day11")
  end

  def test do
    Parser.read_file("test")
  end

  def format(file) do
    file
    |> Enum.map(fn string ->
      string |> String.graphemes() |> Enum.with_index() |> Map.new(fn {a, b} -> {b, a} end)
    end)
    |> Enum.with_index()
    |> Map.new(fn {a, b} -> {b, a} end)
  end
end
