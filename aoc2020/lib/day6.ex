defmodule Day6 do
  def part_one do
    {file, _} = file() |> group()

    Enum.map(file, fn string ->
      string
      |> String.graphemes()
      |> Enum.reject(&(&1 == " "))
      |> Enum.sort()
      |> Enum.dedup()
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  def part_two do
    {file, _} = file() |> group()

    file
    |> Enum.map(fn string ->
      string
      |> String.split(" ")
      |> Enum.map(fn string ->
        string |> String.graphemes()
      end)
      |> Enum.reduce([], fn list, acc ->
        if acc == [] do
          Enum.into(list, MapSet.new())
        else
          find_common(list, acc)
        end
      end)
      |> MapSet.to_list()
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  def file do
    Parser.read_file("day6")
  end

  def test do
    Parser.read_file("test")
  end

  def find_common(list1, list2) do
    MapSet.intersection(Enum.into(list1, MapSet.new()), Enum.into(list2, MapSet.new()))
  end

  def group(list) do
    Enum.reduce(list, {[], 0}, fn
      x, {list, index} ->
        if x === "" do
          {list, index + 1}
        else
          if Enum.at(list, index) do
            {List.replace_at(list, index, Enum.at(list, index) <> " " <> x), index}
          else
            {list ++ [x], index}
          end
        end
    end)
  end
end
