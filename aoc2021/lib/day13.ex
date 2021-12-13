defmodule Day13 do
  def file do
    Parser.read_file("day13")
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    {coordinates, fold} = input |> Enum.split_while(&String.contains?(&1, ","))

    a =
      Enum.map(coordinates, fn string ->
        String.split(string, ",") |> Enum.map(&String.to_integer/1)
      end)

    b =
      fold
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(fn string ->
        [coord, value] = String.trim(string, "fold along ") |> String.split("=")
        {coord, String.to_integer(value)}
      end)

    {a, b}
  end

  def fold([x, y], {"y", y_pos}) when y > y_pos, do: [x, y - 2 * (y - y_pos)]
  def fold([x, y], {"x", x_pos}) when x > x_pos, do: [x - 2 * (x - x_pos), y]
  def fold([x, y], _), do: [x, y]

  def apply_folding(positions, [head] = _fold) do
    positions |> Enum.map(&fold(&1, head)) |> Enum.uniq()
  end

  def apply_folding(positions, [head | rest] = _fold) do
    positions
    |> Enum.map(&fold(&1, head))
    |> Enum.uniq()
    |> apply_folding(rest)
  end

  def solve_part_one do
    {positions, fold_instructions} = file() |> parse()
    first = List.first(fold_instructions)

    positions
    |> apply_folding([first])
    |> Enum.count()
  end

  def solve_part_two do
    {positions, fold_instructions} = file() |> parse()

    positions
    |> apply_folding(fold_instructions)
    |> plot_solution()
  end

  def plot_solution(positions) do
    x_max = Enum.map(positions, fn [x, _y] -> x end) |> Enum.max()
    y_max = Enum.map(positions, fn [_x, y] -> y end) |> Enum.max()
    {x_max, y_max}

    Enum.reduce(0..x_max, [], fn x, acc_x ->
      line_y =
        Enum.reduce(0..y_max, [], fn y, acc ->
          val = if [x, y] in positions, do: 1, else: 0
          acc ++ [val]
        end)

      [line_y | acc_x]
    end)
  end
end
