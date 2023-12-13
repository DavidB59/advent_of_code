defmodule Day13 do
  def file do
    Parser.read_file(13)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    input
    |> Enum.chunk_by(&(&1 == ""))
    |> Enum.reject(&(&1 == [""]))
  end

  def solve(input) do
    input
    |> parse
    |> Enum.map(&find_horizontal_reflection(&1, true))
    |> Enum.sum()
  end

  def solve_two(input) do
    input
    |> parse
    |> Enum.map(&find_horizontal_reflection(&1, false))
    |> Enum.sum()
  end

  def find_horizontal_reflection(lines, smudge?) do
    case find_reflection_key(lines, smudge?) do
      key when is_integer(key) -> (key + 1) * 100
      _ -> find_vertical_reflections(lines, smudge?)
    end
  end

  def find_vertical_reflections(lines, smudge?) do
    columns = get_columns(lines)

    case find_reflection_key(columns, smudge?) do
      key when is_integer(key) -> key + 1
      _ -> raise "panic"
    end
  end

  def find_reflection_key(lines, smudge?) do
    lines
    |> Stream.with_index()
    |> Map.new(fn {line, index} -> {index, line} end)
    |> do_find_reflection(smudge?)
  end

  def do_find_reflection(map, smudge?) do
    map
    |> Map.keys()
    |> Enum.find_value(&check_embrassing_lines(map, &1, &1 + 1, smudge?, &1))
  end

  def check_embrassing_lines(map, index1, index2, smudge?, key) do
    line1 = Map.get(map, index1)
    line2 = Map.get(map, index2)

    cond do
      line1 == line2 ->
        check_embrassing_lines(map, index1 - 1, index2 + 1, smudge?, key)

      line1 == nil and smudge? ->
        key

      line2 == nil and smudge? and key != index1 ->
        key

      line1 == nil ->
        false

      line2 == nil ->
        false

      !smudge? and Levenshtein.distance(line2, line1) == 1 ->
        check_embrassing_lines(map, index1 - 1, index2 + 1, true, key)

      true ->
        false
    end
  end

  def get_columns(list) do
    length = list |> List.first() |> String.length()
    one_string = list |> Enum.join() |> String.graphemes()

    Enum.map(0..(length - 1), fn offset ->
      {_, string} = Enum.split(one_string, offset)
      Enum.take_every(string, length) |> Enum.join()
    end)
  end
end
