defmodule Day19 do
  def file do
    Parser.read_file(19)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    [instructions, _, materials] = input |> Enum.chunk_by(&(&1 == ""))

    parsed_instructions =
      Map.new(instructions, fn string ->
        [workshop_key, instruction] = String.split(string, "{")

        parsed =
          instruction
          |> String.trim("}")
          |> String.split(",")
          |> Enum.map(&(&1 |> String.split(":") |> Enum.map(fn a -> extract_instruction(a) end)))

        {workshop_key, parsed}
      end)

    parsed_material =
      Enum.map(materials, fn a ->
        a |> String.trim("{") |> String.trim("}") |> String.split(",") |> Map.new(&extract_info/1)
      end)

    {parsed_instructions, parsed_material}
  end

  def extract_info(<<letter::binary-1>> <> "=" <> value), do: {letter, String.to_integer(value)}

  def extract_instruction(<<letter::binary-1>> <> ">" <> key),
    do: {letter, ">", String.to_integer(key)}

  def extract_instruction(<<letter::binary-1>> <> "<" <> key),
    do: {letter, "<", String.to_integer(key)}

  def extract_instruction(key), do: key

  def solve(input \\ file()) do
    {instructions, materials} = parse(input)

    materials
    |> Enum.filter(&process_part(&1, instructions))
    |> Enum.map(&(&1 |> Map.values() |> Enum.sum()))
    |> Enum.sum()
  end

  def process_part(part, map, key \\ "in") do
    instruction = Map.get(map, key)

    case process_instruction(part, instruction) do
      "A" -> true
      "R" -> false
      key -> process_part(part, map, key)
    end
  end

  def process_instruction(_part, [[key]]), do: key

  def process_instruction(part, [[{category_key, comparateur, value}, target_key] | rest]) do
    part_value = Map.get(part, category_key)

    if compare(part_value, comparateur, value) do
      target_key
    else
      process_instruction(part, rest)
    end
  end

  def compare(value1, "<", value2), do: value1 < value2
  def compare(value1, ">", value2), do: value1 > value2

  def processing([{key, comparator, value}, "A"], _map, list) do
    # [{key, comparator, value, "A"} | list]
    list <> "(#{key} #{comparator} #{value} = 1) "
  end

  def processing([{_key, _comparator, _value}, "R"], _map, list) do
    # #
    # IO.inspect(list, label: "list")
    #  list <> " => R"
    # ""
    list
  end

  def processing([{key, comparator, value}, target_key], map, list) do
    IO.inspect(label: "HERE")
    # [{key, comparator, value} | list]
    acc = (list <> "(#{key} #{comparator} #{value}) ") |> IO.inspect()

    map
    |> Map.get(target_key)
    |> Enum.reduce(acc, &processing(&1, map, &2))
  end

  def processing(["A"], _map, list), do: list <> "= 1) "
  def processing(["R"], _map, list), do: list

  def processing([key], map, list) do
    IO.inspect(key)

    map
    |> Map.get(key)
    |> IO.inspect()
    |> Enum.reduce(list, &processing(&1, map, &2))
  end

  def solve_two(input \\ file()) do
    [instructions, _, _materials] = input |> Enum.chunk_by(&(&1 == ""))

    map =
      instructions
      |> Enum.map(fn string ->
        [key, value] = String.split(string, "{")
        {key, "{" <> value}
      end)
      |> Map.new()

    keys = Map.keys(map)

    Map.get(map, "in") |> custom_replace(map, keys)
  end

  def custom_replace(string, map, keys) do
    key = Enum.find(keys, &String.contains?(string, &1))

    if key do
      val = Map.get(map, key)

      String.replace(string, key, val)
      |> custom_replace(map, keys)
    else
      string
    end
  end
end
