defmodule Day3 do
  @take_mul_regex ~r/mul\([0-9]+[,][0-9]+\)/
  @only_number ~r/[0-9]+/
  @split_by_do_and_dont ~r/don't\(\)|do\(\)/

  def file do
    Parser.read_file(3)
  end

  def test do
    ["xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"]
  end

  def solve(input \\ file()) do
    input
    |> Enum.reduce(fn a, b -> b <> a end)
    |> calculate_one_line()
  end

  def solve_two(input \\ file()) do
    input = Enum.reduce(input, fn a, b -> b <> a end)

    @split_by_do_and_dont
    |> Regex.split(input, include_captures: true)
    |> Enum.reduce({0, :do}, &my_reduce/2)
    |> elem(0)
  end

  def my_reduce("don't()", {sum, _next}), do: {sum, :do_not}
  def my_reduce("do()", {sum, _}), do: {sum, :do}
  def my_reduce(_skipped, {sum, :do_not}), do: {sum, :whatever}
  def my_reduce(input, {sum, :do}), do: {calculate_one_line(input) + sum, :whatever}

  def calculate_one_line(line) do
    @take_mul_regex
    |> Regex.scan(line)
    |> List.flatten()
    |> Enum.map(&Regex.scan(@only_number, &1))
    |> Enum.map(fn [[a], [b]] -> String.to_integer(a) * String.to_integer(b) end)
    |> Enum.reduce(fn a, b -> a + b end)
  end
end
