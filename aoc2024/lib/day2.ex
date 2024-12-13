defmodule Day2 do
  def file do
    Parser.read_file(2)
  end

  def test do
    Parser.read_file("test")
  end

  def solve() do
    file()
    |> Enum.map(fn string -> string |> String.split() |> Enum.map(&String.to_integer/1) end)
    |> Enum.map(&check_one_line/1)
    |> Enum.reject(&(&1 == :unsafe))
    |> Enum.count()
  end

  def solve_two() do
    file()
    |> Enum.map(fn string -> string |> String.split() |> Enum.map(&String.to_integer/1) end)
    |> Enum.filter(&check_one_line_two/1)
    |> Enum.count()
  end

  def check_one_line(line) do
    Enum.reduce_while(line, :start, fn
      next_number, :start ->
        {:cont, {next_number, :one}}

      next_number, {previous, direction} ->
        diff = next_number - previous

        cond do
          abs(diff) > 3 ->
            {:halt, :unsafe}

          diff == 0 ->
            {:halt, :unsafe}

          diff > 0 ->
            continue(direction, {next_number, :decrease})

          diff < 0 ->
            continue(direction, {next_number, :increase})
        end
    end)
  end

  def continue(:one, {next_number, direction}), do: {:cont, {next_number, direction}}
  def continue(direction, {next_number, direction}), do: {:cont, {next_number, direction}}
  def continue(_, _), do: {:halt, :unsafe}

  # def valid?(0, _), do: false
  # def valid?(diff, _direction) when abs(diff) > 3, do: false
  # def valid?(diff, :increase) when diff > 0, do: false
  # def valid?(diff, :decrease) when diff < 0, do: false
  # def valid?(_, _), do: true

  def check_one_line_two(line) do
    case check_one_line(line) do
      :unsafe -> recheck_without_one(line)
      _ -> true
    end
  end

  def recheck_without_one(line) do
    length = length(line)
    max = length - 1

    Enum.any?(0..max, fn index ->
      new_list = List.delete_at(line, index)

      case check_one_line(new_list) do
        :unsafe -> false
        _ -> true
      end
    end)
  end
end
