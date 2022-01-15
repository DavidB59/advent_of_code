defmodule Day24 do
  def file, do: Parser.read_file("day24")
  def test, do: Parser.read_file("test")

  @variable ["x", "y", "w", "z"]

  # 1 ===> 9
  # 2 ===> 9
  # 3 ===> 3
  # 4 ===> 9
  # 5 ===> 4
  # 6 ===> 8
  # 7 ===> 9
  # 8 ===> 9
  # 9 ===> 8
  # 10 ==> 9
  # 11 ==> 1
  # 12 ==> 9
  # 13 ==> 7
  # 14 ==> 1

  # => solution part1 99394899891971

  # 1 ===> 9
  # 2 ===> 2
  # 3 ===> 1
  # 4 ===> 7
  # 5 ===> 1
  # 6 ===> 1
  # 7 ===> 2
  # 8 ===> 6
  # 9 ===> 1
  # 10 ==> 3
  # 11 ==> 1
  # 12 ==> 9
  # 13 ==> 1
  # 14 ==> 1

  # => solution part2 92171126131911

  # rules ( obtained by reading the ALU program )
  # input3 + 6 = input4
  # input6 + 1 = input7
  # input8 = input5 + 5
  # input2 - 1 =  input9
  # input11 + 8 = input 12
  # input10 -2 = input 13
  # input1 -8 = input14

  # code only serve to verify solution.
  @map %{"x" => 0, "y" => 0, "z" => 0, "w" => 0}
  def parse(input) do
    input
  end

  def solve_part_one() do
    instructions = file()
    model_number = 92_171_126_131_911
    input_list = model_number |> Integer.digits()
    run_program(@map, instructions, input_list)
  end

  def solve_part_two() do
    instructions = file()
    model_number = 92_171_126_131_911
    input_list = model_number |> Integer.digits()
    run_program(@map, instructions, input_list)
  end

  def run_program(map, [head | rest], input_list) do
    if String.starts_with?(head, "inp") do
      [input | rest_input] = input_list

      map
      |> apply_instruction(head, input)
      |> run_program(rest, rest_input)
    else
      map
      |> apply_instruction(head)
      |> run_program(rest, input_list)
    end
  end

  def run_program(map, _, _input), do: map

  def apply_instruction(map, "inp " <> a, input) do
    Map.put(map, a, input)
  end

  @spec apply_instruction(map, <<_::32, _::_*8>>) :: map
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
    %{map | a => new_val_a}
  end

  def get_a_b(a_space_b), do: String.split(a_space_b, " ")
  def determine_b(b, map), do: if(b in @variable, do: Map.get(map, b), else: String.to_integer(b))
end
