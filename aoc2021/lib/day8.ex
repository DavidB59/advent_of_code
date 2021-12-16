defmodule Day8 do
  def file do
    Parser.read_file("day8")
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Enum.map(&String.split(&1, " | "))
  end

  def solve_part_one() do
    file()
    |> parse()
    |> Enum.map(fn [_, output] -> count_unique(output) end)
    |> IO.inspect()
    |> Enum.sum()
  end

  def count_unique(string) do
    string
    |> String.split(" ")
    |> Enum.reduce(0, fn string, acc ->
      if unique_number(string), do: acc + 1, else: acc
    end)
  end

  defp unique_number(string) do
    String.length(string) in [2, 4, 3, 7]
  end

  # zero = a,b,c,e,f,g - 6 -> contains one/seven
  # zero - seven = b,e,g
  #
  # one = c,f - 2
  # two = a,c, d,e,g - 5 -> contains nothing >
  # three = a,c,d,f,g - 5 -> contains one/seven
  # three - seven = d/g
  # four = b,c,d,f - 4
  # four -- one = db
  # five = a,b,d,f,g - 5 -> contains -> nothing
  # six = a,b,d,e,f,g - 6 -> contains -> nothing
  # seven = a,c,f - 3
  # eight = a,b,c,d,e,f,g - 8
  # nine = a,b,c,d,f,g - 6 -> contains one/four/seven
  # je connais a,g,d,b

  def solve_line([entry, output]) do
    line = entry <> " " <> output
    one = line |> number_by_length(2)
    four = line |> number_by_length(4)
    seven = line |> number_by_length(3)

    line =
      line
      |> String.split(" ")
      |> Enum.map(&(&1 |> String.graphemes() |> Enum.sort()))
      |> List.delete(one)
      |> List.delete(four)
      |> List.delete(seven)

    nine = find_by_contain(line, 6, four)
    three = find_by_contain(line, 5, seven)

    zero =
      line
      |> Enum.uniq()
      |> List.delete(nine)
      |> find_by_contain(6, seven)

    a = seven -- one
    ag = nine -- four
    g = ag -- a
    dg = three -- seven
    d = dg -- g
    bd = four -- one
    b = bd -- d
    beg = zero -- seven
    be = beg -- g
    e = be -- b

    six =
      Enum.filter(line, &(length(&1) == 6))
      |> Enum.uniq()
      |> List.delete(zero)
      |> List.delete(nine)
      |> List.first()

    [a, b, d, e, e]
    f = six -- List.flatten([a, b, d, e, g])
    c = one -- f

    [a, b, c, d, e, f, g]
    |> List.flatten()
  end

  def find_value(string, [a, b, c, d, e, f, g]) do
    comb = string |> String.graphemes()

    cond do
      String.length(string) == 2 -> 1
      String.length(string) == 4 -> 4
      String.length(string) == 7 -> 8
      String.length(string) == 3 -> 7
      Enum.all?(comb, fn l -> l in [a, c, d, f, g] end) -> 3
      Enum.all?(comb, fn l -> l in [a, b, d, f, g] end) -> 5
      Enum.all?(comb, fn l -> l in [a, c, d, e, g] end) -> 2
      Enum.all?(comb, fn l -> l in [a, b, c, e, f, g] end) -> 0
      Enum.all?(comb, fn l -> l in [a, b, d, e, f, g] end) -> 6
      Enum.all?(comb, fn l -> l in [a, b, c, d, f, g] end) -> 9
      true -> IO.inspect(string)
    end
  end

  def number_by_length(string, length) do
    string
    |> String.split(" ")
    |> Enum.find(&(String.length(&1) == length))
    |> case do
      nil -> nil
      value -> value |> String.graphemes() |> Enum.sort()
    end
  end

  def find_by_contain(line, length, contained) do
    line
    |> Enum.filter(&(length(&1) == length))
    |> Enum.find(fn letters ->
      Enum.all?(contained, &(&1 in letters))
    end)
  end

  def solve_part_two() do
    file()
    |> parse()
    |> Enum.map(fn [_entry, output] = line ->
      code = solve_line(line)

      output
      |> String.split(" ")
      |> Enum.map(&find_value(&1, code))
      |> Enum.reduce("", fn number, acc -> acc <> "#{number}" end)
      |> String.to_integer()
    end)
    |> Enum.sum()
  end
end
