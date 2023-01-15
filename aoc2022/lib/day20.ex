defmodule Day20 do
  @key 811_589_153
  def file do
    Parser.read_file(20)
  end

  def test do
    "test" |> Parser.read_file()
  end

  def part_one() do
    list = file() |> format()
    max = Enum.count(list)
    result = move(list, 0, max) |> Enum.map(&elem(&1, 0))

    index = Enum.find_index(result, &(&1 == 0)) |> IO.inspect(label: "0 index")
    a = Enum.at(result, index + 1000)
    b = Enum.at(result, index + 2000)
    c = Enum.at(result, index + 3000)

    a + b + c
  end

  def part_two do
    list = file() |> format() |> Enum.map(fn {value, index} -> {value * @key, index} end)
    max = Enum.count(list)
    # result = move(list, 0, max) |> Enum.map(&elem(&1, 0))
    result = do_10_times(list, max, 0) |> Enum.map(&elem(&1, 0))
    index = Enum.find_index(result, &(&1 == 0))
    a = Enum.at(result, index + 1000)
    b = Enum.at(result, index + 2000)
    c = Enum.at(result, index + 3000)

    a + b + c
  end

  def do_10_times(list, _max, 10), do: list

  def do_10_times(list, max, counter) do
    new_list = move(list, 0, max)
    do_10_times(new_list, max, counter + 1)
  end

  def format(file) do
    file
    |> Enum.map(fn string -> String.to_integer(string) end)
    |> Enum.with_index()
  end

  def move(list, max, max), do: list

  def move(list, counter, max) do
    {value, _order} = to_insert = Enum.find(list, fn {_value, order} -> order == counter end)

    current_index = Enum.find_index(list, fn {_value, order} -> order == counter end)

    list
    |> move_item(current_index, value, max, to_insert)
    |> move(counter + 1, max)
  end

  def move_item(list, current_index, steps, nb_items, to_be_moved) do
    insert_at = target_correction(steps + current_index, nb_items)

    list
    |> List.delete_at(current_index)
    |> List.insert_at(insert_at, to_be_moved)
  end

  # for testing purpose only
  def move_item(list, current_index, steps) do
    nb_items = list |> Enum.count()
    to_be_moved = Enum.at(list, current_index)
    move_item(list, current_index, steps, nb_items, to_be_moved)
  end

  def target_correction(0, _nb_items), do: 0

  def target_correction(target_index, nb_items) when target_index > 0 do
    if target_index > nb_items - 1 do
      new_target_index = rem(target_index, nb_items - 1)
      target_correction(new_target_index, nb_items)
    else
      target_index
    end
  end

  def target_correction(target_index, nb_items) when target_index < 0 do
    new_target_index = rem(target_index, nb_items - 1) + (nb_items - 1)
    target_correction(new_target_index, nb_items)
  end
end
