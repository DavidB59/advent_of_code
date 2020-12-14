defmodule Day7 do
  @moduledoc """
  Documentation for Day7.
  """

  def part_one do
    file = file() |> format()
    really_solve(file)
  end

  def part_two do
    file = file() |> format()

    shiny_bag_content = content(file, "shiny gold bag")
    test_reduce(shiny_bag_content, file)
  end

  def calculate(list) do
    Enum.reduce(list, 0, fn
      elt, acc when is_tuple(elt) ->
        {alpha, beta} = elt
        sum = calculate(alpha) |> IO.inspect()

        acc + sum * beta + beta

      elt, acc ->
        elt + acc
    end)
  end

  def content(list, bag_type) do
    [_container, content] =
      Enum.find(list, fn [container, _content] -> String.contains?(container, bag_type) end)

    String.split(content, ",")
    |> Enum.map(fn string ->
      case string |> String.trim() |> Integer.parse() do
        {number, bag_type} ->
          [bag_type, _] = String.split(bag_type, "bag")
          {number, String.trim(bag_type)}

        :error ->
          {1, :done}
      end
    end)
  end

  def test_reduce(list, file) do
    Enum.reduce(list, [], fn {number, bag_type}, acc ->
      content = content(file, bag_type)

      nb =
        case content do
          [{1, :done}] -> number
          list -> {test_reduce(list, file), number}
        end

      acc ++ [nb]
    end)
  end

  def really_solve(list) do
    list_bag_contain_gold = Enum.filter(list, &can_contain_gold_bag_directly(&1))
    count = Enum.count(list_bag_contain_gold)
    list_indirect = Enum.map(list_bag_contain_gold, fn [a, _b] -> a end)

    new_list =
      Enum.reject(list, fn string ->
        Enum.any?(list_indirect, fn type_bag -> already_counted_bags(string, type_bag) end)
      end)

    really_solve(new_list, list_indirect, count)
  end

  def really_solve(_list, [], count), do: count

  def really_solve(list, list_contain, count) do
    list_bag_contain_gold =
      Enum.filter(list, fn string ->
        Enum.any?(list_contain, fn type_bag -> can_contain_gold_indirect(string, type_bag) end)
      end)

    extra_count = Enum.count(list_bag_contain_gold)
    count = count + extra_count
    list_indirect = Enum.map(list_bag_contain_gold, fn [a, _b] -> a end)

    new_list =
      Enum.reject(list, fn string ->
        Enum.any?(list_indirect, fn type_bag -> already_counted_bags(string, type_bag) end)
      end)

    really_solve(new_list, list_indirect, count)
  end

  def already_counted_bags([type, _content], type_bag) do
    type_bag = String.trim(type_bag, "s")
    String.contains?(type, type_bag)
  end

  def can_contain_gold_bag_directly([_type, content]) do
    String.contains?(content, "shiny gold bag")
  end

  def can_contain_gold_indirect([_type, content], type_bag) do
    type_bag = String.trim(type_bag, "s")
    String.contains?(content, type_bag)
  end

  def can_contain_gold_bag(list) do
    Enum.filter(list, fn [_a, b] -> can_contain_gold_bag_directly(b) end)
  end

  def test do
    Parser.read_file("test")
  end

  def file do
    Parser.read_file("day7")
  end

  def format(file) do
    Enum.map(file, &remove_contain/1)
  end

  def remove_contain(string) do
    String.split(string, "contain") |> Enum.map(&String.trim(&1))
  end
end
