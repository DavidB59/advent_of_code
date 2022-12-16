defmodule Day1 do
  def file do
    "day1" |> Parser.read_file() |> Enum.map(&String.to_integer/1)
  end

  def test do
    [199, 200, 208, 210, 200, 207, 240, 269, 260, 263]
  end

  def count_increase(list) do
    Enum.reduce(list, {0, -1}, fn value, {previous, acc} ->
      if value > previous do
        {value, acc + 1}
      else
        {value, acc}
      end
    end)
  end

  def count_increase_part_two do
    list = file()

    Enum.reduce_while(list, {0, []}, fn value, {index, new_list} ->
      if index == Enum.count(list) - 2 do
        {:halt, new_list}
      else
        sum = value + Enum.at(list, index + 1) + Enum.at(list, index + 2)
        {:cont, {index + 1, [sum | new_list]}}
      end
    end)
    |> Enum.reverse()
    |> count_increase()
  end
end
