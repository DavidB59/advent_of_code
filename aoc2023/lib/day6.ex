defmodule Day6 do
  def file do
    Parser.read_file(6)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Enum.map(fn string ->
      string
      |> String.split()
      |> List.delete_at(0)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.zip()
  end

  def solve(input) do
    input
    |> parse()
    |> Enum.map(fn {time, distance} -> calculate(time, distance) end)
    |> Enum.reduce(fn a, acc -> a * acc end)
  end

  def calculate(time, distance, results \\ 0, previous_distance \\ 0, holding_time \\ 0) do
    traveled_distance = (time - holding_time) * holding_time

    cond do
      traveled_distance > distance ->
        calculate(time, distance, results + 1, traveled_distance, holding_time + 1)

      traveled_distance < previous_distance ->
        results

      holding_time > time ->
        results

      true ->
        calculate(time, distance, results, traveled_distance, holding_time + 1)
    end
  end

  def solve_two(input) do
   [time, distance ] =  input
    |> Enum.map(fn string ->
      string
      |> String.split()
      |> List.delete_at(0)
      |> Enum.join()
      |> String.to_integer()
    end)
     calculate(time, distance)
  end
end
