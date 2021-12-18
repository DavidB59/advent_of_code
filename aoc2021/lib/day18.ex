defmodule Day18 do
  def file, do: Parser.read_file("day18")
  def test, do: Parser.read_file("test")

  def parse(input) do
    Enum.map(input, fn string -> string |> Code.eval_string() |> elem(0) |> add_nesting() end)
  end

  def add_nesting(list), do: list |> add_nesting_level() |> List.flatten()

  def add_nesting_level(list, nesting_level \\ 0)

  def add_nesting_level([a, b], nested) do
    [add_nesting_level(a, nested + 1), add_nesting_level(b, nested + 1)]
  end

  def add_nesting_level(last, nested), do: {last, nested}

  def solve_part_one do
    file()
    |> parse()
    |> Enum.reduce(fn list, acc -> acc |> addition(list) |> compute_after_addition() end)
    |> calculate_magnitude()
  end

  def solve_part_two do
    input = file() |> parse()

    input
    |> Enum.reduce(0, fn list, acc ->
      input
      |> Enum.reduce(0, fn list_two, acc ->
        list
        |> addition(list_two)
        |> compute_after_addition()
        |> calculate_magnitude()
        |> return_highest(acc)
      end)
      |> return_highest(acc)
    end)
  end

  def return_highest(a, b) when a > b, do: a
  def return_highest(_, b), do: b

  def calculate_magnitude(list, nesting_level \\ 4)
  def calculate_magnitude([{result, 0}], 0), do: result

  def calculate_magnitude(list, nesting_level) do
    index = Enum.find_index(list, fn {_, nesting} -> nesting == nesting_level end)

    if index do
      {left, ^nesting_level} = Enum.at(list, index)
      {right, ^nesting_level} = Enum.at(list, index + 1)
      result = 3 * left + 2 * right

      list
      |> List.delete_at(index + 1)
      |> List.replace_at(index, {result, nesting_level - 1})
      |> calculate_magnitude(nesting_level)
    else
      calculate_magnitude(list, nesting_level - 1)
    end
  end

  def addition(pair_one, pair_two) do
    (pair_one ++ pair_two) |> Enum.map(fn {value, nesting} -> {value, nesting + 1} end)
  end

  def compute_after_addition(list) do
    result = list |> explode_them_all() |> split()

    if result == list do
      result
    else
      compute_after_addition(result)
    end
  end

  def explode_them_all(list) do
    index = Enum.find_index(list, fn {_, nesting} -> nesting == 5 end)

    if index do
      explode(list, index) |> explode_them_all()
    else
      list
    end
  end

  def split(list) do
    to_split = Enum.find(list, fn {value, _nesting} -> value > 9 end)

    if to_split do
      index_to_split = Enum.find_index(list, fn {value, _nesting} -> value > 9 end)

      {value_to_split, nesting_to_increase} = to_split
      half = value_to_split / 2
      left_value = half |> floor()
      right_value = half |> ceil()

      list
      |> List.replace_at(index_to_split, {left_value, nesting_to_increase + 1})
      |> List.insert_at(index_to_split + 1, {right_value, nesting_to_increase + 1})
    else
      list
    end
  end

  def explode(list, index) do
    {to_explode_1, 5} = Enum.at(list, index)
    {to_explode_2, 5} = Enum.at(list, index + 1)
    # no number on the left
    if index == 0 do
      if index + 1 == length(list) do
        :no_number_on_the_right_and_left
        [{0, 4}]
      else
        {value_right, nesting_right} = Enum.at(list, index + 2)

        value_at_index_plus_one = to_explode_2 + value_right
        at_index_plus_one = {value_at_index_plus_one, nesting_right}
        at_index = {0, 4}

        list
        |> List.delete_at(0)
        |> List.replace_at(0, at_index)
        |> List.replace_at(1, at_index_plus_one)
      end
    else
      # no number on the right
      if index + 2 == length(list) do
        {value_left, nesting_left} = Enum.at(list, index - 1)

        value_at_index_minus_one = value_left + to_explode_1

        list
        |> List.delete_at(index + 1)
        |> List.replace_at(index, {0, 4})
        |> List.replace_at(index - 1, {value_at_index_minus_one, nesting_left})
      else
        # general_case
        {value_right, nesting_right} = Enum.at(list, index + 2)
        {value_left, nesting_left} = Enum.at(list, index - 1)

        value_at_index_minus_one = value_left + to_explode_1
        value_at_index_plus_two = value_right + to_explode_2

        list
        |> List.replace_at(index - 1, {value_at_index_minus_one, nesting_left})
        |> List.replace_at(index + 2, {value_at_index_plus_two, nesting_right})
        |> List.replace_at(index + 1, {0, 4})
        |> List.delete_at(index)
      end
    end
  end
end
