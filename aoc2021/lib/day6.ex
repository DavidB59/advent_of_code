defmodule Day6 do
  def file do
    Parser.read_file("day6")
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> List.first()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.group_by(& &1)
    |> Enum.reduce(
      %{0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0},
      fn {k, v}, acc ->
        Map.put(acc, k, Enum.count(v))
      end
    )
  end

  def calculate_next_day(map, day \\ 0)

  def calculate_next_day(map, 256), do: map

  def calculate_next_day(
        %{
          0 => zero,
          1 => one,
          2 => two,
          3 => three,
          4 => four,
          5 => five,
          6 => six,
          7 => seven,
          8 => eight
        },
        day
      ) do
    new = %{
      0 => one,
      1 => two,
      2 => three,
      3 => four,
      4 => five,
      5 => six,
      6 => zero + seven,
      7 => eight,
      8 => zero
    }

    calculate_next_day(new, day + 1)
  end

  def solve() do
    file()
    |> parse()
    |> calculate_next_day()
    |> Map.values()
    |> Enum.sum()
  end
end
