defmodule Day2 do
  def file do
    Parser.read_file(2)
  end

  def part_one do
    {double, triple} =
      file()
      |> Enum.reduce({0, 0}, fn string, {double, triple} ->
        list =
          string
          |> String.graphemes()
          |> Enum.reduce(%{}, fn char, acc ->
            case Map.get(acc, char) do
              nil -> Map.put(acc, char, 1)
              val -> Map.put(acc, char, val + 1)
            end
          end)
          |> Map.values()

        double =
          if(Enum.member?(list, 2)) do
            double + 1
          else
            double
          end

        triple =
          if(Enum.member?(list, 3)) do
            triple + 1
          else
            triple
          end

        {double, triple}
      end)

    double * triple
  end

  def part_two do
    index_list =
      file()
      |> Enum.map(fn string ->
        string |> String.graphemes() |> Stream.with_index() |> Enum.map(& &1)
      end)

    {l1, l2} =
      Enum.reduce(index_list, {0, 0}, fn list1, acc ->
        res =
          Enum.find(index_list, fn l2 ->
            diff = list1 -- l2
            length(diff) == 1
          end)

        if res do
          {list1, res}
        else
          acc
        end
      end)

    diff = l1 -- l2

    (l1 -- diff)
    |> Enum.map(fn {a, _} -> a end)
    |> Enum.join()
  end
end
