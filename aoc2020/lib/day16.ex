defmodule Day16 do
  @moduledoc """
  Documentation for Day16.
  """

  def part_two() do
    {ranges, _my_ticket, nearby_ticket} = file() |> format()
    solve_two(ranges, nearby_ticket)
  end

  def part_one() do
    {ranges, _my_ticket, nearby_ticket} = file() |> format()
    solve_one(ranges, nearby_ticket)
  end

  def my_ticket do
    [151, 71, 67, 113, 127, 163, 131, 59, 137, 103, 73, 139, 107, 101, 97, 149, 157, 53, 109, 61]
  end

  def solution() do
    m = my_ticket()

    Enum.at(m, 13) * Enum.at(m, 15) * Enum.at(m, 3) * Enum.at(m, 14) * Enum.at(m, 6) *
      Enum.at(m, 18)
  end

  def test() do
    {ranges, _my_ticket, nearby_ticket} = Parser.read_file("test") |> format()
    # ticket_by_order = nearby_ticket |> format_nearby_ticket() |> format_nearby_ticket_by_order()
    solve_two(ranges, nearby_ticket)
  end

  def solve_two(ranges, nearby_ticket) do
    list = list_valid_tickets(ranges, nearby_ticket) |> IO.inspect()
    ticket_by_order = list |> format_nearby_ticket_by_order() |> IO.inspect()
    formated_ranges = format_ranges(ranges)
    start = %{remaining: formated_ranges, found: []}

    find_corresponding_class(ticket_by_order, start)
  end

  def find_corresponding_class(ticket_by_order, start) do
    result =
      Enum.reduce(ticket_by_order, start, fn {key, value}, acc ->
        remaining = Map.get(acc, :remaining)

        found =
          Enum.filter(remaining, fn {_type, [range1, range2]} ->
            Enum.all?(value, fn value ->
              IO.inspect(value, label: "value")
              IO.inspect(range1, label: "range1")
              IO.inspect(range2, label: "range2")

              Enum.member?(range1, value) || Enum.member?(range2, value)
            end)
          end)

        case length(found) do
          1 ->
            remaining = remaining -- found
            found = Map.get(acc, :found) ++ [{key, found}]
            %{remaining: remaining, found: found}

          _ ->
            acc
        end
      end)

    case result |> Map.get(:remaining) |> IO.inspect() do
      [] -> result
      _ -> find_corresponding_class(ticket_by_order, result)
    end
  end

  def list_valid_tickets(ranges, nearby_ticket) do
    formated_ranges = format_ranges(ranges)
    formatted_tickets = format_nearby_ticket(nearby_ticket)
    valid_tickets(formated_ranges, formatted_tickets)
  end

  def solve_one(ranges, nearby_ticket) do
    formated_ranges = format_ranges(ranges)
    formatted_tickets = format_nearby_ticket(nearby_ticket)
    list = invalid_numbers(formated_ranges, formatted_tickets)
    list |> Enum.reject(&is_nil(&1)) |> Enum.sum()
  end

  def valid_tickets(ranges, tickets) do
    Enum.filter(tickets, fn ticket ->
      Enum.all?(ticket, fn number ->
        Enum.any?(ranges, fn {_type, [range1, range2]} ->
          Enum.member?(range1, number) || Enum.member?(range2, number)
        end)
      end)
    end)
  end

  def invalid_numbers(ranges, tickets) do
    Enum.map(tickets, fn ticket ->
      Enum.find(ticket, fn number ->
        Enum.all?(ranges, fn {_type, [range1, range2]} ->
          !Enum.member?(range1, number) and !Enum.member?(range2, number)
        end)
      end)
    end)
  end

  def file() do
    Parser.read_file("day16")
  end

  def format(file) do
    {ranges, [_, my_ticket, _ | nearby_ticket]} =
      file
      |> Enum.reject(&(&1 == ""))
      |> Enum.split_while(fn string -> !String.starts_with?(string, "your ticket") end)

    {ranges, my_ticket, nearby_ticket}
    # |> Enum.find_index(fn string -> String.starts_with?(string, "your ticket") end)
  end

  def format_ranges(ranges) do
    ranges
    |> Enum.map(fn string ->
      [type, ranges] = String.split(string, ":")

      range =
        String.split(ranges, "or")
        |> Enum.map(fn range ->
          [a, b] = range |> String.trim() |> String.split("-") |> Enum.map(&String.to_integer(&1))
          a..b
        end)

      {type, range}
    end)
  end

  def format_nearby_ticket(nearby_ticket) do
    nearby_ticket
    |> Enum.map(fn string ->
      string
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def format_nearby_ticket_by_order(formatted_nearby_ticket) do
    formatted_nearby_ticket
    |> Enum.map(&Enum.with_index/1)
    |> List.flatten()
    |> Enum.reduce(%{}, fn {value, key}, acc ->
      {_, map} =
        Map.get_and_update(acc, key, fn
          nil ->
            {nil, [value]}

          list ->
            IO.inspect(list)
            {list, list ++ [value]}
        end)

      map
    end)
  end
end
