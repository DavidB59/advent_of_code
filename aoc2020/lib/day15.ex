defmodule Day15 do
  @moduledoc """
  Documentation for Day15.
  """

  def part_two() do
  end

  def part_one() do
    file() |> format() |> solve_one |> find_answer()
  end

  def test() do
    Parser.read_file("test") |> format() |> solve_one
  end

  def solve_one(map) do
    recursive_call(map, 7, 4)
  end

  def find_answer(map) do
    to_find = 29_999_999

    Enum.find(map, fn {_key, value} ->
      case value do
        {a, b} -> a == to_find || b == to_find
        a -> a == to_find
      end
    end)
  end

  def recursive_call(map, 30_000_000, _last), do: map

  def recursive_call(map, times, last) do
    if Integer.mod(times, 10000) == 0, do: IO.inspect(times)
    previous = Map.get(map, last)
    # found = map |> find_previous(number_to_find, 0, nil)

    {new_map, last_number} =
      case previous do
        {a, b} ->
          key = a - b

          new_map =
            case Map.get(map, key) do
              nil -> Map.put(map, key, times)
              {a, _b} -> Map.put(map, key, {times, a})
              a -> Map.put(map, key, {times, a})
            end

          {new_map, key}

        _a ->
          new_map =
            case Map.get(map, 0) do
              nil -> Map.put(map, 0, times)
              {a, _b} -> Map.put(map, 0, {times, a})
              a -> Map.put(map, 0, {times, a})
            end

          {new_map, 0}
      end

    recursive_call(new_map, times + 1, last_number)
  end

  def reducer(list) do
    Enum.reduce(1..2020, list, fn _, acc ->
      {number_to_find, index} = hd(acc) |> IO.inspect()
      found = acc |> find_previous(number_to_find, 0, nil)

      case is_list(found) do
        false ->
          [{0, index + 1}] ++ acc

        true ->
          [{_nb, index1}, {_nb2, index2}] = found
          new = index1 - index2
          [{new, index + 1}] ++ acc
      end
    end)
  end

  def find_previous([{number, index}], number, found_x_time, found_before) do
    case found_x_time do
      1 -> [found_before, {number, index}]
      0 -> {number, index}
    end
  end

  def find_previous([_], _, _found_x_time, found_before), do: found_before

  def find_previous([{number, index} | reste], number, found_x_time, found_before) do
    case found_x_time do
      1 -> [found_before, {number, index}]
      0 -> find_previous(reste, number, 1, {number, index})
    end
  end

  def find_previous([_head | reste], number, found_x_time, found_before) do
    find_previous(reste, number, found_x_time, found_before)
  end

  def file() do
    Parser.read_file("day15")
  end

  def format(file) do
    file
    |> Enum.at(0)
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Map.new()
  end
end
