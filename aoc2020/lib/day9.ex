defmodule Day9 do
  @moduledoc """
  Documentation for Day8.
  """

  def part_one do
    file = file() |> Enum.map(&String.to_integer/1)
    find_invalid_number(25, file)
  end

  def test_part_one() do
    file = test() |> Enum.map(&String.to_integer/1)
    find_invalid_number(5, file)
  end

  def part_two do
    file = file() |> Enum.map(&String.to_integer/1)
    find_countiguous_set(file)
  end

  def find_countiguous_set(file) do
    {invalid_nb, _index} = part_one()
    list = recursive(file, 0, 1, invalid_nb) |> IO.inspect()
    Enum.min(list) + Enum.max(list)
  end

  def recursive(list, index1, index2, invalid_nb) do
    to_be_summed = Enum.slice(list, index1..index2)
    IO.inspect(length(to_be_summed), label: "length")
    sum = Enum.sum(to_be_summed)

    cond do
      sum < invalid_nb -> recursive(list, index1, index2 + 1, invalid_nb)
      sum > invalid_nb -> recursive(list, index1 + 1, index1 + 2, invalid_nb)
      sum == invalid_nb -> to_be_summed
    end
  end

  def find_invalid_number(preamble, list) do
    list
    |> Enum.with_index()
    |> Enum.find(fn
      {_number, index} when index < preamble ->
        false

      {number, index} ->
        slice_to = index - 1
        slice_from = index - preamble

        preamble_list = list |> Enum.slice(slice_from..slice_to)

        Enum.all?(
          preamble_list,
          fn nb ->
            validnb =
              Enum.find(preamble_list, fn nb2 ->
                nb + nb2 == number && nb !== nb2
              end)

            is_nil(validnb)
          end
        )
    end)
  end

  def file do
    Parser.read_file("day9")
  end

  def test do
    Parser.read_file("test")
  end

  def format(file) do
    file
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn [a, b] -> {a, String.to_integer(b)} end)
  end
end
