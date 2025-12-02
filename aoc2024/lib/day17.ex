defmodule Day17 do
  require Integer
  # Wrong = 1,5,7,4,1,6,0,3,0

  def file do
    Parser.read_file(17)
  end

  def test do
    Parser.read_file("test")
  end

  def parse(input) do
    [register_a, register_b, register_c, "", instructions | _] = input
    instructions = parse_instruction(instructions)

    registers =
      [register_a, register_b, register_c]
      |> Map.new(fn string ->
        [key, raw_value] = string |> String.split(":")
        value = raw_value |> String.trim() |> String.to_integer()
        {key, value}
      end)

    {instructions, registers}
  end

  def try_some() do
    {instructions, registers} = file() |> parse

    117_040..(117_440 + 50)
    |> Enum.map(fn a ->
      new_register = Map.put(registers, "Register A", a)
      {output, _new_registers} = read_program(instructions, new_register)
      reversed = output |> Enum.reverse() |> Integer.undigits(8)

      IO.inspect(output |> Integer.undigits(8),
        label: "#{a} : #{inspect(output)} : #{reversed} : #{a / reversed}"
      )
    end)
  end

  @spec try_some_test() :: list()
  def try_some_test() do
    {instructions, registers} = test() |> parse

    117_040..(117_440 + 50)
    |> Enum.map(fn a ->
      new_register = Map.put(registers, "Register A", a)
      {output, _new_registers} = read_program(instructions, new_register)
      reversed = output |> Enum.reverse() |> Integer.undigits(8)

      IO.inspect(output |> Integer.undigits(8),
        label: "#{a} : #{inspect(output)} : #{reversed} : #{a / reversed}"
      )
    end)
  end

  def parse_instruction(string) do
    string
    |> Utils.extract_number_from_string()
    |> String.graphemes()
    |> Stream.with_index()
    |> Map.new(fn {x, y} -> {y, String.to_integer(x)} end)
  end

  def solve(input \\ file()) do
    {instructions, registers} = input |> parse

    {output, _new_registers} = read_program(instructions, registers)

    output
    # |> Enum.join()
  end

  def solve_two(input \\ file()) do
    {instructions, registers} = input |> parse
    objective = instructions |> Map.values() |> IO.inspect()
    modify_register_a(instructions, registers, objective, 100_000_000_000_000)
  end

  def modify_register_a(_, _, _, 3_262_541_294_666), do: :fail

  def modify_register_a(instructions, registers, _objective, tentative) do
    [_head | rest] =
      tentative
      |> Integer.digits()

    Enum.map(1..9, fn number ->
      list = [number] ++ rest
      input = Integer.undigits(list)
      registers = Map.put(registers, "Register A", input)
      {output, _new_registers} = read_program(instructions, registers)

      # length(output)
      output |> IO.inspect(label: "#{input}")
    end)

    # Enum.map(1..100, fn a ->
    #   input = a + tentative
    #   registers = Map.put(registers, "Register A", input)
    #   {output, _new_registers} = read_program(instructions, registers)
    #   output |> length() |> IO.inspect()
    #   output

    # end)
  end

  def read_program(instructions_map, registers, pointer \\ 0, output \\ []) do
    opcode = Map.get(instructions_map, pointer)
    operand = Map.get(instructions_map, pointer + 1)

    if is_nil(opcode) do
      {output |> Enum.reverse(), registers}
    else
      execute_instruction(opcode, operand, registers)
      |> case do
        updated_register when is_map(updated_register) ->
          read_program(instructions_map, updated_register, pointer + 2, output)

        :do_nothing ->
          read_program(instructions_map, registers, pointer + 2, output)

        {:move_pointer_to, new_pointer} ->
          read_program(instructions_map, registers, new_pointer, output)

        {:output_value, result} ->
          read_program(instructions_map, registers, pointer + 2, [result | output])
      end
    end
  end

  def combo_operand(4, registers), do: Map.get(registers, "Register A")
  def combo_operand(5, registers), do: Map.get(registers, "Register B")
  def combo_operand(6, registers), do: Map.get(registers, "Register C")
  def combo_operand(7, _registers), do: raise("boom")
  def combo_operand(nb, _), do: nb

  def execute_instruction(opcode, operand, registers)

  # adv instruction
  def execute_instruction(0, operand, registers) do
    numerator = Map.get(registers, "Register A")
    power = operand |> combo_operand(registers)
    denominator = :math.pow(2, power)
    result = (numerator / denominator) |> trunc()

    Map.put(registers, "Register A", result)
  end

  # bxl instruction
  def execute_instruction(1, operand, registers) do
    b_value = Map.get(registers, "Register B")
    result = Bitwise.bxor(b_value, operand)

    Map.put(registers, "Register B", result)
  end

  # bst instruction
  def execute_instruction(2, operand, registers) do
    result = operand |> combo_operand(registers) |> rem(8)

    Map.put(registers, "Register B", result)
  end

  # jnz instruction
  def execute_instruction(3, operand, registers) do
    if Map.get(registers, "Register A") == 0 do
      :do_nothing
    else
      {:move_pointer_to, operand}
    end
  end

  # bxc instruction
  def execute_instruction(4, _operand, registers) do
    register_b = Map.get(registers, "Register B")
    register_c = Map.get(registers, "Register C")
    result = Bitwise.bxor(register_b, register_c)

    Map.put(registers, "Register B", result)
  end

  # out instruction
  def execute_instruction(5, operand, registers) do
    result = operand |> combo_operand(registers) |> rem(8)

    {:output_value, result}
  end

  # bdv instruction
  def execute_instruction(6, operand, registers) do
    numerator = Map.get(registers, "Register A")
    power = operand |> combo_operand(registers)

    denominator = :math.pow(2, power)
    result = (numerator / denominator) |> trunc()

    Map.put(registers, "Register B", result)
  end

  # cdv instruction
  def execute_instruction(7, operand, registers) do
    numerator = Map.get(registers, "Register A")
    power = operand |> combo_operand(registers)

    denominator = :math.pow(2, power)

    result = (numerator / denominator) |> trunc()

    Map.put(registers, "Register C", result)
  end

  def registers_test do
    %{
      "Register A" => 10,
      "Register B" => 9,
      "Register C" => 9
    }
  end
end
