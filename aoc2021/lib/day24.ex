defmodule Day24 do
  def file, do: Parser.read_file("day24")
  def test, do: Parser.read_file("test")
  def first, do: Parser.read_file("first")

  @variable ["x", "y", "w", "z"]
  @largest_14_digits 99_399_999_999_999
  # @largest_14_digits 55_555_555_555_555

  @map %{"x" => 0, "y" => 0, "z" => 0, "w" => 0}
  def parse(input) do
    input
  end

  def solve_part_one() do
    # model_number = input |> Integer.digits()
    instructions = file()
    IO.inspect(label: "here")
    find_largest_number(instructions)
    # run_program(@map, instructions, model_number)
  end

  def find_largest_number(instructions, model_number \\ @largest_14_digits) do
    input_list = model_number |> Integer.digits()

    if Enum.member?(input_list, 0) do
      find_largest_number(instructions, model_number - 1)
    else
      # IO.inspect(model_number, label: "inspect one")
      map = run_program(@map, instructions, input_list)
      %{"z" => z} = map
      # IO.inspect(model_number, label: "number ")

      if z == 0 and !Enum.member?(input_list, 0) do
        model_number
      else
        # IO.inspect(map, label: "model_number: #{model_number} => ")
        find_largest_number(instructions, model_number - 1)
      end
    end
  end

  def for_one_number() do
    instructions = file()
    run_program2(@map, instructions)
  end

  def complete_to_fourten(list) do
    if Enum.count(list) == 14 do
      list
    else
      [0 | list] |> complete_to_fourten()
    end
  end

  def run_program2(map, [head | rest]) do
    if String.starts_with?(head, "inp") do
      map
      |> apply_instruction(head, "input")
      # |> IO.inspect(label: "#{head}: ")
      |> run_program2(rest)
    else
      map
      |> apply_instruction(head)
      # |> IO.inspect(label: "#{head}: ")
      |> run_program2(rest)
    end
  end

  def run_program2(map, _), do: map

  def run_program(map, [head | rest], input_list) do
    if String.starts_with?(head, "inp") do
      [input | rest_input] = input_list

      map
      |> apply_instruction(head, input)
      # |> IO.inspect(label: "#{head}: ")
      |> run_program(rest, rest_input)
    else
      map
      |> apply_instruction(head)
      # |> IO.inspect(label: "#{head}: ")
      |> run_program(rest, input_list)
    end
  end

  def run_program(map, _, _input), do: map

  def apply_instruction(map, "inp " <> a, input) do
    # value = IO.gets("") |> String.trim("\n") |> String.to_integer()

    Map.put(map, a, input)
  end

  def apply_instruction(map, "add " <> a_space_b) do
    [a, b] = get_a_b(a_space_b)
    b = determine_b(b, map)
    val_a = Map.get(map, a)
    new_val_a = (val_a + b) |> trunc()
    %{map | a => new_val_a}
  end

  def apply_instruction(map, "mul " <> a_space_b) do
    [a, b] = get_a_b(a_space_b)
    b = determine_b(b, map)
    val_a = Map.get(map, a)
    new_val_a = (val_a * b) |> trunc()
    %{map | a => new_val_a}
  end

  def apply_instruction(map, "div " <> a_space_b) do
    [a, b] = get_a_b(a_space_b)
    b = determine_b(b, map)
    val_a = Map.get(map, a)
    new_val_a = (val_a / b) |> trunc()
    %{map | a => new_val_a}
  end

  def apply_instruction(map, "mod " <> a_space_b) do
    [a, b] = get_a_b(a_space_b)
    b = determine_b(b, map)
    val_a = Map.get(map, a)
    new_val_a = rem(val_a, b)
    %{map | a => new_val_a}
  end

  def apply_instruction(map, "eql " <> a_space_b) do
    [a, b] = get_a_b(a_space_b)
    val_b = determine_b(b, map)
    val_a = Map.get(map, a)
    new_val_a = if val_a == val_b, do: 1, else: 0
    # if a == "x" and b == "w", do: IO.inspect({new_val_a, val_a, val_b}, label: "eql x w ")
    %{map | a => new_val_a}
  end

  def get_a_b(a_space_b), do: String.split(a_space_b, " ")
  def determine_b(b, map), do: if(b in @variable, do: Map.get(map, b), else: String.to_integer(b))
end

# XX39
