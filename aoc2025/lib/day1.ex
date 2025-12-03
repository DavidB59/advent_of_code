defmodule Day1 do
  def file, do: Parser.read_file(1)
  def test, do: Parser.read_file("test")

  def parse(input) do
    input
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&get_number/1)
  end

  def get_number("R" <> nb), do: {"R", String.to_integer(nb)}
  def get_number("L" <> nb), do: {"L", String.to_integer(nb)}
  def get_number(a), do: IO.inspect(a)

  def solve(input \\ file()) do
    input
    |> parse()
    |> Enum.reduce({50, 0}, fn instructions, {current_pos, counter} ->
      calculate_next(current_pos, instructions, counter)
    end)
  end

  # because if you start a 0, the go_back_to_100 will consider you need to add one to the counter
  # but you shouldn't because you were already at 0
  def calculate_next(0, {"L", number}, counter) do
    go_back_to_100(0 - number, counter - 1)
  end

  def calculate_next(current_nb, {"L", number}, counter) do
    go_back_to_100(current_nb - number, counter)
  end

  def calculate_next(current_nb, {"R", number}, counter) do
    go_back_to_100(current_nb + number, counter)
  end

  def go_back_to_100(100, counter), do: {0, counter + 1}
  def go_back_to_100(0, counter), do: {0, counter + 1}
  def go_back_to_100(nb, counter) when nb > 99, do: go_back_to_100(nb - 100, counter + 1)
  def go_back_to_100(nb, counter) when nb < 0, do: go_back_to_100(100 + nb, counter + 1)
  def go_back_to_100(nb, counter), do: {nb, counter}
end
