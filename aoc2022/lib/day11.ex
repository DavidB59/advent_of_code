defmodule Day11 do
  def file do
    Parser.read_file(11)
  end

  def test do
    Parser.read_file("test")
  end

  def part_one() do
    file()
    |> format()
    |> add_lcm_test()
    |> do_n_times(20)
    |> Enum.map(fn {_key, value} -> Map.get(value, :count) end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end

  def part_two() do
    file()
    |> format()
    |> add_lcm_test()
    |> do_n_times(10000)
    |> Enum.map(fn {_key, value} -> Map.get(value, :count) end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end

  def solve_test() do
    test()
    |> format()
    |> add_lcm_test()
    |> do_n_times(20)
    |> Enum.map(fn {_key, value} -> Map.get(value, :count) end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end

  def do_n_times(tuple, count \\ 0, stop_count)
  def do_n_times({map, _lcn}, count, count), do: map

  def do_n_times({map, lcm}, count, stop_count) do
    map
    |> reduce(lcm)
    |> do_n_times(count + 1, stop_count)
  end

  def reduce(map, lcm) do
    new_map =
      Enum.reduce(map, map, fn {monkey_number, _}, acc ->
        value = Map.get(acc, monkey_number)
        items_list = Map.get(value, :list)
        if_false_monkey = Map.get(acc, value.if_false)
        if_true_monkey = Map.get(acc, value.if_true)

        {new_true_monkey, new_false_monkey} =
          go_through_list(items_list, if_true_monkey, if_false_monkey, value, lcm)

        new_monkey_value =
          value
          |> Map.update!(:count, &(&1 + Enum.count(items_list)))
          |> Map.put(:list, [])

        acc
        |> Map.put(monkey_number, new_monkey_value)
        |> Map.put(value.if_true, new_true_monkey)
        |> Map.put(value.if_false, new_false_monkey)
      end)

    {new_map, lcm}
  end

  def go_through_list([], true_monkey, false_monkey, _, _), do: {true_monkey, false_monkey}

  def go_through_list([head | rest], true_monkey, false_monkey, current_monkey, lcm) do
    # part_one
    worry_level = apply_operation(head, current_monkey.operation) |> div(3)

    # part_two
    # worry_level = apply_operation(head, current_monkey.operation)

    case rem(worry_level, current_monkey.test) do
      0 ->
        new_value = rem(worry_level, lcm)
        new_true_monkey = Map.update!(true_monkey, :list, fn list -> list ++ [new_value] end)
        go_through_list(rest, new_true_monkey, false_monkey, current_monkey, lcm)

      _ ->
        new_value = rem(worry_level, lcm)
        new_false_monkey = Map.update!(false_monkey, :list, fn list -> list ++ [new_value] end)
        go_through_list(rest, true_monkey, new_false_monkey, current_monkey, lcm)
    end
  end

  def apply_operation(worry, "* old"), do: worry * worry
  def apply_operation(worry, "+ " <> value), do: worry + String.to_integer(value)
  def apply_operation(worry, "* " <> value), do: worry * String.to_integer(value)

  def format(file) do
    file
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.chunk_every(6)
    |> Map.new(fn list ->
      Enum.reduce(list, {"", %{count: 0}}, fn current, {key, map} ->
        case build_map(current) do
          {:monkey, monkey} -> {monkey, map}
          {new_key, new_value} -> {key, Map.put(map, new_key, new_value)}
        end
      end)
    end)
  end

  # least common multiple
  def add_lcm_test(map) do
    lcm =
      map
      |> Enum.map(fn {_k, value} -> Map.get(value, :test) end)
      |> Enum.product()

    {map, lcm}
  end

  def build_map("Monkey " <> monkey) do
    {:monkey, monkey |> String.trim(":") |> String.to_integer()}
  end

  def build_map("Starting items: " <> items) do
    {:list,
     items
     |> String.split(",")
     |> Enum.map(&(&1 |> String.trim() |> String.to_integer()))}
  end

  def build_map("Operation: new = old" <> operation), do: {:operation, String.trim(operation)}
  def build_map("Test: divisible by " <> divide_by), do: {:test, String.to_integer(divide_by)}
  def build_map("If true: throw to monkey " <> monkey), do: {:if_true, String.to_integer(monkey)}

  def build_map("If false: throw to monkey " <> monkey),
    do: {:if_false, String.to_integer(monkey)}
end
