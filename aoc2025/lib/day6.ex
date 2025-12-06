defmodule Day6 do
  def file, do: Parser.read_file(6)
  def test, do: Parser.read_file("test")

  def parse(input) do
    input
  end

  def solve(input \\ file()) do
    input
    |> Enum.reduce(%{}, fn line, acc ->
      line
      |> String.split()
      |> Stream.with_index()
      |> Enum.reduce(acc, fn {value, index}, acc ->
        Map.update(acc, index, [value], fn list -> [value | list] end)
      end)
    end)
    |> Map.values()
    |> Enum.map(&solve_line/1)
    |> Enum.sum()
  end

  def solve_line(list) do
    [operation | rest] = list
    new_list = Enum.reverse(rest) |> Enum.map(&String.to_integer/1)
    calculate(new_list, operation)
  end

  def calculate(list, "+"), do: Enum.sum(list)
  def calculate(list, "*"), do: Enum.product(list)

  def solve_two(input \\ file()) do
    {operator_line, number_lines} = Enum.map(input, &String.graphemes/1) |> List.pop_at(-1)

    operator_line
    |> get_operation_length
    |> Enum.reduce({[], number_lines}, fn {operator, operation_length},
                                          {new_stuf, lines_to_cut} ->
      {problem, rest} =
        Enum.reduce(lines_to_cut, {[], []}, fn line, {new, old} ->
          {one, two} = line |> Enum.split(operation_length)
          {new ++ [one], old ++ [two]}
        end)

      {[{operator, problem} | new_stuf], rest}
    end)
    |> elem(0)
    |> Enum.map(fn {operator, future_number} ->
      future_number |> build_number() |> Enum.reverse() |> calculate(operator)
    end)
    |> Enum.sum()
  end

  def build_number(list) do
    list
    |> Enum.reduce(%{}, fn list, acc ->
      list
      |> Stream.with_index()
      |> Map.new(fn {k, v} -> {v, k} end)
      |> Map.merge(acc, fn _key, v1, v2 -> [v1 | List.wrap(v2)] end)
    end)
    |> Map.values()
    |> Enum.map(fn list ->
      Enum.join(list)
      |> String.trim()
      |> String.reverse()
    end)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.to_integer/1)
  end

  def get_operation_length(operator_line) do
    operator_line
    |> Enum.reduce([], fn symbol, acc ->
      case symbol do
        " " ->
          [{operator, count} | rest] = acc
          [{operator, count + 1} | rest]

        operator ->
          [{operator, 1} | acc]
      end
    end)
    |> Enum.map(fn {op, count} -> {op, count} end)
    |> Enum.reverse()
  end
end
