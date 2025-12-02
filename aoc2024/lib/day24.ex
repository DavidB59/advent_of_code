defmodule Day24 do
  def file do
    Parser.read_file(24)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    {first, [_ | second]} =
      input
      |> Enum.split_while(&(&1 != ""))

    first =
      first
      |> Enum.map(&String.split(&1, ": "))
      |> Map.new(fn [a, b] -> {a, String.to_integer(b)} end)

    second =
      second
      |> Enum.map(&extract/1)

    {first, second}
  end

  def extract(
        <<first::bytes-size(3)>> <>
          " XOR " <> <<second::bytes-size(3)>> <> " -> " <> <<third::bytes-size(3)>>
      ) do
    {first, second, :xor, third}
  end

  def extract(
        <<first::bytes-size(3)>> <>
          " AND " <> <<second::bytes-size(3)>> <> " -> " <> <<third::bytes-size(3)>>
      ) do
    {first, second, :and, third}
  end

  def extract(
        <<first::bytes-size(3)>> <>
          " OR " <> <<second::bytes-size(3)>> <> " -> " <> <<third::bytes-size(3)>>
      ) do
    {first, second, :or, third}
  end

  def solve(input \\ file()) do
    # map =
    {map_input, connected_doors} =
      input
      |> parse()

    calculate_all_doors(map_input, connected_doors)
    |> Enum.filter(fn {key, _value} -> String.starts_with?(key, "z") end)
    |> Enum.sort()
    |> Enum.reduce([], fn {_key, nb}, acc -> [nb | acc] end)
    |> Integer.undigits(2)
  end

  def calculate_all_doors(map, list, results \\ [])
  def calculate_all_doors(map, [], _results), do: map

  def calculate_all_doors(map, [head | rest], results) do
    {key1, key2, operator, key_result} = head
    value1 = Map.get(map, key1)
    value2 = Map.get(map, key2)

    if is_nil(value1) or is_nil(value2) do
      calculate_all_doors(map, rest ++ [head], results)
    else
      value_result = operate_gates(value1, value2, operator)
      new_map = Map.put(map, key_result, value_result)
      calculate_all_doors(new_map, rest, results)
    end
  end

  # def operate_gates(1, 1, :and), do: 1
  # def operate_gates(_, _, :and), do: 0

  # def operate_gates(0, 0, :or), do: 0
  # def operate_gates(_, _, :or), do: 1
  # def operate_gates(input, input, :xor), do: 0
  # def operate_gates(_, _, :xor), do: 1
  def operate_gates(a, b, :and), do: Bitwise.band(a, b)
  def operate_gates(a, b, :xor), do: Bitwise.bxor(a, b)
  def operate_gates(a, b, :or), do: Bitwise.bor(a, b)

  def solve_two(input \\ file()) do
    # map =
    {_map_input, connected_doors} =
      input
      |> parse()

    find_wrong_cable(1, connected_doors)
  end

  def find_wrong_cable(nb1, connected_doors) do
    nb2 = 1
    map_input = generate_input(nb2, nb1)

    bit_result =
      calculate_all_doors(map_input, connected_doors)
      |> Enum.filter(fn {key, _value} -> String.starts_with?(key, "z") end)
      |> Enum.sort()
      |> Enum.reduce([], fn {_key, nb}, acc -> [nb | acc] end)

    result = bit_result |> Integer.undigits(2)

    if result == nb1 + nb2 do
      find_wrong_cable(nb1 + 1, connected_doors)
    else
      IO.inspect(Integer.digits(nb1, 2), label: "input nb1 ")
      IO.inspect(bit_result, label: "bit_result")
      IO.inspect(nb1)
    end
  end

  def generate_input(nb1, nb2) do
    x_map =
      Map.new(0..44, fn a ->
        if a < 10 do
          {"x0#{a}", 0}
        else
          {"x#{a}", 0}
        end
      end)

    y_map =
      Map.new(0..44, fn a ->
        if a < 10 do
          {"y0#{a}", 0}
        else
          {"y#{a}", 0}
        end
      end)

    map1 =
      nb1
      |> Integer.digits(2)
      # |> IO.inspect(label: "nb1")
      |> Enum.reverse()
      |> Stream.with_index()
      |> Enum.reduce(x_map, fn {bit, index}, acc ->
        key = if index < 10, do: "x0#{index}", else: "x#{index}"
        Map.put(acc, key, bit)
      end)

    map2 =
      nb2
      |> Integer.digits(2)
      # |> IO.inspect(label: "nb2")
      |> Enum.reverse()
      |> Stream.with_index()
      |> Enum.reduce(y_map, fn {bit, index}, acc ->
        key = if index < 10, do: "y0#{index}", else: "y#{index}"
        Map.put(acc, key, bit)
      end)

    Map.merge(map1, map2)
  end
end
